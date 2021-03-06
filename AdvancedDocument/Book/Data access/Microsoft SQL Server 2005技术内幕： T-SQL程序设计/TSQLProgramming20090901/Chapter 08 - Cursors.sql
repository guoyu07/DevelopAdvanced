---------------------------------------------------------------------
-- Inside Microsoft SQL Server 2008: T-SQL Programming (MSPress, 2009)
-- Chapter 08 - Cursors
-- Copyright Itzik Ben-Gan, 2009
-- All Rights Reserved
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Cursor Overhead
---------------------------------------------------------------------

-- Compare simple table scan using set-based query vs. cursor
SET NOCOUNT ON;
USE tempdb;
IF OBJECT_ID('dbo.T1', 'U') IS NOT NULL DROP TABLE dbo.T1;
GO

SELECT n AS keycol, CAST('a' AS CHAR(200)) AS filler
INTO dbo.T1
FROM dbo.Nums
WHERE n <= 1000000;

CREATE UNIQUE CLUSTERED INDEX idx_keycol ON dbo.T1(keycol);
GO

-- Turn on "Discard results after execution"
-- Clear data cache, run twice, and measure both runs (cold/warm cache)
CHECKPOINT;
DBCC DROPCLEANBUFFERS;
GO

-- Set-Based, 10/1 seconds
SELECT keycol, filler FROM dbo.T1;
GO

DBCC DROPCLEANBUFFERS;
GO

-- Cursor-Based, 25/19 seconds
DECLARE @keycol AS INT, @filler AS CHAR(200);
DECLARE C CURSOR FAST_FORWARD FOR SELECT keycol, filler FROM dbo.T1;
OPEN C;
FETCH NEXT FROM C INTO @keycol, @filler;
WHILE @@FETCH_STATUS = 0
BEGIN
  -- Process data here
  FETCH NEXT FROM C INTO @keycol, @filler;
END
CLOSE C;
DEALLOCATE C;
GO

-- Using a cursor variable
DECLARE @C AS CURSOR, @keycol AS INT, @filler AS CHAR(200);
SET @C = CURSOR FAST_FORWARD FOR SELECT keycol, filler FROM dbo.T1;
OPEN @C;
FETCH NEXT FROM @C INTO @keycol, @filler;
WHILE @@FETCH_STATUS = 0
BEGIN
  -- Process data here
  FETCH NEXT FROM @C INTO @keycol, @filler;
END
GO

---------------------------------------------------------------------
-- Dealing with each Row Individually
---------------------------------------------------------------------

DBCC DROPCLEANBUFFERS;
GO

-- Listing 8-1: Code iterating through rows without a cursor
DECLARE @keycol AS INT, @filler AS CHAR(200);

SELECT TOP (1) @keycol = keycol, @filler = filler
FROM dbo.T1
ORDER BY keycol;

WHILE @@ROWCOUNT = 1
BEGIN
  -- Process data here

  -- Get next row
  SELECT TOP (1) @keycol = keycol, @filler = filler
  FROM dbo.T1
  WHERE keycol > @keycol
  ORDER BY keycol;
END
GO

-- Turn "Discard results after execution" back on

---------------------------------------------------------------------
-- Order Based Access
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Custom Aggregations
---------------------------------------------------------------------

-- Creating and Populating the Groups Table
USE tempdb;
IF OBJECT_ID('dbo.Groups', 'U') IS NOT NULL DROP TABLE dbo.Groups;

CREATE TABLE dbo.Groups
(
  groupid  VARCHAR(10) NOT NULL,
  memberid INT         NOT NULL,
  string   VARCHAR(10) NOT NULL,
  val      INT         NOT NULL,
  PRIMARY KEY (groupid, memberid)
);
GO
    
INSERT INTO dbo.Groups(groupid, memberid, string, val) VALUES
  ('a', 3, 'stra1',  6),
  ('a', 9, 'stra2',  7),
  ('b', 2, 'strb1',  3),
  ('b', 4, 'strb2',  7),
  ('b', 5, 'strb3',  3),
  ('b', 9, 'strb4', 11),
  ('c', 3, 'strc1',  8),
  ('c', 7, 'strc2', 10),
  ('c', 9, 'strc3', 12);
GO

-- Cursor Code for Custom Aggregate
DECLARE
  @Result AS TABLE(groupid VARCHAR(10), product BIGINT);
DECLARE
  @groupid AS VARCHAR(10), @prvgroupid AS VARCHAR(10),
  @val AS INT, @product AS BIGINT;

DECLARE C CURSOR FAST_FORWARD FOR
  SELECT groupid, val FROM dbo.Groups ORDER BY groupid;

OPEN C;

FETCH NEXT FROM C INTO @groupid, @val;
SELECT @prvgroupid = @groupid, @product = 1;

WHILE @@FETCH_STATUS = 0
BEGIN
  IF @groupid <> @prvgroupid
  BEGIN
    INSERT INTO @Result VALUES(@prvgroupid, @product);
    SELECT @prvgroupid = @groupid, @product = 1;
  END

  SET @product = @product * @val;
  
  FETCH NEXT FROM C INTO @groupid, @val;
END

IF @prvgroupid IS NOT NULL
  INSERT INTO @Result VALUES(@prvgroupid, @product);

CLOSE C;

DEALLOCATE C;

SELECT groupid, product FROM @Result;
GO

---------------------------------------------------------------------
-- Running Aggregations
---------------------------------------------------------------------

-- Creating and Populating the Sales Table
SET NOCOUNT ON;
IF DB_ID('CLRUtilities') IS NULL CREATE DATABASE CLRUtilities;
GO
USE CLRUtilities;

IF OBJECT_ID('dbo.Sales', 'U') IS NOT NULL DROP TABLE dbo.Sales;

CREATE TABLE dbo.Sales
(
  empid INT      NOT NULL,                -- partitioning column
  dt    DATETIME NOT NULL,                -- ordering column
  qty   INT      NOT NULL DEFAULT (1),    -- measure 1
  val   MONEY    NOT NULL DEFAULT (1.00), -- measure 2
  CONSTRAINT PK_Sales PRIMARY KEY(empid, dt)
);
GO

DECLARE
  @num_partitions     AS INT,
  @rows_per_partition AS INT,
  @start_dt           AS DATETIME;

SET @num_partitions     = 10000;
SET @rows_per_partition = 10;
SET @start_dt = '20090101';

TRUNCATE TABLE dbo.Sales;

INSERT INTO dbo.Sales WITH (TABLOCK) (empid, dt)
  SELECT NP.n AS empid, DATEADD(day, RPP.n - 1, @start_dt) AS dt
  FROM dbo.Nums AS NP
    CROSS JOIN dbo.Nums AS RPP
WHERE NP.n <= @num_partitions
  AND RPP.n <= @rows_per_partition;
GO

-- Set-Based Code Using Subquery for Running Aggregate
SELECT empid, dt, qty,
  (SELECT SUM(S2.qty)
   FROM dbo.Sales AS S2
   WHERE S2.empid = S1.empid
     AND S2.dt <= S1.dt) AS sumqty
FROM dbo.Sales AS S1;
GO

-- Cursor Code for Running Aggregate
DECLARE @Result AS TABLE
(
  empid  INT,
  dt     DATETIME,
  qty    INT,
  sumqty BIGINT
);

DECLARE
  @empid    AS INT,
  @prvempid AS INT,
  @dt       AS DATETIME,
  @qty      AS INT,
  @sumqty   AS BIGINT;

DECLARE C CURSOR FAST_FORWARD FOR
  SELECT empid, dt, qty
  FROM dbo.Sales
  ORDER BY empid, dt;

OPEN C;

FETCH NEXT FROM C INTO @empid, @dt, @qty;

SELECT @prvempid = @empid, @sumqty = 0;

WHILE @@fetch_status = 0
BEGIN
  IF @empid <> @prvempid
    SELECT @prvempid = @empid, @sumqty = 0;

  SET @sumqty = @sumqty + @qty;

  INSERT INTO @Result VALUES(@empid, @dt, @qty, @sumqty);
  
  FETCH NEXT FROM C INTO @empid, @dt, @qty;
END

CLOSE C;

DEALLOCATE C;

SELECT * FROM @Result;
GO

-- CLR-Based Solution Using C#
/*
using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;

public partial class StoredProcedures
{
  [Microsoft.SqlServer.Server.SqlProcedure]
  public static void SalesRunningSum()
  {
    using (SqlConnection conn = new SqlConnection("context connection=true;"))
    {
      SqlCommand comm = new SqlCommand();
      comm.Connection = conn;
      comm.CommandText = "" +
          "SELECT empid, dt, qty " +
          "FROM dbo.Sales " +
          "ORDER BY empid, dt;";

      SqlMetaData[] columns = new SqlMetaData[4];
      columns[0] = new SqlMetaData("empid", SqlDbType.Int);
      columns[1] = new SqlMetaData("dt", SqlDbType.DateTime);
      columns[2] = new SqlMetaData("qty", SqlDbType.Int);
      columns[3] = new SqlMetaData("sumqty", SqlDbType.BigInt);

      SqlDataRecord record = new SqlDataRecord(columns);

      SqlContext.Pipe.SendResultsStart(record);

      conn.Open();

      SqlDataReader reader = comm.ExecuteReader();

      SqlInt32 prvempid = 0;
      SqlInt64 sumqty = 0;

      while (reader.Read())
      {
        SqlInt32 empid = reader.GetSqlInt32(0);
        SqlInt32 qty = reader.GetSqlInt32(2);

        if (empid == prvempid)
        {
          sumqty += qty;
        }
        else
        {
          sumqty = qty;
        }

        prvempid = empid;

        record.SetSqlInt32(0, reader.GetSqlInt32(0));
        record.SetSqlDateTime(1, reader.GetSqlDateTime(1));
        record.SetSqlInt32(2, qty);
        record.SetSqlInt64(3, sumqty);

        SqlContext.Pipe.SendResultsRow(record);
      }

      SqlContext.Pipe.SendResultsEnd();
    }
  }
};
*/

-- CLR-Based Solution Using Visual Basic
/*
Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports System.Data.SqlTypes
Imports Microsoft.SqlServer.Server

Partial Public Class StoredProcedures
  <Microsoft.SqlServer.Server.SqlProcedure()> _
  Public Shared Sub SalesRunningSum()

    Using conn As New SqlConnection("context connection=true")
      Dim comm As New SqlCommand
      comm.Connection = conn
      comm.CommandText = "" & _
          "SELECT empid, dt, qty " & _
          "FROM dbo.Sales " & _
          "ORDER BY empid, dt;"

      Dim columns() As SqlMetaData = New SqlMetaData(3) {}
      columns(0) = New SqlMetaData("empid", SqlDbType.Int)
      columns(1) = New SqlMetaData("dt", SqlDbType.DateTime)
      columns(2) = New SqlMetaData("qty", SqlDbType.Int)
      columns(3) = New SqlMetaData("sumqty", SqlDbType.BigInt)

      Dim record As New SqlDataRecord(columns)

      SqlContext.Pipe.SendResultsStart(record)

      conn.Open()

      Dim reader As SqlDataReader = comm.ExecuteReader

      Dim prvempid As SqlInt32 = 0
      Dim sumqty As SqlInt64 = 0

      While (reader.Read())
        Dim empid As SqlInt32 = reader.GetSqlInt32(0)
        Dim qty As SqlInt32 = reader.GetSqlInt32(2)

        If (empid = prvempid) Then
          sumqty = sumqty + qty
        Else
          sumqty = qty
        End If

        prvempid = empid

        record.SetSqlInt32(0, reader.GetSqlInt32(0))
        record.SetSqlDateTime(1, reader.GetSqlDateTime(1))
        record.SetSqlInt32(2, qty)
        record.SetSqlInt64(3, sumqty)

        SqlContext.Pipe.SendResultsRow(record)
      End While

      SqlContext.Pipe.SendResultsEnd()
    End Using

  End Sub
End Class
*/

-- Test solution
EXEC dbo.SalesRunningSum;

-- Solution using the OVER clause
SELECT empid, dt, qty,
  SUM(qty) OVER(PARTITION BY empid
                ORDER BY dt
                ROWS BETWEEN UNBOUNDED PRECEDING
                         AND CURRENT ROW) AS sumqty
FROM dbo.Sales;
GO

---------------------------------------------------------------------
-- Max Concurrent Sessions
---------------------------------------------------------------------

-- Listing 8-2: Creating and Populating Sessions
USE tempdb;
IF OBJECT_ID('dbo.Sessions', 'U') IS NOT NULL DROP TABLE dbo.Sessions;

CREATE TABLE dbo.Sessions
(
  keycol    INT         NOT NULL IDENTITY,
  app       VARCHAR(10) NOT NULL,
  usr       VARCHAR(10) NOT NULL,
  host      VARCHAR(10) NOT NULL,
  starttime DATETIME    NOT NULL,
  endtime   DATETIME    NOT NULL,
  CONSTRAINT PK_Sessions PRIMARY KEY(keycol),
  CHECK(endtime > starttime)
);
GO

INSERT INTO dbo.Sessions VALUES
  ('app1', 'user1', 'host1', '20090212 08:30', '20090212 10:30'),
  ('app1', 'user2', 'host1', '20090212 08:30', '20090212 08:45'),
  ('app1', 'user3', 'host2', '20090212 09:00', '20090212 09:30'),
  ('app1', 'user4', 'host2', '20090212 09:15', '20090212 10:30'),
  ('app1', 'user5', 'host3', '20090212 09:15', '20090212 09:30'),
  ('app1', 'user6', 'host3', '20090212 10:30', '20090212 14:30'),
  ('app1', 'user7', 'host4', '20090212 10:45', '20090212 11:30'),
  ('app1', 'user8', 'host4', '20090212 11:00', '20090212 12:30'),
  ('app2', 'user8', 'host1', '20090212 08:30', '20090212 08:45'),
  ('app2', 'user7', 'host1', '20090212 09:00', '20090212 09:30'),
  ('app2', 'user6', 'host2', '20090212 11:45', '20090212 12:00'),
  ('app2', 'user5', 'host2', '20090212 12:30', '20090212 14:00'),
  ('app2', 'user4', 'host3', '20090212 12:45', '20090212 13:30'),
  ('app2', 'user3', 'host3', '20090212 13:00', '20090212 14:00'),
  ('app2', 'user2', 'host4', '20090212 14:00', '20090212 16:30'),
  ('app2', 'user1', 'host4', '20090212 15:30', '20090212 17:00');

CREATE INDEX idx_nc_app_st_et ON dbo.Sessions(app, starttime, endtime);
GO

-- Set-based solution
SELECT app, MAX(concurrent) AS mx
FROM (SELECT app,
        (SELECT COUNT(*)
         FROM dbo.Sessions AS S
         WHERE T.app = S.app
           AND T.ts >= S.starttime
           AND T.ts < S.endtime) AS concurrent
      FROM (SELECT app, starttime AS ts FROM dbo.Sessions) AS T) AS C
GROUP BY app;
GO

-- Cursor Code for Max Concurrent Sessions Problem
DECLARE
  @app AS VARCHAR(10), @prevapp AS VARCHAR (10), @ts AS datetime,
  @event_type AS INT, @concurrent AS INT, @mx AS INT;

DECLARE @Result AS TABLE(app VARCHAR(10), mx INT);

DECLARE C CURSOR FAST_FORWARD FOR
  SELECT app, starttime AS ts, 1 AS event_type FROM dbo.Sessions
  UNION ALL
  SELECT app, endtime, -1 FROM dbo.Sessions
  ORDER BY app, ts, event_type;

OPEN C;

FETCH NEXT FROM C INTO @app, @ts, @event_type;
SELECT @prevapp = @app, @concurrent = 0, @mx = 0;

WHILE @@FETCH_STATUS = 0
BEGIN
  IF @app <> @prevapp
  BEGIN
    INSERT INTO @Result VALUES(@prevapp, @mx);
    SELECT @prevapp = @app, @concurrent = 0, @mx = 0;
  END

  SET @concurrent = @concurrent + @event_type;
  IF @concurrent > @mx SET @mx = @concurrent;
  
  FETCH NEXT FROM C INTO @app, @ts, @event_type;
END

IF @prevapp IS NOT NULL
  INSERT INTO @Result VALUES(@prevapp, @mx);

CLOSE C;

DEALLOCATE C;

SELECT * FROM @Result;
GO

-- Benchmark Code for Max Concurrent Sessions Problem
SET NOCOUNT ON;
USE tempdb;

IF OBJECT_ID('dbo.Sessions', 'U') IS NOT NULL DROP TABLE dbo.Sessions
GO

DECLARE @numrows AS INT;
SET @numrows = 10000;
-- Test with 10K - 100K

SELECT
  IDENTITY(int, 1, 1) AS keycol, 
  D.*,
  DATEADD(
    second,
    1 + ABS(CHECKSUM(NEWID())) % (20*60),
    starttime) AS endtime
INTO dbo.Sessions
FROM
(
  SELECT 
    'app' + CAST(1 + ABS(CHECKSUM(NEWID())) % 10 AS VARCHAR(10)) AS app,
    'user1' AS usr,
    'host1' AS host,
    DATEADD(
      second,
      1 + ABS(CHECKSUM(NEWID())) % (30*24*60*60),
      '20090101') AS starttime
  FROM dbo.Nums
  WHERE n <= @numrows
) AS D;

ALTER TABLE dbo.Sessions ADD PRIMARY KEY(keycol);
CREATE INDEX idx_app_st_et ON dbo.Sessions(app, starttime, endtime);

CHECKPOINT;
DBCC FREEPROCCACHE WITH NO_INFOMSGS;
DBCC DROPCLEANBUFFERS WITH NO_INFOMSGS;

DECLARE @dt1 AS DATETIME, @dt2 AS DATETIME,
  @dt3 AS DATETIME, @dt4 AS DATETIME;
SET @dt1 = GETDATE();

-- Set-Based Solution
SELECT app, MAX(concurrent) AS mx
FROM (SELECT app,
        (SELECT COUNT(*)
         FROM dbo.Sessions AS S
         WHERE T.app = S.app
           AND T.ts >= S.starttime
           AND T.ts < S.endtime) AS concurrent
      FROM (SELECT app, starttime AS ts FROM dbo.Sessions) AS T) AS C
GROUP BY app;

SET @dt2 = GETDATE();

DBCC FREEPROCCACHE WITH NO_INFOMSGS;
DBCC DROPCLEANBUFFERS WITH NO_INFOMSGS;

SET @dt3 = GETDATE();

-- Cursor-Based Solution
DECLARE
  @app AS VARCHAR(10), @prevapp AS VARCHAR (10), @ts AS datetime,
  @event_type AS INT, @concurrent AS INT, @mx AS INT;

DECLARE @Result TABLE(app VARCHAR(10), mx INT);

DECLARE C CURSOR FAST_FORWARD FOR
  SELECT app, starttime AS ts, 1 AS event_type FROM dbo.Sessions
  UNION ALL
  SELECT app, endtime, -1 FROM dbo.Sessions
  ORDER BY app, ts, event_type;

OPEN C;

FETCH NEXT FROM C INTO @app, @ts, @event_type;
SELECT @prevapp = @app, @concurrent = 0, @mx = 0;

WHILE @@FETCH_STATUS = 0
BEGIN
  IF @app <> @prevapp
  BEGIN
    INSERT INTO @Result VALUES(@prevapp, @mx);
    SELECT @prevapp = @app, @concurrent = 0, @mx = 0;
  END

  SET @concurrent = @concurrent + @event_type;
  IF @concurrent > @mx SET @mx = @concurrent;
  
  FETCH NEXT FROM C INTO @app, @ts, @event_type;
END

IF @prevapp IS NOT NULL
  INSERT INTO @Result VALUES(@prevapp, @mx);

CLOSE C;

DEALLOCATE C;

SELECT * FROM @Result;

SET @dt4 = GETDATE();

PRINT CAST(@numrows AS VARCHAR(10)) + ' rows, set-based: '
  + CAST(DATEDIFF(ms, @dt1, @dt2) / 1000. AS VARCHAR(30))
  + ', cursor: '
  + CAST(DATEDIFF(ms, @dt3, @dt4) / 1000. AS VARCHAR(30))
  + ' (sec)';
GO

-- Using the OVER Clause
SELECT app, MAX(concurrent) AS mx 
FROM (SELECT app, SUM(event_type) 
        OVER(PARTITION BY app
             ORDER BY ts, event_type
             ROWS BETWEEN UNBOUNDED PRECEDING
                      AND CURRENT ROW) AS concurrent 
      FROM (SELECT app, starttime AS ts, 1 AS event_type FROM dbo.Sessions 
            UNION ALL 
            SELECT app, endtime, -1 FROM dbo.Sessions) AS D1) AS D2 
GROUP BY app;

-- Bad Sample Data...
-- Rerun the code in Listing 8-2

-- First against existing data
SELECT app, MAX(concurrent) AS mx
FROM (SELECT app,
        (SELECT COUNT(*)
         FROM dbo.Sessions AS S
         WHERE T.app = S.app
           AND T.ts >= S.starttime
           AND T.ts < S.endtime) AS concurrent
      FROM (SELECT app, starttime AS ts FROM dbo.Sessions) AS T) AS C
GROUP BY app;
GO

-- Next, populate the table with duplicates
INSERT INTO dbo.Sessions
  SELECT app, usr, host, starttime, endtime
  FROM dbo.Sessions
    JOIN dbo.Nums
      ON n <= 10000;

-- Rerun query

---------------------------------------------------------------------
-- Matching Problems
---------------------------------------------------------------------

-- Code that Creates and Populates the Events and Rooms Tables
USE tempdb;
IF OBJECT_ID('dbo.Events', 'U') IS NOT NULL DROP TABLE dbo.Events;
IF OBJECT_ID('dbo.Rooms', 'U') IS NOT NULL DROP TABLE dbo.Rooms;
GO

CREATE TABLE dbo.Rooms
(
  roomid VARCHAR(10) NOT NULL PRIMARY KEY,
  seats INT NOT NULL
);

INSERT INTO dbo.Rooms(roomid, seats) VALUES
  ('C001', 2000),
  ('B101', 1500),
  ('B102', 100),
  ('R103', 40),
  ('R104', 40),
  ('B201', 1000),
  ('R202', 100),
  ('R203', 50),
  ('B301', 600),
  ('R302', 55),
  ('R303', 55);

CREATE TABLE dbo.Events
(
  eventid INT NOT NULL PRIMARY KEY,
  eventdesc VARCHAR(25) NOT NULL,
  attendees INT NOT NULL
);

INSERT INTO dbo.Events(eventid, eventdesc, attendees) VALUES
  (1, 'Adv T-SQL Seminar', 203),
  (2, 'Logic Seminar',     48),
  (3, 'DBA Seminar',       212),
  (4, 'XML Seminar',       98),
  (5, 'Security Seminar',  892),
  (6, 'Modeling Seminar',  48);

CREATE UNIQUE INDEX idx_att_eid_edesc
  ON dbo.Events(attendees, eventid, eventdesc);
CREATE UNIQUE INDEX idx_seats_rid
  ON dbo.Rooms(seats, roomid);
GO

-- Cursor Code for Matching Problem (guaranteed solution)
DECLARE
  @roomid AS VARCHAR(10), @seats AS INT,
  @eventid AS INT, @attendees AS INT;

DECLARE @Result AS TABLE(roomid  VARCHAR(10), eventid INT);

DECLARE CRooms CURSOR FAST_FORWARD FOR
  SELECT roomid, seats FROM dbo.Rooms
  ORDER BY seats, roomid;
DECLARE CEvents CURSOR FAST_FORWARD FOR
  SELECT eventid, attendees FROM dbo.Events
  ORDER BY attendees, eventid;

OPEN CRooms;
OPEN CEvents;

FETCH NEXT FROM CEvents INTO @eventid, @attendees;
WHILE @@FETCH_STATUS = 0
BEGIN
  FETCH NEXT FROM CRooms INTO @roomid, @seats;

  WHILE @@FETCH_STATUS = 0 AND @seats < @attendees
    FETCH NEXT FROM CRooms INTO @roomid, @seats;

  IF @@FETCH_STATUS = 0
    INSERT INTO @Result(roomid, eventid) VALUES(@roomid, @eventid);
  ELSE
  BEGIN
    RAISERROR('Not enough rooms for events.', 16, 1);
    BREAK;
  END

  FETCH NEXT FROM CEvents INTO @eventid, @attendees;
END

CLOSE CRooms;
CLOSE CEvents;

DEALLOCATE CRooms;
DEALLOCATE CEvents;

SELECT roomid, eventid FROM @Result;
GO

-- First remove rooms where seats > 600
DELETE FROM dbo.Rooms WHERE seats > 600;
GO

-- Cursor Code for Matching Problem (nonguaranteed solution)
DECLARE
  @roomid AS VARCHAR(10), @seats AS INT,
  @eventid AS INT, @attendees AS INT;

DECLARE @Events AS TABLE(eventid INT, attendees INT);
DECLARE @Result AS TABLE(roomid  VARCHAR(10), eventid INT);

-- Step 1: Descending
DECLARE CRoomsDesc CURSOR FAST_FORWARD FOR
  SELECT roomid, seats FROM dbo.Rooms
  ORDER BY seats DESC, roomid DESC;
DECLARE CEventsDesc CURSOR FAST_FORWARD FOR
  SELECT eventid, attendees FROM dbo.Events
  ORDER BY attendees DESC, eventid DESC;

OPEN CRoomsDesc;
OPEN CEventsDesc;

FETCH NEXT FROM CRoomsDesc INTO @roomid, @seats;
WHILE @@FETCH_STATUS = 0
BEGIN
  FETCH NEXT FROM CEventsDesc INTO @eventid, @attendees;

  WHILE @@FETCH_STATUS = 0 AND @seats < @attendees
    FETCH NEXT FROM CEventsDesc INTO @eventid, @attendees;

  IF @@FETCH_STATUS = 0
    INSERT INTO @Events(eventid, attendees)
      VALUES(@eventid, @attendees);
  ELSE
    BREAK;

  FETCH NEXT FROM CRoomsDesc INTO @roomid, @seats;
END

CLOSE CRoomsDesc;
CLOSE CEventsDesc;

DEALLOCATE CRoomsDesc;
DEALLOCATE CEventsDesc;

-- Step 2: Ascending
DECLARE CRooms CURSOR FAST_FORWARD FOR
  SELECT roomid, seats FROM Rooms
  ORDER BY seats, roomid;
DECLARE CEvents CURSOR FAST_FORWARD FOR
  SELECT eventid, attendees FROM @Events
  ORDER BY attendees, eventid;

OPEN CRooms;
OPEN CEvents;

FETCH NEXT FROM CEvents INTO @eventid, @attendees;
WHILE @@FETCH_STATUS = 0
BEGIN
  FETCH NEXT FROM CRooms INTO @roomid, @seats;

  WHILE @@FETCH_STATUS = 0 AND @seats < @attendees
    FETCH NEXT FROM CRooms INTO @roomid, @seats;

  IF @@FETCH_STATUS = 0
    INSERT INTO @Result(roomid, eventid) VALUES(@roomid, @eventid);
  ELSE
  BEGIN
    RAISERROR('Not enough rooms for events.', 16, 1);
    BREAK;
  END

  FETCH NEXT FROM CEvents INTO @eventid, @attendees;
END

CLOSE CRooms;
CLOSE CEvents;

DEALLOCATE CRooms;
DEALLOCATE CEvents;

SELECT roomid, eventid FROM @Result;
GO
