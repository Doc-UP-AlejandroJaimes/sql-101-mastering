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


-- tables related: university.faculties; university.programs
SELECT
    T1.name AS Facultades,
    T2.name AS Programas
FROM university.faculties T1
INNER JOIN university.programs T2
    ON T1.faculty_id = T2.faculty_id
WHERE T1.name = 'Facultad de Ciencias Económicas y Empresariales';


-- Encontrar el salon y el edificio, en el cual se ofrece el curso
-- de Cálculo Diferencial

-- tables related:
university.courses T1
university.course_offerings T2 | T1.course_id = T2.course_id
university.classrooms T3       | T2.classroom_id = T3.classroom_id
university.buildings T4        | T3.building_id = T4.building_id

SELECT
    T4.name AS Edificio,
    T3.name AS Salon
FROM university.courses T1
INNER JOIN university.course_offerings T2 
    ON T1.course_id = T2.course_id
INNER JOIN university.classrooms T3       
    ON T2.classroom_id = T3.classroom_id
INNER JOIN university.buildings T4        
    ON T3.building_id = T4.building_id
WHERE T1.name LIKE '%Cálculo Diferencial%';


-- Identificar que personas tiene o no el rol de Admin
SELECT
    *
FROM university.roles T1
RIGHT JOIN university.users T2
    ON T1.role_id = T2.role_id
WHERE T1.name = 'Admin';