INSERT INTO university.faculties (name) VALUES
('Facultad de Artes y Humanidades'),
('Facultad de Ciencias Agrarias'),
('Facultad de Ciencias Básicas'),
('Facultad de Ciencias Económicas y Empresariales'),
('Facultad de Ciencias de la Educación'),
('Facultad de Ingenierías y Arquitectura'),
('Facultad de Salud');

SELECT *
FROM university.programs
WHERE program_id = 17;

SELECT *
FROM university.faculties
WHERE faculty_id = 5;

SELECT 
    T1.name AS Carrera,
    T2.name AS Facultad
FROM university.programs T1
INNER JOIN university.faculties T2
    ON T2.faculty_id = T1.faculty_id
WHERE T1.program_id = 17;