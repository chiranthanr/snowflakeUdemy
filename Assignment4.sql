USE EXERCISE_DB.PUBLIC

DESC TABLE CUSTOMERS
SELECT * FROM CUSTOMERS

CREATE OR REPLACE STAGE EXERCISE_DB.EXTERNAL_STAGES.EX4_STAGE
    url = 's3://snowflake-assignments-mc/fileformat/'

LIST @EXERCISE_DB.EXTERNAL_STAGES.EX4_STAGE

CREATE SCHEMA FILE_FORMATS

CREATE file format EXERCISE_DB.FILE_FORMATS.exercise_file_format
TYPE = CSV
FIELD_DELIMITER = '|'
SKIP_HEADER = 1

//Copying the customer data from the exercise stage to the customer table
CREATE OR REPLACE TABLE EXERCISE_DB.PUBLIC.CUSTOMERS(
    ID INT,
    first_name VARCHAR,
    last_name VARCHAR,
    email VARCHAR,
    age INT,
    city VARCHAR
);

SELECT * FROM CUSTOMERS

COPY INTO EXERCISE_DB.PUBLIC.CUSTOMERS
FROM @EXERCISE_DB.EXTERNAL_STAGES.EX4_STAGE
file_format = (FORMAT_NAME = EXERCISE_DB.FILE_FORMATS.EXERCISE_FILE_FORMAT)
files = ('customers4.csv')

SELECT * FROM CUSTOMERS