"""Divide un mes de viajes de la TLC en partes que la consola de BigQuery acepte (máx. 100 MB cada una).

Sirve para cualquier mes y cualquier tamaño: calcula cuántas partes hacen falta, corta por filas
y comprueba que ninguna pase del límite (si alguna pasa, vuelve a cortar con una parte más).
No cambia ninguna columna ni ningún valor: las partes juntas son el mes exacto.

Uso:  python dividir_mes.py fhvhv_tripdata_2025-01.parquet
"""
import math
import os
import sys

import pyarrow.parquet as pq

LIMITE_MB = 100          # lo que acepta «Crear tabla -> Subir» en la consola de BigQuery
OBJETIVO_MB = 80         # tamaño buscado por parte: deja margen bajo el límite
MB = 1024 * 1024


def dividir(origen):
    tabla = pq.read_table(origen)                       # el mes completo en memoria
    tam_mb = os.path.getsize(origen) / MB
    base = os.path.basename(origen).replace("fhvhv_tripdata_", "viajes_").replace("-", "_").replace(".parquet", "")
    partes = max(1, math.ceil(tam_mb * 1.10 / OBJETIVO_MB))   # +10 %: al reescribir, cada parte comprime algo peor
    print(f"{origen}: {tabla.num_rows:,} viajes | {tabla.num_columns} columnas | {tam_mb:.0f} MB")

    while True:
        filas = math.ceil(tabla.num_rows / partes)
        archivos = []
        for i in range(partes):
            trozo = tabla.slice(i * filas, filas)                  # filas i*k … i*k+k-1
            destino = f"{base}_parte_{i + 1}.parquet"
            pq.write_table(trozo, destino, compression="snappy")  # misma compresión del original
            archivos.append((destino, trozo.num_rows, os.path.getsize(destino) / MB))
        if max(mb for _, _, mb in archivos) < LIMITE_MB:
            break
        for destino, _, _ in archivos:                             # alguna pasó de 100 MB: una parte más
            os.remove(destino)
        partes += 1

    for destino, n, mb in archivos:
        print(f"  {destino}: {n:,} viajes | {mb:.1f} MB")
    total = sum(n for _, n, _ in archivos)
    print(f"Comprobación: {total:,} viajes en {partes} partes = {tabla.num_rows:,} del mes -> "
          f"{'OK' if total == tabla.num_rows else 'ERROR'}")
    return [d for d, _, _ in archivos]


if __name__ == "__main__":
    dividir(sys.argv[1] if len(sys.argv) > 1 else "fhvhv_tripdata_2025-06.parquet")
