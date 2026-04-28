//// -- LDM: University Course Management System

//----------------------------------------------//
//// -- ENUMS
//----------------------------------------------//

Enum days_of_week {
  Monday
  Tuesday
  Wednesday
  Thursday
  Friday
  Saturday
  Sunday
}

//----------------------------------------------//
//// -- CORE TABLES
//----------------------------------------------//

Table faculties {
  faculty_id int [pk, increment]
  name varchar(100) [not null]
}

Table programs {
  program_id int [pk, increment]
  name varchar(100) [not null]
  faculty_id int [not null, ref: > faculties.faculty_id]
}

Table courses {
  course_id int [pk, increment]
  name varchar(150) [not null]
  faculty_id int [not null, ref: > faculties.faculty_id]
}

Table buildings {
  building_id int [pk, increment]
  name varchar(100) [not null]
}

Table classrooms {
  classroom_id int [pk, increment]
  name varchar(50) [not null]
  building_id int [not null, ref: > buildings.building_id]
}

Table schedules {
  schedule_id int [pk, increment]
  day days_of_week [not null]
  start_time time [not null]
  end_time time [not null]
}

Table roles {
  role_id int [pk, increment]
  name varchar(50) [not null]
}

Table users {
  user_id int [pk, increment]
  first_name varchar(100) [not null]
  last_name varchar(100) [not null]
  email varchar(150) [not null, unique]
  role_id int [not null, ref: > roles.role_id]
}

//----------------------------------------------//
//// -- TRANSACTIONAL TABLES
//----------------------------------------------//

Table course_offerings {
  course_offering_id int [pk, increment]
  course_id int [not null, ref: > courses.course_id]
  schedule_id int [not null, ref: > schedules.schedule_id]
  classroom_id int [not null, ref: > classrooms.classroom_id]
  professor_id int [not null, ref: > users.user_id]
  capacity int [not null, default: 30, check: `capacity > 0`]
}

//----------------------------------------------//
//// -- PIVOT / JUNCTION TABLES
//----------------------------------------------//

Table programs_courses {
  program_id int [not null, ref: > programs.program_id]
  course_id int [not null, ref: > courses.course_id]
  curriculum_semester int [not null, check: `curriculum_semester between 1 and 12`]

  Indexes {
    (program_id, course_id) [pk]
  }
}

Table programs_students {
  program_id int [not null, ref: > programs.program_id]
  user_id int [not null, ref: > users.user_id]
  current_semester int [not null, check: `current_semester between 1 and 12`]

  Indexes {
    (program_id, user_id) [pk]
  }
}

Table enrollments {
  course_offering_id int [not null, ref: > course_offerings.course_offering_id]
  user_id int [not null, ref: > users.user_id]

  Indexes {
    (course_offering_id, user_id) [pk]
  }
}