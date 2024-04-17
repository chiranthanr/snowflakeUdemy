// Creating a stage object to create a folder to unload the data from snowflake to GCP
CREATE OR REPLACE STAGE MANAGED_DB.EXTERNAL_STAGES.GCP_STAGE_UNLOAD
    STORAGE_INTEGRATION = GCP_INTEGRATION
    URL = "gcs://snowflakeudemygcpbucket/country_happiness"
    FILE_FORMAT = MANAGED_DB.FILE_FORMATS.CSV_FILEFORMAT

// Previewing the table which needs to be unloaded into GCP
SELECT * FROM MANAGED_DB.PUBLIC.GCP_CSV_TABLE

//Now unloading the data into the newly created GCP bucket
COPY INTO @MANAGED_DB.EXTERNAL_STAGES.GCP_STAGE_UNLOAD
FROM
MANAGED_DB.PUBLIC.GCP_CSV_TABLE