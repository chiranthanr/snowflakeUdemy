DESC PIPE MANAGED_DB.PIPES.EMPLOYEE_PIPE

SHOW PIPES

SHOW PIPES in database MANAGED_DB

SHOW PIPES in schema MANAGED_DB.PIPES

SHOW PIPES like '%emp%' in database MANAGED_DB

// If we want to change the pipe to load into a new table then the following steps need to be done
// 1. Pause the existing pipe
// 2. Recreate the pipe by using CREATE OR REPLACE PIPE and replace with the new table name in the COPY INTO section
// 3. Manually load the files from the stage into the new table
// 4. Resume the pipe

//Creating a new table
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.employees2(
    ID int,
    first_name varchar,
    last_name varchar,
    email varchar,
    location varchar,
    department varchar
)

//Pausing the pipe
ALTER PIPE MANAGED_DB.PIPES.EMPLOYEE_PIPE SET PIPE_EXECUTION_PAUSED = TRUE

//Checking if the pause was successful
SELECT SYSTEM$PIPE_STATUS('MANAGED_DB.PIPES.employee_pipe')

// Recreating the pipe with new table for copy into
CREATE OR REPLACE PIPE MANAGED_DB.PIPES.EMPLOYEE_PIPE
AUTO_INGEST = TRUE
AS
COPY INTO OUR_FIRST_DB.PUBLIC.EMPLOYEES2
FROM @MANAGED_DB.EXTERNAL_STAGES.STAGE_CSV_SNOWPIPE

// Manually load all the files from the stage to the new table
LIST @MANAGED_DB.EXTERNAL_STAGES.STAGE_CSV_SNOWPIPE

COPY INTO OUR_FIRST_DB.PUBLIC.EMPLOYEES2
FROM @MANAGED_DB.EXTERNAL_STAGES.STAGE_CSV_SNOWPIPE

// Now resuming the PIPE execution to enable future automated loads
ALTER PIPE MANAGED_DB.PIPES.EMPLOYEE_PIPE SET PIPE_EXECUTION_PAUSED = FALSE






