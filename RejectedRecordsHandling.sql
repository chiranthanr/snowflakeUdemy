USE COPY_DB.PUBLIC

CREATE TABLE ORDERS2(
    ORDER_ID VARCHAR,
    AMOUNT INT,
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR,
    SUBCATEGORY VARCHAR
)

LIST @AWS_STAGE_COPY2

COPY INTO ORDERS2
FROM @AWS_STAGE_COPY2
file_format = (type='csv' field_delimiter=',' skip_header =1 )
pattern = '.*Order.*'
VALIDATION_MODE = RETURN_ERRORS

//Copying rejected results into a new table
CREATE TABLE rejected AS(
    SELECT * FROM TABLE(result_scan('01b387bf-0305-102e-0004-ea7f0003c1fa'))
)
//Extracting only the rejected rows
CREATE TABLE rejected_records AS(
    SELECT rejected_record FROM TABLE (RESULT_SCAN('01b387bf-0305-102e-0004-ea7f0003c1fa'))
)
SELECT * FROM rejected_records

//Using the function last_query_id() instead of using a specific number
INSERT INTO REJECTED_RECORDS
SELECT rejected_record FROM TABLE (RESULT_SCAN(last_query_id()))

//Using the validate function when ON_ERROR Continue copy option is used.
SELECT * FROM ORDERS2

COPY INTO ORDERS2
FROM @AWS_STAGE_COPY2
file_format = (type='csv' field_delimiter=',' skip_header=1)
pattern = '.*Order.*'
ON_ERROR = 'CONTINUE'

//seeing the error rows that were identified when using the continue option
CREATE OR REPLACE TABLE REJECTED AS(
SELECT REJECTED_RECORD FROM TABLE(VALIDATE(ORDERS2,JOB_ID => '01b387d3-0305-1169-0004-ea7f00047102'))
)

//Now formatting the result from the rejected table and storing as a new table
SELECT * FROM REJECTED

CREATE TABLE REJECTED_VALUES AS( SELECT 
    SPLIT_PART(rejected_record,',',1) as ORDER_ID,
    SPLIT_PART(rejected_record,',',2) as AMOUNT,
    SPLIT_PART(rejected_record,',',3) as PROFIT,
    SPLIT_PART(rejected_record,',',4) as QUANTITY,
    SPLIT_PART(rejected_record,',',5) as CATEGORY,
    SPLIT_PART(rejected_record,',',6) as SUBCATEGORY
    FROM REJECTED
)
SELECT * FROM REJECTED_VALUES