USE OUR_FIRST_DB.PUBLIC

CREATE TABLE OUR_FIRST_DB.PUBLIC.EMPLOYEES(
    ID int,
    first_name varchar,
    last_name varchar,
    email varchar,
    location varchar,
    department varchar
)

//Creating a file format object for CSV
CREATE OR REPLACE FILE FORMAT MANAGED_DB.FILE_FORMATS.CSV_FILEFORMAT
    TYPE = CSV
    SKIP_HEADER = 1
    FIELD_DELIMITER = ','
    NULL_IF = ('NULL','null')
    EMPTY_FIELD_AS_NULL = True

//MOdifying the storage allowed locations to include the snowpipe folder
ALTER STORAGE INTEGRATION gcp_integration
SET STORAGE_ALLOWED_LOCATIONS = ("gcs://snowflakeudemygcpbucket/", "gcs://snowflakeudemygcpbucket/snowpipe/")

//Checking AWS S3 integration object
DESC INTEGRATION S3_INT
    
//Creating a stage from S3 "snowpipe" folder which has already been setup in AWS s3 bucket
CREATE OR REPLACE STAGE MANAGED_DB.EXTERNAL_STAGES.STAGE_CSV_SNOWPIPE
    STORAGE_INTEGRATION = s3_int
    url = "s3://snowflakeudemys3bucket/csv/snowpipe/"
    file_format = MANAGED_DB.FILE_FORMATS.CSV_FILEFORMAT

list @MANAGED_DB.EXTERNAL_STAGES.STAGE_CSV_SNOWPIPE



