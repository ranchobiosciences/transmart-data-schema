--Deleting existing user and schema for avoiding errors
DROP SCHEMA IF EXISTS tm_data CASCADE;
DROP ROLE IF EXISTS tm_data;

--Creating user and schema
CREATE ROLE tm_data LOGIN PASSWORD 'tm_data';
CREATE SCHEMA AUTHORIZATION tm_data;
--Granting access permissions
GRANT ALL ON SCHEMA tm_data TO tm_data;

--1) List of all studies
CREATE OR REPLACE VIEW tm_data.studies AS
SELECT 
	DISTINCT(sourcesystem_cd) AS study_id 
FROM 
	i2b2demodata.concept_dimension;
--Granting access permissions
GRANT SELECT ON tm_data.studies TO tm_data;

--2) List of all patients
CREATE OR REPLACE VIEW tm_data.studies_patients AS
SELECT
	pd.patient_num AS patient_num,
	substring(pd.sourcesystem_cd from '^[^\:]*\:(.*)$') AS subject_id,
	pd.birth_date AS birth_date,
	pd.death_date AS death_date,
	pd.sex_cd AS sex,
	pd.age_in_years_num AS AGE,
	pd.language_cd AS language,
	pd.race_cd AS race,
	pd.marital_status_cd AS marital_status,
	pd.religion_cd AS religion,
	pd.zip_cd AS zip_code,
	pd.update_date AS update_date
FROM
	i2b2demodata.patient_dimension pd;
--Granting access permissions
GRANT SELECT ON tm_data.studies_patients TO tm_data;

--3) List of clinical attributes
CREATE OR REPLACE VIEW tm_data.studies_clinical_attributes AS
SELECT DISTINCT
	cd.sourcesystem_cd AS study_id,
	CASE
		WHEN of.valtype_cd = 'N' THEN 'NUMERIC'
		WHEN of.valtype_cd = 'T' THEN 'TEXT'
		ELSE 'UNDEFINED'
	END AS data_type,
	CASE
		WHEN of.valtype_cd = 'N' THEN cd.concept_path
		ELSE substring(cd.concept_path from '^(.*)\\[^\\]*\\$')  
	END AS clinical_attribute,
	cd.concept_cd AS concept_cd
FROM 
	i2b2demodata.concept_dimension cd
	INNER JOIN i2b2demodata.observation_fact of ON cd.concept_cd = of.concept_cd
WHERE
(	-- Exclude expression data
	of.concept_cd NOT IN (
		SELECT DISTINCT sm.concept_code FROM deapp.de_subject_sample_mapping sm
	)
);
--Granting access permissions
GRANT SELECT ON tm_data.studies_clinical_attributes TO tm_data;

--4) List of clinical values
CREATE OR REPLACE VIEW tm_data.studies_clinical_values AS
SELECT 
	cd.sourcesystem_cd AS study_id,
	of.patient_num AS patient_num,
	substring(pd.sourcesystem_cd from '^[^\:]*\:(.*)$') AS subject_id,
	CASE
		WHEN of.valtype_cd = 'N' THEN 'NUMERIC'
		WHEN of.valtype_cd = 'T' THEN 'TEXT'
		ELSE 'UNDEFINED'
	END AS data_type,
	CASE 
		WHEN of.valtype_cd = 'N' THEN trim(to_char(of.nval_num, '999D9'))
		WHEN of.valtype_cd = 'T' THEN of.tval_char
		ELSE NULL
	END AS data_value,
	CASE
		WHEN of.valtype_cd = 'N' THEN cd.concept_path
		ELSE substring(cd.concept_path from '^(.*)\\[^\\]*\\$')  
	END AS clinical_attribute,
	of.sample_cd AS sample_cd,
	cd.concept_cd AS concept_cd,
	of.update_date AS update_date
FROM 
	i2b2demodata.concept_dimension cd
	INNER JOIN i2b2demodata.observation_fact of ON cd.concept_cd = of.concept_cd
	INNER JOIN i2b2demodata.patient_dimension pd ON pd.patient_num = of.patient_num
WHERE
(	-- Exclude expression data
	of.concept_cd NOT IN (
		SELECT DISTINCT sm.concept_code FROM deapp.de_subject_sample_mapping sm
	)
);
--Granting access permissions
GRANT SELECT ON tm_data.studies_clinical_values TO tm_data;