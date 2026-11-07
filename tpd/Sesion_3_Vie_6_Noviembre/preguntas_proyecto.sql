-- Las 8 preguntas del Proyecto Final en BigQuery (misma lógica que tpd/spark/job_proyecto.py).
-- Dinero como NUMERIC: sumas exactas al centavo, igual que los centavos enteros del MapReduce.
-- Requiere: tpd.viajes_2025_06 (el mes) y tpd.zonas (taxi_zone_lookup de la TLC).

-- p1 · ¿A qué horas hay más viajes y qué parte de la tarifa se queda la plataforma?
SELECT FORMAT('%02d', EXTRACT(HOUR FROM pickup_datetime)) AS hora, COUNT(*) AS viajes,
  SUM(CAST(base_passenger_fare AS NUMERIC)) AS tarifa_base_usd,
  SUM(CAST(base_passenger_fare AS NUMERIC)) - SUM(CAST(driver_pay AS NUMERIC)) AS plataforma_usd,
  ROUND(100 * (SUM(CAST(base_passenger_fare AS NUMERIC)) - SUM(CAST(driver_pay AS NUMERIC))) / SUM(CAST(base_passenger_fare AS NUMERIC)), 2) AS plataforma_pct
FROM tpd.viajes_2025_06 GROUP BY hora ORDER BY hora;

-- p2 · Viajes y tarifa promedio por día de la semana y empresa (DAYOFWEEK: 1 = domingo … 7 = sábado)
SELECT ['7-domingo','1-lunes','2-martes','3-miercoles','4-jueves','5-viernes','6-sabado'][OFFSET(EXTRACT(DAYOFWEEK FROM pickup_datetime) - 1)] AS dia,
  CASE hvfhs_license_num WHEN 'HV0003' THEN 'Uber' WHEN 'HV0005' THEN 'Lyft' ELSE hvfhs_license_num END AS empresa,
  COUNT(*) AS viajes, SUM(CAST(base_passenger_fare AS NUMERIC)) AS tarifa_base_usd,
  ROUND(SUM(CAST(base_passenger_fare AS NUMERIC)) / COUNT(*), 2) AS tarifa_promedio_usd
FROM tpd.viajes_2025_06 GROUP BY dia, empresa ORDER BY dia, empresa;

-- p3 · Propinas por borough de origen y empresa
SELECT IFNULL(IF(z.Borough = 'N/A', 'Fuera de NYC', z.Borough), 'Desconocido') AS borough,
  CASE v.hvfhs_license_num WHEN 'HV0003' THEN 'Uber' WHEN 'HV0005' THEN 'Lyft' ELSE v.hvfhs_license_num END AS empresa,
  COUNT(*) AS viajes, COUNTIF(v.tips > 0) AS viajes_con_propina,
  ROUND(100 * COUNTIF(v.tips > 0) / COUNT(*), 2) AS pct_con_propina,
  SUM(CAST(v.tips AS NUMERIC)) AS propina_total_usd,
  ROUND(SUM(CAST(v.tips AS NUMERIC)) / COUNTIF(v.tips > 0), 2) AS propina_promedio_cuando_hay_usd
FROM tpd.viajes_2025_06 v LEFT JOIN tpd.zonas z ON v.PULocationID = z.LocationID
GROUP BY borough, empresa ORDER BY borough, empresa;

-- p4 · Aeropuertos, desde y hacia (un viaje entre dos aeropuertos cuenta en los dos sentidos)
WITH aero AS (SELECT * FROM UNNEST([STRUCT(1 AS id, 'Newark' AS nombre), (132, 'JFK'), (138, 'LaGuardia')])),
partes AS (
  SELECT a.nombre AS aeropuerto, 'desde' AS sentido, v.* FROM tpd.viajes_2025_06 v JOIN aero a ON v.PULocationID = a.id
  UNION ALL
  SELECT a.nombre, 'hacia', v.* FROM tpd.viajes_2025_06 v JOIN aero a ON v.DOLocationID = a.id)
SELECT aeropuerto, sentido, COUNT(*) AS viajes,
  ROUND(SUM(CAST(base_passenger_fare AS NUMERIC)) / COUNT(*), 2) AS tarifa_promedio_usd,
  SUM(CAST(airport_fee AS NUMERIC)) AS cargo_aeropuerto_usd,
  SUM(CAST(base_passenger_fare AS NUMERIC)) - SUM(CAST(driver_pay AS NUMERIC)) AS plataforma_usd
FROM partes GROUP BY aeropuerto, sentido ORDER BY aeropuerto, sentido;

-- p5 · Pago al conductor por milla, por borough y empresa (solo viajes con distancia)
SELECT IFNULL(IF(z.Borough = 'N/A', 'Fuera de NYC', z.Borough), 'Desconocido') AS borough,
  CASE v.hvfhs_license_num WHEN 'HV0003' THEN 'Uber' WHEN 'HV0005' THEN 'Lyft' ELSE v.hvfhs_license_num END AS empresa,
  COUNT(*) AS viajes, SUM(CAST(v.driver_pay AS NUMERIC)) AS pago_conductor_usd,
  (SUM(ROUND(CAST(v.trip_miles * 100 AS BIGNUMERIC), 0, "ROUND_HALF_EVEN")) / 100) AS millas,
  ROUND(SUM(CAST(v.driver_pay AS NUMERIC)) / (SUM(ROUND(CAST(v.trip_miles * 100 AS BIGNUMERIC), 0, "ROUND_HALF_EVEN")) / 100), 2) AS pago_por_milla_usd
FROM tpd.viajes_2025_06 v LEFT JOIN tpd.zonas z ON v.PULocationID = z.LocationID
WHERE ROUND(CAST(v.trip_miles * 100 AS BIGNUMERIC), 0, "ROUND_HALF_EVEN") > 0
GROUP BY borough, empresa ORDER BY borough, empresa;

-- p6 · ¿A qué horas es más lento moverse? (velocidad = millas / horas)
SELECT FORMAT('%02d', EXTRACT(HOUR FROM pickup_datetime)) AS hora, COUNT(*) AS viajes,
  (SUM(ROUND(CAST(trip_miles * 100 AS BIGNUMERIC), 0, "ROUND_HALF_EVEN")) / 100) AS millas, SUM(trip_time) / 3600 AS horas_de_viaje,
  ROUND((SUM(ROUND(CAST(trip_miles * 100 AS BIGNUMERIC), 0, "ROUND_HALF_EVEN")) / 100) / (SUM(trip_time) / 3600), 2) AS velocidad_mph,
  ROUND(SUM(trip_time) / COUNT(*) / 60, 2) AS duracion_promedio_min
FROM tpd.viajes_2025_06 WHERE ROUND(CAST(trip_miles * 100 AS BIGNUMERIC), 0, "ROUND_HALF_EVEN") > 0 AND trip_time > 0
GROUP BY hora ORDER BY hora;

-- p7 · Zonas de recogida que más dinero le dejan a la plataforma
SELECT v.PULocationID AS zona_id, z.Zone AS zona, z.Borough AS borough, COUNT(*) AS viajes,
  SUM(CAST(v.base_passenger_fare AS NUMERIC)) AS tarifa_base_usd,
  SUM(CAST(v.base_passenger_fare AS NUMERIC)) - SUM(CAST(v.driver_pay AS NUMERIC)) AS plataforma_usd,
  ROUND((SUM(CAST(v.base_passenger_fare AS NUMERIC)) - SUM(CAST(v.driver_pay AS NUMERIC))) / COUNT(*), 2) AS plataforma_por_viaje_usd
FROM tpd.viajes_2025_06 v LEFT JOIN tpd.zonas z ON v.PULocationID = z.LocationID
GROUP BY zona_id, zona, borough ORDER BY plataforma_usd DESC;

-- p8 · Cargo de congestión de Manhattan por hora
SELECT FORMAT('%02d', EXTRACT(HOUR FROM pickup_datetime)) AS hora, COUNT(*) AS viajes,
  COUNTIF(cbd_congestion_fee > 0) AS viajes_con_cargo,
  ROUND(100 * COUNTIF(cbd_congestion_fee > 0) / COUNT(*), 2) AS pct_con_cargo,
  SUM(CAST(cbd_congestion_fee AS NUMERIC)) AS recaudo_usd
FROM tpd.viajes_2025_06 GROUP BY hora ORDER BY hora;
