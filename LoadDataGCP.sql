//Create an integration object to connect to GCP
CREATE STORAGE INTEGRATION gcp_integration
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = GCS
    ENABLED = TRUE
    STORAGE_ALLOWED_LOCATIONS = ('gcs://snowflakeudemygcpbucket','gcs://snowflakeudemygcpbucketjson')

DESC INTEGRATION gcp_integration

// Next step is to create a file format and stage object using the integration object
CREATE OR REPLACE FILE FORMAT MANAGED_DB.FILE_FORMATS.GCP_CSV_FORMAT
    TYPE = CSV
    FIELD_DELIMITER = ","
    SKIP_HEADER = 1

CREATE OR REPLACE STAGE MANAGED_DB.EXTERNAL_STAGES.GCP_STAGE_CSV
    STORAGE_INTEGRATION = gcp_integration
    url = 'gcs://snowflakeudemygcpbucket'
    file_format = MANAGED_DB.FILE_FORMATS.GCP_CSV_FORMAT

LIST @MANAGED_DB.EXTERNAL_STAGES.GCP_STAGE_CSV

// Loading the csv file from the gcp bucket