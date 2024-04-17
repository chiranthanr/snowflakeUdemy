USE MANAGED_DB

CREATE STORAGE INTEGRATION AZURE_INT
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = AZURE
    ENABLED = TRUE
    AZURE_TENANT_ID = '95478103-8e77-46bb-85ab-d3c05e72675b'
    STORAGE_ALLOWED_LOCATIONS = ('azure://snowflakeudemystorage.blob.core.windows.net/snowflakecsv/','azure://snowflakeudemystorage.blob.core.windows.net/snowflakejson/')

DESC STORAGE INTEGRATION AZURE_INT

// Now to create a file format & stage object
CREATE OR REPLACE FILE FORMAT MANAGED_DB.FILE_FORMATS.CSV_FILEFORMAT
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1

CREATE STAGE MANAGED_DB.EXTERNAL_STAGES.AZURE_STAGE_CSV
    STORAGE_INTEGRATION = AZURE_INT
    URL = 'azure://snowflakeudemystorage.blob.core.windows.net/snowflakecsv/'
    file_format = MANAGED_DB.FILE_FORMATS.CSV_FORMAT

LIST @MANAGED_DB.EXTERNAL_STAGES.AZURE_STAGE

// Loading the csv file into a table using copy into command
CREATE OR REPLACE TABLE MANAGED_DB.PUBLIC.AZURE_CSV_TABLE (
    Country_name varchar,
    Regional_indicator varchar,
    Ladder_score number(4,3),
    Standard_error_ladder number(4,3),
    upper_whisker number(4,3),
    lower_whisker number(4,3),
    logged_gdp_per_capita number(5,3),
    social_security number(4,3),
    health_life_expectance number(5,3),
    freedom_to_life_choices number(4,3),
    generosity number(4,3),
    perception_of_corruption number(4,3),
    Ladder_score_dystopic number(4,3),
    Explained_by_LOG_GDP number(4,3),
    Explained_by_social_support number(4,3),
    Explained_by_health_expectency number(4,3),
    Explained_by_freedom_to_choices number(4,3),
    Explained_by_generosity number(4,3),
    Explained_by_perception_of_corruption number(4,3),
    Dystopia_residual number(4,3)
)

COPY INTO MANAGED_DB.PUBLIC.AZURE_CSV_TABLE
    FROM @MANAGED_DB.EXTERNAL_STAGES.AZURE_STAGE
    FILE_FORMAT = MANAGED_DB.FILE_FORMATS.CSV_FILEFORMAT

SELECT * FROM AZURE_CSV_TABLE ORDER BY COUNTRY_NAME ASC

// Now repeating the process for a JSON file. First creating a file format for json

CREATE OR REPLACE FILE FORMAT MANAGED_DB.FILE_FORMATS.JSONFORMAT
    TYPE = JSON

// Creating a stage object for the json file
CREATE STAGE MANAGED_DB.EXTERNAL_STAGES.AZURE_STAGE_JSON
    STORAGE_INTEGRATION = AZURE_INT
    URL = 'azure://snowflakeudemystorage.blob.core.windows.net/snowflakejson/'
    file_format = MANAGED_DB.FILE_FORMATS.JSONFORMAT

SELECT * FROM @MANAGED_DB.EXTERNAL_STAGES.AZURE_STAGE_JSON

SELECT $1:"Car Model"::String as CAR_MODEL,
$1:"Car Model Year"::int as YEAR,
$1:"car make"::string as CAR_MAKE,
$1:"first_name"::string as FIRST_NAME,
$1:"id"::int as ID,
$1:"last_name"::STRING AS LAST_NAME
FROM @MANAGED_DB.EXTERNAL_STAGES.AZURE_STAGE_JSON

//Copying into a new table CREATING
CREATE TABLE MANAGED_DB.PUBLIC.CAR_MODELS(
    CAR_MODEL STRING,
    CAR_MODEL_YEAR INT,
    CAR_MAKE STRING,
    FIRST_NAME STRING,
    ID INT,
    LAST_NAME STRING
)

//First load the stage into a RAW table with only 1 column to match json format
CREATE TABLE MANAGED_DB.PUBLIC.CAR_MODELS_RAW(
    RAW variant
)

COPY INTO MANAGED_DB.PUBLIC.CAR_MODELS_RAW
FROM @MANAGED_DB.EXTERNAL_STAGES.AZURE_STAGE_JSON

SELECT * FROM MANAGED_DB.PUBLIC.CAR_MODELS_RAW

// Now copy from RAW into final table CAR MODELS
INSERT INTO MANAGED_DB.PUBLIC.CAR_MODELS
(
SELECT $1:"Car Model"::String as CAR_MODEL,
$1:"Car Model Year"::int as YEAR,
$1:"car make"::string as CAR_MAKE,
$1:"first_name"::string as FIRST_NAME,
$1:"id"::int as ID,
$1:"last_name"::STRING AS LAST_NAME
FROM MANAGED_DB.PUBLIC.CAR_MODELS_RAW
)

SELECT * FROM CAR_MODELS