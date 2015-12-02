# TM data
TM data - set of scripts for easy and user-friendly view of tranSMART data.

  - sql folder contains SQL scripts for Oracle and PostgreSQL databases that create necessary views;
  - scripts folder contains R and MATLAB scripts.

# Installing for Oracle
From `sql/oracle/` run script **tm_data_oracle.sql** using SQL Developer of sqlplus with database user `system`.

This script creates new tablespace tm_data with following views:
  - tm_data.studies - list of all studies;
  - tm_data.studies_patients - list of all patients;
  - tm_data.studies_clinical_attributes - list of clinical attributes;
  - tm_data.studies_clinical_values - list of clinical values;
  - tm_data.studies_clinical_values_mat - list of all values on Materialized View;

and indexes for following clinical values:
  - tm_data.IDX_CVALS_1 - Patient number;
  - tm_data.IDX_CVALS_2 - Subject id;
  - tm_data.IDX_CVALS_3 - Clinical attribute;
  - tm_data.IDX_CVALS_4 - Data value.
  
# Installing for PostgreSQL
Coming soon...

# Samples
R-script **tm_data.R** and MATLAB script **tm_data.m** demonstrates how to get and how to use data from our views (on Oracle database) as time series.