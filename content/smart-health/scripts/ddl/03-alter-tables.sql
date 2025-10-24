-- ##################################################
-- #         SMART HEALTH ALTER TABLE SCRIPT        #
-- ##################################################
-- This script contains one alteration to enhance the Smart Health database structure,
-- including adding new columns, modifying constraints, and implementing additional
-- validation rules to better support healthcare management requirements and improve
-- data integrity across the system.

-- ##################################################
-- #                ALTERATIONS                     #
-- ##################################################

-- Add a 'blood_type' column to the PATIENTS table to store patient blood type
-- This is critical medical information needed for emergencies and transfusions
ALTER TABLE smart_health.patients 
ADD COLUMN blood_type VARCHAR(5) CHECK (blood_type IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'));

COMMENT ON COLUMN smart_health.patients.blood_type IS 'Tipo de sangre del paciente (A+, A-, B+, B-, AB+, AB-, O+, O-)';

-- ============================================
-- CONSTRAINTS PARA ALERGIAS
-- ============================================
ALTER TABLE smart_health.patient_allergies
ADD CONSTRAINT chk_patient_severity
CHECK (severity IN ('Leve', 'Moderada', 'Grave', 'Crítica', 'Letal'));

-- ============================================
-- CONSTRAINTS PARA TIPOS DE DIRECCIONES
-- ============================================

-- Constraint para tipos de direcciones de pacientes
ALTER TABLE smart_health.patient_addresses
ADD CONSTRAINT chk_patient_address_type 
CHECK (address_type IN ('Casa', 'Trabajo', 'Facturación', 'Temporal', 'Contacto Emergencia'));

-- Constraint para tipos de direcciones de doctores
ALTER TABLE smart_health.doctor_addresses
ADD CONSTRAINT chk_doctor_address_type 
CHECK (address_type IN ('Casa', 'Consultorio', 'Hospital', 'Clínica', 'Administrativa'));

-- ##################################################
-- #                 END OF SCRIPT                  #
-- ##################################################