-- Taller 2B - Tablas que Power BI importa desde BigQuery (cambia 2025_06 por tu mes).
-- 1) hechos_viajes: una fila por fecha, hora, empresa y zona de recogida, con las sumas que necesitan las 8 preguntas.
--    Del mes completo (unos 20 millones de viajes) quedan unas 300.000 filas: Power BI las importa en segundos.
CREATE OR REPLACE TABLE tpd.hechos_viajes AS
SELECT
  DATE(pickup_datetime) AS fecha,
  ['1-lunes','2-martes','3-miercoles','4-jueves','5-viernes','6-sabado','7-domingo'][OFFSET(CAST(FORMAT_DATE('%u', DATE(pickup_datetime)) AS INT64) - 1)] AS dia,
  EXTRACT(HOUR FROM pickup_datetime) AS hora,
  CASE hvfhs_license_num WHEN 'HV0003' THEN 'Uber' WHEN 'HV0005' THEN 'Lyft' ELSE hvfhs_license_num END AS empresa,
  PULocationID AS zona_id,
  COUNT(*) AS viajes,
  SUM(CAST(base_passenger_fare AS NUMERIC)) AS tarifa_base_usd,
  SUM(CAST(driver_pay AS NUMERIC)) AS pago_conductor_usd,
  COUNTIF(tips > 0) AS viajes_con_propina,
  SUM(CAST(tips AS NUMERIC)) AS propinas_usd,
  COUNTIF(cbd_congestion_fee > 0) AS viajes_con_cargo,
  SUM(CAST(cbd_congestion_fee AS NUMERIC)) AS cargo_congestion_usd,
  COUNTIF(m > 0) AS viajes_con_millas,
  SUM(IF(m > 0, CAST(driver_pay AS NUMERIC), 0)) AS pago_con_millas_usd,
  SUM(IF(m > 0, m, 0)) / 100 AS millas,
  COUNTIF(m > 0 AND trip_time > 0) AS viajes_velocidad,
  SUM(IF(m > 0 AND trip_time > 0, m, 0)) / 100 AS millas_velocidad,
  SUM(IF(m > 0 AND trip_time > 0, trip_time, 0)) AS segundos_velocidad
FROM (SELECT *, ROUND(CAST(trip_miles * 100 AS BIGNUMERIC), 0, 'ROUND_HALF_EVEN') AS m FROM tpd.viajes_2025_06)
GROUP BY fecha, dia, hora, empresa, zona_id;

-- 2) aeropuertos: viajes desde y hacia Newark, JFK y LaGuardia (pregunta 4), por empresa.
CREATE OR REPLACE TABLE tpd.aeropuertos AS
WITH aero AS (SELECT * FROM UNNEST([STRUCT(1 AS id, 'Newark' AS aeropuerto), (132, 'JFK'), (138, 'LaGuardia')])),
partes AS (
  SELECT a.aeropuerto, 'desde' AS sentido, v.* FROM tpd.viajes_2025_06 v JOIN aero a ON v.PULocationID = a.id
  UNION ALL
  SELECT a.aeropuerto, 'hacia', v.* FROM tpd.viajes_2025_06 v JOIN aero a ON v.DOLocationID = a.id)
SELECT aeropuerto, sentido,
  CASE hvfhs_license_num WHEN 'HV0003' THEN 'Uber' WHEN 'HV0005' THEN 'Lyft' ELSE hvfhs_license_num END AS empresa,
  COUNT(*) AS viajes,
  SUM(CAST(base_passenger_fare AS NUMERIC)) AS tarifa_base_usd,
  SUM(CAST(airport_fee AS NUMERIC)) AS cargo_aeropuerto_usd,
  SUM(CAST(driver_pay AS NUMERIC)) AS pago_conductor_usd
FROM partes GROUP BY aeropuerto, sentido, empresa;

-- 3) dim_zonas: nombre y borough de cada zona. La columna zona_id se llama igual que en hechos_viajes,
--    así Power BI crea solo la relación entre las dos tablas.
CREATE OR REPLACE TABLE tpd.dim_zonas AS
SELECT LocationID AS zona_id, Zone AS zona, IF(Borough = 'N/A', 'Fuera de NYC', Borough) AS borough
FROM tpd.zonas;
