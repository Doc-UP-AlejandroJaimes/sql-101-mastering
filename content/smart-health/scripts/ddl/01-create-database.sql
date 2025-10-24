-- ##################################################
-- #         SMARTHEALTH DATABASE CREATION SCRIPT       #
-- ##################################################

-- RUN IN POSTGRES - POSTGRES

-- 01. Create user
CREATE USER sm_admin WITH PASSWORD '******';

-- 02. Create database (with ENCODING= 'UTF8', TEMPLATE=Template0, OWNER: music_admin)
CREATE DATABASE smarthdb WITH 
    ENCODING='UTF8' 
    LC_COLLATE='es_CO.UTF-8' 
    LC_CTYPE='es_CO.UTF-8' 
    TEMPLATE=template0 
    OWNER = sm_admin;

-- 03. Grant privileges
GRANT ALL PRIVILEGES ON DATABASE smarthdb TO sm_admin;