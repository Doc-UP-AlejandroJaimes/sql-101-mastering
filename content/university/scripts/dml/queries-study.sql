-- =============================================
-- UNIVERSITY SCHEMA - Queries
-- Funciones de Agregación, GROUP BY, HAVING
-- =============================================


-- 01. Obtener la cantidad de cursos que pertenecen al plan
--     de estudios de cada programa académico,
--     mostrando el nombre del programa.
--     Tipo de JOIN: INNER
--     Agregación: COUNT

SELECT
    T2.name              AS program,
    COUNT(T1.course_id)  AS total_courses
FROM university.programs_courses T1
INNER JOIN university.programs T2
    ON T1.program_id = T2.program_id
GROUP BY T2.name
ORDER BY total_courses DESC;


-- 02. Obtener la cantidad de estudiantes inscritos en cada
--     oferta de curso, mostrando el nombre del curso
--     y el nombre completo del profesor que la dicta.
--     Tipo de JOIN: INNER
--     Agregación: COUNT



-- 03. Obtener el número de programas académicos que tiene
--     cada facultad, mostrando el nombre de la facultad.
--     Tipo de JOIN: INNER
--     Agregación: COUNT



-- 04. Obtener la cantidad de aulas disponibles por edificio,
--     mostrando el nombre del edificio.
--     Tipo de JOIN: INNER
--     Agregación: COUNT




-- 05. Obtener la cantidad de ofertas de curso asignadas a cada
--     profesor, mostrando su nombre completo.
--     Tipo de JOIN: INNER
--     Agregación: COUNT



-- 06. Obtener únicamente los profesores que dictan más de 2
--     ofertas de curso, mostrando su nombre completo
--     y el total de ofertas.
--     Tipo de JOIN: INNER
--     Agregación: COUNT
--     Filtro: HAVING



-- 07. Obtener los programas académicos que tienen más de 5
--     cursos registrados en su plan de estudios.
--     Tipo de JOIN: INNER
--     Agregación: COUNT
--     Filtro: HAVING




-- 08. Obtener la cantidad de estudiantes inscritos en cada
--     programa académico, mostrando el nombre del programa.
--     Tipo de JOIN: INNER
--     Agregación: COUNT




-- 09. Obtener el semestre del currículo con más cursos asignados
--     en todos los programas, mostrando la cantidad por semestre.
--     Agregación: COUNT
--     Agrupación: curriculum_semester



-- 10. Obtener los semestres del currículo que tienen más de 3
--     cursos asignados considerando todos los programas.
--     Agregación: COUNT
--     Filtro: HAVING



-- 11. Obtener cuántas ofertas de curso se realizan en cada aula,
--     mostrando el nombre del aula y el edificio al que pertenece.
--     Tipo de JOIN: INNER
--     Agregación: COUNT



-- 12. Obtener los cursos que se ofrecen en más de un horario
--     diferente, mostrando el nombre del curso
--     y cuántas ofertas distintas tiene.
--     Tipo de JOIN: INNER
--     Agregación: COUNT
--     Filtro: HAVING




-- 13. Obtener la capacidad total de estudiantes que puede
--     atender cada edificio, sumando la capacidad de todas
--     las ofertas impartidas en sus aulas.
--     Tipo de JOIN: INNER
--     Agregación: SUM



-- 14. Obtener el promedio de capacidad de las ofertas de curso
--     agrupadas por curso, mostrando el nombre del curso.
--     Tipo de JOIN: INNER
--     Agregación: AVG




-- 15. Obtener la capacidad máxima y mínima registrada entre
--     todas las ofertas de curso de cada facultad.
--     Tipo de JOIN: INNER
--     Agregación: MAX, MIN


-- 16. Obtener la cantidad de inscripciones activas de cada
--     estudiante, mostrando su nombre completo y el total
--     de ofertas en las que está registrado.
--     Tipo de JOIN: INNER
--     Agregación: COUNT



-- 17. Obtener los estudiantes que tienen más de 3 inscripciones
--     activas en ofertas de curso.
--     Tipo de JOIN: INNER
--     Agregación: COUNT
--     Filtro: HAVING



-- 18. Obtener cuántos usuarios hay registrados por cada rol
--     del sistema, mostrando el nombre del rol.
--     Tipo de JOIN: INNER
--     Agregación: COUNT


-- 19. Obtener la cantidad de ofertas de curso que se dictan
--     en cada franja horaria (schedule), mostrando el día
--     y los horarios de inicio y fin.
--     Tipo de JOIN: INNER
--     Agregación: COUNT


-- 20. Obtener los horarios que tienen más de 2 ofertas
--     de curso asignadas, mostrando día, hora y cantidad.
--     Tipo de JOIN: INNER
--     Agregación: COUNT
--     Filtro: HAVING


-- 21. Obtener el número de cursos que ofrece cada facultad,
--     mostrando únicamente las facultades con más de 3 cursos.
--     Tipo de JOIN: INNER
--     Agregación: COUNT
--     Filtro: HAVING


-- 22. Obtener el semestre actual más frecuente entre los
--     estudiantes de cada programa académico.
--     Tipo de JOIN: INNER
--     Agregación: COUNT


-- 23. Obtener los programas que tienen registros de estudiantes
--     en más de 4 semestres distintos, contando las filas
--     agrupadas por semestre y luego filtrando por programa.
--     Tipo de JOIN: INNER + Subquery en FROM
--     Agregación: COUNT
--     Filtro: HAVING


-- 24. Obtener la cantidad total de inscripciones (enrollments)
--     registradas por cada facultad, trazando la relación
--     a través de la oferta y el curso.
--     Tipo de JOIN: INNER
--     Agregación: COUNT


-- 25. Obtener las facultades cuya cantidad total de inscripciones
--     supera las 50, mostrando el nombre y el conteo.
--     Tipo de JOIN: INNER
--     Agregación: COUNT
--     Filtro: HAVING


-- =============================================
-- QUERIES CON SUBQUERIES EN EL JOIN
-- =============================================


-- 26. Obtener el nombre completo del profesor y el total de
--     cursos distintos que dicta, filtrando solo los profesores
--     que dictan cursos con más de 1 oferta registrada en total.
--     Tipo de JOIN: INNER + Subquery en JOIN
--     Agregación: COUNT



-- 27. Obtener el nombre del programa y la cantidad de estudiantes
--     inscritos, considerando solo los programas que pertenecen
--     a facultades con más de 2 programas registrados.
--     Tipo de JOIN: INNER + Subquery en JOIN
--     Agregación: COUNT


-- 28. Obtener el nombre del curso y cuántos estudiantes están
--     inscritos en él, mostrando solo los cursos cuya capacidad
--     promedio entre sus ofertas es mayor a 25 estudiantes.
--     Tipo de JOIN: INNER + Subquery en JOIN
--     Agregación: COUNT


-- 29. Obtener el nombre del edificio y el total de inscripciones
--     que se generaron en sus aulas, considerando solo los
--     edificios que tienen más de 2 aulas registradas.
--     Tipo de JOIN: INNER + Subquery en JOIN
--     Agregación: COUNT


-- 30. Obtener el nombre del programa, el nombre de la facultad
--     y el total de cursos del currículo, mostrando solo los
--     programas cuya facultad tiene más de 3 cursos en su
--     catálogo general.
--     Tipo de JOIN: INNER + Subquery en JOIN
--     Agregación: COUNT


-- =============================================
-- QUERIES ADICIONALES - AGREGACIÓN Y HAVING
-- =============================================


-- 31. Obtener el nombre del programa y la cantidad de cursos
--     asignados en el primer semestre del currículo.
--     Tipo de JOIN: INNER
--     Agregación: COUNT
--     Filtro WHERE: curriculum_semester = 1



-- 32. Obtener el día de la semana con mayor número de ofertas
--     de curso programadas.
--     Tipo de JOIN: INNER
--     Agregación: COUNT



-- 33. Obtener los cursos cuya suma total de capacidad entre
--     todas sus ofertas supera las 40 plazas disponibles.
--     Tipo de JOIN: INNER
--     Agregación: SUM
--     Filtro: HAVING

SELECT
    T2.name            AS course,
    SUM(T1.capacity)   AS total_capacity
FROM university.course_offerings T1
INNER JOIN university.courses T2
    ON T1.course_id = T2.course_id
GROUP BY T2.name
HAVING SUM(T1.capacity) > 40
ORDER BY total_capacity DESC;


-- 34. Obtener la cantidad de cursos registrados en el currículo
--     de los programas de cada facultad, agrupando por facultad.
--     Tipo de JOIN: INNER
--     Agregación: COUNT


-- 35. Obtener la cantidad de estudiantes por semestre actual
--     en todos los programas, mostrando solo los semestres
--     que concentran más de 10 estudiantes en total.
--     Agregación: COUNT
--     Filtro: HAVING


-- 36. Obtener el total de inscripciones por oferta de curso,
--     mostrando el nombre del curso, el nombre del profesor
--     y el porcentaje de ocupación respecto a la capacidad.
--     Tipo de JOIN: INNER
--     Agregación: COUNT


-- 37. Obtener los cursos cuya oferta con más inscripciones
--     supera el 80% de la capacidad de esa oferta.
--     Tipo de JOIN: INNER + Subquery en JOIN
--     Agregación: COUNT, MAX
--     Filtro: HAVING


-- 38. Obtener la cantidad de programas en los que cada
--     estudiante está matriculado (puede estar en más de uno)
--     mostrando su nombre completo.
--     Tipo de JOIN: INNER
--     Agregación: COUNT


-- 39. Obtener los cursos que aparecen en el currículo de más
--     de un programa académico, mostrando cuántos programas
--     los incluyen.
--     Tipo de JOIN: INNER
--     Agregación: COUNT
--     Filtro: HAVING


-- 40. Obtener el total de inscripciones y el total de ofertas
--     de curso agrupados por facultad, mostrando también
--     la capacidad total habilitada por esa facultad.
--     Tipo de JOIN: INNER
--     Agregación: COUNT, SUM