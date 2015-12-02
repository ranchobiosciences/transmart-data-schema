--Granting dba role to system user, if require
GRANT dba to system;

--Comment this drop rows if it is first launch of this script
DROP USER tm_data CASCADE;
DROP TABLESPACE tm_data INCLUDING CONTENTS AND DATAFILES;

--Creating tablespace tm_data
CREATE TABLESPACE tm_data DATAFILE 'tm_data.dbf' SIZE 1024K
    EXTENT MANAGEMENT LOCAL UNIFORM SIZE 128K;
--Creating user for this tablespace
CREATE USER tm_data IDENTIFIED BY tm_data
  DEFAULT TABLESPACE tm_data;
  
--Grant options
GRANT CREATE SESSION to tm_data;
GRANT SELECT ON I2B2DEMODATA.CONCEPT_DIMENSION to tm_data;
GRANT SELECT ON I2B2DEMODATA.PATIENT_DIMENSION to tm_data;
GRANT SELECT ON I2B2DEMODATA.OBSERVATION_FACT to tm_data;
GRANT SELECT ON deapp.de_subject_sample_mapping to tm_data;
  
--1) List of all studies
CREATE OR REPLACE VIEW tm_data.studies AS
SELECT 
	DISTINCT(sourcesystem_cd) as study_id 
FROM 
	I2B2DEMODATA.CONCEPT_DIMENSION;

--2) List of all patients
CREATE OR REPLACE VIEW tm_data.studies_patients AS
SELECT
	pd.patient_num AS patient_num,
  REGEXP_SUBSTR(pd.sourcesystem_cd, '([^\:]*)$') AS subject_id,
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

--3) List of clinical attributes
CREATE OR REPLACE VIEW tm_data.studies_clinical_attributes AS
SELECT DISTINCT
	cd.sourcesystem_cd AS study_id,
  CASE obf.valtype_cd
		WHEN 'N' THEN 'NUMERIC'
		WHEN 'T' THEN 'TEXT'
		ELSE 'UNDEFINED'
	END AS data_type,
  CASE obf.valtype_cd 
		WHEN 'N' THEN cd.concept_path
		ELSE REGEXP_SUBSTR(cd.concept_path, '^(.*)\\[^\\]*\\$')  
	END AS clinical_attribute,
  cd.concept_cd AS concept_cd
FROM 
	i2b2demodata.concept_dimension cd
	INNER JOIN i2b2demodata.observation_fact obf ON cd.concept_cd = obf.concept_cd
WHERE
(	--Exclude expression data
	obf.concept_cd NOT IN (
		SELECT DISTINCT sm.concept_code FROM deapp.de_subject_sample_mapping sm
	)
);

--4) List of clinical values
CREATE OR REPLACE VIEW tm_data.studies_clinical_values AS
SELECT 
	cd.sourcesystem_cd AS study_id,
	obf.patient_num AS patient_num,
	REGEXP_SUBSTR(pd.sourcesystem_cd, '([^\:]*)$') AS subject_id,
	CASE obf.valtype_cd
		WHEN 'N' THEN 'NUMERIC'
		WHEN 'T' THEN 'TEXT'
		ELSE 'UNDEFINED'
	END AS data_type,
	CASE obf.valtype_cd 
		WHEN 'N' THEN trim(to_char(obf.nval_num))
		WHEN 'T' THEN obf.tval_char
		ELSE NULL
	END AS data_value,
	CASE obf.valtype_cd 
		WHEN 'N' THEN cd.concept_path
		ELSE REGEXP_SUBSTR(cd.concept_path, '^(.*)\\[^\\]*\\$')  
	END AS clinical_attribute,
	obf.sample_cd AS sample_cd,
	cd.concept_cd AS concept_cd,
	obf.update_date AS update_date
FROM 
	i2b2demodata.concept_dimension cd
	INNER JOIN i2b2demodata.observation_fact obf ON cd.concept_cd = obf.concept_cd
  INNER JOIN i2b2demodata.patient_dimension pd ON pd.patient_num = obf.patient_num
WHERE
(	--Exclude expression data
	obf.concept_cd NOT IN (
		SELECT DISTINCT sm.concept_code FROM deapp.de_subject_sample_mapping sm
	)
);

--Grant options
GRANT CREATE ANY TABLE,  CREATE ANY MATERIALIZED VIEW to tm_data;
GRANT SELECT ON i2b2demodata.concept_dimension TO tm_data;
GRANT SELECT ON i2b2demodata.observation_fact  TO tm_data;
GRANT SELECT ON i2b2demodata.patient_dimension TO tm_data;
GRANT unlimited tablespace to tm_data;

--5) List of all values on MATERIALIZED VIEW
--Note: update for that view is on demand
CREATE MATERIALIZED VIEW tm_data.studies_clinical_values_mat
TABLESPACE TRANSMART
BUILD IMMEDIATE
REFRESH ON DEMAND
AS
SELECT 
	cd.sourcesystem_cd AS study_id,
	obf.patient_num AS patient_num,
	REGEXP_SUBSTR(pd.sourcesystem_cd, '([^\:]*)$') AS subject_id,
	CASE obf.valtype_cd
		WHEN 'N' THEN 'NUMERIC'
		WHEN 'T' THEN 'TEXT'
		ELSE 'UNDEFINED'
	END AS data_type,
	CASE obf.valtype_cd 
		WHEN 'N' THEN trim(to_char(obf.nval_num))
		WHEN 'T' THEN obf.tval_char
		ELSE NULL
	END AS data_value,
	CASE obf.valtype_cd 
		WHEN 'N' THEN cd.concept_path
		ELSE REGEXP_SUBSTR(cd.concept_path, '^(.*)\\[^\\]*\\$')  
	END AS clinical_attribute,
	obf.sample_cd AS sample_cd,
	cd.concept_cd AS concept_cd,
	obf.update_date AS update_date
FROM 
	i2b2demodata.concept_dimension cd
	INNER JOIN i2b2demodata.observation_fact obf ON cd.concept_cd = obf.concept_cd
  INNER JOIN i2b2demodata.patient_dimension pd ON pd.patient_num = obf.patient_num
WHERE
(	--Exclude expression data
	obf.concept_cd NOT IN (
		SELECT DISTINCT sm.concept_code FROM deapp.de_subject_sample_mapping sm
	)
);

--6) Indexes
CREATE INDEX tm_data.IDX_CVALS_1 ON TM_DATA.studies_clinical_values_mat(patient_num) tablespace INDX;
CREATE INDEX tm_data.IDX_CVALS_2 ON TM_DATA.studies_clinical_values_mat(subject_id) tablespace INDX;
CREATE INDEX tm_data.IDX_CVALS_3 ON TM_DATA.studies_clinical_values_mat(clinical_attribute) tablespace INDX;
CREATE INDEX tm_data.IDX_CVALS_4 ON TM_DATA.studies_clinical_values_mat(data_value) tablespace INDX;