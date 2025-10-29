-- -- 1️⃣ La primera consulta obtiene los nombres y apellidos de los pacientes registrados, 
-- junto con su correo electrónico y fecha de nacimiento, ordenados por fecha de registro 
-- de manera descendente para visualizar los más recientes primero. 
-- Esta consulta usa un alias para facilitar la lectura de las 
-- columnas en la salida y un límite para mostrar solo los diez registros más recientes.
SELECT
    first_name||' '||COALESCE(middle_name,'') AS nombres,
    first_surname||' '||COALESCE(second_surname,'') AS apellidos,
    email AS correo_electronico,
    birth_date AS fecha_nacimiento

FROM smart_health.patients
ORDER BY registration_date DESC
LIMIT 10;

--     nombres    |    apellidos     |      correo_electronico       | fecha_nacimiento
-- ---------------+------------------+-------------------------------+------------------
--  Juliana       | LópezCabrera     | juliana.lopez@unipamplona.com | 1978-10-11
--  Diego         | PérezPineda      | diego.perez@unipamplona.com   | 1972-02-20
--  Laura         | MoralesLeón      | laura.morales@hotmail.com     | 1998-03-04
--  Gabriela      | LópezCifuentes   | gabriela.lopez@hotmail.com    | 1964-01-07
--  Juliana       | ÁlvarezRodríguez | juliana.alvarez@gmail.com     | 1971-01-04
--  Felipe        | VargasMedina     | felipe.vargas@unipamplona.com | 2002-01-26
--  MaríaMilena   | CastañoLópez     | maria.castano@yahoo.com       | 1973-10-10
--  DiegoEnrique  | CastroDíaz       | diego.castro@yahoo.com        | 1985-03-15
--  IsabelMilena  | OrtizRivera      | isabel.ortiz@outlook.com      | 1989-06-20
--  ManuelNatalia | MontoyaTorres    | manuel.montoya@hotmail.com    | 1968-03-09
-- (10 filas)



-- -- 2️⃣ La segunda consulta selecciona los nombres completos de los 
-- médicos activos junto con su número de licencia médica, ordenando alfabéticamente 
-- por apellidos. También aplica alias a las columnas para mostrar un encabezado 
-- más legible y limita el resultado a los primeros 20 doctores.
SELECT
    first_name||' '||last_name AS nombre_completo,
    medical_license_number
FROM smart_health.doctors
ORDER BY last_name
LIMIT 20;

--   nombre_completo  | medical_license_number
-- -------------------+------------------------
--  Vanessa Aguirre   | MED-1785-5108
--  Gabriela Aguirre  | MED-3533-5102
--  Santiago Aguirre  | MED-7676-7595
--  Miguel Aguirre    | MED-6931-5803
--  Camila Aguirre    | MED-4668-6184
--  Juliana Aguirre   | MED-6033-9169
--  Valentina Aguirre | MED-4602-5367
--  Luis Aguirre      | MED-6018-9149
--  Ricardo Aguirre   | MED-7342-9237
--  Laura Aguirre     | MED-4957-6189
--  María Aguirre     | MED-7634-9788
--  Julián Aguirre    | MED-4522-6775
--  Manuel Aguirre    | MED-1088-3499
--  Angela Aguirre    | MED-9328-8217
--  Rodrigo Aguirre   | MED-4697-9388
--  Santiago Aguirre  | MED-2088-5994
--  Andrés Aguirre    | MED-5371-7298
--  Ricardo Aguirre   | MED-2739-5764
--  Fernando Aguirre  | MED-4496-6666
--  Daniela Aguirre   | MED-5051-4234
-- (20 filas)


-- -- 4️⃣ La cuarta consulta selecciona las citas médicas 
-- programadas (tabla appointment), mostrando el tipo de cita, el estado actual 
-- y la fecha correspondiente. Se utiliza un alias para cada campo y se ordena 
-- por fecha de cita en orden ascendente, limitando la salida a las próximas 10 citas.
SELECT
    appointment_type AS tipo_cita,
    status AS estado_cita,
    appointment_date AS fecha_cita
FROM smart_health.appointments
ORDER BY appointment_date
LIMIT 10;

--     tipo_cita     | estado_cita | fecha_cita
-- ------------------+-------------+------------
--  Teleconsulta     | Attended    | 2020-01-01
--  Vacunación       | Scheduled   | 2020-01-01
--  Psicología       | Confirmed   | 2020-01-01
--  Control          | Cancelled   | 2020-01-01
--  Teleconsulta     | Scheduled   | 2020-01-01
--  Emergencia       | Scheduled   | 2020-01-01
--  Emergencia       | Confirmed   | 2020-01-01
--  Emergencia       | Scheduled   | 2020-01-01
--  Psicología       | Attended    | 2020-01-01
--  Consulta General | Scheduled   | 2020-01-01
-- (10 filas)
 
-- -- 5️⃣ Finalmente, la quinta consulta obtiene los nombres comerciales de 
-- los medicamentos junto con su ingrediente activo, presentándolos de forma 
-- alfabética. Se usa alias para mejorar la presentación de los encabezados y 
-- un límite de 25 registros, ideal para una vista rápida del catálogo farmacológico disponible.
SELECT
    commercial_name,
    active_ingredient
FROM smart_health.medications
ORDER BY commercial_name
LIMIT 25;

-- 1. Mostrar los medicamentos, que tienen un ingrediente activo como PARACETAMOL o IBUPROFENO.
SELECT
    commercial_name,
    active_ingredient
FROM smart_health.medications
WHERE active_ingredient IN ('PARACETAMOL','IBUPROFENO')

-- 2. Mostrar los primeros 5 medicos, que tienen dominio 
-- institucional @hospitalcentral.com

SELECT
    'Dr. '||first_name||' '||last_name AS medico,
    medical_license_number,
    professional_email
FROM smart_health.doctors
WHERE professional_email LIKE '%@hospitalcentral.com%'
LIMIT 5;

-- 3. Mostrar nombre completo, genero, tipo identificacion, 
-- numero de documento y la fecha de registro, 
-- de los 5 pacientes mas jovenes, que tengan estado activo.
SELECT
    first_name||' '||COALESCE(middle_name, '')||' '||first_surname||' '||COALESCE(second_surname, '') AS nombre_completo,
    gender,
    document_type_id,
    document_number,
    registration_date

FROM smart_health.patients
WHERE active = TRUE
ORDER BY birth_date DESC
LIMIT 5;

-- 4. Mostrar las 10 primeras citas, que se hicieron 
-- entre el 25 de Febrero del 2025 
-- y el 28 de Octubre del 2025.
SELECT
    *
FROM smart_health.appointments
WHERE appointment_date BETWEEN '2025-10-25' AND '2025-10-28'
LIMIT 10;

-- 5. Mostrar los datos del numero de telefono, 
-- para los siguientes pacientes.
-- Filtrar por el campo numero_documento.
-- JSON
SELECT
    patient_id,
    phone_type,
    phone_number
FROM smart_health.patient_phones
WHERE patient_id IN 
(
    SELECT patient_id FROM smart_health.patients
    WHERE document_number IN ('30451580',
'1006631391',
'1009149871',
'1298083',
'1004928596',
'1008188849',
'1607132',
'30470003')
);

--  patient_id | phone_type | phone_number
-- ----------+------------+--------------
--       11118 | Móvil      | 3117935551
--         855 | Móvil      | 3014649922
--       15919 | Móvil      | 3201212554
--       11188 | Móvil      | 3149662006
--        7453 | Fijo       | 6043698899
--       14125 | Móvil      | 3185171082
-- (6 filas)
