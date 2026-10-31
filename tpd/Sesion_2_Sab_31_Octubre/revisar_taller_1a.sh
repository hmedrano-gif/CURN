#!/usr/bin/env bash
# revisar_taller_1a.sh — dice qué pasos del Taller 1A quedaron hechos y cuáles faltan, mirando lo que dejó cada paso
# (archivos en HDFS, configuración de YARN y la salida de Spark). Solo lee: no borra ni cambia nada.
# Si Hadoop está apagado, lo enciende un momento para revisar y lo vuelve a apagar.
# Uso, en la terminal del codespace:
#   curl -fsSL https://hmedrano-gif.github.io/CURN/tpd/Sesion_2_Sab_31_Octubre/revisar_taller_1a.sh | bash
H=/workspaces/tpd-codespace/tpd/hadoop
S=/workspaces/tpd-codespace/tpd/spark
faltan=0
ok() { printf '  \033[32m[HECHO]\033[0m %s\n' "$1"; }
no() { printf '  \033[31m[FALTA]\033[0m %s\n' "$1"; faltan=$((faltan+1)); }
info() { printf '  \033[36m[BITÁCORA]\033[0m %s\n' "$1"; }

echo "Revisión del Taller 1A · Tecnologías de Procesamiento de Datos"
if [ ! -d "$H" ]; then echo "No encuentro $H: abre esta terminal en tu codespace del taller."; exit 1; fi
sudo iptables-legacy -P FORWARD ACCEPT 2>/dev/null
cd "$H" || exit 1

estaba_apagado=0
if ! docker compose ps --status running --services 2>/dev/null | grep -qx namenode; then
  estaba_apagado=1
  echo "Hadoop está apagado: lo enciendo un momento para revisar (menos de un minuto)..."
  docker compose start >/dev/null 2>&1
fi
for _ in $(seq 1 40); do
  docker compose exec -T namenode hdfs dfsadmin -safemode get 2>/dev/null | grep -q OFF && break
  sleep 3
done
h() { docker compose exec -T namenode hdfs "$@" 2>/dev/null; }
hecho() { h dfs -test -e "$1/_SUCCESS"; }

echo
echo "Parte A"
tam=$(h dfs -stat %b /caso/input/fhvhv_2025-06.csv | tr -dc '0-9')
if [ -n "$tam" ] && [ "$tam" -gt 4000000000 ]; then ok "A0. El mes completo está en HDFS (4,04 GB)"
else no "A0. El mes no está completo en HDFS: repite la copia (-put) de la Parte A"; fi
info "A2. pandas: anota los 10,8 GB que pide el mes frente a los 16 GB del codespace"

echo
echo "Parte B · Hadoop"
if hecho /caso/salida && h dfs -cat '/caso/salida/part-*' | grep -q "^Uber"$'\t'"14167361"; then ok "Paso 4. El job del mes: Uber y Lyft calculados"
else no "Paso 4. Falta el job del mes (carpeta /caso/salida)"; fi
info "Paso 5. Anota el tiempo del job (puerto 19888, «Elapsed»)"
if hecho /caso/salida_combiner; then ok "Paso 6. El job con combiner"
else no "Paso 6. Falta el job con combiner (carpeta /caso/salida_combiner)"; fi
if hecho /caso/salida_yarn; then ok "Paso 7. El job con más memoria para YARN"
else no "Paso 7. Falta el job con 6.144 MB (carpeta /caso/salida_yarn)"; fi
if grep -q "memory-mb=4096" "$H/config" 2>/dev/null; then ok "Paso 7. YARN quedó de vuelta en 4.096 MB"
else no "Paso 7. YARN no quedó en 4096: cámbialo en tpd/hadoop/config y recrea YARN (ver la hoja)"; fi
if hecho /caso/espera && h dfs -cat '/caso/espera/part-*' | grep -q "Flushing Meadows"; then ok "Paso 8. Tu propio job: la espera por zona"
else no "Paso 8. Falta el job de la espera por zona (carpeta /caso/espera)"; fi

echo
echo "Parte C · Spark"
if ls "$S"/output_spark/part-*.csv >/dev/null 2>&1 && grep -q "^Uber,14167361" "$S"/output_spark/part-*.csv; then ok "Pasos 2 y 5. Spark calculó Uber y Lyft (spark/output_spark)"
else no "Pasos 2 y 5. Falta correr Spark (no está spark/output_spark)"; fi
info "Pasos 3, 5 y 6. Anota los tiempos de CSV y Parquet, lo leído en la Spark UI y la curva de 1, 2 y 4 núcleos"

if [ "$estaba_apagado" -eq 1 ]; then docker compose stop >/dev/null 2>&1; echo; echo "Hadoop quedó apagado otra vez, como estaba."; fi
echo
if [ "$faltan" -eq 0 ]; then printf '\033[32mRESULTADO: TALLER 1A COMPLETO. Revisa que tu bitácora tenga las cifras marcadas [BITÁCORA].\033[0m\n'
else printf '\033[31mRESULTADO: FALTAN %d pasos. Hazlos con la hoja de comandos y vuelve a correr esta revisión.\033[0m\n' "$faltan"; fi
