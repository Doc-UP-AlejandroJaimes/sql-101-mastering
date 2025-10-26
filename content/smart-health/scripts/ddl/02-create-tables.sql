-- ##################################################
-- #            DDL SCRIPT DOCUMENTATION            #
-- ##################################################
-- This script defines the database structure for Smart Health Hospital Management System
-- Includes tables for PATIENTS, DOCTORS, APPOINTMENTS, MEDICAL_RECORDS, and supporting
-- catalog tables for geographic locations, document types, specialties, diagnoses, and medications.
-- The system is designed to manage patient records, medical appointments, clinical history,
-- prescriptions, and professional credentials in a normalized academic environment.
-- All tables include appropriate constraints, relationships, and data types to ensure 
-- data integrity and support comprehensive healthcare management operations.
-- Database Normalization: 4NF (Fourth Normal Form)
-- Target DBMS: PostgreSQL

-- ##################################################
-- #           SCHEMA CREATION (Optional)           #
-- ##################################################

-- RUN IN smarthdb - sm_admin
-- 04. Create Schema
CREATE SCHEMA IF NOT EXISTS smart_health AUTHORIZATION sm_admin;

-- 05. Comment on database
COMMENT ON DATABASE smarthdb IS 'Base de datos para el control de pacientes y citas';

-- 06. Comment on schema
COMMENT ON SCHEMA smart_health IS 'Esquema principal para el sistema de control de pacientes y citas';

-- ##################################################
-- #        MÓDULO GEOGRÁFICO - INDEPENDENT         #
-- ##################################################

-- Table: departments
-- Brief: Stores information about departments/states for geographic location
CREATE TABLE IF NOT EXISTS smart_health.departments (
    department_code VARCHAR(10) PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL
);

COMMENT ON TABLE smart_health.departments IS 'Catálogo de departamentos o estados';
COMMENT ON COLUMN smart_health.departments.department_code IS 'Código único del departamento';
COMMENT ON COLUMN smart_health.departments.department_name IS 'Nombre completo del departamento';

-- Table: municipalities
-- Brief: Stores municipalities/cities that belong to departments
CREATE TABLE IF NOT EXISTS smart_health.municipalities (
    municipality_code VARCHAR(10) PRIMARY KEY,
    municipality_name VARCHAR(100) NOT NULL,
    department_code VARCHAR(10) NOT NULL
);

COMMENT ON TABLE smart_health.municipalities IS 'Catálogo de municipios o ciudades';
COMMENT ON COLUMN smart_health.municipalities.municipality_code IS 'Código único del municipio';
COMMENT ON COLUMN smart_health.municipalities.municipality_name IS 'Nombre completo del municipio';
COMMENT ON COLUMN smart_health.municipalities.department_code IS 'Código del departamento al que pertenece';

-- Table: addresses
-- Brief: Reusable physical addresses for patients and doctors
CREATE TABLE IF NOT EXISTS smart_health.addresses (
    address_id SERIAL PRIMARY KEY,
    municipality_code VARCHAR(10) NOT NULL,
    address_line VARCHAR(200) NOT NULL,
    postal_code VARCHAR(20),
    active BOOLEAN DEFAULT TRUE
);

COMMENT ON TABLE smart_health.addresses IS 'Direcciones físicas reutilizables para pacientes y doctores';
COMMENT ON COLUMN smart_health.addresses.address_id IS 'Identificador único de la dirección';
COMMENT ON COLUMN smart_health.addresses.municipality_code IS 'Código del municipio donde se ubica la dirección';
COMMENT ON COLUMN smart_health.addresses.address_line IS 'Línea completa de dirección';
COMMENT ON COLUMN smart_health.addresses.postal_code IS 'Código postal (opcional)';
COMMENT ON COLUMN smart_health.addresses.active IS 'Indica si la dirección está activa';

-- ##################################################
-- #        MÓDULO DE CATÁLOGOS - INDEPENDENT       #
-- ##################################################

-- Table: document_types
-- Brief: Catalog of identification document types (CC, CE, PA, TI, etc.)
CREATE TABLE IF NOT EXISTS smart_health.document_types (
    document_type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(70) NOT NULL UNIQUE,
    type_code VARCHAR(10) NOT NULL UNIQUE,
    description TEXT
);

COMMENT ON TABLE smart_health.document_types IS 'Catálogo de tipos de documento de identidad';
COMMENT ON COLUMN smart_health.document_types.document_type_id IS 'Identificador único del tipo de documento';
COMMENT ON COLUMN smart_health.document_types.type_name IS 'Nombre completo del tipo de documento';
COMMENT ON COLUMN smart_health.document_types.type_code IS 'Código abreviado del tipo de documento';
COMMENT ON COLUMN smart_health.document_types.description IS 'Descripción detallada del tipo de documento';

-- Table: specialties
-- Brief: Catalog of medical specialties (Cardiology, Pediatrics, etc.)
CREATE TABLE IF NOT EXISTS smart_health.specialties (
    specialty_id SERIAL PRIMARY KEY,
    specialty_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

COMMENT ON TABLE smart_health.specialties IS 'Catálogo de especialidades médicas';
COMMENT ON COLUMN smart_health.specialties.specialty_id IS 'Identificador único de la especialidad';
COMMENT ON COLUMN smart_health.specialties.specialty_name IS 'Nombre de la especialidad médica';
COMMENT ON COLUMN smart_health.specialties.description IS 'Descripción detallada de la especialidad';

-- Table: diagnoses
-- Brief: Catalog of diagnoses using ICD-10 codes (International Classification of Diseases)
CREATE TABLE IF NOT EXISTS smart_health.diagnoses (
    diagnosis_id SERIAL PRIMARY KEY,
    icd_code VARCHAR(10) NOT NULL UNIQUE,
    description VARCHAR(500) NOT NULL
);

COMMENT ON TABLE smart_health.diagnoses IS 'Catálogo de diagnósticos según CIE-10';
COMMENT ON COLUMN smart_health.diagnoses.diagnosis_id IS 'Identificador único del diagnóstico';
COMMENT ON COLUMN smart_health.diagnoses.icd_code IS 'Código CIE-10 del diagnóstico';
COMMENT ON COLUMN smart_health.diagnoses.description IS 'Descripción del diagnóstico';

-- Table: medications
-- Brief: Catalog of medications with ATC codes (Anatomical Therapeutic Chemical)
CREATE TABLE IF NOT EXISTS smart_health.medications (
    medication_id SERIAL PRIMARY KEY,
    atc_code VARCHAR(10) NOT NULL UNIQUE,
    commercial_name VARCHAR(200) NOT NULL,
    active_ingredient VARCHAR(200) NOT NULL,
    presentation VARCHAR(100) NOT NULL
);

COMMENT ON TABLE smart_health.medications IS 'Catálogo de medicamentos con código ATC';
COMMENT ON COLUMN smart_health.medications.medication_id IS 'Identificador único del medicamento';
COMMENT ON COLUMN smart_health.medications.atc_code IS 'Código ATC del medicamento';
COMMENT ON COLUMN smart_health.medications.commercial_name IS 'Nombre comercial del medicamento';
COMMENT ON COLUMN smart_health.medications.active_ingredient IS 'Principio activo del medicamento';
COMMENT ON COLUMN smart_health.medications.presentation IS 'Presentación del medicamento (tabletas, jarabe, etc.)';

-- ##################################################
-- #          MÓDULO DE PACIENTES - CORE            #
-- ##################################################

-- Table: patients
-- Brief: Main entity storing patient information
CREATE TABLE IF NOT EXISTS smart_health.patients (
    patient_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),
    first_surname VARCHAR(50) NOT NULL,
    second_surname VARCHAR(50),
    birth_date DATE NOT NULL,
    gender CHAR(1) NOT NULL CHECK (gender IN ('M', 'F', 'O')),
    email VARCHAR(100) UNIQUE,
    document_type_id INTEGER NOT NULL,
    document_number VARCHAR(50) NOT NULL,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    active BOOLEAN DEFAULT TRUE
);

COMMENT ON TABLE smart_health.patients IS 'Entidad principal de pacientes del hospital';
COMMENT ON COLUMN smart_health.patients.patient_id IS 'Identificador único del paciente';
COMMENT ON COLUMN smart_health.patients.first_name IS 'Primer nombre del paciente';
COMMENT ON COLUMN smart_health.patients.middle_name IS 'Segundo nombre del paciente (opcional)';
COMMENT ON COLUMN smart_health.patients.first_surname IS 'Primer apellido del paciente';
COMMENT ON COLUMN smart_health.patients.second_surname IS 'Segundo apellido del paciente (opcional)';
COMMENT ON COLUMN smart_health.patients.birth_date IS 'Fecha de nacimiento del paciente';
COMMENT ON COLUMN smart_health.patients.gender IS 'Género del paciente (M: Masculino, F: Femenino, O: Otro)';
COMMENT ON COLUMN smart_health.patients.email IS 'Correo electrónico del paciente';
COMMENT ON COLUMN smart_health.patients.registration_date IS 'Fecha y hora de registro en el sistema';
COMMENT ON COLUMN smart_health.patients.active IS 'Indica si el paciente está activo en el sistema';
COMMENT ON COLUMN smart_health.patients.document_type_id IS 'Tipo de documento';
COMMENT ON COLUMN smart_health.patients.document_number IS 'Número del documento';

-- Table: patient_phones
-- Brief: Contact phone numbers for patients
CREATE TABLE IF NOT EXISTS smart_health.patient_phones (
    patient_phone_id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL,
    phone_type VARCHAR(20) NOT NULL CHECK (phone_type IN ('Móvil', 'Fijo')),
    phone_number VARCHAR(20) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE
);

COMMENT ON TABLE smart_health.patient_phones IS 'Teléfonos de contacto del paciente';
COMMENT ON COLUMN smart_health.patient_phones.patient_phone_id IS 'Identificador único del teléfono';
COMMENT ON COLUMN smart_health.patient_phones.patient_id IS 'Referencia al paciente';
COMMENT ON COLUMN smart_health.patient_phones.phone_type IS 'Tipo de teléfono (Mobile: Móvil, Landline: Fijo)';
COMMENT ON COLUMN smart_health.patient_phones.phone_number IS 'Número de teléfono';
COMMENT ON COLUMN smart_health.patient_phones.is_primary IS 'Indica si es el teléfono principal';

-- Table: patient_addresses
-- Brief: Relationship between patients and their addresses
CREATE TABLE IF NOT EXISTS smart_health.patient_addresses (
    patient_address_id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL,
    address_id INTEGER NOT NULL,
    address_type VARCHAR(20) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    valid_from DATE,
    valid_to DATE,
    CONSTRAINT uq_patient_address UNIQUE (patient_id, address_id)
);

COMMENT ON TABLE smart_health.patient_addresses IS 'Relación entre pacientes y direcciones con temporalidad';
COMMENT ON COLUMN smart_health.patient_addresses.patient_address_id IS 'Identificador único de la relación';
COMMENT ON COLUMN smart_health.patient_addresses.patient_id IS 'Referencia al paciente';
COMMENT ON COLUMN smart_health.patient_addresses.address_id IS 'Referencia a la dirección';
COMMENT ON COLUMN smart_health.patient_addresses.address_type IS 'Tipo de dirección (Permanent: Permanente, Temporary: Temporal)';
COMMENT ON COLUMN smart_health.patient_addresses.is_primary IS 'Indica si es la dirección principal';
COMMENT ON COLUMN smart_health.patient_addresses.valid_from IS 'Fecha de inicio de validez';
COMMENT ON COLUMN smart_health.patient_addresses.valid_to IS 'Fecha de fin de validez';

-- Table: patient_allergies
-- Brief: Patient allergies to specific medications
CREATE TABLE IF NOT EXISTS smart_health.patient_allergies (
    patient_allergy_id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL,
    medication_id INTEGER NOT NULL,
    severity VARCHAR(20) NOT NULL,
    reaction_description TEXT,
    diagnosed_date DATE
);

COMMENT ON TABLE smart_health.patient_allergies IS 'Alergias del paciente a medicamentos específicos';
COMMENT ON COLUMN smart_health.patient_allergies.patient_allergy_id IS 'Identificador único de la alergia';
COMMENT ON COLUMN smart_health.patient_allergies.patient_id IS 'Referencia al paciente';
COMMENT ON COLUMN smart_health.patient_allergies.medication_id IS 'Referencia al medicamento';
COMMENT ON COLUMN smart_health.patient_allergies.severity IS 'Severidad de la alergia (Mild: Leve, Moderate: Moderada, Severe: Severa)';
COMMENT ON COLUMN smart_health.patient_allergies.reaction_description IS 'Descripción de la reacción alérgica';
COMMENT ON COLUMN smart_health.patient_allergies.diagnosed_date IS 'Fecha de diagnóstico de la alergia';

-- ##################################################
-- #       MÓDULO DE PROFESIONALES - CORE           #
-- ##################################################

-- Table: doctors
-- Brief: Main entity storing doctor/professional information
CREATE TABLE IF NOT EXISTS smart_health.doctors (
    doctor_id SERIAL PRIMARY KEY,
    internal_code VARCHAR(20) NOT NULL UNIQUE,
    medical_license_number VARCHAR(50) NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    professional_email VARCHAR(100) NOT NULL UNIQUE,
    phone_number VARCHAR(20) NOT NULL,
    hospital_admission_date DATE NOT NULL,
    active BOOLEAN DEFAULT TRUE
);

COMMENT ON TABLE smart_health.doctors IS 'Entidad principal de médicos y profesionales de salud';
COMMENT ON COLUMN smart_health.doctors.doctor_id IS 'Identificador único del médico';
COMMENT ON COLUMN smart_health.doctors.internal_code IS 'Código interno del hospital para el médico';
COMMENT ON COLUMN smart_health.doctors.medical_license_number IS 'Número de licencia médica o colegiatura';
COMMENT ON COLUMN smart_health.doctors.first_name IS 'Nombres del médico';
COMMENT ON COLUMN smart_health.doctors.last_name IS 'Apellidos del médico';
COMMENT ON COLUMN smart_health.doctors.professional_email IS 'Correo electrónico profesional';
COMMENT ON COLUMN smart_health.doctors.phone_number IS 'Número de teléfono de contacto';
COMMENT ON COLUMN smart_health.doctors.hospital_admission_date IS 'Fecha de ingreso al hospital';
COMMENT ON COLUMN smart_health.doctors.active IS 'Indica si el médico está activo en el sistema';

-- Table: doctor_specialties
-- Brief: N:M relationship - A doctor can have multiple specialties
CREATE TABLE IF NOT EXISTS smart_health.doctor_specialties (
    doctor_specialty_id SERIAL PRIMARY KEY,
    doctor_id INTEGER NOT NULL,
    specialty_id INTEGER NOT NULL,
    certification_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    CONSTRAINT uq_doctor_specialty UNIQUE (doctor_id, specialty_id)
);

COMMENT ON TABLE smart_health.doctor_specialties IS 'Relación N:M entre médicos y especialidades';
COMMENT ON COLUMN smart_health.doctor_specialties.doctor_specialty_id IS 'Identificador único de la relación';
COMMENT ON COLUMN smart_health.doctor_specialties.doctor_id IS 'Referencia al médico';
COMMENT ON COLUMN smart_health.doctor_specialties.specialty_id IS 'Referencia a la especialidad';
COMMENT ON COLUMN smart_health.doctor_specialties.certification_date IS 'Fecha de certificación en la especialidad';
COMMENT ON COLUMN smart_health.doctor_specialties.is_active IS 'Indica si la especialidad está activa para el médico';

-- Table: doctor_addresses
-- Brief: Practice locations for doctors (offices, hospitals)
CREATE TABLE IF NOT EXISTS smart_health.doctor_addresses (
    doctor_address_id SERIAL PRIMARY KEY,
    doctor_id INTEGER NOT NULL,
    address_id INTEGER NOT NULL,
    address_type VARCHAR(20) NOT NULL,
    office_hours TEXT,
    is_primary BOOLEAN DEFAULT FALSE,
    CONSTRAINT uq_doctor_address UNIQUE (doctor_id, address_id)
);

COMMENT ON TABLE smart_health.doctor_addresses IS 'Lugares de práctica del médico (consultorios, hospitales)';
COMMENT ON COLUMN smart_health.doctor_addresses.doctor_address_id IS 'Identificador único de la relación';
COMMENT ON COLUMN smart_health.doctor_addresses.doctor_id IS 'Referencia al médico';
COMMENT ON COLUMN smart_health.doctor_addresses.address_id IS 'Referencia a la dirección';
COMMENT ON COLUMN smart_health.doctor_addresses.address_type IS 'Tipo de lugar (Office: Consultorio, Hospital: Hospital)';
COMMENT ON COLUMN smart_health.doctor_addresses.office_hours IS 'Horario de atención en este lugar';
COMMENT ON COLUMN smart_health.doctor_addresses.is_primary IS 'Indica si es el lugar principal de práctica';

-- ##################################################
-- #          MÓDULO DE ATENCIÓN - CORE             #
-- ##################################################

-- Table: rooms
-- Brief: Medical care rooms in the hospital
CREATE TABLE IF NOT EXISTS smart_health.rooms (
    room_id SERIAL PRIMARY KEY,
    room_name VARCHAR(50) NOT NULL UNIQUE,
    room_type VARCHAR(50) NOT NULL,
    capacity INTEGER,
    location VARCHAR(100),
    active BOOLEAN DEFAULT TRUE
);

COMMENT ON TABLE smart_health.rooms IS 'Salas de atención médica del hospital';
COMMENT ON COLUMN smart_health.rooms.room_id IS 'Identificador único de la sala';
COMMENT ON COLUMN smart_health.rooms.room_name IS 'Nombre de la sala';
COMMENT ON COLUMN smart_health.rooms.room_type IS 'Tipo de sala (consulta, emergencia, cirugía, etc.)';
COMMENT ON COLUMN smart_health.rooms.capacity IS 'Capacidad de personas en la sala';
COMMENT ON COLUMN smart_health.rooms.location IS 'Ubicación física de la sala';
COMMENT ON COLUMN smart_health.rooms.active IS 'Indica si la sala está activa';

-- Table: appointments
-- Brief: Scheduled medical appointments between patients and doctors
CREATE TABLE IF NOT EXISTS smart_health.appointments (
    appointment_id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL,
    doctor_id INTEGER NOT NULL,
    room_id INTEGER,
    appointment_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    appointment_type VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('Scheduled', 'Confirmed', 'Attended', 'Cancelled', 'NoShow')),
    reason TEXT,
    creation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_appointment_time CHECK (start_time < end_time)
);

COMMENT ON TABLE smart_health.appointments IS 'Citas médicas programadas entre pacientes y doctores';
COMMENT ON COLUMN smart_health.appointments.appointment_id IS 'Identificador único de la cita';
COMMENT ON COLUMN smart_health.appointments.patient_id IS 'Referencia al paciente';
COMMENT ON COLUMN smart_health.appointments.doctor_id IS 'Referencia al médico';
COMMENT ON COLUMN smart_health.appointments.room_id IS 'Referencia a la sala (opcional)';
COMMENT ON COLUMN smart_health.appointments.appointment_date IS 'Fecha de la cita';
COMMENT ON COLUMN smart_health.appointments.start_time IS 'Hora de inicio de la cita';
COMMENT ON COLUMN smart_health.appointments.end_time IS 'Hora de finalización de la cita';
COMMENT ON COLUMN smart_health.appointments.appointment_type IS 'Tipo de cita (consulta general, control, especialidad, etc.)';
COMMENT ON COLUMN smart_health.appointments.status IS 'Estado de la cita (Scheduled: Programada, Confirmed: Confirmada, Attended: Atendida, Cancelled: Cancelada, NoShow: No asistió)';
COMMENT ON COLUMN smart_health.appointments.reason IS 'Motivo de la cita';
COMMENT ON COLUMN smart_health.appointments.creation_date IS 'Fecha y hora de creación de la cita';

-- Table: medical_records
-- Brief: Medical history records for patients (clinical notes, diagnoses, procedures)
CREATE TABLE IF NOT EXISTS smart_health.medical_records (
    medical_record_id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL,
    doctor_id INTEGER NOT NULL,
    primary_diagnosis_id INTEGER,
    registration_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    record_type VARCHAR(50) NOT NULL,
    summary_text TEXT NOT NULL,
    vital_signs TEXT
);

COMMENT ON TABLE smart_health.medical_records IS 'Historia clínica - Registros médicos del paciente';
COMMENT ON COLUMN smart_health.medical_records.medical_record_id IS 'Identificador único del registro médico';
COMMENT ON COLUMN smart_health.medical_records.patient_id IS 'Referencia al paciente';
COMMENT ON COLUMN smart_health.medical_records.doctor_id IS 'Referencia al médico que registra';
COMMENT ON COLUMN smart_health.medical_records.primary_diagnosis_id IS 'Diagnóstico principal del registro';
COMMENT ON COLUMN smart_health.medical_records.registration_datetime IS 'Fecha y hora del registro';
COMMENT ON COLUMN smart_health.medical_records.record_type IS 'Tipo de registro (nota de evolución, historia inicial, etc.)';
COMMENT ON COLUMN smart_health.medical_records.summary_text IS 'Resumen o contenido del registro médico';
COMMENT ON COLUMN smart_health.medical_records.vital_signs IS 'Signos vitales registrados (presión arterial, temperatura, pulso, etc.)';

-- Table: record_diagnoses
-- Brief: N:M relationship - Multiple diagnoses can be associated with a medical record
CREATE TABLE IF NOT EXISTS smart_health.record_diagnoses (
    record_diagnosis_id SERIAL PRIMARY KEY,
    medical_record_id INTEGER NOT NULL,
    diagnosis_id INTEGER NOT NULL,
    diagnosis_type VARCHAR(20) NOT NULL CHECK (diagnosis_type IN ('Principal', 'Secondary', 'Differential')),
    note TEXT,
    CONSTRAINT uq_record_diagnosis UNIQUE (medical_record_id, diagnosis_id)
);

COMMENT ON TABLE smart_health.record_diagnoses IS 'Relación N:M entre registros médicos y diagnósticos';
COMMENT ON COLUMN smart_health.record_diagnoses.record_diagnosis_id IS 'Identificador único de la relación';
COMMENT ON COLUMN smart_health.record_diagnoses.medical_record_id IS 'Referencia al registro médico';
COMMENT ON COLUMN smart_health.record_diagnoses.diagnosis_id IS 'Referencia al diagnóstico';
COMMENT ON COLUMN smart_health.record_diagnoses.diagnosis_type IS 'Tipo de diagnóstico (Principal, Secondary: Secundario, Differential: Diferencial)';
COMMENT ON COLUMN smart_health.record_diagnoses.note IS 'Notas adicionales sobre el diagnóstico';

-- Table: prescriptions
-- Brief: Medical prescriptions generated during consultations
CREATE TABLE IF NOT EXISTS smart_health.prescriptions (
    prescription_id SERIAL PRIMARY KEY,
    medical_record_id INTEGER NOT NULL,
    medication_id INTEGER NOT NULL,
    dosage VARCHAR(100) NOT NULL,
    frequency VARCHAR(100) NOT NULL,
    duration VARCHAR(50) NOT NULL,
    instruction TEXT,
    prescription_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    alert_generated BOOLEAN DEFAULT FALSE
);

COMMENT ON TABLE smart_health.prescriptions IS 'Prescripciones médicas generadas en las consultas';
COMMENT ON COLUMN smart_health.prescriptions.prescription_id IS 'Identificador único de la prescripción';
COMMENT ON COLUMN smart_health.prescriptions.medical_record_id IS 'Referencia al registro médico';
COMMENT ON COLUMN smart_health.prescriptions.medication_id IS 'Referencia al medicamento';
COMMENT ON COLUMN smart_health.prescriptions.dosage IS 'Dosis del medicamento';
COMMENT ON COLUMN smart_health.prescriptions.frequency IS 'Frecuencia de administración';
COMMENT ON COLUMN smart_health.prescriptions.duration IS 'Duración del tratamiento';
COMMENT ON COLUMN smart_health.prescriptions.instruction IS 'Instrucciones adicionales para el paciente';
COMMENT ON COLUMN smart_health.prescriptions.prescription_date IS 'Fecha y hora de la prescripción';
COMMENT ON COLUMN smart_health.prescriptions.alert_generated IS 'Indica si se generó alguna alerta (por alergia o interacción)';

-- ##################################################
-- #            RELATIONSHIP DEFINITIONS            #
-- ##################################################

-- Relationships for MÓDULO GEOGRÁFICO

ALTER TABLE smart_health.municipalities ADD CONSTRAINT fk_municipalities_departments
    FOREIGN KEY (department_code) REFERENCES smart_health.departments (department_code)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE smart_health.addresses ADD CONSTRAINT fk_addresses_municipalities
    FOREIGN KEY (municipality_code) REFERENCES smart_health.municipalities (municipality_code)
    ON UPDATE CASCADE ON DELETE RESTRICT;

-- Relationships for PATIENT_ADDRESSES

ALTER TABLE smart_health.patient_addresses ADD CONSTRAINT fk_patient_addresses_patients
    FOREIGN KEY (patient_id) REFERENCES smart_health.patients (patient_id)
    ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE smart_health.patient_addresses ADD CONSTRAINT fk_patient_addresses_addresses
    FOREIGN KEY (address_id) REFERENCES smart_health.addresses (address_id)
    ON UPDATE CASCADE ON DELETE CASCADE;

-- Relationships for DOCTOR_ADDRESSES

ALTER TABLE smart_health.doctor_addresses ADD CONSTRAINT fk_doctor_addresses_doctors
    FOREIGN KEY (doctor_id) REFERENCES smart_health.doctors (doctor_id)
    ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE smart_health.doctor_addresses ADD CONSTRAINT fk_doctor_addresses_addresses
    FOREIGN KEY (address_id) REFERENCES smart_health.addresses (address_id)
    ON UPDATE CASCADE ON DELETE CASCADE;

-- Relationships for PATIENT_DOCUMENTS
-- Brief: Catalog of identification document types (CC, CE, PA, TI, etc.)

ALTER TABLE smart_health.patients ADD CONSTRAINT fk_patient_document_type_id
    FOREIGN KEY (document_type_id) REFERENCES smart_health.document_types (document_type_id)
    ON UPDATE CASCADE ON DELETE CASCADE;    

-- Relationships for PATIENT_PHONES

ALTER TABLE smart_health.patient_phones ADD CONSTRAINT fk_patient_phones_patients
    FOREIGN KEY (patient_id) REFERENCES smart_health.patients (patient_id)
    ON UPDATE CASCADE ON DELETE CASCADE;

-- Relationships for PATIENT_ALLERGIES

ALTER TABLE smart_health.patient_allergies ADD CONSTRAINT fk_patient_allergies_patients
    FOREIGN KEY (patient_id) REFERENCES smart_health.patients (patient_id)
    ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE smart_health.patient_allergies ADD CONSTRAINT fk_patient_allergies_medications
    FOREIGN KEY (medication_id) REFERENCES smart_health.medications (medication_id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

-- Relationships for DOCTOR_SPECIALTIES

ALTER TABLE smart_health.doctor_specialties ADD CONSTRAINT fk_doctor_specialties_doctors
    FOREIGN KEY (doctor_id) REFERENCES smart_health.doctors (doctor_id)
    ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE smart_health.doctor_specialties ADD CONSTRAINT fk_doctor_specialties_specialties
    FOREIGN KEY (specialty_id) REFERENCES smart_health.specialties (specialty_id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

-- Relationships for APPOINTMENTS

ALTER TABLE smart_health.appointments ADD CONSTRAINT fk_appointments_patients
    FOREIGN KEY (patient_id) REFERENCES smart_health.patients (patient_id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE smart_health.appointments ADD CONSTRAINT fk_appointments_doctors
    FOREIGN KEY (doctor_id) REFERENCES smart_health.doctors (doctor_id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE smart_health.appointments ADD CONSTRAINT fk_appointments_rooms
    FOREIGN KEY (room_id) REFERENCES smart_health.rooms (room_id)
    ON UPDATE CASCADE ON DELETE SET NULL;

-- Relationships for MEDICAL_RECORDS

ALTER TABLE smart_health.medical_records ADD CONSTRAINT fk_medical_records_patients
    FOREIGN KEY (patient_id) REFERENCES smart_health.patients (patient_id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE smart_health.medical_records ADD CONSTRAINT fk_medical_records_doctors
    FOREIGN KEY (doctor_id) REFERENCES smart_health.doctors (doctor_id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE smart_health.medical_records ADD CONSTRAINT fk_medical_records_diagnoses
    FOREIGN KEY (primary_diagnosis_id) REFERENCES smart_health.diagnoses (diagnosis_id)
    ON UPDATE CASCADE ON DELETE SET NULL;

-- Relationships for RECORD_DIAGNOSES

ALTER TABLE smart_health.record_diagnoses ADD CONSTRAINT fk_record_diagnoses_medical_records
    FOREIGN KEY (medical_record_id) REFERENCES smart_health.medical_records (medical_record_id)
    ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE smart_health.record_diagnoses ADD CONSTRAINT fk_record_diagnoses_diagnoses
    FOREIGN KEY (diagnosis_id) REFERENCES smart_health.diagnoses (diagnosis_id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

-- Relationships for PRESCRIPTIONS

ALTER TABLE smart_health.prescriptions ADD CONSTRAINT fk_prescriptions_medical_records
    FOREIGN KEY (medical_record_id) REFERENCES smart_health.medical_records (medical_record_id)
    ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE smart_health.prescriptions ADD CONSTRAINT fk_prescriptions_medications
    FOREIGN KEY (medication_id) REFERENCES smart_health.medications (medication_id)
    ON UPDATE CASCADE ON DELETE RESTRICT;

-- ##################################################
-- #                 END OF SCRIPT                  #
-- ##################################################