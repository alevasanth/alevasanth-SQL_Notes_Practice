---order of execution

-->FROM-->WHERE-->GROUP BY--> HAVING-->SELECT-->DISTINCT-->ORDER BY-->TOP/LIMIT

-->FROM-->JOINS-->WHERE-->GROUP BY--> AGGREGATIONS-->HAVING-->SELECT-->DISTINCT-->ORDER BY-->TOP/LIMIT

---You can’t use column aliases from SELECT in the WHERE clause (because WHERE executes first)
---You can use column aliases from SELECT in ORDER BY (because ORDER BY executes after SELECT)
---HAVING can filter on aggregate functions while WHERE cannot (because WHERE runs before grouping)


----PERFORMANCE Tuning
--INDEXING -right index for window functions (AVOIDS FULL TABLE SCAN, SPEEDS UP ORDER BY WINDOW FUNCTIONS)
--Avoid  SELECT * (LESS I/O, FASTER EXECUTION, SMALLER MEMORY)
--FILTER EARLY (LESS ROWS SCANNED, LESS MEMORY) 
--PARTITIONING (RANKING HAPPENS PER PARTITION, LESS DATA SCANNED, FASTER AGGREGATIONS)
--USE WINDOW FUNCTIONS ACCORDING TO ITS TIES (DENSE_RANK() IS MORE EXPENSIVE)
--USE TOP = ORDER BY (VERY FAST, USING INDEX SEEK, AVOIDS WINDOW FUNCTIONS)
--EXECUTION PLAN CHECKLIST
		-- UPDATE STATISTICS dim_product WITH FULLSCAN;
		-- AUTO_UPDATE_STATISTICS ON

--- TYPES OF FACT TABLES
-- 1. Transactional Fact Table (known as default and only one row per transaction)
-- 2. Periodic Fact Table (aggregated on week, month, year, day and each row represents a period)
-- 3. Accumulating Fact Table (describes the journey of a product/customer with lot of timestamps mostly for tracking)
-- 4. Factless Fact Table (have no numerics that can be aggregated)

--- TYPES OF DIMENSIONsions
-- 1. Confirmed Dimensions (only dimension referred by 2 or more fact tables)
-- 2. Degenerate Dimensions (dimension with context and have no supporting attributes)
-- 3. Junk Dimensions (Table with very few columns with context)
-- 4. Role Playing Dimensions (having active and inactive feilds within table such as order_date / return_date and cancel_date


--- SLOWLY CHANGING DIMENSIONS (SCD)
  --  Dimensions Do change with Time and so need to updated with Time

---TYPES OF SCD
--1. SCD TYPE1 (UPSERT - UPDATE & INSERT)
--2. SCD TYPE2 (To Track the history of changes from time to time and do not overwrite existing but have latest change with active/inactive flag and applicable timestamps)
--3. SCD TYPE3
--4. SCD TYPE4


Create Table UBER_Toll (txn_id int unique, vehicle_no varchar(255) not null, vehicle_type varchar(255) not null, crossing_time datetime);

insert into UBER_Toll values (1, 'DL01AA1111', 'car', '2026-1-10 8:00');
insert into UBER_Toll values (2, 'DL01AA1111', 'car', '2026-1-10 11:00');
insert into UBER_Toll values (3, 'DL02BB2222', 'truck', '2026-1-10 9:00');
insert into UBER_Toll values (4, 'DL02BB2222', 'truck', '2026-1-10 16:00');
insert into UBER_Toll values (5, 'DL03CC3333', 'bus', '2026-1-10 10:00');
insert into UBER_Toll values (6, 'DL03CC3333', 'bus', '2026-1-10 12:00');
insert into UBER_Toll values (7, 'DL04DD4444', 'motorcycle', '2026-1-10 11:00');
insert into UBER_Toll values (8, 'DL05EE5555', 'car', '2026-1-10 14:00');

select * from UBER_Toll;

with txn as (
	select t.*, LAG(crossing_time, 1) over (partition by vehicle_no order by crossing_time) as next_time
	from UBER_Toll t
	),
	txn1 as (
		select txn.*, DATEDIFF(HOUR, next_time, crossing_time) as diff_hour
		from txn
		),
		--SELECT diff_hour FROM TXN1
	txn2 as (
		select txn1.*, 
			case when diff_hour <= 4 and vehicle_type = 'car' then 20
			when (diff_hour is null or diff_hour > 4) and vehicle_type = 'car' then 40
			when diff_hour <= 4 and vehicle_type = 'truck' then 40
			when (diff_hour is null or diff_hour > 4) and vehicle_type = 'truck' then 80
			when diff_hour <= 4 and vehicle_type = 'bus' then 30
			when (diff_hour is null or diff_hour > 4) and vehicle_type = 'bus' then 70
			else 0
		end as fare from txn1
		)
	select sum(fare) as total_fare from txn2;


create TABLE Table1 (ID INT NOT NULL, NAME1 VARCHAR(200) NOT NULL);
INSERT INTO Table1 VALUES (1, 'Rishabh');
INSERT INTO Table1 VALUES (2, 'Sachin')
INSERT INTO Table1 VALUES (3, 'Kohli');
INSERT INTO Table1 VALUES (3, 'Saurabh');
INSERT INTO Table1 VALUES (4, 'Hardik');
INSERT INTO Table1 VALUES (5, 'Rahul');
 

INSERT INTO Table2 VALUES (1, 'Rohit');
INSERT INTO Table2 VALUES (1, 'Dhoni');
INSERT INTO Table2 VALUES (2, 'Shubham');
INSERT INTO Table2 VALUES (3, 'Kartik');
INSERT INTO Table2 VALUES (4, 'Jasprit');

 1. Rishabh
 1. Rohith
 1. Dhoni
 2. Sachin 2. shubham
 


select * from table1 t1 
Inner join table2 t2
On t1.id = t2.id ;


CREATE TABLE ACCOUNTS (account_id INT NOT NULL, ACCOUNT_TYPE VARCHAR(25) NOT NULL);

INSERT INTO ACCOUNTS 
	VALUES
	(100, 'A'),
	(100, 'B'),
	(100, 'C'),
	(101, 'B'),
	(101, 'C'),
	(102, 'A'),
	(103, 'C');

SELECT account_id 
	FROM 
ACCOUNTS 
	GROUP BY 
account_id
	HAVING 
COUNT(DISTINCT ACCOUNT_TYPE) = 1;


SELECT account_id, Counts_u
	FROM
		(select account_id from ACCOUNTS GROUP BY ACCOUNT_ID having count(account_id) <=1)
		having Counts_u <=1;
group by account_id;

account_id
	HAVING 
COUNT(DISTINCT ACCOUNT_TYPE) = 1;

Select account_id from   
(SELECT account_id,
	ROW_NUMBER() OVER(Partition by account_id order by account_id) as acc_rank
	FROM 
ACCOUNTS) t
where acc_rank > 1;


CREATE TABLE FRIENDS (USER_IDS INT NOT NULL, FRIEND_ID INT NOT NULL);

INSERT INTO FRIENDS VALUES (4, 3), (4, 3), (1,5), (2, 4), (2, 5), (3,2), (3,4), (4,5), (5, 4);
SELECT * FROM FRIENDS

----GET ID'S FRIENDS WITH EACH OTHER
WITH dedup_friends AS (
    SELECT DISTINCT USER_IDS, friend_id
    FROM friends
)
SELECT
    f1.USER_IDS,
    f1.friend_id
FROM dedup_friends f1
JOIN dedup_friends f2
  ON f1.USER_IDS = f2.friend_id
 AND f1.friend_id = f2.USER_IDS
WHERE f1.USER_IDS < f1.friend_id;


--- Get user IDS have more than 2 Friends
SELECT
    USER_IDS,
    COUNT(friend_id) AS friend_count
FROM friends
GROUP BY USER_IDS
HAVING COUNT(friend_id) > 2;

---Eliminating Duplicates		
SELECT
    USER_IDS,
    COUNT(DISTINCT friend_id) AS friend_count
FROM friends
GROUP BY USER_IDS
HAVING COUNT(DISTINCT friend_id) > 2;



---Amazon sql interview
create table Triangle (CombinationID Integer not null, SideID varchar(10) not null, SideLength Integer not null)

insert into Triangle 
values 
	(1, 'A', 3),
	(1, 'B', 4),
	(1,'C', 5),
	(2, 'A', 2),
	(2, 'B', 3),
	(2,'C', 6),
	(3, 'A', 13),
	(3, 'B', 5),
	(3,'C', 12);

SELECT * FROM Triangle;

SELECT CombinationID from Triangle
	Group by CombinationID
	HAVING 
		POWER(MAX(SideLength), 2) = SUM(POWER(SideLength, 2)) - POWER(MAX(SideLength), 2);
		25 = 50 - 25
		36 = 46 - 36
		169 = 338 - 169


--- WRITE A SQL Query to get Price corresponding to latest PurchaseDate for each itemID
Create table Sale_Price (ItemID Integer, PurchaseDate DATE, Price Float)
	
--DROP TABLE Sale_Price
Insert into Sale_Price
	Values
		(1, '03-17-2013', 19.00),
		(2, '03-17-2013', 14.00),
		(1, '03-18-2013', 13.00),
		(2, '03-18-2013', 15.00),
		(1, '03-19-2013', 17.00),
		(3, '03-19-2013', 19.00);

---SUBQUERY
Select ItemID, PurchaseDate, Price from Sale_Price sp1
	WHERE PurchaseDate = (SELECT max(PurchaseDate) from Sale_Price sp2
		where sp1.ItemID = sp2.ItemID) order by ItemID;


---ROW_Number()
SELECT ItemID, PurchaseDate, Price
	FROM (
		SELECT 
			ItemID, 
			PurchaseDate, 
			Price,
			row_number() over (partition by ItemID order by purchaseDate desc) rn
		from Sale_Price
		) ranked
	Where rn=1;


---WITH CTE CLAUSE
with latest_prices as (
	SELECT
		ItemId,
		MAX(PurchaseDate) as Max_date
	from 
		Sale_Price
	Group by
		ItemID
	)
select sp.ItemID, sp.purchaseDate, sp.price
	from Sale_Price sp
	INNER JOIN latest_prices lp 
		on sp.ItemID = lp.ItemID
		AND sp.PurchaseDate = lp.Max_date;
