// ============================================
// SMART HEALTH DATABASE - Academic Version
// Database: PostgreSQL
// Normalization: 4NF
// ============================================

// ============================================
// MÓDULO GEOGRÁFICO
// ============================================

Table departments {
  department_code varchar(10) [primary key]
  department_name varchar(100) [not null]
}

Table municipalities {
  municipality_code varchar(10) [primary key]
  municipality_name varchar(100) [not null]
  department_code varchar(10) [not null]
}

Table addresses {
  address_id serial [primary key]
  municipality_code varchar(10) [not null]
  address_line varchar(200) [not null]
  postal_code varchar(20)
  active boolean [default: true]
}

// ============================================
// MÓDULO DE PACIENTES
// ============================================

Table patients {
  patient_id serial [primary key]
  first_name varchar(50) [not null]
  middle_name varchar(50)
  first_surname varchar(50) [not null]
  second_surname varchar(50)
  birth_date date [not null]
  gender char(1) [not null]
  email varchar(100) [unique]
  document_type_id int [not null]
  document_number varchar(50) [not null]
  registration_date timestamp [default: `CURRENT_TIMESTAMP`]
  active boolean [default: true]
}

Table patient_phones {
  patient_phone_id serial [primary key]
  patient_id int [not null]
  phone_type varchar(20) [not null]
  phone_number varchar(20) [not null]
  is_primary boolean [default: false]
}

Table patient_addresses {
  patient_address_id serial [primary key]
  patient_id int [not null]
  address_id int [not null]
  address_type varchar(20) [not null]
  is_primary boolean [default: false]
  valid_from date
  valid_to date
}

Table patient_allergies {
  patient_allergy_id serial [primary key]
  patient_id int [not null]
  medication_id int [not null]
  severity varchar(20) [not null]
  reaction_description text
  diagnosed_date date
}

// ============================================
// MÓDULO DE PROFESIONALES
// ============================================

Table doctors {
  doctor_id serial [primary key]
  internal_code varchar(20) [unique, not null]
  medical_license_number varchar(50) [unique, not null]
  first_name varchar(100) [not null]
  last_name varchar(100) [not null]
  professional_email varchar(100) [unique, not null]
  phone_number varchar(20) [not null]
  hospital_admission_date date [not null]
  active boolean [default: true]
}

Table doctor_specialties {
  doctor_specialty_id serial [primary key]
  doctor_id int [not null]
  specialty_id int [not null]
  certification_date date
  is_active boolean [default: true]
}

Table doctor_addresses {
  doctor_address_id serial [primary key]
  doctor_id int [not null]
  address_id int [not null]
  address_type varchar(20) [not null]
  office_hours text
  is_primary boolean [default: false]
}

// ============================================
// MÓDULO DE ATENCIÓN
// ============================================

Table rooms {
  room_id serial [primary key]
  room_name varchar(50) [unique, not null]
  room_type varchar(50) [not null]
  capacity int
  location varchar(100)
  active boolean [default: true]
}

Table appointments {
  appointment_id serial [primary key]
  patient_id int [not null]
  doctor_id int [not null]
  room_id int
  appointment_date date [not null]
  start_time time [not null]
  end_time time [not null]
  appointment_type varchar(50) [not null]
  status varchar(20) [not null]
  reason text
  creation_date timestamp [default: `CURRENT_TIMESTAMP`]
}

Table medical_records {
  medical_record_id serial [primary key]
  patient_id int [not null]
  doctor_id int [not null]
  primary_diagnosis_id int
  registration_datetime timestamp [default: `CURRENT_TIMESTAMP`]
  record_type varchar(50) [not null]
  summary_text text [not null]
  vital_signs text
}

Table record_diagnoses {
  record_diagnosis_id serial [primary key]
  medical_record_id int [not null]
  diagnosis_id int [not null]
  diagnosis_type varchar(20) [not null]
  note text
}

Table prescriptions {
  prescription_id serial [primary key]
  medical_record_id int [not null]
  medication_id int [not null]
  dosage varchar(100) [not null]
  frequency varchar(100) [not null]
  duration varchar(50) [not null]
  instruction text
  prescription_date timestamp [default: `CURRENT_TIMESTAMP`]
  alert_generated boolean [default: false]
}

// ============================================
// MÓDULO DE CATÁLOGOS
// ============================================

Table document_types {
  document_type_id serial [primary key]
  type_name varchar(50) [unique, not null]
  type_code varchar(10) [unique, not null]
  description text
}

Table specialties {
  specialty_id serial [primary key]
  specialty_name varchar(100) [unique, not null]
  description text
}

Table diagnoses {
  diagnosis_id serial [primary key]
  icd_code varchar(10) [unique, not null]
  description varchar(500) [not null]
}

Table medications {
  medication_id serial [primary key]
  atc_code varchar(10) [unique, not null]
  commercial_name varchar(200) [not null]
  active_ingredient varchar(200) [not null]
  presentation varchar(100) [not null]
}

// ============================================
// RELACIONES - MÓDULO GEOGRÁFICO
// ============================================

Ref: municipalities.department_code > departments.department_code [delete: restrict, update: cascade]

Ref: addresses.municipality_code > municipalities.municipality_code [delete: restrict, update: cascade]

Ref: patient_addresses.address_id > addresses.address_id [delete: cascade, update: cascade]

Ref: doctor_addresses.address_id > addresses.address_id [delete: cascade, update: cascade]

// ============================================
// RELACIONES - MÓDULO PACIENTES
// ============================================

Ref: document_types.document_type_id - patients.document_type_id [delete: cascade, update: cascade]

Ref: patient_phones.patient_id > patients.patient_id [delete: cascade, update: cascade]

Ref: patient_addresses.patient_id > patients.patient_id [delete: cascade, update: cascade]

Ref: patient_allergies.patient_id > patients.patient_id [delete: cascade, update: cascade]

Ref: patient_allergies.medication_id > medications.medication_id [delete: restrict, update: cascade]

// ============================================
// RELACIONES - MÓDULO PROFESIONALES
// ============================================

Ref: doctor_specialties.doctor_id > doctors.doctor_id [delete: cascade, update: cascade]

Ref: doctor_specialties.specialty_id > specialties.specialty_id [delete: restrict, update: cascade]

Ref: doctor_addresses.doctor_id > doctors.doctor_id [delete: cascade, update: cascade]

// ============================================
// RELACIONES - MÓDULO ATENCIÓN
// ============================================

Ref: appointments.patient_id > patients.patient_id [delete: restrict, update: cascade]

Ref: appointments.doctor_id > doctors.doctor_id [delete: restrict, update: cascade]

Ref: appointments.room_id > rooms.room_id [delete: set null, update: cascade]

Ref: medical_records.patient_id > patients.patient_id [delete: restrict, update: cascade]

Ref: medical_records.doctor_id > doctors.doctor_id [delete: restrict, update: cascade]

Ref: medical_records.primary_diagnosis_id > diagnoses.diagnosis_id [delete: set null, update: cascade]

Ref: record_diagnoses.medical_record_id > medical_records.medical_record_id [delete: cascade, update: cascade]

Ref: record_diagnoses.diagnosis_id > diagnoses.diagnosis_id [delete: restrict, update: cascade]

Ref: prescriptions.medical_record_id > medical_records.medical_record_id [delete: cascade, update: cascade]

Ref: prescriptions.medication_id > medications.medication_id [delete: restrict, update: cascade]