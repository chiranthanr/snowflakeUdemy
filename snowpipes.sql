USE OUR_FIRST_DB.PUBLIC

CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.EMPLOYEES(
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

//Creating a schema specifically for Pipes
CREATE OR REPLACE SCHEMA MANAGED_DB.PIPES;

//First step to create a pip is to test copy into the target table from the external stage
COPY INTO OUR_FIRST_DB.PUBLIC.EMPLOYEES
FROM @MANAGED_DB.EXTERNAL_STAGES.STAGE_CSV_SNOWPIPE

SELECT count(*) FROM OUR_FIRST_DB.PUBLIC.EMPLOYEES

//Creating the pipe
CREATE OR REPLACE PIPE MANAGED_DB.PIPES.employee_pipe
AUTO_INGEST = TRUE
AS
COPY INTO OUR_FIRST_DB.PUBLIC.EMPLOYEES
FROM @MANAGED_DB.EXTERNAL_STAGES.STAGE_CSV_SNOWPIPE

DESC PIPE MANAGED_DB.PIPES.employee_pipe

// Error handling with pipes when they fail to load. First we modify the file format in the stage so that the pipe fails to load a regular csv
CREATE OR REPLACE FILE FORMAT MANAGED_DB.FILE_FORMATS.CSV_FILEFORMAT
    TYPE = CSV
    SKIP_HEADER = 1
    FIELD_DELIMITER = '|'
    NULL_IF = ('NULL','null')
    EMPTY_FIELD_AS_NULL = True