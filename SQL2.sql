select * from dim_customer

select TOP 100 
	customer_id,
	email
from 
	dim_customer;

SELECT * FROM dim_customer where (gender = 'F') and ((country = 'France') OR (join_date > '2023-01-01'));

SELECT * FROM dim_customer WHERE first_name LIKE 'S__R%Y';

SELECT TOP 3 * FROM dim_product ORDER BY unit_price DESC;

---GROUPING
SELECT category, AVG(unit_price) AS AVERAGE_PRICE, sum(unit_price) as total_price FROM dim_product GROUP BY category order by AVERAGE_PRICE;

SELECT category, AVG(unit_price) AS AVERAGE_PRICE FROM dim_product GROUP BY category HAVING (AVG(unit_price) > 500);

---JOINS
create table orders
(
	o_id INT,
	CUST_ID INT,
	PRICE INT
);

INSERT INTO orders values (1, 101, 1000), (2, 201, 1100), (3, 501, 1200);

CREATE TABLE CUSTOMERS
(
	ID INT,
	NAME VARCHAR(255),
	EMAIL VARCHAR(255)
);

---TRUNCATE (HOLDS SCHEMA AND REMOVES DATA)
TRUNCATE TABLE CUSTOMERS

INSERT INTO CUSTOMERS VALUES (101, 'ale', 'ale@gmail'), (201, 'vasu', 'vasu@gmail'), (301, 'roja', 'roja@yahoo');

SELECT * FROM orders;
SELECT * FROM CUSTOMERS;

----INNER JOIN
select * from orders O Inner join CUSTOMERS C ON O.CUST_ID = C.ID;

--LEFT JOIN
select * from orders O LEFT join CUSTOMERS C ON O.CUST_ID = C.ID;

--RIGHT JOIN
select * from orders O RIGHT join CUSTOMERS C ON O.CUST_ID = C.ID;

--FULL JOIN (UNION in MYSQL FROM LEFT AND RIGHT JOIN)
select * from orders O FULL join CUSTOMERS C ON O.CUST_ID = C.ID;

select O.*, C.NAME from orders O Inner join CUSTOMERS C ON O.CUST_ID = C.ID;

select O.o_id, O.CUST_ID, C.NAME from orders O Inner join CUSTOMERS C ON O.CUST_ID = C.ID;


---UPDATE
UPDATE CUSTOMERS SET NAME = 'VASANTH' WHERE ID = 201;
SELECT * FROM CUSTOMERS

---DELETE
DELETE FROM CUSTOMERS WHERE ID = 101;


---TRANSFORMATIONS
/* NUMERIC */
select * from dim_product;

SELECT 
	unit_price * 0.90 as discounted_price,
	ROUND((unit_price * 0.13), 1) as tax,
	unit_price + (unit_price * 0.13) after_tax,
	unit_price / 10 as fractioned_price,
	ROUND(unit_price, 1) as rounded_price
FROM
	dim_product

SELECT
	CAST(ROUND(unit_price, 0) AS DECIMAL(10,2)) as rounded_price,
    CAST(unit_price * 0.90 AS DECIMAL(10,2)) as discounted_price,
    CAST(ROUND((unit_price * 0.13), 1) AS DECIMAL(10,1)) as tax,
    CAST(unit_price + (unit_price * 0.13) AS DECIMAL(10,2)) as after_tax,
    CAST(unit_price / 10 AS DECIMAL(10,2)) as fractioned_price
FROM dim_product;


---DATE TRANSFORMATIONS
SELECT * FROM dim_date;
SELECT date, 
	CAST(date as datetime) as DateTimeStamp,   ---TypeCasting
	DATEADD(DAY, 25, date) as Dateplus25Days,
	DATETRUNC(MONTH, date) as TruncatedMonth,
	DATEADD(MONTH, 3, date) as Dateplusmonths,
	DATEADD(MONTH, -5, date) as DateMinusMonths,
	DATEADD(YEAR, -7, date) as DateMinusYears,
	YEAR(DATE) AS YearNumber,
	Month(date) as MonthNumber,
	DATEPART(Quarter, date) as QuarterNumber,
	Day(date) as DayNumber,
	DATENAME(MONTH, date) as MonthName,
	DATENAME(WEEKDAY, date) as 'dayofweek',
	DATEPART(WEEKDAY, date) as dayweek,
	DATEDIFF(DAY, CURRENT_TIMESTAMP, date) as DiffInDays,
	DATEDIFF(MONTH, date, CURRENT_TIMESTAMP) as DiffInMonths,
	DATEDIFF(YEAR, CURRENT_TIMESTAMP, date) as DiffInYears,
	FORMAT(DATE, 'MM-dd-yyyy') as FormattedDate,
	FORMAT(CURRENT_TIMESTAMP, 'MM-dd-yyyy HH:mm:ss') as FormattedDateTime,
	FORMAT(CURRENT_TIMESTAMP, 'mm-dd-yyyy HH:MM:SSS') as FormattedDateTime1,
	FORMAT(CURRENT_TIMESTAMP, 'DD-mm-YYYY HH:mm:sss') as FormattedDateTime2,
	FORMAT(CURRENT_TIMESTAMP, 'dd-MM-yyyy HH:mm:ss') as FormattedDateTime3,
	FORMAT(date, 'dddd, dd-MM-yyyy HH:mm') as FormattedDateTime4,
	FORMAT(GETDATE(), 'dddd, MMMM dd, yyyy') AS LongFormattedDate,
	CURRENT_TIMESTAMP as Current_DateTime,
	getdate() as 'date',
	GETUTCDATE() as UTCDate,
	DATEADD(HOUR, 38, CURRENT_TIMESTAMP) as DatePlusHours
from 
	dim_date
order BY 'dayweek';

---Type Casting
Select customer_key, CAST(CUSTOMER_KEY AS VARCHAR(300)) FROM dim_customer;
Select customer_key, CAST(CUSTOMER_KEY AS int) FROM dim_customer;


----STRING Functions
SELECT 
	Customer_id, 
	CONCAT(first_name,' ',last_name) AS FULL_NAME,
	CONCAT_WS(', ', city, country) as Location,
	Gender, 
	email,
	SUBSTRING(email, 1,5) as mails,
	REPLACE(email, '.net', '.com') as mail_com,
	lower(city) as CITY, 
	upper(country) AS COUNTRY, 
	len(country) as countrySize,
	LEFT(COUNTRY, 4) AS country_left,
	RIGHT(COUNTRY, 4) AS country_Right,
	REVERSE(CUSTOMER_ID) AS Customer_Reversed,
	REPlicate((GENDER+' '+country), 3) AS REPEATED_Gender
FROM
	dim_customer;


----Conditionals
SELECT * FROM DIM_PRODUCT;

SELECT 
	product_id, 
	category, 
	unit_price, 
	CASE 
	WHEN unit_price <= 200 THEN 'AFFORDABLE'
	WHEN unit_price <= 400 THEN 'MEDICORE'
	ELSE 'EXPENSIVE'
	END AS PRICE_CATEGORY
from 
	DIM_PRODUCT;

---Filter with where
SELECT 
	product_id, 
	category, 
	unit_price, 
	CASE 
	WHEN unit_price <= 200 THEN 'AFFORDABLE'
	WHEN unit_price <= 400 THEN 'MEDICORE'
	ELSE 'EXPENSIVE'
	END AS PRICE_CATEGORY
from 
	DIM_PRODUCT where category='clothing';

----Filter with AND in CASE statement
SELECT 
	product_id, 
	category, 
	unit_price, 
	CASE 
	WHEN unit_price <= 200 AND category= 'clothing' THEN 'AFFORDABLE'
	WHEN unit_price <= 400 AND category= 'clothing' THEN 'MEDICORE'
	WHEN unit_price > 400 AND category= 'clothing' THEN 'EXPENSIVE'
	else  concat('not for ', category)
	END AS PRICE_CATEGORY
from 
	DIM_PRODUCT
order by category;

----CASE-1
SELECT *,
CASE 
	WHEN unit_price <= 200 then '5%'
	WHEN unit_price <= 400 then '8%'
	ELSE '15%' END AS Discount_Percentage, 
CASE 
	WHEN unit_price <= 200 then unit_price * 0.95
	WHEN unit_price <= 400 then unit_price * 0.92
	ELSE unit_price * 0.85 END AS Discounted_Price
from 
	DIM_PRODUCT
--order by category;


----CASE 2
SELECT distinct(category) from dim_product


SET STATISTICS TIME ON;
SET STATISTICS IO ON;
AUTO_UPDATE_STATISTICS ON

-- run query
SELECT
    p.*,
    d.*
FROM DIM_PRODUCT p
CROSS APPLY (
    SELECT
        CASE
            WHEN p.category = 'Books' THEN 5
            ELSE NULL
        END AS discount_pct
) d;

---select p.*, d.* FROM DIM_PRODUCT p CROSS APPLY ( SELECT CASE WHEN p.category='Books' THEN 5 END discounts) d


----BASIC and more Computation
Select *,
CASE WHEN Category = 'Books' then '5% off'
	 WHEN Category = 'Clothing' then '15% off'
	 WHEN Category = 'Electronics' then '20% off'
	 WHEN Category = 'Home & Kitchen' then '8% off'
	 ELSE '25% off'
	 end as Offer_Sale,
CASE
	WHEN category = 'Books' THEN unit_price * 0.95
	WHEN category = 'Clothing' THEN unit_price * 0.85
    WHEN category = 'Electronics' THEN unit_price * 0.80
    WHEN category = 'Home & Kitchen' THEN unit_price * 0.92
    ELSE unit_price * 0.75
END AS Price_After_Discount
from 
	DIM_PRODUCT


----GOOD
SELECT
    *,
    CONCAT(discount_pct, '% off') AS Offer_Sale,
    CAST(ROUND(unit_price * (1 - discount_pct / 100.0), 2) AS DECIMAL(5,2)) AS Price_After_Discount
FROM (
    SELECT
        *,
        CASE
            WHEN category = 'Books' THEN 5
            WHEN category = 'Clothing' THEN 15
            WHEN category = 'Electronics' THEN 20
            WHEN category = 'Home & Kitchen' THEN 8
            ELSE 25
        END AS discount_pct
    FROM DIM_PRODUCT
) t;


----BEST
SELECT
    p.*,
    CONCAT(d.discount_pct, '% off') AS Offer_Sale,
    p.unit_price * (1 - d.discount_pct / 100.0) AS Price_After_Discount
FROM DIM_PRODUCT p
CROSS APPLY (
    SELECT
        CASE
            WHEN p.category = 'Books' THEN 5
            WHEN p.category = 'Clothing' THEN 15
            WHEN p.category = 'Electronics' THEN 20
            WHEN p.category = 'Home & Kitchen' THEN 8
            ELSE 25
        END AS discount_pct 
) d;


----WINDOW FUNCTIONS
SELECT *, SUM(unit_price) OVER (ORDER BY unit_price) as Running_Product_Sum
	from DIM_PRODUCT;

SELECT *, SUM(unit_price) OVER (ORDER BY launch_date) as Running_Day_Total
	from DIM_PRODUCT;

SELECT *, AVG(unit_price) OVER (ORDER BY launch_date) as Running_Day_Average
	from DIM_PRODUCT;

---Frames
SELECT *, SUM(unit_price) OVER (ORDER BY launch_date ROWS BETWEEN unbounded preceding AND Current ROW) FROM DIM_PRODUCT;

SELECT *, SUM(unit_price) OVER (ORDER BY launch_date ROWS BETWEEN unbounded preceding AND unbounded following) FROM DIM_PRODUCT;

---RANK, ROW_NUMBER, DENSE_RANK
SELECT UNIT_PRICE, 
	ROW_NUMBER() OVER (ORDER BY UNIT_PRICE) AS 'ROW_NUMBER',
	RANK() OVER (ORDER BY UNIT_PRICE) AS 'RANK',
	DENSE_RANK() OVER (ORDER BY UNIT_PRICE) AS 'DENSE_RANK'
FROM 
	DIM_PRODUCT;

SELECT UNIT_PRICE, CATEGORY, 
	ROW_NUMBER() OVER (PARTITION BY CATEGORY ORDER BY UNIT_PRICE) AS 'ROW_NUMBER',
	RANK() OVER (PARTITION BY CATEGORY ORDER BY UNIT_PRICE) AS 'RANK',
	DENSE_RANK() OVER (PARTITION BY CATEGORY ORDER BY UNIT_PRICE) AS 'DENSE_RANK'
FROM 
	DIM_PRODUCT;

---GET SUM OF SALES PURCHASED BY EACH CUSTOMER and group by category
select top 100 * from dim_customer
select top 100 * from fact_sales


---create table calculated_customers as
SELECT CUSTOMER_KEY, CUSTOMER_ID, FULL_NAME, COUNTRY, PURCHASE_TOTAL,
	ROW_NUMBER() OVER (PARTITION BY COUNTRY ORDER BY CUSTOMER_KEY DESC ) AS RN
FROM (
		SELECT C.customer_key, C.customer_id, CONCAT_WS(' ', first_name, last_name) AS FULL_NAME, C.COUNTRY,
			sum(S.total_amount) AS PURCHASE_TOTAL
		FROM 
			dim_customer C 
		JOIN 
			fact_sales S ON S.customer_key = C.customer_key 
		GROUP BY C.CUSTOMER_KEY, C.CUSTOMER_ID, C.first_name, C.last_name, C.COUNTRY) FINAL;


SELECT customer_key, SUM(total_amount) AS TOTALS FROM fact_sales GROUP BY customer_key ORDER BY customer_key;

----Stored Proc
WITH derived_totals AS (
    SELECT
        C.customer_key,
        SUM(S.total_amount) AS purchase_total
    FROM dim_customer C
    JOIN fact_sales S
        ON S.customer_key = C.customer_key
    GROUP BY C.customer_key
),
fact_totals AS (
    SELECT
        customer_key,
        SUM(total_amount) AS totals
    FROM fact_sales
    GROUP BY customer_key
)
SELECT
    d.customer_key,
    d.purchase_total AS derived_total,
    f.totals AS fact_total,
    (d.purchase_total - f.totals) AS difference,
    CASE
        WHEN d.purchase_total = f.totals THEN 'PASS'
        ELSE 'FAIL'
    END AS recon_status
FROM derived_totals d
JOIN fact_totals f
    ON d.customer_key = f.customer_key
ORDER BY recon_status DESC, d.customer_key;


----SUB-QUERY
SELECT * FROM DIM_PRODUCT WHERE unit_price > (SELECT AVG(UNIT_PRICE) FROM dim_product);

---2
SELECT * FROM 
	(SELECT * FROM DIM_PRODUCT 
		WHERE unit_price > (SELECT AVG(UNIT_PRICE)
	FROM dim_product)) AS B 
where product_name = 'Huge Change';


---CTE's
WITH CTE_TABLE AS
(
SELECT * FROM dim_product
	WHERE unit_price > (SELECT AVG(UNIT_PRICE) FROM dim_product)
),
CTE_TABLE_2 AS
(
SELECT * FROM CTE_TABLE 
	WHERE category IN ('BOOKS', 'SPORTS', 'CLOTHING', 'TOYS')
)
SELECT * FROM CTE_TABLE_2 WHERE category='BOOKS' AND product_name= 'ONLY SENSE';


---REAL-TIME SCENARIOS
---1 SCENARIO (Finding Nth Value)
---WINDOW FUNCTIONS ARE EVALUATED AFTER HAVING
SELECT * FROM (select 
	*, 
	DENSE_RANK() OVER (ORDER BY UNIT_PRICE ) AS RANKING
FROM 
	dim_product) SQ WHERE RANKING=5;

--PARTITION BY
SELECT * FROM (select 
	*, 
	DENSE_RANK() OVER (PARTITION BY CATEGORY ORDER BY UNIT_PRICE) AS RANKING
FROM 
	dim_product) SQ WHERE RANKING=5;


---2 REMOVE DUPLICATES (DEduplication of Data)
SELECT * FROM CUSTOMERS_NEW

CREATE TABLE 
	CUSTOMERS_NEW (EMP_ID INT, EMP_NAME VARCHAR(255), CITY VARCHAR(255));
INSERT INTO CUSTOMERS_NEW
VALUES 
	(12, 'AAAA', 'TORONTO'),
	(13, 'BBBB', 'MONTREAL'),
	(14, 'CCCC', 'TORONTO'),
	(15, 'DDDD', 'CALGARY'),
	(21, 'AAAA', 'TORONTO'),
	(22, 'AAAA', 'TORONTO'),
	(10, 'AABB', 'TORONTO');


SELECT * FROM 
	(SELECT *, ROW_NUMBER() OVER (PARTITION BY EMP_ID ORDER BY EMP_ID) AS DEDUP_BY_RN
	FROM CUSTOMERS_NEW ) EMP_RN
	WHERE DEDUP_BY_RN=1;


SELECT * FROM 
	(SELECT *, ROW_NUMBER() OVER (PARTITION BY CALENDAR_DATE ORDER BY TEMP_C) AS DEDUP_DATE 
	FROM WEATHER_CANADA ) Weather_RN
	WHERE DEDUP_DATE=1;


---SCENARIO 3 [LAG & LEAD]
SELECT * FROM WEATHER_CANADA;

SELECT 
	*, 
	LAG(TEMP_C, 1) OVER (ORDER BY CALENDAR_DATE) AS PREV_DAY_TEMP,
	LEAD(TEMP_C,1) OVER (ORDER BY CALENDAR_DATE) AS NEXT_DAY_TEMP
FROM 
	WEATHER_CANADA WHERE DATENAME(YEAR, CALENDAR_DATE) = 2024;


SELECT 
	*,
	LAG(TEMP_C, 1) OVER (PARTITION BY CITY ORDER BY CALENDAR_DATE) AS PREV_TEMP_MAX,
	LEAD(TEMP_C,1) OVER (PARTITION BY CITY ORDER BY CALENDAR_DATE) AS NEXT_TEMP_MAX
FROM 
	WEATHER_CANADA WHERE DATENAME(YEAR, CALENDAR_DATE) IN (2023,2024);


---COMPARE FOR YEAR OR MONTH INSTEAD OF DAYS
SELECT 
	*,
	MAX(TEMP_C) AS MAX_TEMP,
	LAG(TEMP_C, 1) OVER (PARTITION BY PROVINCE ORDER BY PREVIOUS_YEARS) AS PREV_TEMP,
	LEAD(TEMP_C,1) OVER (PARTITION BY PROVINCE ORDER BY NEXT_YEARS) AS NEXT_TEMP
FROM 
	(SELECT *,
		DATEADD(YEAR, -1, CALENDAR_DATE) AS PREVIOUS_YEARS,
		DATEADD(YEAR, 1, CALENDAR_DATE) AS NEXT_YEARS
	FROM WEATHER_CANADA
	)
	YEARLY_WEATHER_REPORT WHERE DATENAME(YEAR, CALENDAR_DATE) IN (2023,2024)
	GROUP BY CALENDAR_DATE;


----
WITH daily_max AS (
    SELECT
		CITY,
        Province,
        YEAR(Calendar_Date)  AS Yr,
        MONTH(Calendar_Date) AS Mn,
        DAY(Calendar_Date)   AS Dy,
        MAX(Temp_C)          AS Max_Temp_C
    FROM dbo.Weather_Canada
    GROUP BY
		CITY,
        Province,
        YEAR(Calendar_Date),
        MONTH(Calendar_Date),
        DAY(Calendar_Date)
)
SELECT
    CITY, Province, Yr, Mn, Dy, Max_Temp_C,
    LAG(Max_Temp_C)  OVER (PARTITION BY Province, Mn, Dy ORDER BY Yr) AS PrevYear_Max_Temp_C,
    LEAD(Max_Temp_C) OVER (PARTITION BY Province, Mn, Dy ORDER BY Yr) AS NextYear_Max_Temp_C
FROM daily_max
WHERE Yr IN (2020, 2021, 2022, 2023, 2024) AND MN =1
ORDER BY CITY, Province, Mn, Dy, Yr;


---MAX TEMPURATURE OF CITY IN EACH MONTH 
SELECT 
	CITY,
	Province,
	YEAR(Calendar_Date) AS Yr,
	MONTH(Calendar_Date) AS Mn,
	MAX(Temp_C) AS HIGH_TEMP,
	MIN(Temp_C) AS LOW_TEMP
FROM 
	dbo.Weather_Canada
	group by
		city, province, YEAR(Calendar_Date), MONTH(Calendar_Date)
	ORDER BY
		CITY;



----VIEWS (JUST HOLDS THE INFORMATION OF SQL STATEMENTS)
CREATE VIEW RESULT_BY_MONTH 
	AS 
SELECT 
	CITY,
	Province,
	YEAR(Calendar_Date) AS Yr,
	MONTH(Calendar_Date) AS Mn,
	MAX(Temp_C) AS HIGH_TEMP,
	MIN(Temp_C) AS LOW_TEMP
FROM 
	dbo.Weather_Canada
	group by
		city, province, YEAR(Calendar_Date), MONTH(Calendar_Date)
	----ORDER BY CITY; (invalid in views)

SELECT * FROM RESULT_BY_MONTH ORDER BY CITY


----STORED PROCEDURE (PRE-DEFINED SET OF SQL STATEMENTS
--DELIMETER    (IN mysql)
CREATE PROCEDURE VECTOR_BASIC
	@p_id INT,
	@p_name CHAR(100),
	@p_email CHAR(100)
AS
BEGIN
	INSERT INTO VECTOR_BASIC (id, first_name, email)
	VALUES (@p_id, @p_name, @p_email);
END;

DROP PROCEDURE VECTOR


CREATE TABLE dbo.VECTOR (
    id    INT NOT NULL PRIMARY KEY,
    name  VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL
);

---PRO VERSION
CREATE OR ALTER PROCEDURE dbo.INSERT_VECTOR
    @p_id INT,
    @p_name VARCHAR(100),
    @p_email VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        INSERT INTO dbo.VECTOR (id, name, email)
        VALUES (@p_id, @p_name, @p_email);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;


SELECT *
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME = 'VECTOR';


EXEC INSERT_VECTOR
    @p_id = 1,
    @p_name = 'John',
    @p_email = 'john@gmail.com';


---FUNCTIONS (CUSTOMIZED TRANSFORMATIONS)
--- 1) SCALAR (returns one value)
CREATE FUNCTION SQUARE_IT(@X INT)
RETURNS INT
BEGIN
	return @X*@x;
END;

SELECT dbo.SQUARE_IT(5) AS Result;

--CELSIUS TO FAHRENHEIT
CREATE FUNCTION dbo.CtoF (@c DECIMAL(5,2))
RETURNS DECIMAL(5,2)
AS
BEGIN
    RETURN (@c * 9/5) + 32;
END;

SELECT
    City,
    Temp_C,
    dbo.CtoF(Temp_C) AS Temp_F
FROM Weather_Canada WHERE CITY='TORONTO' AND TEMP_C > 11;


--- 2) INLINE TABLE-VALUED (FASTEST)
CREATE FUNCTION dbo.GetCoolDays (@minTemp DECIMAL(5,2))
RETURNS TABLE
AS
RETURN
(
    SELECT *
    FROM Weather_Canada
    WHERE Temp_C < @minTemp
);


SELECT *
FROM dbo.GetCoolDays(-20);

--- 3 ) Multi-Statement Table-Valued Functions (Used when logic is complex and needs variables or multiple steps, 'SLOWER THAN INLINE TABLE VALUED FUNCTIONS')

CREATE FUNCTION dbo.CityAvgTemp()
RETURNS @result TABLE
(
    City VARCHAR(100),
    AvgTemp DECIMAL(5,2)
)
AS
BEGIN
    INSERT INTO @result
    SELECT City, AVG(Temp_C)
    FROM Weather_Canada
    GROUP BY City;

    RETURN;
END;


SELECT *
FROM dbo.CityAvgTemp();
