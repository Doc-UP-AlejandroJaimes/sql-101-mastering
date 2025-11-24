-- ##################################################
-- # CONSULTAS FUNCTIONS - SMART HEALTH #
-- ##################################################

-- 1. Crear una función que calcule la edad de un paciente en años
-- dado su ID, y utilizarla para mostrar el nombre completo y la edad
-- de todos los pacientes activos ordenados por edad descendente.
-- Dificultad: BAJA

CREATE OR REPLACE FUNCTION smart_health.calcular_edad_paciente(p_patient_id INTEGER)
RETURNS INTEGER AS $$
DECLARE
    v_edad INTEGER;
BEGIN
    SELECT EXTRACT(YEAR FROM AGE(CURRENT_DATE, birth_date))
    INTO v_edad
    FROM smart_health.patients
    WHERE patient_id = p_patient_id;
    
    RETURN v_edad;
END;
$$ LANGUAGE plpgsql;

-- Uso de la función
SELECT 
    p.patient_id,
    p.first_name || ' ' || p.first_surname AS nombre_completo,
    smart_health.calcular_edad_paciente(p.patient_id) AS edad_años,
    p.blood_type AS tipo_sangre
FROM smart_health.patients p
WHERE p.active = TRUE
ORDER BY edad_años DESC;


-- 2. Crear una función que calcule el monto total de pagos realizados
-- por un paciente específico, y utilizarla para mostrar los pacientes
-- con sus nombres y el total pagado, ordenados por monto total descendente.
-- Dificultad: BAJA-INTERMEDIA

CREATE OR REPLACE FUNCTION smart_health.calcular_total_pagado_paciente(p_patient_id INTEGER)
RETURNS NUMERIC(10, 2) AS $$
DECLARE
    v_total NUMERIC(10, 2);
BEGIN
    SELECT COALESCE(SUM(pay.amount), 0)
    INTO v_total
    FROM smart_health.orders o
    INNER JOIN smart_health.payments pay ON o.order_id = pay.order_id
    WHERE o.patient_id = p_patient_id;
    
    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

-- Uso de la función
SELECT 
    p.patient_id,
    p.first_name || ' ' || p.first_surname AS nombre_completo,
    p.email,
    smart_health.calcular_total_pagado_paciente(p.patient_id) AS total_pagado
FROM smart_health.patients p
WHERE p.active = TRUE
ORDER BY total_pagado DESC
LIMIT 10;


-- 3. Crear una función que determine el número de años de experiencia
-- de un doctor en el hospital, y utilizarla para listar todos los doctores
-- con su nombre completo, especialidad principal y años de experiencia,
-- ordenados por años de experiencia descendente.
-- Dificultad: INTERMEDIA

CREATE OR REPLACE FUNCTION smart_health.calcular_experiencia_doctor(p_doctor_id INTEGER)
RETURNS INTEGER AS $$
DECLARE
    v_años_experiencia INTEGER;
BEGIN
    SELECT EXTRACT(YEAR FROM AGE(CURRENT_DATE, hospital_admission_date))
    INTO v_años_experiencia
    FROM smart_health.doctors
    WHERE doctor_id = p_doctor_id;
    
    RETURN v_años_experiencia;
END;
$$ LANGUAGE plpgsql;

-- Uso de la función
SELECT 
    d.doctor_id,
    d.first_name || ' ' || d.last_name AS nombre_completo,
    d.medical_license_number AS licencia_medica,
    smart_health.calcular_experiencia_doctor(d.doctor_id) AS años_experiencia,
    s.specialty_name AS especialidad
FROM smart_health.doctors d
INNER JOIN smart_health.doctor_specialties ds ON d.doctor_id = ds.doctor_id
INNER JOIN smart_health.specialties s ON ds.specialty_id = s.specialty_id
WHERE d.active = TRUE AND ds.is_active = TRUE
ORDER BY años_experiencia DESC;


-- 4. Crear una función que calcule el número total de citas de un doctor,
-- y utilizarla para mostrar los doctores con más de 10 citas,
-- incluyendo su nombre, total de citas y el promedio de duración de las citas en minutos.
-- Dificultad: INTERMEDIA

CREATE OR REPLACE FUNCTION smart_health.contar_citas_doctor(p_doctor_id INTEGER)
RETURNS INTEGER AS $$
DECLARE
    v_total_citas INTEGER;
BEGIN
    SELECT COUNT(appointment_id)
    INTO v_total_citas
    FROM smart_health.appointments
    WHERE doctor_id = p_doctor_id;
    
    RETURN v_total_citas;
END;
$$ LANGUAGE plpgsql;

-- Uso de la función
SELECT 
    d.doctor_id,
    d.first_name || ' ' || d.last_name AS nombre_completo,
    smart_health.contar_citas_doctor(d.doctor_id) AS total_citas,
    ROUND(AVG(EXTRACT(EPOCH FROM (a.end_time - a.start_time)) / 60), 0) AS duracion_promedio_minutos
FROM smart_health.doctors d
INNER JOIN smart_health.appointments a ON d.doctor_id = a.doctor_id
WHERE d.active = TRUE
GROUP BY d.doctor_id, d.first_name, d.last_name
HAVING smart_health.contar_citas_doctor(d.doctor_id) > 10
ORDER BY total_citas DESC;


-- 5. Crear una función que calcule el porcentaje de impuestos sobre el total de una orden,
-- y utilizarla para mostrar todas las órdenes con el nombre del paciente,
-- el monto total, el monto de impuestos y el porcentaje de impuestos calculado,
-- ordenadas por porcentaje de impuestos descendente.
-- Dificultad: INTERMEDIA

CREATE OR REPLACE FUNCTION smart_health.calcular_porcentaje_impuestos(p_order_id INTEGER)
RETURNS NUMERIC(5, 2) AS $$
DECLARE
    v_porcentaje NUMERIC(5, 2);
    v_total NUMERIC(10, 2);
    v_tax NUMERIC(10, 2);
BEGIN
    SELECT total_amount, tax_amount
    INTO v_total, v_tax
    FROM smart_health.orders
    WHERE order_id = p_order_id;
    
    IF v_total > 0 THEN
        v_porcentaje := (v_tax / v_total) * 100;
    ELSE
        v_porcentaje := 0;
    END IF;
    
    RETURN v_porcentaje;
END;
$$ LANGUAGE plpgsql;

-- Uso de la función
SELECT 
    o.order_id,
    p.first_name || ' ' || p.first_surname AS nombre_paciente,
    o.total_amount AS monto_total,
    o.tax_amount AS monto_impuestos,
    smart_health.calcular_porcentaje_impuestos(o.order_id) AS porcentaje_impuestos,
    o.order_date AS fecha_orden
FROM smart_health.orders o
INNER JOIN smart_health.patients p ON o.patient_id = p.patient_id
WHERE o.status = TRUE AND o.tax_amount IS NOT NULL
ORDER BY porcentaje_impuestos DESC
LIMIT 15;


-- ##################################################
-- #                 END OF QUERIES                 #
-- ##################################################