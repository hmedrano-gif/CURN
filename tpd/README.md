# Tecnologías de Procesamiento de Datos

Especialización en Analítica de Datos · Universidad Rafael Núñez · 3 créditos · 36 horas · 6 sesiones

## ▶ [Abrir la página de Tecnologías de Procesamiento de Datos](https://hmedrano-gif.github.io/CURN/tpd/)

> Los archivos `index.html` se ven como código aquí en GitHub; para verlos como página usa los enlaces ▶. El material desde la Sesión 3 se abre con la clave que da el docente en clase.

## El caso

La gerencia de una plataforma de movilidad pregunta: **¿dónde y cuándo se gana o se pierde dinero en el transporte por aplicación, y cómo se reacciona a tiempo?**
Trabajamos con los viajes reales de Uber y Lyft en Nueva York de 2025 (registros públicos de la TLC). En clase usamos junio, con 19,9 millones de viajes. Cada grupo trabaja su propio mes: el grupo 1 enero, el 2 abril, el 3 septiembre y el 4 diciembre.

La pregunta se responde con **8 preguntas concretas**:

| | Pregunta de la gerencia |
|---|---|
| P1 | ¿A qué horas hay más viajes, y qué parte de la tarifa se queda la plataforma? |
| P2 | ¿Cómo cambian los viajes y la tarifa según el día y la empresa? |
| P3 | ¿Dónde y con qué empresa se dejan más propinas? |
| P4 | ¿Cuánto mueven los aeropuertos (Newark, JFK y LaGuardia)? |
| P5 | ¿Cuánto se paga al conductor por milla, según el borough y la empresa? |
| P6 | ¿A qué horas es más lento moverse por la ciudad? |
| P7 | ¿Qué zonas le dejan más dinero a la plataforma? |
| P8 | ¿Cuánto recauda el cargo de congestión de Manhattan, y a qué horas? |

**Cómo se sabe que un resultado está bien:**
- El mismo cálculo debe dar la misma cifra, al centavo, en Hadoop, en Spark y en BigQuery.
- Cada grupo compara sus cifras con la clave de su mes, que tiene el docente.

## Competencias y resultados de aprendizaje

Tomados del contenido programático del seminario.


| Competencia | Resultado de aprendizaje |
|---|---|
| **C1** Diseñar sistemas distribuidos y escalables para el procesamiento eficiente de datos masivos | **RA1** Configurar un sistema Hadoop o Spark para procesar un conjunto de datos masivos, asegurando eficiencia y escalabilidad |
| **C2** Evaluar herramientas y servicios en la nube para el procesamiento y almacenamiento de big data | **RA2** Seleccionar las herramientas adecuadas, como AWS o Google Cloud, para integrar y analizar datos masivos |
| **C3** Crear flujos de procesamiento en tiempo real utilizando tecnologías avanzadas de big data | **RA3** Desarrollar un flujo de datos en tiempo real utilizando herramientas como Apache Kafka, garantizando su funcionalidad y precisión |
| **C4** Optimizar el rendimiento de sistemas de procesamiento de datos mediante técnicas avanzadas | **RA4** Ajustar configuraciones y parámetros de sistemas distribuidos para mejorar su rendimiento y reducir tiempos de procesamiento |

## Las sesiones

Cada sesión indica qué competencia (C) y qué resultado de aprendizaje (RA) de la tabla anterior desarrolla, y con qué actividad.

| Sesión | Fecha | Contenido | Competencia y resultado de aprendizaje que desarrolla |
|---|---|---|---|
| [▶ Sesión 1](https://hmedrano-gif.github.io/CURN/tpd/Sesion_1_Vie_30_Octubre/) | Viernes 30 de octubre, 5:00–9:00 p. m. | **Unidad 1:** fundamentos del procesamiento distribuido (escalado, teorema CAP, particiones y réplicas), MapReduce a mano y el ecosistema Hadoop | **C1 · RA1** (Unidad 1): base para configurar Hadoop o Spark: por qué se reparte el trabajo, cómo lo hace MapReduce y qué hacen HDFS y YARN |
| [▶ Sesión 2](https://hmedrano-gif.github.io/CURN/tpd/Sesion_2_Sab_31_Octubre/) | Sábado 31 de octubre, 8:00 a. m.–4:00 p. m. | **Taller 1A**, Hadoop y Spark en GitHub Codespaces: junio en HDFS, el job MapReduce, YARN con más memoria y Spark con 1, 2 y 4 núcleos.<br>**Taller 1B**, Kafka y Spark Streaming: los viajes llegan en tiempo real | **C1 · RA1** (Taller 1A): configura Hadoop y Spark y procesa el mes completo (19,9 millones de viajes) con cifras exactas<br>**C4 · RA4** (Taller 1A): ajusta la memoria de YARN y los núcleos de Spark y mide cuánto baja el tiempo<br>**C3 · RA3** (Taller 1B): desarrolla un flujo en tiempo real con Kafka y Spark Streaming que no pierde eventos y da cifras exactas |
| [▶ Sesión 3](https://hmedrano-gif.github.io/CURN/tpd/Sesion_3_Vie_6_Noviembre/) | Viernes 6 de noviembre, 5:00–9:00 p. m. | **Unidad 2:** la nube (AWS, Google Cloud y Azure).<br>[**Taller 2A**: su mes en BigQuery](https://hmedrano-gif.github.io/CURN/tpd/Sesion_3_Vie_6_Noviembre/Taller_2A_BigQuery.html): dividir el mes en Colab, cargarlo y resolverlo con SQL.<br>[Proyecto Final](https://hmedrano-gif.github.io/CURN/tpd/Sesion_3_Vie_6_Noviembre/Proyecto_Final_v2.html) | **C2 · RA2** (Taller 2A): selecciona e integra un servicio de nube (BigQuery) para cargar y analizar su mes, justificando cada configuración y el costo de cada consulta |
| [▶ Sesión 4](https://hmedrano-gif.github.io/CURN/tpd/Sesion_4_Sab_7_Noviembre/) | Sábado 7 de noviembre, 8:00 a. m.–4:00 p. m. | [**Taller 2B**: dashboard en Power BI](https://hmedrano-gif.github.io/CURN/tpd/Sesion_4_Sab_7_Noviembre/Taller_2B_PowerBI.html): modelo en estrella, conexión a BigQuery y medidas DAX. También análisis de casos y seguridad (GDPR, ISO/IEC 27001, Ley 1581) | **C2 · RA2** (Taller 2B y análisis de casos): integra BigQuery con Power BI y analiza su mes en un dashboard; elige entre AWS, Google Cloud y Azure con criterios de costo, seguridad y normativa |
| [▶ Sesión 5](https://hmedrano-gif.github.io/CURN/tpd/Sesion_5_Mie_18_Noviembre/) | Miércoles 18 de noviembre, 4 horas | **Dataproc**: el clúster administrado, con el laboratorio GSP104 de Google Skills explicado. **Unidad 3:** optimización. Asesoría a cada grupo | **C1 · RA1** (Dataproc): compara el clúster que configuró en el codespace con un clúster administrado<br>**C2 · RA2** (Dataproc): decide entre clúster propio, clúster administrado y servicio sin servidor<br>**C4 · RA4** (Unidad 3): cinco ajustes medidos (combiner, memoria de YARN, Parquet, núcleos de Spark y columnas en BigQuery) y su efecto en tiempo y costo |
| [▶ Sesión 6](https://hmedrano-gif.github.io/CURN/tpd/Sesion_6_Sab_21_Noviembre/) | Sábado 21 de noviembre, 8:00 a. m.–4:00 p. m. | Sustentación del Proyecto Final: 15 minutos por grupo. Comparación de los cinco meses | **C1 a C4 · RA1 a RA4.** El Proyecto Final evidencia los cuatro: RA1, configuración del entorno; RA2, integración y análisis en la nube; RA3, flujo en tiempo real del Taller 1B; RA4, rendimiento y costos medidos |

El paquete del codespace (`tpd-codespace.zip`) está en [Releases](https://github.com/hmedrano-gif/tpd-materiales/releases/tag/v1).
