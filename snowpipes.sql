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

//First step to create a pipe is to test copy into the target table from the external stage
COPY INTO OUR_FIRST_DB.PUBLIC.EMPLOYEES
FROM @MANAGED_DB.EXTERNAL_STAGES.STAGE_CSV_SNOWPIPE

SELECT count(*) FROM OUR_FIRST_DB.PUBLIC.EMPLOYEES

//Creating the pipe
CREATE OR REPLACE PIPE MANAGED_DB.PIPES.employee_pipe
AUTO_INGEST = TRUE
AS
COPY INTO OUR_FIRST_DB.PUBLIC.EMPLOYEES
FROM @MANAGED_DB.EXTERNAL_STAGES.STAGE_CSV_SNOWPIPE

// On running describe, we can get the "notification channel" to update in AWS S3 bucket and set notifications
// so that whenever a file gets added or deleted in the S3 bucket, it sends a trigger notification to the pipe
DESC PIPE MANAGED_DB.PIPES.employee_pipe

// Error handling with pipes when they fail to load. First we modify the file format in the stage so that the pipe fails to load a regular csv
CREATE OR REPLACE FILE FORMAT MANAGED_DB.FILE_FORMATS.CSV_FILEFORMAT
    TYPE = CSV
    SKIP_HEADER = 1
    FIELD_DELIMITER = ','
    NULL_IF = ('NULL','null')
    EMPTY_FIELD_AS_NULL = True
// Checking whether the 3rd file has been notified from S3
ALTER PIPE employee_pipe REFRESH

//To check the status of the pipe whether it is working. Running this shows that all 3 files were notified
// to the pipe and there are no pending files. THis means that the 3rd file has not loaded because the target table still does not have any additional rows.
SELECT SYSTEM$PIPE_STATUS('employee_pipe')

// To view file level error messages from the pipe loading - this command will show all the error messages in the last two hours i.e., as specified in the function arguements

SELECT * FROM TABLE(VALIDATE_PIPE_LOAD(
    pipe_name => 'managed_db.pipes.employee_pipe',
    START_TIME => DATEADD(HOUR,-2,current_timestamp)))

//Another option to troubleshoot is to see the copy history of the target table and check

SELECT * FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
    TABLE_NAME => 'OUR_FIRST_DB.PUBLIC.employees',
    START_TIME => DATEADD(HOUR,-2,current_timestamp)
))



SELECT * FROM OUR_FIRST_DB.PUBLIC.employees