SHOW TABLES

SELECT AVG(C_BIRTH_YEAR) FROM CUSTOMER // First time run took 2.2s to show the result. Now running the same query the second time.

SELECT AVG(C_BIRTH_YEAR) FROM CUSTOMER // The second run took only 77ms. This is because of caching