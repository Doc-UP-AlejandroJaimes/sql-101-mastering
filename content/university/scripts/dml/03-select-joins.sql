-- Listar los programas relacionados a la facultad de salud.

-- associated tables: university.faculties T1 ; university.programs T2
-- keys: T1.faculty_id = T2.faculty_id

SELECT
    T2.name AS program,
    T1.name AS faculty
FROM university.faculties T1
INNER JOIN university.programs T2
    ON T1.faculty_id = T2.faculty_id
WHERE T1.name LIKE '%Facultad de Salud%'
ORDER BY T2.name;


-- Obtener el nombre completo del estudiante, el nombre del curso
-- y el nombre del salón en el que está inscrito.
-- Solo mostrar estudiantes que estén inscritos en al menos una oferta.
-- Ordenar por apellido del estudiante.
-- Tipo de JOIN: INNER
--

-- Obtener todos los cursos junto con el nombre de la facultad
-- que los ofrece y el programa académico al que pertenecen.
-- Incluir cursos aunque no estén asignados a ningún programa.
-- Ordenar por nombre de la facultad.
-- Tipo de JOIN: LEFT
--

-- Obtener el nombre completo del profesor, el nombre del curso
-- que dicta, el día de la semana y el horario de inicio y fin.
-- Solo mostrar ofertas que tengan profesor y horario asignado.
-- Ordenar por día de la semana y hora de inicio.
-- Tipo de JOIN: INNER
--

-- Obtener el nombre del edificio, el nombre del salón
-- y el nombre del curso que se dicta en cada salón.
-- Incluir todos los salones aunque no tengan ninguna
-- oferta de curso asignada.
-- Ordenar por nombre del edificio y luego por salón.
-- Tipo de JOIN: LEFT
