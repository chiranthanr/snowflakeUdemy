USE EXERCISE_DB.PUBLIC

SHOW TABLES
SELECT * FROM JSON_RAW

SELECT RAW:first_name::VARCHAR as first_name,
    RAW:last_name::VARCHAR as last_name,
    RAW:Skills[0]::VARCHAR as skills1,
    RAW:Skills[1]::VARCHAR as skills2
    FROM EXERCISE_DB.PUBLIC.JSON_RAW