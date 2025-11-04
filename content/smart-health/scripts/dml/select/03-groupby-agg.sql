-- Obtener la cita max y min, con el nombre de sus pacientes.


SELECT
    T1.first_name||' '||COALESCE(T1.middle_name,'')||' '||T1.first_surname||' '||COALESCE(T1.second_surname,'') AS Paciente,
    T2.appointment_date AS FECHA_MIN

FROM smart_health.patients T1
INNER JOIN smart_health.appointments T2
ON T1.patient_id = T2.patient_id
WHERE T2.appointment_date = (
    SELECT MIN(appointment_date) FROM smart_health.appointments
)
LIMIT 1;


SELECT
    T1.first_name||' '||COALESCE(T1.middle_name,'')||' '||T1.first_surname||' '||COALESCE(T1.second_surname,'') AS Paciente,
    T2.appointment_date AS FECHA_MAX

FROM smart_health.patients T1
INNER JOIN smart_health.appointments T2
ON T1.patient_id = T2.patient_id
WHERE T2.appointment_date = (
    SELECT MAX(appointment_date) FROM smart_health.appointments
)
LIMIT 1;

-- TOP5 LOS PACIENTES MAS VIEJOS
SELECT
    first_name||' '||second_surname as patient,
    EXTRACT(YEAR FROM birth_date) AS age

FROM smart_health.patients
GROUP BY first_name, second_surname, birth_date
ORDER BY age DESC 
LIMIT 5;