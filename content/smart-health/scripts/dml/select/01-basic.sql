-- 1. Cuantos doctores hay
SELECT
    'Dr. '||first_name||' '||last_name AS fullname,
    medical_license_number

FROM smart_health.doctors
WHERE active = TRUE
ORDER BY first_name
LIMIT 10;



-- 1️⃣ La primera consulta obtiene los nombres y apellidos de los pacientes registrados, junto con su correo electrónico y fecha de nacimiento, ordenados por fecha de registro de manera descendente para visualizar los más recientes primero. Esta consulta usa un alias para facilitar la lectura de las columnas en la salida y un límite para mostrar solo los diez registros más recientes.

-- 2️⃣ La segunda consulta selecciona los nombres completos de los médicos activos junto con su número de licencia médica, ordenando alfabéticamente por apellidos. También aplica alias a las columnas para mostrar un encabezado más legible y limita el resultado a los primeros 20 doctores.
 
-- 3️⃣ La tercera consulta obtiene el listado de municipios y sus respectivos departamentos, uniendo ambas tablas mediante la clave foránea `department_code`. Se ordena por el nombre del departamento para facilitar la localización geográfica, mostrando los 15 primeros resultados.
 
-- 4️⃣ La cuarta consulta selecciona las citas médicas programadas (tabla `appointment`), mostrando el tipo de cita, el estado actual y la fecha correspondiente. Se utiliza un alias para cada campo y se ordena por fecha de cita en orden ascendente, limitando la salida a las próximas 10 citas.
 
-- 5️⃣ Finalmente, la quinta consulta obtiene los nombres comerciales de los medicamentos junto con su ingrediente activo, presentándolos de forma alfabética. Se usa alias para mejorar la presentación de los encabezados y un límite de 25 registros, ideal para una vista rápida del catálogo farmacológico disponible.
