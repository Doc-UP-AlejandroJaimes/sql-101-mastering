-- COUNT ALL TABLES

 SELECT
    'buildings' AS table,
    COUNT(*) AS total_records
 FROM university.buildings
 UNION ALL
 SELECT
    'classrooms' AS table,
    COUNT(*) AS total_records
 FROM university.classrooms
 UNION ALL
 SELECT
    'course_offerings' AS table,
    COUNT(*) AS total_records
 FROM university.course_offerings
 UNION ALL
 SELECT
    'courses' AS table,
    COUNT(*) AS total_records
 FROM university.courses
 UNION ALL
 SELECT
    'enrollments' AS table,
    COUNT(*) AS total_records
 FROM university.enrollments
 UNION ALL
 SELECT
    'faculties' AS table,
    COUNT(*) AS total_records
 FROM university.faculties
 UNION ALL
 SELECT
    'programs' AS table,
    COUNT(*) AS total_records
 FROM university.programs
 UNION ALL
 SELECT
    'programs_courses' AS table,
    COUNT(*) AS total_records
 FROM university.programs_courses
 UNION ALL
 SELECT
    'programs_students' AS table,
    COUNT(*) AS total_records
 FROM university.programs_students
 UNION ALL
 SELECT
    'roles' AS table,
    COUNT(*) AS total_records
 FROM university.roles
 UNION ALL
 SELECT
    'schedules' AS table,
    COUNT(*) AS total_records
 FROM university.schedules
 UNION ALL
 SELECT
    'users' AS table,
    COUNT(*) AS total_records
 FROM university.users;

-- Total Data

SELECT SUM(F.total_records) AS total
FROM 
(
   SELECT
    'buildings' AS table,
    COUNT(*) AS total_records
 FROM university.buildings
 UNION ALL
 SELECT
    'classrooms' AS table,
    COUNT(*) AS total_records
 FROM university.classrooms
 UNION ALL
 SELECT
    'course_offerings' AS table,
    COUNT(*) AS total_records
 FROM university.course_offerings
 UNION ALL
 SELECT
    'courses' AS table,
    COUNT(*) AS total_records
 FROM university.courses
 UNION ALL
 SELECT
    'enrollments' AS table,
    COUNT(*) AS total_records
 FROM university.enrollments
 UNION ALL
 SELECT
    'faculties' AS table,
    COUNT(*) AS total_records
 FROM university.faculties
 UNION ALL
 SELECT
    'programs' AS table,
    COUNT(*) AS total_records
 FROM university.programs
 UNION ALL
 SELECT
    'programs_courses' AS table,
    COUNT(*) AS total_records
 FROM university.programs_courses
 UNION ALL
 SELECT
    'programs_students' AS table,
    COUNT(*) AS total_records
 FROM university.programs_students
 UNION ALL
 SELECT
    'roles' AS table,
    COUNT(*) AS total_records
 FROM university.roles
 UNION ALL
 SELECT
    'schedules' AS table,
    COUNT(*) AS total_records
 FROM university.schedules
 UNION ALL
 SELECT
    'users' AS table,
    COUNT(*) AS total_records
 FROM university.users 
) F



-- Contar Cuantos profesores dictan en la facultad de "Facultad de Ingenierías y Arquitectura"
-- tables related: 
-- university.roles, 
-- university.users,
-- university.course_offerings,
-- university.courses,
-- university.faculties
SELECT
   COUNT(*) AS total_professors

FROM university.roles T1
INNER JOIN university.users T2
   ON T1.role_id = T2.role_id
INNER JOIN university.course_offerings T3
   ON T2.user_id = T3.professor_id
INNER JOIN university.courses T4
   ON T3.course_id = T4.course_id
INNER JOIN university.faculties T5
   ON T4.faculty_id = T5.faculty_id
WHERE 
   T1.name = 'Professor'
   AND T5.name LIKE '%Facultad de Ingenierías y Arquitectura%';

---------------
SELECT
   T3.name AS faculty,
   T1.professor_id AS professor
FROM university.course_offerings T1
LEFT JOIN university.courses T2
   ON T1.course_id = T2.course_id
LEFT JOIN university.faculties T3
   ON T3.faculty_id = T2.faculty_id;
--WHERE T3.name LIKE '%Facultad de Ingenierías y Arquitectura%';