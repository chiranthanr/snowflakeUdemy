USE EXERCISE_DB;
CREATE OR REPLACE SCHEMA EXTERNAL_STAGES;
CREATE OR REPLACE STAGE EXERCISE_DB.EXTERNAL_STAGES.assignment3
    url = 's3://snowflake-assignments-mc/loadingdata/';

USE EXERCISE_DB.EXTERNAL_STAGES;
DESC STAGE assignment3;

LIST @assignment3;

COPY INTO EXERCISE_DB.PUBLIC.CUSTOMERS
FROM @assignment3
file_format = (type = csv field_delimiter = ';' skip_header=1);

SELECT COUNT (*) FROM CUSTOMERS