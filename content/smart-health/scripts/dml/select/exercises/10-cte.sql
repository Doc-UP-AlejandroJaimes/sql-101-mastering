-- ##################################################
-- # CONSULTAS CTES - SMART HEALTH #
-- ##################################################

-- 1. Usar un CTE para calcular la edad de todos los pacientes activos,
-- y luego seleccionar aquellos que tienen más de 30 años,
-- mostrando el nombre completo, edad y tipo de sangre,
-- ordenados por edad descendente.
-- Dificultad: BAJA

WITH pacientes_con_edad AS (
    SELECT 
        p.patient_id,
        p.first_name || ' ' || p.first_surname AS nombre_completo,
        EXTRACT(YEAR FROM AGE(CURRENT_DATE, p.birth_date)) AS edad,
        p.blood_type AS tipo_sangre
    FROM smart_health.patients p
    WHERE p.active = TRUE
)
SELECT 
    patient_id,
    nombre_completo,
    edad,
    tipo_sangre
FROM pacientes_con_edad
WHERE edad > 30
ORDER BY edad DESC;


-- 2. Crear un CTE que calcule el total de citas por doctor,
-- y luego mostrar solo aquellos doctores con más de 5 citas,
-- incluyendo el nombre del doctor, especialidad y total de citas,
-- ordenados por total de citas descendente.
-- Dificultad: BAJA

WITH citas_por_doctor AS (
    SELECT 
        d.doctor_id,
        d.first_name || ' ' || d.last_name AS nombre_doctor,
        s.specialty_name AS especialidad,
        COUNT(a.appointment_id) AS total_citas
    FROM smart_health.doctors d
    INNER JOIN smart_health.doctor_specialties ds ON d.doctor_id = ds.doctor_id
    INNER JOIN smart_health.specialties s ON ds.specialty_id = s.specialty_id
    LEFT JOIN smart_health.appointments a ON d.doctor_id = a.doctor_id
    WHERE d.active = TRUE AND ds.is_active = TRUE
    GROUP BY d.doctor_id, d.first_name, d.last_name, s.specialty_name
)
SELECT 
    doctor_id,
    nombre_doctor,
    especialidad,
    total_citas
FROM citas_por_doctor
WHERE total_citas > 5
ORDER BY total_citas DESC;


-- 3. Utilizar un CTE para calcular el monto total pagado por cada paciente,
-- y luego mostrar los 10 pacientes que más han pagado,
-- incluyendo nombre completo, correo electrónico y total pagado,
-- ordenados por monto total descendente.
-- Dificultad: BAJA-INTERMEDIA

WITH pagos_por_paciente AS (
    SELECT 
        p.patient_id,
        p.first_name || ' ' || p.first_surname AS nombre_completo,
        p.email AS correo_electronico,
        COALESCE(SUM(pay.amount), 0) AS total_pagado
    FROM smart_health.patients p
    LEFT JOIN smart_health.orders o ON p.patient_id = o.patient_id
    LEFT JOIN smart_health.payments pay ON o.order_id = pay.order_id
    WHERE p.active = TRUE
    GROUP BY p.patient_id, p.first_name, p.first_surname, p.email
)
SELECT 
    patient_id,
    nombre_completo,
    correo_electronico,
    total_pagado
FROM pagos_por_paciente
WHERE total_pagado > 0
ORDER BY total_pagado DESC
LIMIT 10;


-- 4. Crear dos CTEs: uno para contar prescripciones por medicamento
-- y otro para calcular el promedio de prescripciones,
-- luego mostrar los medicamentos que superan el promedio,
-- incluyendo nombre comercial, principio activo y total de prescripciones.
-- Dificultad: INTERMEDIA

WITH prescripciones_por_medicamento AS (
    SELECT 
        m.medication_id,
        m.commercial_name AS nombre_comercial,
        m.active_ingredient AS principio_activo,
        COUNT(pr.prescription_id) AS total_prescripciones
    FROM smart_health.medications m
    LEFT JOIN smart_health.prescriptions pr ON m.medication_id = pr.medication_id
    GROUP BY m.medication_id, m.commercial_name, m.active_ingredient
),
promedio_prescripciones AS (
    SELECT AVG(total_prescripciones) AS promedio
    FROM prescripciones_por_medicamento
)
SELECT 
    ppm.medication_id,
    ppm.nombre_comercial,
    ppm.principio_activo,
    ppm.total_prescripciones,
    ROUND(pp.promedio, 2) AS promedio_general
FROM prescripciones_por_medicamento ppm
CROSS JOIN promedio_prescripciones pp
WHERE ppm.total_prescripciones > pp.promedio
ORDER BY ppm.total_prescripciones DESC;


-- 5. Usar un CTE para calcular las estadísticas de órdenes por paciente,
-- incluyendo total de órdenes, monto total y monto promedio,
-- luego filtrar aquellos con más de 2 órdenes y monto total mayor a 500,
-- ordenados por monto total descendente.
-- Dificultad: INTERMEDIA

WITH estadisticas_ordenes AS (
    SELECT 
        p.patient_id,
        p.first_name || ' ' || p.first_surname AS nombre_completo,
        COUNT(o.order_id) AS total_ordenes,
        SUM(o.total_amount) AS monto_total,
        ROUND(AVG(o.total_amount), 2) AS monto_promedio,
        SUM(o.tax_amount) AS total_impuestos
    FROM smart_health.patients p
    INNER JOIN smart_health.orders o ON p.patient_id = o.patient_id
    WHERE p.active = TRUE AND o.status = TRUE
    GROUP BY p.patient_id, p.first_name, p.first_surname
)
SELECT 
    patient_id,
    nombre_completo,
    total_ordenes,
    monto_total,
    monto_promedio,
    total_impuestos
FROM estadisticas_ordenes
WHERE total_ordenes > 2 AND monto_total > 500
ORDER BY monto_total DESC;


-- 6. Crear un CTE que combine información de citas con sus pagos asociados,
-- mostrando la fecha de cita, nombre del paciente, nombre del doctor,
-- monto de la orden y método de pago utilizado,
-- solo para citas con estado 'Attended' que tengan órdenes pagadas,
-- ordenadas por fecha de cita descendente, limitado a 15 resultados.
-- Dificultad: INTERMEDIA-ALTA

WITH citas_con_pagos AS (
    SELECT 
        a.appointment_id,
        a.appointment_date AS fecha_cita,
        a.appointment_type AS tipo_cita,
        p.first_name || ' ' || p.first_surname AS nombre_paciente,
        d.first_name || ' ' || d.last_name AS nombre_doctor,
        o.total_amount AS monto_orden,
        pm.payment_name AS metodo_pago,
        pay.amount AS monto_pagado,
        pay.payment_date AS fecha_pago
    FROM smart_health.appointments a
    INNER JOIN smart_health.patients p ON a.patient_id = p.patient_id
    INNER JOIN smart_health.doctors d ON a.doctor_id = d.doctor_id
    INNER JOIN smart_health.orders o ON a.appointment_id = o.appointment_id
    INNER JOIN smart_health.payments pay ON o.order_id = pay.order_id
    INNER JOIN smart_health.payment_methods pm ON pay.payment_method_id = pm.payment_method_id
    WHERE a.status = 'Attended' AND o.status = TRUE
)
SELECT 
    appointment_id,
    fecha_cita,
    tipo_cita,
    nombre_paciente,
    nombre_doctor,
    monto_orden,
    metodo_pago,
    monto_pagado,
    fecha_pago
FROM citas_con_pagos
ORDER BY fecha_cita DESC
LIMIT 15;


-- 7. Utilizar múltiples CTEs para analizar la relación entre alergias y prescripciones:
-- un CTE para pacientes con alergias, otro para pacientes con prescripciones,
-- y luego combinarlos para mostrar pacientes que tienen ambas,
-- incluyendo el nombre del paciente, cantidad de alergias, cantidad de prescripciones
-- y si se generó alguna alerta, ordenados por cantidad de alergias descendente.
-- Dificultad: ALTA

WITH pacientes_con_alergias AS (
    SELECT 
        p.patient_id,
        p.first_name || ' ' || p.first_surname AS nombre_completo,
        COUNT(pa.patient_allergy_id) AS total_alergias,
        STRING_AGG(DISTINCT pa.severity, ', ') AS severidades
    FROM smart_health.patients p
    INNER JOIN smart_health.patient_allergies pa ON p.patient_id = pa.patient_id
    WHERE p.active = TRUE
    GROUP BY p.patient_id, p.first_name, p.first_surname
),
pacientes_con_prescripciones AS (
    SELECT 
        p.patient_id,
        COUNT(pr.prescription_id) AS total_prescripciones,
        SUM(CASE WHEN pr.alert_generated = TRUE THEN 1 ELSE 0 END) AS alertas_generadas
    FROM smart_health.patients p
    INNER JOIN smart_health.medical_records mr ON p.patient_id = mr.patient_id
    INNER JOIN smart_health.prescriptions pr ON mr.medical_record_id = pr.medical_record_id
    GROUP BY p.patient_id
)
SELECT 
    pca.patient_id,
    pca.nombre_completo,
    pca.total_alergias,
    pca.severidades,
    pcp.total_prescripciones,
    pcp.alertas_generadas,
    CASE 
        WHEN pcp.alertas_generadas > 0 THEN 'Con alertas'
        ELSE 'Sin alertas'
    END AS estado_alertas
FROM pacientes_con_alergias pca
INNER JOIN pacientes_con_prescripciones pcp ON pca.patient_id = pcp.patient_id
ORDER BY pca.total_alergias DESC, pcp.alertas_generadas DESC;


-- ##################################################
-- #                 END OF QUERIES                 #
-- ##################################################