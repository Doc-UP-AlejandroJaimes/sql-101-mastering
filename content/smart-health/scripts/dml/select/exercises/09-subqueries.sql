-- ##################################################
-- # CONSULTAS SUBQUERIES - SMART HEALTH #
-- ##################################################

-- 1. Obtener todos los pacientes cuya edad es mayor al promedio de edad
-- de todos los pacientes activos en el sistema,
-- mostrando el nombre completo, la edad y el tipo de sangre,
-- ordenados por edad descendente.
-- Dificultad: BAJA

SELECT 
    p.patient_id,
    p.first_name || ' ' || p.first_surname AS nombre_completo,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, p.birth_date)) AS edad,
    p.blood_type AS tipo_sangre
FROM smart_health.patients p
WHERE p.active = TRUE
    AND EXTRACT(YEAR FROM AGE(CURRENT_DATE, p.birth_date)) > (
        SELECT AVG(EXTRACT(YEAR FROM AGE(CURRENT_DATE, birth_date)))
        FROM smart_health.patients
        WHERE active = TRUE
    )
ORDER BY edad DESC;


-- 2. Listar todos los doctores que tienen más citas programadas
-- que el promedio de citas por doctor,
-- mostrando el nombre completo del doctor, su especialidad y el total de citas,
-- ordenados por total de citas descendente.
-- Dificultad: BAJA-INTERMEDIA

SELECT 
    d.doctor_id,
    d.first_name || ' ' || d.last_name AS nombre_completo,
    s.specialty_name AS especialidad,
    COUNT(a.appointment_id) AS total_citas
FROM smart_health.doctors d
INNER JOIN smart_health.doctor_specialties ds ON d.doctor_id = ds.doctor_id
INNER JOIN smart_health.specialties s ON ds.specialty_id = s.specialty_id
INNER JOIN smart_health.appointments a ON d.doctor_id = a.doctor_id
WHERE d.active = TRUE AND ds.is_active = TRUE
GROUP BY d.doctor_id, d.first_name, d.last_name, s.specialty_name
HAVING COUNT(a.appointment_id) > (
    SELECT AVG(citas_por_doctor)
    FROM (
        SELECT COUNT(appointment_id) AS citas_por_doctor
        FROM smart_health.appointments
        GROUP BY doctor_id
    ) AS subconsulta
)
ORDER BY total_citas DESC;


-- 3. Mostrar todos los medicamentos que han sido prescritos
-- más veces que el medicamento promedio,
-- incluyendo el nombre comercial, principio activo y cantidad de prescripciones,
-- ordenados por cantidad de prescripciones descendente.
-- Dificultad: INTERMEDIA

SELECT 
    m.medication_id,
    m.commercial_name AS nombre_comercial,
    m.active_ingredient AS principio_activo,
    COUNT(pr.prescription_id) AS total_prescripciones
FROM smart_health.medications m
INNER JOIN smart_health.prescriptions pr ON m.medication_id = pr.medication_id
GROUP BY m.medication_id, m.commercial_name, m.active_ingredient
HAVING COUNT(pr.prescription_id) > (
    SELECT AVG(prescripciones_por_medicamento)
    FROM (
        SELECT COUNT(prescription_id) AS prescripciones_por_medicamento
        FROM smart_health.prescriptions
        GROUP BY medication_id
    ) AS subconsulta
)
ORDER BY total_prescripciones DESC;


-- 4. Obtener los pacientes que han gastado más que el monto promedio
-- de todos los pagos realizados en el sistema,
-- mostrando el nombre del paciente, el total pagado y el número de órdenes,
-- solo para aquellos con órdenes activas,
-- ordenados por total pagado descendente.
-- Dificultad: INTERMEDIA

SELECT 
    p.patient_id,
    p.first_name || ' ' || p.first_surname AS nombre_completo,
    SUM(pay.amount) AS total_pagado,
    COUNT(DISTINCT o.order_id) AS numero_ordenes
FROM smart_health.patients p
INNER JOIN smart_health.orders o ON p.patient_id = o.patient_id
INNER JOIN smart_health.payments pay ON o.order_id = pay.order_id
WHERE o.status = TRUE
GROUP BY p.patient_id, p.first_name, p.first_surname
HAVING SUM(pay.amount) > (
    SELECT AVG(amount)
    FROM smart_health.payments
)
ORDER BY total_pagado DESC;


-- 5. Listar todas las citas que tienen una duración mayor
-- a la duración promedio de todas las citas del mismo tipo,
-- mostrando la fecha de la cita, el tipo, el nombre del paciente, el nombre del doctor,
-- la duración en minutos y el estado de la cita,
-- ordenadas por duración descendente.
-- Dificultad: INTERMEDIA-ALTA

SELECT 
    a.appointment_id,
    a.appointment_date AS fecha_cita,
    a.appointment_type AS tipo_cita,
    p.first_name || ' ' || p.first_surname AS nombre_paciente,
    d.first_name || ' ' || d.last_name AS nombre_doctor,
    EXTRACT(EPOCH FROM (a.end_time - a.start_time)) / 60 AS duracion_minutos,
    a.status AS estado
FROM smart_health.appointments a
INNER JOIN smart_health.patients p ON a.patient_id = p.patient_id
INNER JOIN smart_health.doctors d ON a.doctor_id = d.doctor_id
WHERE EXTRACT(EPOCH FROM (a.end_time - a.start_time)) / 60 > (
    SELECT AVG(EXTRACT(EPOCH FROM (end_time - start_time)) / 60)
    FROM smart_health.appointments
    WHERE appointment_type = a.appointment_type
)
ORDER BY duracion_minutos DESC;

/*
6. Mostrar los medicos que mas hayan atentido citas en el ultimo semestre.
Obteniendo los datos del nombre completo del doctor, licencia medica,
cita mas reciente y la primera cita.*/
SELECT
    sub.doctor,
    COUNT(sub.appointment_date) as total_citas,
    MAX(sub.appointment_date) as cita_reciente,
    MIN(sub.appointment_date) as primera_cita
FROM
(
SELECT
 T1.first_name||' '||T1.last_name as doctor,
 T2.appointment_date

FROM smart_health.doctors T1
INNER JOIN smart_health.appointments T2
ON T1.doctor_id = T2.doctor_id
AND T1.active = TRUE
WHERE T2.appointment_date BETWEEN 
    CURRENT_DATE - INTERVAL '6 months' AND CURRENT_DATE
) sub
GROUP BY sub.doctor
ORDER BY total_citas DESC
LIMIT 10;


-- ##################################################
-- #                 END OF QUERIES                 #
-- ##################################################