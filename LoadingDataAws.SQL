CREATE STORAGE INTEGRATION S3_INT
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = S3
    ENABLED = TRUE
    STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::654654299403:role/snowflake-access-role'
    STORAGE_ALLOWED_LOCATIONS = ('S3://snowflakeudemys3bucket/csv','S3://snowflakeudemys3bucket/json')
    COMMENT = "Connection to AWS free tier account storage"

// Create table first
CREATE OR REPLACE TABLE MANAGED_DB.PUBLIC.movie_titles (
  show_id STRING,
  type STRING,
  title STRING,
  director STRING,
  cast STRING,
  country STRING,
  date_added STRING,
  release_year STRING,
  rating STRING,
  duration STRING,
  listed_in STRING,
  description STRING )
  
  

// Create file format object
CREATE OR REPLACE file format MANAGED_DB.file_formats.csv_fileformat
    type = csv
    field_delimiter = ','
    skip_header = 1
    null_if = ('NULL','null')
    empty_field_as_null = TRUE;
    
    
 // Create stage object with integration object & file format object
CREATE OR REPLACE stage MANAGED_DB.external_stages.csv_folder
    URL = 's3://snowflakeudemys3bucket/csv'
    STORAGE_INTEGRATION = s3_int
    FILE_FORMAT = MANAGED_DB.file_formats.csv_fileformat



// Use Copy command       
COPY INTO MANAGED_DB.PUBLIC.movie_titles
    FROM @MANAGED_DB.external_stages.csv_folder
   
    
    
    
    
// Create file format object
CREATE OR REPLACE file format MANAGED_DB.file_formats.csv_fileformat
    type = csv
    field_delimiter = ','
    skip_header = 1
    null_if = ('NULL','null')
    empty_field_as_null = TRUE    
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'    
CREATE OR REPLACE file format MANAGED_DB.file_formats.csv_fileformat
    type = csv
    field_delimiter = ','
    skip_header = 1
    null_if = ('NULL','null')
    empty_field_as_null = TRUE    
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'   
    
SELECT * FROM MANAGED_DB.PUBLIC.movie_titles
    
// Loading a JSON file
CREATE OR REPLACE FILE FORMAT MANAGED_DB.FILE_FORMATS.JSONFORMAT
    type = JSON

//Creating a stage object
CREATE OR REPLACE STAGE MANAGED_DB.EXTERNAL_STAGES.AWS_JSON_STAGE
    url = 's3://snowflakeudemys3bucket/json'
    storage_integration = s3_int
    file_format = MANAGED_DB.FILE_FORMATS.JSONFORMAT

list @MANAGED_DB.EXTERNAL_STAGES.AWS_JSON_STAGE

SELECT * FROM @MANAGED_DB.EXTERNAL_STAGES.AWS_JSON_STAGE

SELECT $1:asin::STRING as ASIN,
$1:helpful::STRING AS HELPFUL,
$1:overall::STRING as OVERALL,
$1:reviewText::string as REVIEWTEXT,
$1:reviewTime::string as REVIEWTIME,
$1:reviewerName::string as REVIEWER_NAME,
$1:summary::string as SUMMARY,
DATE($1:unixReviewTime::int) as REVIEW_TIME

FROM @MANAGED_DB.EXTERNAL_STAGES.AWS_JSON_STAGE

// Handling formatting for custom data format 'REVIEWTIME' column
// Custom data function is DATE_FROM_PARTS(<year>,<month>,<date>)
SELECT $1:asin::STRING as ASIN,
$1:helpful::STRING AS HELPFUL,
$1:overall::STRING as OVERALL,
$1:reviewText::string as REVIEWTEXT,
DATE_FROM_PARTS(
    RIGHT($1:reviewTime::string,4),
    LEFT($1:reviewTime::string,2),
    CASE WHEN SUBSTRING($1:reviewTime::STRING,5,1) = ',' 
        THEN SUBSTRING($1:reviewTime::string,4,1)
        ELSE SUBSTRING($1:reviewTime::string,4,2)
        END) as REVIEWTIME_CUSTOM,
$1:reviewerName::string as REVIEWER_NAME,
$1:summary::string as SUMMARY,
DATE($1:unixReviewTime::int) as REVIEW_TIME

FROM @MANAGED_DB.EXTERNAL_STAGES.AWS_JSON_STAGE

// Storing the results into a table
CREATE OR REPLACE TABLE MANAGED_DB.PUBLIC.AWS_JSON AS (
SELECT $1:asin::STRING as ASIN,
$1:helpful::STRING AS HELPFUL,
$1:overall::STRING as OVERALL,
$1:reviewText::string as REVIEWTEXT,
DATE_FROM_PARTS(
    RIGHT($1:reviewTime::string,4),
    LEFT($1:reviewTime::string,2),
    CASE WHEN SUBSTRING($1:reviewTime::STRING,5,1) = ',' 
        THEN SUBSTRING($1:reviewTime::string,4,1)
        ELSE SUBSTRING($1:reviewTime::string,4,2)
        END) as REVIEWTIME_CUSTOM,
$1:reviewerName::string as REVIEWER_NAME,
$1:summary::string as SUMMARY,
DATE($1:unixReviewTime::int) as REVIEW_TIME

FROM @MANAGED_DB.EXTERNAL_STAGES.AWS_JSON_STAGE
)

SELECT * FROM MANAGED_DB.PUBLIC.AWS_JSON