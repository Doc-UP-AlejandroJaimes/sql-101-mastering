SELECT
    T1.first_name||' '||T1.last_name AS student,
    T2.current_semester AS semester,
    T3.name AS program,
    T5.name AS course,
    T7.name AS classroom,
    T6.capacity AS capacity_course

FROM university.users T1
INNER JOIN university.programs_students T2
    ON T1.user_id = T2.user_id
INNER JOIN university.programs T3
    ON T2.program_id = T3.program_id
INNER JOIN university.programs_courses T4
    ON T3.program_id = T4.program_id
INNER JOIN university.courses T5
    ON T4.course_id = T5.course_id
INNER JOIN university.course_offerings T6
    ON T5.course_id = T6.course_id
INNER JOIN university.classrooms T7
    ON T6.classroom_id = T7.classroom_id
WHERE T1.user_id = 5;