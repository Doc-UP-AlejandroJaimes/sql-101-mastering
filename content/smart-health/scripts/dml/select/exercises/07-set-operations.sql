-- ##################################################
-- # CONSULTAS SET OPERATIONS - SMART HEALTH #
-- ##################################################

-- 1. Obtener una lista combinada de todos los nombres únicos
-- de pacientes y doctores en el sistema, mostrando el nombre completo
-- y el tipo de registro (Paciente o Doctor),
-- ordenados alfabéticamente por nombre completo.
-- Dificultad: BAJA

SELECT 
    p.first_name || ' ' || p.first_surname AS nombre_completo,
    'Paciente' AS tipo_registro,
    p.patient_id AS id_registro
FROM smart_health.patients p
WHERE p.active = TRUE

UNION

SELECT 
    d.first_name || ' ' || d.last_name AS nombre_completo,
    'Doctor' AS tipo_registro,
    d.doctor_id AS id_registro
FROM smart_health.doctors d
WHERE d.active = TRUE

ORDER BY nombre_completo ASC;


-- 2. Listar todos los municipios que tienen tanto pacientes como doctores registrados,
-- mostrando el código del municipio, el nombre del municipio y el nombre del departamento,
-- utilizando INTERSECT para encontrar solo los municipios con ambos tipos de usuarios.
-- Dificultad: BAJA-INTERMEDIA

SELECT DISTINCT
    m.municipality_code,
    m.municipality_name AS nombre_municipio,
    d.department_name AS nombre_departamento
FROM smart_health.municipalities m
INNER JOIN smart_health.departments d ON m.department_code = d.department_code
INNER JOIN smart_health.addresses a ON m.municipality_code = a.municipality_code
INNER JOIN smart_health.patient_addresses pa ON a.address_id = pa.address_id

INTERSECT

SELECT DISTINCT
    m.municipality_code,
    m.municipality_name AS nombre_municipio,
    d.department_name AS nombre_departamento
FROM smart_health.municipalities m
INNER JOIN smart_health.departments d ON m.department_code = d.department_code
INNER JOIN smart_health.addresses a ON m.municipality_code = a.municipality_code
INNER JOIN smart_health.doctor_addresses da ON a.address_id = da.address_id

ORDER BY nombre_departamento ASC, nombre_municipio ASC;


-- 3. Obtener una lista unificada de todos los IDs de pacientes
-- que aparecen en citas o en órdenes de pago,
-- mostrando el ID del paciente, nombre completo y correo electrónico,
-- eliminando duplicados y ordenados por ID de paciente.
-- Dificultad: BAJA

SELECT DISTINCT
    p.patient_id,
    p.first_name || ' ' || p.first_surname AS nombre_completo,
    p.email AS correo_electronico
FROM smart_health.patients p
INNER JOIN smart_health.appointments a ON p.patient_id = a.patient_id

UNION

SELECT DISTINCT
    p.patient_id,
    p.first_name || ' ' || p.first_surname AS nombre_completo,
    p.email AS correo_electronico
FROM smart_health.patients p
INNER JOIN smart_health.orders o ON p.patient_id = o.patient_id

ORDER BY patient_id ASC;


-- 4. Listar todos los pacientes que tienen alergias registradas
-- pero que NO tienen prescripciones médicas activas,
-- mostrando el ID del paciente, nombre completo, tipo de sangre y cantidad de alergias,
-- utilizando EXCEPT para excluir aquellos con prescripciones.
-- Dificultad: INTERMEDIA

SELECT DISTINCT
    p.patient_id,
    p.first_name || ' ' || p.first_surname AS nombre_completo,
    p.blood_type AS tipo_sangre,
    COUNT(pa.patient_allergy_id) AS cantidad_alergias
FROM smart_health.patients p
INNER JOIN smart_health.patient_allergies pa ON p.patient_id = pa.patient_id
WHERE p.active = TRUE
GROUP BY p.patient_id, p.first_name, p.first_surname, p.blood_type

EXCEPT

SELECT DISTINCT
    p.patient_id,
    p.first_name || ' ' || p.first_surname AS nombre_completo,
    p.blood_type AS tipo_sangre,
    COUNT(pa.patient_allergy_id) AS cantidad_alergias
FROM smart_health.patients p
INNER JOIN smart_health.patient_allergies pa ON p.patient_id = pa.patient_id
INNER JOIN smart_health.medical_records mr ON p.patient_id = mr.patient_id
INNER JOIN smart_health.prescriptions pr ON mr.medical_record_id = pr.medical_record_id
WHERE p.active = TRUE
GROUP BY p.patient_id, p.first_name, p.first_surname, p.blood_type

ORDER BY patient_id ASC;


-- 5. Obtener una lista combinada de todos los métodos de pago utilizados
-- y todos los tipos de citas registradas en el sistema,
-- mostrando el nombre del concepto, el tipo (Método de Pago o Tipo de Cita),
-- y un contador de cuántas veces aparece cada uno,
-- ordenados primero por tipo y luego por cantidad descendente.
-- Dificultad: INTERMEDIA-ALTA

SELECT 
    pm.payment_name AS concepto,
    'Método de Pago' AS tipo_concepto,
    COUNT(pay.payment_id) AS cantidad_registros
FROM smart_health.payment_methods pm
INNER JOIN smart_health.payments pay ON pm.payment_method_id = pay.payment_method_id
GROUP BY pm.payment_name

UNION ALL

SELECT 
    a.appointment_type AS concepto,
    'Tipo de Cita' AS tipo_concepto,
    COUNT(a.appointment_id) AS cantidad_registros
FROM smart_health.appointments a
GROUP BY a.appointment_type

ORDER BY tipo_concepto ASC, cantidad_registros DESC;


-- ##################################################
-- #                 END OF QUERIES                 #
-- ##################################################