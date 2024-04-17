USE MANAGED_DB.EXTERNAL_STAGES

CREATE OR REPLACE STAGE MANAGED_DB.EXTERNAL_STAGES.JSONSTAGE
    url = 's3://bucketsnowflake-jsondemo'

LIST @MANAGED_DB.EXTERNAL_STAGES.JSONSTAGE
    
CREATE OR REPLACE file format MANAGED_DB.FILE_FORMATS.JSONFORMAT
    TYPE = JSON

CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.JSON_RAW(
    raw_file variant
);

DESC TABLE OUR_FIRST_DB.PUBLIC.JSON_RAW

COPY INTO OUR_FIRST_DB.PUBLIC.JSON_RAW
FROM @MANAGED_DB.EXTERNAL_STAGES.JSONSTAGE
file_format = (FORMAT_NAME = MANAGED_DB.FILE_FORMATS.JSONFORMAT)
pattern = '.*json.*'

SELECT * FROM OUR_FIRST_DB.PUBLIC.JSON_RAW

// Extracting columns as subset of the data from the json raw column along with proper data format and loading to a new table.

CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.JSON_CLEAN AS(
SELECT RAW_FILE:first_name::varchar as first_name,
       RAW_FILE:last_name::varchar as last_name,
       RAW_FILE:city::varchar as city
FROM OUR_FIRST_DB.PUBLIC.JSON_RAW)

SELECT * FROM OUR_FIRST_DB.PUBLIC.JSON_CLEAN

//Dealing with nested JSON columns. In this example the "JOB" column is a nested object with multiple attributes like last salary etc.
// and 'PREV_COMPANY field has an arry of previous companies'
SELECT RAW_FILE:job FROM OUR_FIRST_DB.PUBLIC.JSON_RAW

//First handling nested objects for a parent field in the RAW_FILE
SELECT RAW_FILE:job.salary::INT as salary FROM OUR_FIRST_DB.PUBLIC.JSON_RAW
SELECT RAW_FILE:job.title::VARCHAR as title FROM OUR_FIRST_DB.PUBLIC.JSON_RAW

//Handling Arrays
SELECT RAW_FILE:prev_company FROM OUR_FIRST_DB.PUBLIC.JSON_RAW
//Extracting only the 1st array element from the array
SELECT RAW_FILE:prev_company[0] FROM OUR_FIRST_DB.PUBLIC.JSON_RAW

//Two ways of handling data in arrays. Method 1 - just display the count of the array in the column. E.g. in this case how many previous companies
SELECT ARRAY_SIZE(RAW_FILE:prev_company) as NO_OF_PREV_COMPANY
FROM OUR_FIRST_DB.PUBLIC.JSON_RAW

//Method 2 - Create a union of the results so that there will duplicate entries of other column values based on the number of specified repetitions in the array
SELECT RAW_FILE:id::INT as ID,
       RAW_FILE:first_name::varchar as first_name,
       RAW_FILE:last_name::varchar as last_name,
       RAW_FILE:city::varchar as city,
       RAW_FILE:prev_company[0] as PREV_JOBS
FROM OUR_FIRST_DB.PUBLIC.JSON_RAW
UNION ALL
SELECT RAW_FILE:id::INT as ID,
       RAW_FILE:first_name::varchar as first_name,
       RAW_FILE:last_name::varchar as last_name,
       RAW_FILE:city::varchar as city,
       RAW_FILE:prev_company[1] AS PREV_JOBS
FROM OUR_FIRST_DB.PUBLIC.JSON_RAW
ORDER BY ID

// The field spoken_languages consists of an array of languages and respective level of proficiency for each record.
SELECT RAW_FILE:spoken_languages FROM OUR_FIRST_DB.PUBLIC.JSON_RAW

//Extracting the name and the first language and level for each person
SELECT RAW_FILE:first_name:: STRING as FIRST_NAME,
       RAW_FILE:spoken_languages[0].language::STRING as FIRST_LANGUAGE,
       RAW_FILE:spoken_languages[0].level::STRING as PROFICIENCY
       FROM OUR_FIRST_DB.PUBLIC.JSON_RAW
//Another option is to do a union of all languages across users
SELECT RAW_FILE:id::INT as ID,
       RAW_FILE:first_name::STRING as FIRST_NAME,
       RAW_FILE:last_name::STRING as LAST_NAME,
       RAW_FILE:spoken_languages[0].language::STRING as Language1,
       RAW_FILE:spoken_languages[0].level::STRING as Level  
       FROM OUR_FIRST_DB.PUBLIC.JSON_RAW
UNION ALL
SELECT RAW_FILE:id::INT as ID,
       RAW_FILE:first_name::STRING as FIRST_NAME,
       RAW_FILE:last_name::STRING as LAST_NAME,
       RAW_FILE:spoken_languages[1].language::STRING as Language2,
       RAW_FILE:spoken_languages[1].level::STRING as Level  
       FROM OUR_FIRST_DB.PUBLIC.JSON_RAW
UNION ALL
SELECT RAW_FILE:id::INT as ID,
       RAW_FILE:first_name::STRING as FIRST_NAME,
       RAW_FILE:last_name::STRING as LAST_NAME,
       RAW_FILE:spoken_languages[2].language::STRING as Language3,
       RAW_FILE:spoken_languages[2].level::STRING as Level  
       FROM OUR_FIRST_DB.PUBLIC.JSON_RAW
       ORDER BY ID

//Alternate method is to use inbuilt FLATTEN() function - This method is cleaner and it gives the output without having to guess the number of values in the array and thereby avoiding NULL values
SELECT RAW_FILE:id::STRING as ID,
       RAW_FILE:first_name::STRING as first_name,
       RAW_FILE:last_name::STRING as last_name,
       f.value:language::STRING as FIRST_LANGUAGE,
       f.value:level::STRING as LEVEL
       FROM OUR_FIRST_DB.PUBLIC.JSON_RAW, TABLE(FLATTEN(RAW_FILE:spoken_languages))f
//Final step is to copy the result into a new table. This can be done in one of two ways
//Option 1 is to create a new table using the above select statment
CREATE OR REPLACE TABLE LANGUAGES AS(
    SELECT RAW_FILE:id::INT as ID,
           RAW_FILE:first_name::STRING as FIRST_NAME,
           RAW_FILE:last_name::STRING as LAST_NAME,
           f.value:language::STRING as FIRST_LANGUAGE,
           f.value:level::STRING as LEVEL
           FROM OUR_FIRST_DB.PUBLIC.JSON_RAW, TABLE(FLATTEN(RAW_FILE:spoken_languages))f
           )
SELECT * FROM LANGUAGES ORDER BY ID

//Option 2 is to use the INSERT INTO command if the table already exists with the same schema
CREATE TABLE LANGUAGES2(
    ID INT,
    FIRST_NAME STRING,
    LAST_NAME STRING,
    FIRST_LANGUAGE STRING,
    LEVEL STRING
)

INSERT INTO LANGUAGES2
SELECT RAW_FILE:id::STRING as ID,
       RAW_FILE:first_name::STRING as first_name,
       RAW_FILE:last_name::STRING as last_name,
       f.value:language::STRING as first_language,
       f.value:level::STRING as level
       FROM our_first_db.public.json_raw, TABLE(FLATTEN(RAW_FILE:spoken_languages)) f

SELECT * FROM LANGUAGES2 ORDER BY ID