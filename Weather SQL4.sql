CREATE TABLE Weather_Canada
	(Weather_id INT IDENTITY(1,1) PRIMARY KEY,
	Calendar_Date DATE NOT NULL,
	CITY VARCHAR(255) NOT NULL,
	PROVINCE VARCHAR(255) NOT NULL,
	TEMP_C DECIMAL(5, 2)  NOT NULL
	);

--DROP TABLE Weather_Canada

---BULK INSERT
BULK INSERT weather_canada
FROM 'C:\Users\famil\OneDrive\Desktop\WEATHER_DATASETS\usa_weather_2019_dummy_data.csv'
WITH (
    FIRSTROW = 2,            -- skip header
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
	--DATEFORMAT = 'MM-dd-yyyy' (DEFAULT SET IN CSV)
);

---OPENROWSET INSERT (SLOWER AND COMPATIBLE WITH OLDER SQL VERSIONS) 
INSERT INTO dbo.weather_canada (Calendar_Date, city, province, TEMP_C)
SELECT
    CAST([date] AS DATE)          AS Calendar_Date,
    city,
    province,
    CAST(temperature_c AS DECIMAL(5,2)) AS temp_c
FROM OPENROWSET(
        BULK 'C:\Users\famil\OneDrive\Desktop\usa_weather_2020_2024_dummy_data.csv',
        FORMAT = 'CSV',
        FIRSTROW = 2
     ) AS src
where cast([date] AS DATE) < '2023-01-01';


--select * from Weather_Canada_2;
--select * from Weather_Canada_1;
--select * from Weather_Canada;

----INSERT FROM ONE TABLE TO ANOTHER 
---CASE 1 (NO CHECKS APPLIED)
INSERT INTO Weather_Canada_2 (Calendar_Date, city, province, TEMP_C)
SELECT Calendar_Date, city, province, TEMP_C
FROM Weather_Canada_1;

---CASE 2 ALL ROW COUNT CHECKS APPLIED ON INSERTION FROM SOURCE TO TARGET SO NO MISSING RECORD IN TRANSIT
SET NOCOUNT ON;

DECLARE @src_count      INT,
        @before_count   INT,
        @after_count    INT,
        @inserted_count INT;

SELECT @src_count = COUNT(*) FROM dbo.Weather_Canada_1;
SELECT @before_count = COUNT(*) FROM dbo.Weather_Canada_2;

BEGIN TRY
    BEGIN TRAN;

    INSERT INTO dbo.Weather_Canada_2 (Calendar_Date, CITY, PROVINCE, TEMP_C)
    SELECT Calendar_Date, CITY, PROVINCE, TEMP_C
    FROM dbo.Weather_Canada_1;

    SET @inserted_count = @@ROWCOUNT;

    -- Check: did we insert every row from source?
    IF @inserted_count <> @src_count
        THROW 50001, 'Insert aborted: not all source rows were inserted.', 1;

    COMMIT TRAN;

    SELECT @after_count = COUNT(*) FROM dbo.Weather_Canada_2;

    PRINT CONCAT('Insert successful. Inserted rows = ', @inserted_count,
                 ', Source rows = ', @src_count,
                 ', Target before = ', @before_count,
                 ', Target after = ', @after_count);
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    THROW;
END CATCH;

---CASE 3 
---NO DUPLICATE DATA (DEDUPLICATION) INSERTED AGAIN and DElete the records from source that are inserted
SET NOCOUNT ON;

BEGIN TRY
    BEGIN TRAN;

    DECLARE @src_count INT,
            @inserted_count INT,
            @deleted_count INT;

    -- Count rows currently in source
    SELECT @src_count = COUNT(*) 
    FROM dbo.Weather_Canada_1;

    -- Track inserted keys
    DECLARE @inserted_keys TABLE (
        Calendar_Date DATE,
        CITY          VARCHAR(255),
        PROVINCE      VARCHAR(255)
    );

    /* 1) INSERT only rows that do NOT already exist in target */
    INSERT INTO dbo.Weather_Canada (Calendar_Date, CITY, PROVINCE, TEMP_C)
    OUTPUT inserted.Calendar_Date, inserted.CITY, inserted.PROVINCE
    INTO @inserted_keys (Calendar_Date, CITY, PROVINCE)
    SELECT s.Calendar_Date, s.CITY, s.PROVINCE, s.TEMP_C
    FROM dbo.Weather_Canada_1 s
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Weather_Canada t
        WHERE t.Calendar_Date = s.Calendar_Date
          AND t.CITY          = s.CITY
          AND t.PROVINCE      = s.PROVINCE
    );

    SET @inserted_count = @@ROWCOUNT;

    /* 2) DELETE from source only the rows that were inserted */
    DELETE s
    FROM dbo.Weather_Canada_1 s
    JOIN @inserted_keys k
      ON k.Calendar_Date = s.Calendar_Date
     AND k.CITY          = s.CITY
     AND k.PROVINCE      = s.PROVINCE;

    SET @deleted_count = @@ROWCOUNT;

    /* 3) Row count reconciliation checks */
    IF @deleted_count <> @inserted_count
        THROW 50001, 'Mismatch: inserted rows != deleted rows. Rolling back.', 1;

    IF @inserted_count > @src_count
        THROW 50002, 'Mismatch: inserted rows > source rows. Rolling back.', 1;

    COMMIT TRAN;

    PRINT CONCAT('Insert successful: ', @inserted_count, ' new rows inserted.');
    PRINT CONCAT('Source cleanup successful: ', @deleted_count, ' rows deleted from source.');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;

    DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();
    PRINT CONCAT('FAILED: ', @msg);
    THROW;
END CATCH;
