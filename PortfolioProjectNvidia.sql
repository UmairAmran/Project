Select *
From ProjectPortfolioNvidia..nvidia_stock_data

Select *
From ProjectPortfolioNvidia..nvidia_events

-- nvidia_stock_data
-- Cleaning data

Select Date
From ProjectPortfolioNvidia..nvidia_stock_data

-- Cleaning data (Date)

SELECT LEFT(Date, 10)
FROM ProjectPortfolioNvidia..nvidia_stock_data

Alter table ProjectPortfolioNvidia..nvidia_stock_data
ADD Clean_Date Date

Update ProjectPortfolioNvidia..nvidia_stock_data
Set Clean_Date = LEFT(Date, 10) FROM ProjectPortfolioNvidia..nvidia_stock_data

Select *
From ProjectPortfolioNvidia..nvidia_stock_data
Order by Clean_Date

-- Cleaning date (Naming)

EXEC sp_columns nvidia_stock_data

ALTER TABLE ProjectPortfolioNvidia..nvidia_stock_data
ADD Price_High nvarchar(255)

ALTER TABLE ProjectPortfolioNvidia..nvidia_stock_data
ADD Price_Low nvarchar(255)

ALTER TABLE ProjectPortfolioNvidia..nvidia_stock_data
ADD Price_Close nvarchar(255)

ALTER TABLE ProjectPortfolioNvidia..nvidia_stock_data
ADD Price_Open nvarchar(255)

UPDATE ProjectPortfolioNvidia..nvidia_stock_data
SET Price_High = "Price High",
    Price_Low = "Price Low",
	Price_Close = "Price Close",
	Price_Open = "Price Open"

ALTER TABLE ProjectPortfolioNvidia..nvidia_stock_data
ALTER COLUMN Price_High float

ALTER TABLE ProjectPortfolioNvidia..nvidia_stock_data
ALTER COLUMN Price_Low float

ALTER TABLE ProjectPortfolioNvidia..nvidia_stock_data
ALTER COLUMN Price_Close float

ALTER TABLE ProjectPortfolioNvidia..nvidia_stock_data
ALTER COLUMN Price_Open float

-- Cleaning data (NULL)

Select *
FROM ProjectPortfolioNvidia..nvidia_stock_data
WHERE Clean_Date IS NULL;

Delete FROM ProjectPortfolioNvidia..nvidia_stock_data
WHERE Clean_Date IS NULL;

-- Cleaning (Not Needed Columns)

ALTER TABLE ProjectPortfolioNvidia..nvidia_stock_data
DROP COLUMN Instrument, Date

ALTER TABLE ProjectPortfolioNvidia..nvidia_stock_data
DROP COLUMN "Price High", "Price Low", "Price Close", "Price Open"

-- Cleaning (Duplicate)

WITH DuplicatedCleanDates AS (
    SELECT Clean_Date
    FROM ProjectPortfolioNvidia..nvidia_stock_data
    GROUP BY Clean_Date
    HAVING COUNT(*) > 1
)
SELECT *
FROM ProjectPortfolioNvidia..nvidia_stock_data
WHERE Clean_Date IN (SELECT Clean_Date FROM DuplicatedCleanDates)

SELECT *
FROM ProjectPortfolioNvidia..nvidia_stock_data
WHERE Volume = 0

UPDATE t0
SET t0.Volume = t1.NonZeroVolume
FROM ProjectPortfolioNvidia..nvidia_stock_data t0
INNER JOIN (
    SELECT Clean_Date, MAX(Volume) AS NonZeroVolume
    FROM ProjectPortfolioNvidia..nvidia_stock_data
    WHERE Volume > 0
    GROUP BY Clean_Date
) t1
ON t0.Clean_Date = t1.Clean_Date
WHERE t0.Volume = 0

SELECT *
FROM ProjectPortfolioNvidia..nvidia_stock_data
WHERE Volume = 0

WITH DuplicatedCleanDates AS (
    SELECT Clean_Date
    FROM ProjectPortfolioNvidia..nvidia_stock_data
    GROUP BY Clean_Date
    HAVING COUNT(*) > 1
)
SELECT *
FROM ProjectPortfolioNvidia..nvidia_stock_data
WHERE Clean_Date IN (SELECT Clean_Date FROM DuplicatedCleanDates)

SELECT COUNT(*) FROM ProjectPortfolioNvidia..nvidia_stock_data

WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY Price_High, Price_Low, Price_Close, Price_Open 
		   ORDER BY (SELECT NULL)) AS RowNum
    FROM ProjectPortfolioNvidia..nvidia_stock_data
)
DELETE FROM CTE
WHERE RowNum > 1

SELECT COUNT(*) FROM ProjectPortfolioNvidia..nvidia_stock_data

-- Cleaned data

SELECT *
FROM ProjectPortfolioNvidia..nvidia_stock_data


-- nvidia_events
-- Cleaning data

Select *
From ProjectPortfolioNvidia..nvidia_events

-- Cleaning data (Date)

ALTER TABLE ProjectPortfolioNvidia..nvidia_events
ALTER COLUMN "Event Start Date" Date

SELECT LEFT("Event Start Date", 10)
FROM ProjectPortfolioNvidia..nvidia_events

Alter table ProjectPortfolioNvidia..nvidia_events
ADD Event_Start Date

Update ProjectPortfolioNvidia..nvidia_events
Set Event_Start = LEFT("Event Start Date", 10) FROM ProjectPortfolioNvidia..nvidia_events

SELECT LEFT("Event Last Update Date", 10)
FROM ProjectPortfolioNvidia..nvidia_events

Alter table ProjectPortfolioNvidia..nvidia_events
ADD Event_End Date

Update ProjectPortfolioNvidia..nvidia_events
Set Event_End = LEFT("Event Last Update Date", 10) FROM ProjectPortfolioNvidia..nvidia_events

Select *
From ProjectPortfolioNvidia..nvidia_events
Order by Event_Start

-- Cleaning date (Naming)

EXEC sp_columns nvidia_events

ALTER TABLE ProjectPortfolioNvidia..nvidia_events
ADD Event_Type nvarchar(255)

ALTER TABLE ProjectPortfolioNvidia..nvidia_events
ADD Event_Title nvarchar(255)

UPDATE ProjectPortfolioNvidia..nvidia_events
SET Event_Type = "Company Event Type",
    Event_Title = "Event Title"

-- Cleaning (Not Needed Columns)

ALTER TABLE ProjectPortfolioNvidia..nvidia_events
DROP COLUMN Instrument, "Company Event Type", "Event Title", "Event Last Update Date", "Event Start Date"

-- Cleaning data (NULL)

Select *
FROM ProjectPortfolioNvidia..nvidia_events
WHERE Event_Start IS NULL OR 
Event_End IS NULL OR
Event_Type IS NULL OR
Event_Title IS NULL

-- Cleaning (Duplicate)

Select *
From ProjectPortfolioNvidia..nvidia_events
Order by Event_Start

SELECT *
FROM ProjectPortfolioNvidia..nvidia_events
GROUP BY Event_Start, Event_End, Event_Type, Event_Title
HAVING COUNT(*) > 1

-- Cleaned Data
Select *
From ProjectPortfolioNvidia..nvidia_events
