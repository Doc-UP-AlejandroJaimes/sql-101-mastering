-- =============================================
-- UNIVERSITY SCHEMA - PostgreSQL DDL
-- =============================================

CREATE SCHEMA IF NOT EXISTS university;

-- =============================================
-- TABLE CREATION
-- =============================================

CREATE TYPE university.days_of_week AS ENUM (
  'Monday', 'Tuesday', 'Wednesday', 'Thursday',
  'Friday', 'Saturday', 'Sunday'
);

CREATE TABLE university.faculties (
  faculty_id SERIAL PRIMARY KEY,
  name       VARCHAR(100) NOT NULL
);

COMMENT ON COLUMN university.faculties.faculty_id IS 'Unique identifier for the faculty';
COMMENT ON COLUMN university.faculties.name       IS 'Official name of the faculty';

-- ---------------------------------------------

CREATE TABLE university.roles (
  role_id SERIAL PRIMARY KEY,
  name    VARCHAR(50) NOT NULL
);

COMMENT ON COLUMN university.roles.role_id IS 'Unique identifier for the role';
COMMENT ON COLUMN university.roles.name    IS 'Role name, e.g. Student, Professor, Admin';

-- ---------------------------------------------

CREATE TABLE university.users (
  user_id    SERIAL PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name  VARCHAR(100) NOT NULL,
  email      VARCHAR(150) NOT NULL UNIQUE,
  role_id    INT NOT NULL
);

COMMENT ON COLUMN university.users.user_id    IS 'Unique identifier for the user';
COMMENT ON COLUMN university.users.first_name IS 'First name of the user';
COMMENT ON COLUMN university.users.last_name  IS 'Last name of the user';
COMMENT ON COLUMN university.users.email      IS 'Unique institutional email of the user';
COMMENT ON COLUMN university.users.role_id    IS 'FK - Role assigned to the user';

-- ---------------------------------------------

CREATE TABLE university.programs (
  program_id SERIAL PRIMARY KEY,
  name       VARCHAR(100) NOT NULL,
  faculty_id INT NOT NULL
);

COMMENT ON COLUMN university.programs.program_id IS 'Unique identifier for the academic program';
COMMENT ON COLUMN university.programs.name       IS 'Name of the academic program, e.g. Systems Engineering';
COMMENT ON COLUMN university.programs.faculty_id IS 'FK - Faculty that owns this program';

-- ---------------------------------------------

CREATE TABLE university.courses (
  course_id  SERIAL PRIMARY KEY,
  name       VARCHAR(150) NOT NULL,
  faculty_id INT NOT NULL
);

COMMENT ON COLUMN university.courses.course_id  IS 'Unique identifier for the course';
COMMENT ON COLUMN university.courses.name       IS 'Full name of the course, e.g. Calculus I';
COMMENT ON COLUMN university.courses.faculty_id IS 'FK - Faculty that offers this course';

-- ---------------------------------------------

CREATE TABLE university.buildings (
  building_id SERIAL PRIMARY KEY,
  name        VARCHAR(100) NOT NULL
);

COMMENT ON COLUMN university.buildings.building_id IS 'Unique identifier for the building';
COMMENT ON COLUMN university.buildings.name        IS 'Name or code of the building on campus';

-- ---------------------------------------------

CREATE TABLE university.classrooms (
  classroom_id SERIAL PRIMARY KEY,
  name         VARCHAR(50) NOT NULL,
  building_id  INT NOT NULL
);

COMMENT ON COLUMN university.classrooms.classroom_id IS 'Unique identifier for the classroom';
COMMENT ON COLUMN university.classrooms.name         IS 'Classroom label or number, e.g. Lab-3, Room 201';
COMMENT ON COLUMN university.classrooms.building_id  IS 'FK - Building where this classroom is located';

-- ---------------------------------------------

CREATE TABLE university.schedules (
  schedule_id SERIAL PRIMARY KEY,
  day         university.days_of_week NOT NULL,
  start_time  TIME NOT NULL,
  end_time    TIME NOT NULL
);

COMMENT ON COLUMN university.schedules.schedule_id IS 'Unique identifier for the schedule slot';
COMMENT ON COLUMN university.schedules.day         IS 'Day of the week for this schedule slot';
COMMENT ON COLUMN university.schedules.start_time  IS 'Time the class session begins';
COMMENT ON COLUMN university.schedules.end_time    IS 'Time the class session ends';

-- ---------------------------------------------

CREATE TABLE university.course_offerings (
  course_offering_id SERIAL PRIMARY KEY,
  course_id          INT NOT NULL,
  schedule_id        INT NOT NULL,
  classroom_id       INT NOT NULL,
  professor_id       INT NOT NULL,
  capacity           INT NOT NULL DEFAULT 30
);

COMMENT ON COLUMN university.course_offerings.course_offering_id IS 'Unique identifier for the course offering (group/section)';
COMMENT ON COLUMN university.course_offerings.course_id          IS 'FK - Course being offered';
COMMENT ON COLUMN university.course_offerings.schedule_id        IS 'FK - Schedule slot assigned to this offering';
COMMENT ON COLUMN university.course_offerings.classroom_id       IS 'FK - Classroom where the offering takes place';
COMMENT ON COLUMN university.course_offerings.professor_id       IS 'FK - User (professor) who teaches this offering';
COMMENT ON COLUMN university.course_offerings.capacity           IS 'Maximum number of students allowed in this offering';

-- ---------------------------------------------

CREATE TABLE university.programs_courses (
  program_id          INT NOT NULL,
  course_id           INT NOT NULL,
  curriculum_semester INT NOT NULL,
  PRIMARY KEY (program_id, course_id)
);

COMMENT ON COLUMN university.programs_courses.program_id          IS 'FK - Academic program that includes this course';
COMMENT ON COLUMN university.programs_courses.course_id           IS 'FK - Course included in the program curriculum';
COMMENT ON COLUMN university.programs_courses.curriculum_semester IS 'Semester in the curriculum where this course is assigned (1-12)';

-- ---------------------------------------------

CREATE TABLE university.programs_students (
  program_id       INT NOT NULL,
  user_id          INT NOT NULL,
  current_semester INT NOT NULL,
  PRIMARY KEY (program_id, user_id)
);

COMMENT ON COLUMN university.programs_students.program_id       IS 'FK - Academic program the student is enrolled in';
COMMENT ON COLUMN university.programs_students.user_id          IS 'FK - User (student) enrolled in the program';
COMMENT ON COLUMN university.programs_students.current_semester IS 'Current semester the student is attending (1-12)';

-- ---------------------------------------------

CREATE TABLE university.enrollments (
  course_offering_id INT NOT NULL,
  user_id            INT NOT NULL,
  PRIMARY KEY (course_offering_id, user_id)
);

COMMENT ON COLUMN university.enrollments.course_offering_id IS 'FK - Course offering the student is registered in';
COMMENT ON COLUMN university.enrollments.user_id            IS 'FK - User (student) registered in the offering';

-- =============================================
-- FOREIGN KEY CONSTRAINTS
-- =============================================

ALTER TABLE university.programs
  ADD CONSTRAINT fk_programs_faculty
  FOREIGN KEY (faculty_id) REFERENCES university.faculties (faculty_id);

ALTER TABLE university.courses
  ADD CONSTRAINT fk_courses_faculty
  FOREIGN KEY (faculty_id) REFERENCES university.faculties (faculty_id);

ALTER TABLE university.users
  ADD CONSTRAINT fk_users_role
  FOREIGN KEY (role_id) REFERENCES university.roles (role_id);

ALTER TABLE university.classrooms
  ADD CONSTRAINT fk_classrooms_building
  FOREIGN KEY (building_id) REFERENCES university.buildings (building_id);

ALTER TABLE university.course_offerings
  ADD CONSTRAINT fk_offerings_course
  FOREIGN KEY (course_id) REFERENCES university.courses (course_id);

ALTER TABLE university.course_offerings
  ADD CONSTRAINT fk_offerings_schedule
  FOREIGN KEY (schedule_id) REFERENCES university.schedules (schedule_id);

ALTER TABLE university.course_offerings
  ADD CONSTRAINT fk_offerings_classroom
  FOREIGN KEY (classroom_id) REFERENCES university.classrooms (classroom_id);

ALTER TABLE university.course_offerings
  ADD CONSTRAINT fk_offerings_professor
  FOREIGN KEY (professor_id) REFERENCES university.users (user_id);

ALTER TABLE university.programs_courses
  ADD CONSTRAINT fk_pc_program
  FOREIGN KEY (program_id) REFERENCES university.programs (program_id);

ALTER TABLE university.programs_courses
  ADD CONSTRAINT fk_pc_course
  FOREIGN KEY (course_id) REFERENCES university.courses (course_id);

ALTER TABLE university.programs_students
  ADD CONSTRAINT fk_ps_program
  FOREIGN KEY (program_id) REFERENCES university.programs (program_id);

ALTER TABLE university.programs_students
  ADD CONSTRAINT fk_ps_user
  FOREIGN KEY (user_id) REFERENCES university.users (user_id);

ALTER TABLE university.enrollments
  ADD CONSTRAINT fk_enrollments_offering
  FOREIGN KEY (course_offering_id) REFERENCES university.course_offerings (course_offering_id);

ALTER TABLE university.enrollments
  ADD CONSTRAINT fk_enrollments_user
  FOREIGN KEY (user_id) REFERENCES university.users (user_id);

-- =============================================
-- CHECK CONSTRAINTS
-- =============================================

ALTER TABLE university.schedules
  ADD CONSTRAINT chk_schedules_time
  CHECK (end_time > start_time);

ALTER TABLE university.course_offerings
  ADD CONSTRAINT chk_offerings_capacity
  CHECK (capacity > 0);

ALTER TABLE university.programs_courses
  ADD CONSTRAINT chk_pc_semester
  CHECK (curriculum_semester BETWEEN 1 AND 12);

ALTER TABLE university.programs_students
  ADD CONSTRAINT chk_ps_semester
  CHECK (current_semester BETWEEN 1 AND 12);