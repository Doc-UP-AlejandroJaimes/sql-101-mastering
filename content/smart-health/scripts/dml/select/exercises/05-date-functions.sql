-- ##################################################
-- # CONSULTAS DATEPART, NOW, CURRENT_DATE, EXTRACT, AGE, INTERVAL - SMART HEALTH #
-- ##################################################

-- 1. Obtener todos los pacientes que nacieron en el mes actual,
-- mostrando su nombre completo, fecha de nacimiento y edad actual en años.
-- Dificultad: BAJA


-- 2. Listar todas las citas programadas para los próximos 7 días,
-- mostrando la fecha de la cita, el nombre del paciente, el nombre del doctor,
-- y cuántos días faltan desde hoy hasta la cita.
-- Dificultad: BAJA

SELECT
    T1.appointment_date AS fecha_cita,
    CONCAT(T2.first_name,' ',T2.first_surname) AS paciente,
    CONCAT(T3.first_name,' ',T3.last_name) AS doctor,
    T1.appointment_date - CURRENT_DATE AS dias_faltantes

FROM smart_health.appointments T1
INNER JOIN smart_health.patients T2 ON T1.patient_id = T2.patient_id
INNER JOIN smart_health.doctors T3 ON T1.doctor_id = T3.doctor_id
WHERE T1.appointment_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '7 days'
ORDER BY dias_faltantes DESC
LIMIT 10;


-- 3. Mostrar todos los médicos que ingresaron al hospital hace más de 5 años,
-- incluyendo su nombre completo, fecha de ingreso, y la cantidad exacta de años,
-- meses y días que han trabajado en el hospital.
-- Dificultad: BAJA-INTERMEDIA


-- 4. Obtener las prescripciones emitidas en el último mes,
-- mostrando la fecha de prescripción, el nombre del medicamento,
-- el nombre del paciente, cuántos días han pasado desde la prescripción,
-- y el día de la semana en que fue prescrito.
-- Dificultad: INTERMEDIA

-- 5. Listar todos los pacientes registrados en el sistema durante el trimestre actual,
-- mostrando su nombre completo, fecha de registro, edad actual,
-- el trimestre de registro, y cuántas semanas han pasado desde su registro,
-- ordenados por fecha de registro más reciente primero.
-- Dificultad: INTERMEDIA


-- ##################################################
-- #                 END OF QUERIES                 #
-- ##################################################