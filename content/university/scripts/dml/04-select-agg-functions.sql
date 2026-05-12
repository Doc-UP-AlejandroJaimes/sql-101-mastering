-- Obtener el total de programas por cada facultad
-- ordenado de la facultad con mas programas hacia abajo.
SELECT
    T1.name AS faculty,
    COUNT(*) AS total_programs

FROM university.faculties T1
INNER JOIN university.programs T2
    ON T1.faculty_id = T2.faculty_id
GROUP BY T1.name
ORDER BY total_programs DESC;

-- Obtener el total de estudiantes registrados en el sistema
-- que tengan el rol de estudiante.
-- Tipo de JOIN: INNER
-- Agregación: COUNT


-- Obtener la capacidad máxima entre todas las ofertas de curso
-- que se dictan en un edificio específico.
-- Tipo de JOIN: INNER
-- Agregación: MAX

-- Obtener la capacidad mínima registrada entre todas las ofertas
-- de curso disponibles, mostrando el nombre del curso asociado.
-- Tipo de JOIN: INNER
-- Agregación: MIN


-- Obtener la suma total de capacidad disponible en todas las
-- ofertas de curso que pertenecen a una facultad específica.
-- Tipo de JOIN: INNER
-- Agregación: SUM


-- Obtener el promedio de capacidad de todas las ofertas de curso
-- que se dictan los días lunes.
-- Tipo de JOIN: INNER
-- Agregación: AVG


-- Obtener cuántas ofertas de curso tiene asignadas en total
-- un profesor específico, mostrando su nombre completo.
-- Tipo de JOIN: INNER
-- Agregación: COUNT

-- Obtener el número total de cursos que pertenecen al plan
-- de estudios de un programa académico específico,
-- incluyendo los semestres en los que aparecen.
-- Tipo de JOIN: INNER
-- Agregación: COUNT

-- Obtener la cantidad de estudiantes inscritos en una
-- oferta de curso específica, mostrando el nombre del curso
-- y el nombre completo del profesor que la dicta.
-- Tipo de JOIN: INNER
-- Agregación: COUNT