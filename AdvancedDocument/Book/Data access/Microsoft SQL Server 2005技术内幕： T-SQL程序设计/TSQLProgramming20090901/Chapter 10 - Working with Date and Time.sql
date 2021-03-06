---------------------------------------------------------------------
-- Inside Microsoft SQL Server 2008: T-SQL Programming (MSPress, 2009)
-- Chapter 10 - Working with Date and Time
-- Copyright Itzik Ben-Gan, 2009
-- All Rights Reserved
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Datetime Datatypes
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Datetime Manipulation
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Datetime Functions
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Functions Supported Prior to SQL Server 2008
---------------------------------------------------------------------

-- DATEADD
SELECT DATEADD(month, 1, '20090725');

-- DATEDIFF
SELECT DATEDIFF(month, '20090725', '20090825');

-- DATEPART, DAY, MONTH, YEAR
WITH C AS
(
  SELECT CAST('20090118 14:39:05.370' AS DATETIME) AS dt
)
SELECT dt,
  DATEPART(hour, dt) AS thehour,
  YEAR(dt)           AS theyear,
  MONTH(dt)          AS themonth,
  DAY(dt)            AS theday
FROM C;

-- DATENAME
SELECT DATENAME(weekday, '20090118 14:39:05.370');

-- GETDATE, CURRENT_TIMESTAMP, GETUTCDATE
SELECT
  GETDATE()           AS [GETDATE],
  CURRENT_TIMESTAMP   AS [CURRENT_TIMESTAMP],
  GETUTCDATE()        AS [GETUTCDATE];

-- ISDATE
SELECT
  ISDATE('20090229') AS isdate_20090229,
  ISDATE('20120229') AS isdate_20120229;

---------------------------------------------------------------------
-- Functions Introduced in SQL Server 2008
---------------------------------------------------------------------

-- SYSDATETIME, SYSUTCDATETIME, SYSDATETIMEOFFSET
SELECT
  SYSDATETIME()       AS [SYSDATETIME],
  SYSUTCDATETIME()    AS [SYSUTCDATETIME],
  SYSDATETIMEOFFSET() AS [SYSDATETIMEOFFSET];

SELECT
  CAST(SYSDATETIME() AS DATE) AS [current_date],
  CAST(SYSDATETIME() AS TIME) AS [current_time];
GO

-- SWITCHOFFSET
DECLARE @dto AS DATETIMEOFFSET = '2009-02-12 12:30:15.1234567 -05:00';
SELECT SWITCHOFFSET(@dto, '-08:00');
GO

-- DATEDIFF
SELECT 
  DATEDIFF(day,
    '2009-02-12 12:00:00.0000000 -05:00',
    '2009-02-12 22:00:00.0000000 -05:00') AS days;

SELECT
  SWITCHOFFSET('2009-02-12 12:00:00.0000000 -05:00', '+00:00') AS val1,
  SWITCHOFFSET('2009-02-12 22:00:00.0000000 -05:00', '+00:00') AS val2;
GO

-- TODATETIMEOFFSET
DECLARE @dt2 AS DATETIME2 = '2009-02-12 12:30:15.1234567';
SELECT TODATETIMEOFFSET(@dt2, '-08:00');
GO

-- ISO Week

-- Creation Script for the ISOweek Function
USE tempdb;
IF OBJECT_ID (N'dbo.ISOweek', N'FN') IS NOT NULL
    DROP FUNCTION dbo.ISOweek;
GO
CREATE FUNCTION dbo.ISOweek (@DATE DATETIME)
RETURNS int
WITH EXECUTE AS CALLER
AS
BEGIN
     DECLARE @ISOweek int
     SET @ISOweek= DATEPART(wk,@DATE)+1
          -DATEPART(wk,CAST(DATEPART(yy,@DATE) as CHAR(4))+'0104')
--Special cases: Jan 1-3 may belong to the previous year
     IF (@ISOweek=0) 
          SET @ISOweek=dbo.ISOweek(CAST(DATEPART(yy,@DATE)-1 
               AS CHAR(4))+'12'+ CAST(24+DATEPART(DAY,@DATE) AS CHAR(2)))+1
--Special case: Dec 29-31 may belong to the next year
     IF ((DATEPART(mm,@DATE)=12) AND 
          ((DATEPART(dd,@DATE)-DATEPART(dw,@DATE))>= 28))
          SET @ISOweek=1
     RETURN(@ISOweek)
END;
GO

-- Test ISOweek function
DECLARE @DF AS INT;
SET @DF = @@DATEFIRST;
SET DATEFIRST 1;

WITH Dates AS
(
  SELECT CAST('20091227' AS DATETIME) AS dt
  UNION ALL SELECT '20091228'
  UNION ALL SELECT '20091229'
  UNION ALL SELECT '20091230'
  UNION ALL SELECT '20091231'
  UNION ALL SELECT '20100101'
  UNION ALL SELECT '20100102'
  UNION ALL SELECT '20100103'
  UNION ALL SELECT '20100104'
  UNION ALL SELECT '20100105'
  UNION ALL SELECT '20100106'
  UNION ALL SELECT '20100107'
  UNION ALL SELECT '20100108'
  UNION ALL SELECT '20100109'
  UNION ALL SELECT '20100110'
  UNION ALL SELECT '20100111'
)
SELECT dt, dbo.ISOweek(dt) AS wk, DATENAME(weekday, dt) AS wd
FROM Dates;

SET DATEFIRST @DF;
GO

-- Calculating ISO week in SQL Server 2008
WITH Dates AS
(
  SELECT CAST(dt AS DATE) AS dt
  FROM ( VALUES
           ('20091227'),
           ('20091228'),
           ('20091229'),
           ('20091230'),
           ('20091231'),
           ('20100101'),
           ('20100102'),
           ('20100103'),
           ('20100104'),
           ('20100105'),
           ('20100106'),
           ('20100107'),
           ('20100108'),
           ('20100109'),
           ('20100110'),
           ('20100111')  ) AS D(dt)
)
SELECT dt, DATEPART(ISO_WEEK, dt) AS wk, DATENAME(weekday, dt) AS wd
FROM Dates;

---------------------------------------------------------------------
-- Literals
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Identifying Weekday
---------------------------------------------------------------------

SELECT DATEPART(weekday, DATEADD(day, @@DATEFIRST, '20130212'));
SELECT DATEPART(weekday, DATEADD(day, @@DATEFIRST - 1, '20130212'));

-- Return orders placed on a Tuesday

-- Solution 1
USE InsideTSQL2008;

SELECT orderid, orderdate,
  DATENAME(weekday, orderdate) AS weekdayname
FROM Sales.Orders
WHERE DATEPART(weekday, DATEADD(day, @@DATEFIRST - 1, orderdate)) = 2;

-- Solution 2

SELECT orderid, orderdate,
  DATENAME(weekday, orderdate) AS weekdayname
FROM Sales.Orders
WHERE DATEDIFF(day, '19000102', orderdate) % 7 = 0;
GO

-- Weekday with logical first day of the week set to Sunday
SELECT DATEDIFF(day, '19000107', SYSDATETIME()) % 7 + 1;

-- Logical first day of the week set to Monday
SELECT DATEDIFF(day, '19000101', SYSDATETIME()) % 7 + 1;

---------------------------------------------------------------------
-- No Separation Between Date and Time
---------------------------------------------------------------------

-- Using character string manipulation

-- Date only
SELECT CAST(CONVERT(CHAR(8), CURRENT_TIMESTAMP, 112) AS DATETIME);

-- Time only
SELECT CAST(CONVERT(CHAR(12), CURRENT_TIMESTAMP, 114) AS DATETIME);

-- Using offset calculations

-- Date only
SELECT DATEADD(day, DATEDIFF(day, '19000101', CURRENT_TIMESTAMP), '19000101');

-- Time only
SELECT DATEADD(day, DATEDIFF(day, CURRENT_TIMESTAMP, '19000101'), CURRENT_TIMESTAMP);

-- In SQL Server 2008

-- Date only
SELECT CAST(SYSDATETIME() AS DATE);

-- Time only
SELECT CAST(SYSDATETIME() AS TIME);

---------------------------------------------------------------------
-- Respective Datetime Calculations
---------------------------------------------------------------------

---------------------------------------------------------------------
-- First/Last Day of a Period
---------------------------------------------------------------------

-- Reminder: date only
SELECT DATEADD(day, DATEDIFF(day, '19000101', CURRENT_TIMESTAMP), '19000101');

-- First day of the month
SELECT DATEADD(month, DATEDIFF(month, '19000101', SYSDATETIME()), '19000101');

-- Last day of the month
SELECT DATEADD(month, DATEDIFF(month, '18991231', SYSDATETIME()), '18991231');

-- First day of the year
SELECT DATEADD(year, DATEDIFF(year, '19000101', SYSDATETIME()), '19000101');

-- Last day of the year
SELECT DATEADD(year, DATEDIFF(year, '18991231', SYSDATETIME()), '18991231');

---------------------------------------------------------------------
-- Respective Weekday
---------------------------------------------------------------------

-- Last Monday (Inclusive)
SELECT DATEADD(
         day,
         DATEDIFF(
           day,
           '19000101', -- Base Monday date
           SYSDATETIME()) /7*7,
         '19000101'); -- Base Monday date

-- Formatted in one line
SELECT DATEADD(day, DATEDIFF(day, '19000101', SYSDATETIME()) /7*7, '19000101');

-- Last Tuesday
SELECT DATEADD(day, DATEDIFF(day, '19000102', SYSDATETIME()) /7*7, '19000102');

-- Last Sunday
SELECT DATEADD(day, DATEDIFF(day, '19000107', SYSDATETIME()) /7*7, '19000107');

-- Last Monday (Exclusive)
SELECT DATEADD(day, DATEDIFF(day, '19000101', DATEADD(day, -1, SYSDATETIME())) /7*7, '19000101');

-- Next Monday (Inclusive)
SELECT DATEADD(day, DATEDIFF(day, '19000101', DATEADD(day, -1, SYSDATETIME())) /7*7 + 7, '19000101');

-- Next Tuesday (Inclusive)
SELECT DATEADD(day, DATEDIFF(day, '19000102', DATEADD(day, -1, SYSDATETIME())) /7*7 + 7, '19000102');

-- Next Sunday (Inclusive)
SELECT DATEADD(day, DATEDIFF(day, '19000107', DATEADD(day, -1, SYSDATETIME())) /7*7 + 7, '19000107');

-- Next Monday (Exclusive)
SELECT DATEADD(day, DATEDIFF(day, '19000101', SYSDATETIME()) /7*7 + 7, '19000101');

-- Next Tuesday (Exclusive)
SELECT DATEADD(day, DATEDIFF(day, '19000102', SYSDATETIME()) /7*7 + 7, '19000102');

-- Next Sunday (Exclusive)
SELECT DATEADD(day, DATEDIFF(day, '19000107', SYSDATETIME()) /7*7 + 7, '19000107');

-- Reminder: date of the first day of the current month
SELECT DATEADD(month, DATEDIFF(month, '19000101', SYSDATETIME()), '19000101');

-- Reminder: next occurrence of a weekday, inclusive (next Monday in this example)
SELECT DATEADD(day, DATEDIFF(day, '19000101', DATEADD(day, -1, SYSDATETIME())) /7*7 + 7, '19000101');

-- date of the first occurrence of a Monday in this month
SELECT DATEADD(day, DATEDIFF(day, '19000101', 
  -- first day of month
  DATEADD(month, DATEDIFF(month, '19000101', SYSDATETIME()), '19000101')
    -1) /7*7 + 7, '19000101');

-- date of the first occurrence of a Tuesday in this month
SELECT DATEADD(day, DATEDIFF(day, '19000102', 
  -- first day of month
  DATEADD(month, DATEDIFF(month, '19000101', SYSDATETIME()), '19000101')
    -1) /7*7 + 7, '19000102');

-- Reminder: date of the last day of the current month
SELECT DATEADD(month, DATEDIFF(month, '18991231', SYSDATETIME()), '18991231');

-- Reminder: date of the last occurrence of a weekday (Monday in this example)
SELECT DATEADD(day, DATEDIFF(day, '19000101', SYSDATETIME()) /7*7, '19000101');

-- last occurrence of a Monday of the current month
SELECT DATEADD(day, DATEDIFF(day, '19000101',
  -- last day of month
  DATEADD(month, DATEDIFF(month, '18991231', SYSDATETIME()), '18991231')
  ) /7*7, '19000101');

-- last occurrence of a Tuesday of the current month
SELECT DATEADD(day, DATEDIFF(day, '19000102',
  -- last day of month
  DATEADD(month, DATEDIFF(month, '18991231', SYSDATETIME()), '18991231')
  ) /7*7, '19000102');

-- first occurrence of a Monday in the current year
SELECT DATEADD(day, DATEDIFF(day, '19000101', 
  -- first day of year
  DATEADD(year, DATEDIFF(year, '19000101', SYSDATETIME()), '19000101')
    -1) /7*7 + 7, '19000101');

-- first occurrence of a Tuesday in the current year
SELECT DATEADD(day, DATEDIFF(day, '19000102', 
  -- first day of year
  DATEADD(year, DATEDIFF(year, '19000101', SYSDATETIME()), '19000101')
    -1) /7*7 + 7, '19000102');

-- last occurrence of a Monday in the current year
SELECT DATEADD(day, DATEDIFF(day, '19000101',
  -- last day of year
  DATEADD(year, DATEDIFF(year, '18991231', SYSDATETIME()), '18991231')
  ) /7*7, '19000101');

-- last occurrence of a Tuesday in the current year
SELECT DATEADD(day, DATEDIFF(day, '19000102',
  -- last day of year
  DATEADD(year, DATEDIFF(year, '18991231', SYSDATETIME()), '18991231')
  ) /7*7, '19000102');

---------------------------------------------------------------------
-- Rounding Issues
---------------------------------------------------------------------

-- Oops
USE InsideTSQL2008;

SELECT orderid, orderdate
FROM Sales.Orders
WHERE orderdate BETWEEN '20080101 00:00:00.000' AND '20080101 23:59:59.999';

-- Fixed
SELECT orderid, orderdate
FROM Sales.Orders
WHERE orderdate >= '20080101'
  AND orderdate  < '20080102';

-- Can't realy on index ordering
SELECT orderid, orderdate
FROM Sales.Orders
WHERE DATEADD(day, DATEDIFF(day, '19000101', orderdate), '19000101') = '20080101';

-- Casting to DATE
SELECT orderid, orderdate
FROM Sales.Orders
WHERE CAST(orderdate AS DATE) = '20080101';

---------------------------------------------------------------------
-- Datetime-Related Querying Problems
---------------------------------------------------------------------

---------------------------------------------------------------------
-- The Birthday Problem
---------------------------------------------------------------------

-- Add two employees
INSERT INTO HR.Employees
  (lastname, firstname, birthdate, title, titleofcourtesy, hiredate, 
   address, city, region, postalcode, country, phone, mgrid)
VALUES
  (N'Schaller', N'George', '19720229', N'VP', N'Ms.',
   '20020501 00:00:00.000', N'7890 - 20th Ave. E., Apt. 2A', 
   N'Seattle', N'WA', N'10003', N'USA', N'(206) 555-0101', NULL),
  (N'North', N'Mary', CAST(SYSDATETIME() AS DATE), N'VP', N'Dr.',
  '20020814 00:00:00.000', N'9012 W. Capital Way',
   N'Tacoma', N'WA', N'10001', N'USA', N'(206) 555-0100', 1);

WITH Args1 AS
(
  SELECT empid, firstname, lastname, birthdate,
    DATEDIFF(year, birthdate, SYSDATETIME()) AS diff,
    CAST(SYSDATETIME() AS DATE) AS today
  FROM HR.Employees
),
Args2 AS
(
  SELECT empid, firstname, lastname, birthdate, today,
    CAST(DATEADD(year, diff, birthdate) AS DATE) AS bdcur,
    CAST(DATEADD(year, diff + 1, birthdate) AS DATE) AS bdnxt
  FROM Args1
),
Args3 AS
(
  SELECT empid, firstname, lastname, birthdate, today,
    DATEADD(day, CASE WHEN DAY(birthdate) <> DAY(bdcur)
      THEN 1 ELSE 0 END, bdcur) AS bdcur,
    DATEADD(day, CASE WHEN DAY(birthdate) <> DAY(bdnxt)
      THEN 1 ELSE 0 END, bdnxt) AS bdnxt
  FROM Args2
)
SELECT empid, firstname, lastname, birthdate,
  CASE WHEN bdcur >= today THEN bdcur ELSE bdnxt END AS birthday
FROM Args3;
GO

-- Age
DECLARE @targetdate AS DATE = CAST(SYSDATETIME() AS DATE);

SELECT empid, firstname, lastname, birthdate,
  DATEDIFF(year, birthdate, @targetdate)
  - CASE WHEN 100 * MONTH(@targetdate) + DAY(@targetdate)
            < 100 * MONTH(birthdate) + DAY(birthdate)
         THEN 1 ELSE 0
    END AS age
FROM HR.Employees;
GO

-- Age based on integer manipulation
DECLARE @targetdate AS DATE = CAST(SYSDATETIME() AS DATE);

SELECT empid, firstname, lastname, birthdate,
  (CAST(CONVERT(CHAR(8), @targetdate, 112) AS INT)
   - CAST(CONVERT(CHAR(8), birthdate, 112) AS INT)) / 10000 AS age
FROM HR.Employees;
GO

-- Cleanup
DELETE FROM HR.Employees WHERE empid > 9;
DBCC CHECKIDENT('HR.Employees', RESEED, 9);
GO
   
---------------------------------------------------------------------
-- Overlaps
---------------------------------------------------------------------

-- Creating and Populating the Sessions Table
USE tempdb;

IF OBJECT_ID('dbo.Sessions') IS NOT NULL DROP TABLE dbo.Sessions;

CREATE TABLE dbo.Sessions
(
  id        INT         NOT NULL IDENTITY(1, 1),
  username  VARCHAR(10) NOT NULL,
  starttime DATETIME2   NOT NULL,
  endtime   DATETIME2   NOT NULL,
  CONSTRAINT PK_Sessions PRIMARY KEY(id),
  CONSTRAINT CHK_endtime_gteq_starttime
    CHECK (endtime >= starttime)
);
GO

CREATE INDEX idx_nc_username_st_ed ON dbo.Sessions(username, starttime, endtime);
CREATE INDEX idx_nc_username_ed_st ON dbo.Sessions(username, endtime, starttime);

INSERT INTO dbo.Sessions(username, starttime, endtime) VALUES
  ('User1', '20091201 08:00', '20091201 08:30'),
  ('User1', '20091201 08:30', '20091201 09:00'),
  ('User1', '20091201 09:00', '20091201 09:30'),
  ('User1', '20091201 10:00', '20091201 11:00'),
  ('User1', '20091201 10:30', '20091201 12:00'),
  ('User1', '20091201 11:30', '20091201 12:30'),
  ('User2', '20091201 08:00', '20091201 10:30'),
  ('User2', '20091201 08:30', '20091201 10:00'),
  ('User2', '20091201 09:00', '20091201 09:30'),
  ('User2', '20091201 11:00', '20091201 11:30'),
  ('User2', '20091201 11:32', '20091201 12:00'),
  ('User2', '20091201 12:04', '20091201 12:30'),
  ('User3', '20091201 08:00', '20091201 09:00'),
  ('User3', '20091201 08:00', '20091201 08:30'),
  ('User3', '20091201 08:30', '20091201 09:00'),
  ('User3', '20091201 09:30', '20091201 09:30');

---------------------------------------------------------------------
-- Identifying Overlaps
---------------------------------------------------------------------

-- Using OR Logic
SELECT S1.username,
  S1.id AS key1, S1.starttime AS start1, S1.endtime AS end1,
  S2.id AS key2, S2.starttime AS start2, S2.endtime AS end2
FROM dbo.Sessions AS S1
  JOIN dbo.Sessions AS S2
    ON S2.username = S1.username
    AND (S2.starttime BETWEEN S1.starttime AND S1.endtime
         OR S1.starttime BETWEEN S2.starttime AND S2.endtime);

-- Using AND Logic
SELECT S1.username,
  S1.id AS key1, S1.starttime AS start1, S1.endtime AS end1,
  S2.id AS key2, S2.starttime AS start2, S2.endtime AS end2
FROM dbo.Sessions AS S1
  JOIN dbo.Sessions AS S2
    ON S2.username = S1.username
    AND (S2.endtime >= S1.starttime
         AND S2.starttime <= S1.endtime);

---------------------------------------------------------------------
-- Grouping Overlaps
---------------------------------------------------------------------

-- Start Times
SELECT DISTINCT username, starttime
FROM dbo.Sessions AS O
WHERE NOT EXISTS
  (SELECT * FROM dbo.Sessions AS I
   WHERE I.username = O.username
     AND O.starttime > I.starttime
     AND O.starttime <= I.endtime);

-- End Times
SELECT DISTINCT username, endtime
FROM dbo.Sessions AS O
WHERE NOT EXISTS
  (SELECT * FROM dbo.Sessions AS I
   WHERE I.username = O.username
     AND O.endtime >= I.starttime
     AND O.endtime < I.endtime);

-- Complete Solution
WITH StartTimes AS 
(
  SELECT DISTINCT username, starttime,
    DENSE_RANK() OVER(PARTITION BY username ORDER BY starttime) AS rownum
  FROM dbo.Sessions AS O
  WHERE NOT EXISTS
    (SELECT * FROM dbo.Sessions AS I
     WHERE I.username = O.username
       AND O.starttime > I.starttime
       AND O.starttime <= I.endtime)
),
EndTimes AS
(
  SELECT DISTINCT username, endtime,
    DENSE_RANK() OVER(PARTITION BY username ORDER BY endtime) AS rownum
  FROM dbo.Sessions AS O
  WHERE NOT EXISTS
    (SELECT * FROM dbo.Sessions AS I
     WHERE I.username = O.username
       AND O.endtime >= I.starttime
       AND O.endtime < I.endtime)
)
SELECT S.username, S.starttime, E.endtime
FROM StartTimes AS S
  JOIN EndTimes AS E
    ON S.username = E.username
    AND S.rownum = E.rownum;
GO

-- Cursor-Based Solution
DECLARE
  @C AS CURSOR,
  @username     AS VARCHAR(10),
  @prevusername AS VARCHAR(10),
  @starttime    AS DATETIME2,
  @endtime      AS DATETIME2,
  @groupstart   AS DATETIME2,
  @groupend     AS DATETIME2;

DECLARE @Result AS TABLE
(
  username  VARCHAR(10),
  starttime DATETIME2,
  endtime   DATETIME2  
);

SET @C = CURSOR FAST_FORWARD FOR
  SELECT username, starttime, endtime
  FROM dbo.Sessions
  ORDER BY username, starttime, endtime;

OPEN @C;

FETCH NEXT FROM @C INTO @username, @starttime, @endtime;

SET @prevusername = @username;
SET @groupstart   = @starttime;
SET @groupend     = @endtime;

WHILE @@FETCH_STATUS = 0 
BEGIN
  IF @username <> @prevusername OR @starttime > @groupend
  BEGIN
    INSERT INTO @result(username, starttime, endtime)
      VALUES(@prevusername, @groupstart, @groupend);

    SET @groupstart = @starttime;
    SET @groupend   = @endtime;
  END
  ELSE IF @endtime > @groupend
    SET @groupend = @endtime;
  
  SET @prevusername = @username;

  FETCH NEXT FROM @C INTO @username, @starttime, @endtime;
END

IF @prevusername IS NOT NULL
  INSERT INTO @result(username, starttime, endtime)
    VALUES(@username, @groupstart, @groupend);

CLOSE @C;

SELECT username, starttime, endtime
FROM @Result;
GO

---------------------------------------------------------------------
-- Grouping by the Week
---------------------------------------------------------------------

-- Language dependent
USE InsideTSQL2008;

WITH C AS
(
  SELECT
    DATEADD(day, -DATEPART(weekday, orderdate) + 1, orderdate) AS startweek,
    val
  FROM Sales.OrderValues
)
SELECT
  startweek,
  DATEADD(day, 6, startweek) AS endweek,
  SUM(val) AS totalvalue,
  COUNT(*) AS numorders
FROM C
GROUP BY startweek
ORDER BY startweek;

-- Language neutral, with Sunday as the first day of the week
WITH C AS
(
  SELECT
    DATEADD(day,
      -DATEPART(weekday, DATEADD(day, @@DATEFIRST - 7, orderdate)) + 1,
       orderdate) AS startweek,
    val
  FROM Sales.OrderValues
)
SELECT
  startweek,
  DATEADD(day, 6, startweek) AS endweek,
  SUM(val) AS totalvalue,
  COUNT(*) AS numorders
FROM C
GROUP BY startweek
ORDER BY startweek;

---------------------------------------------------------------------
-- Working Days
---------------------------------------------------------------------

DECLARE
  @s AS DATE = '20090101',
  @e AS DATE = '20091231';

SELECT
  days/7*5 + days%7
    - CASE WHEN 6 BETWEEN wd AND wd + days%7-1 THEN 1 ELSE 0 END
    - CASE WHEN 7 BETWEEN wd AND wd + days%7-1 THEN 1 ELSE 0 END
FROM (SELECT
        DATEDIFF(day, @s, @e) + 1 AS days,
        DATEPART(weekday, @s) AS wd
     ) AS D;
GO

---------------------------------------------------------------------
-- Generating a Series of Dates
---------------------------------------------------------------------

-- Using Nums Table
DECLARE
  @startdt AS DATE = '20090101',
  @enddt   AS DATE = '20091231';

SELECT DATEADD(day, n - 1, @startdt) AS dt
FROM dbo.Nums
WHERE n <= DATEDIFF(day, @startdt, @enddt) + 1;
GO

-- UDF Returning an Auxiliary Table of Numbers
IF OBJECT_ID('dbo.GetNums') IS NOT NULL
  DROP FUNCTION dbo.GetNums;
GO
CREATE FUNCTION dbo.GetNums(@n AS BIGINT) RETURNS TABLE
AS
RETURN
  WITH
  L0   AS(SELECT 1 AS c UNION ALL SELECT 1),
  L1   AS(SELECT 1 AS c FROM L0 AS A CROSS JOIN L0 AS B),
  L2   AS(SELECT 1 AS c FROM L1 AS A CROSS JOIN L1 AS B),
  L3   AS(SELECT 1 AS c FROM L2 AS A CROSS JOIN L2 AS B),
  L4   AS(SELECT 1 AS c FROM L3 AS A CROSS JOIN L3 AS B),
  L5   AS(SELECT 1 AS c FROM L4 AS A CROSS JOIN L4 AS B),
  Nums AS(SELECT ROW_NUMBER() OVER(ORDER BY (SELECT 0)) AS n FROM L5)
  SELECT TOP(@n) n FROM Nums ORDER BY n;
GO

DECLARE
  @startdt AS DATE = '20090101',
  @enddt   AS DATE = '20091231';

SELECT DATEADD(day, n - 1, @startdt) AS dt
FROM dbo.GetNums(DATEDIFF(day, @startdt, @enddt) + 1) AS Nums;
GO
