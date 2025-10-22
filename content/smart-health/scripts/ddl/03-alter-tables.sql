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
ALTER TABLE patients 
ADD COLUMN blood_type VARCHAR(5) CHECK (blood_type IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'));

COMMENT ON COLUMN patients.blood_type IS 'Tipo de sangre del paciente (A+, A-, B+, B-, AB+, AB-, O+, O-)';

-- ##################################################
-- #                 END OF SCRIPT                  #
-- ##################################################