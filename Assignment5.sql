USE EXERCISE_DB
SHOW SCHEMAS

ALTER TABLE EXERCISE_DB.PUBLIC.CUSTOMERS
RENAME COLUMN ID TO CUSTOMER_ID

DESC TABLE CUSTOMERS

CREATE STAGE EXERCISE_DB.EXTERNAL_STAGES.aws_example1
    url = 's3://snowflake-assignments-mc/copyoptions/example1'

CREATE file format EXERCISE_DB.FILE_FORMATS.example1
TYPE = 'csv'
FIELD_DELIMITER = ','
SKIP_HEADER = 1

LIST @EXERCISE_DB.EXTERNAL_STAGES.aws_example1

COPY INTO CUSTOMERS
FROM @EXERCISE_DB.EXTERNAL_STAGES.aws_example1
file_format = (FORMAT_NAME=EXERCISE_DB.FILE_FORMATS.example1)
pattern = '.*'
//VALIDATION_MODE = RETURN_ERRORS
ON_ERROR = 'CONTINUE'

TRUNCATE CUSTOMERS
SELECT * FROM CUSTOMERS