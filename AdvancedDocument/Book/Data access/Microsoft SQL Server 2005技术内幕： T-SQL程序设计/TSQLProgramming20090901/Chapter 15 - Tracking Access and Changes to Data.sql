---------------------------------------------------------------------
-- Inside Microsoft SQL Server 2008: T-SQL Programming (MSPress, 2009)
-- Chapter 15 - Tracking Access and Changes to Data
-- Copyright Dr Greg Low, 2009
-- All Rights Reserved
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Extended Events
---------------------------------------------------------------------

USE master;
GO

-- Modules are the top-level containers (.exe or .dll).
-- At release, all packages were exposed from a single module.

SELECT name,module_guid FROM sys.dm_xe_packages;

-- Packages are containers exposed from within modules (.exe, .dll)
-- Four standard packages are exposed when SQL Server is installed

SELECT name,capabilities,description FROM sys.dm_xe_packages;

-- Potential values for capabilities (bitmap)

SELECT DISTINCT capabilities,capabilities_desc
FROM sys.dm_xe_objects;

-- Different packages have different values for capabilities

SELECT DISTINCT capabilities_desc, package_guid 
FROM sys.dm_xe_objects
WHERE capabilities = 1024
ORDER BY package_guid;

-- Different values for 1024

SELECT DISTINCT capabilities_desc, package_guid 
FROM sys.dm_xe_objects
WHERE capabilities = 1024
ORDER BY package_guid;

-- Events are one object type exposed from within packages

SELECT dxp.[name] AS Package,
       dxo.[name] AS EventName,
       dxo.capabilities_desc AS Capabilities,
       dxo.[description] AS Description
FROM sys.dm_xe_packages AS dxp
INNER JOIN sys.dm_xe_objects AS dxo
ON dxp.[guid] = dxo.package_guid
WHERE dxo.object_type = 'event'
ORDER BY Package,EventName;

-- Predicates filter event records

SELECT dxp.[name] AS Package,
       dxo.[name] AS Predicate,
       dxo.[description] AS Description
FROM sys.dm_xe_packages AS dxp
INNER JOIN sys.dm_xe_objects AS dxo
ON dxp.[guid] = dxo.package_guid
WHERE dxo.object_type IN ('pred_compare','pred_source')
ORDER BY Package,Predicate;

-- sql_statement_completed columns

SELECT column_id AS ID,
       [name] AS Name,
       [TYPE_NAME] AS DataType,
       column_type AS ColumnType,
       [description] AS Description
FROM sys.dm_xe_object_columns
WHERE object_name = 'sql_statement_completed'
ORDER BY ColumnType DESC, ID;

-- available actions

SELECT dxp.[name] AS Package,
       dxo.[name] AS ActionName,
       dxo.[description] AS Description,
       dxo.[type_name] AS TypeName
FROM sys.dm_xe_packages AS dxp
INNER JOIN sys.dm_xe_objects AS dxo
ON dxp.[guid] = dxo.package_guid
WHERE dxo.object_type = 'action'
ORDER BY Package,ActionName;

-- available maps

SELECT dxp.[name] AS Package,
       dxo.[name] AS MapName,
       dxo.[description] AS Description
FROM sys.dm_xe_packages AS dxp
INNER JOIN sys.dm_xe_objects AS dxo
ON dxp.[guid] = dxo.package_guid
WHERE dxo.object_type = 'map'
ORDER BY Package,MapName;

-- Map values for the Lock Owner Type map

SELECT map_key,
       map_value
FROM sys.dm_xe_map_values 
WHERE [name] = 'lock_owner_type'
ORDER BY map_key;

-- available targets

SELECT dxp.[name] AS Package,
       dxo.[name] AS TargetName,
       dxo.[description] AS Description
FROM sys.dm_xe_packages AS dxp
INNER JOIN sys.dm_xe_objects AS dxo
ON dxp.[guid] = dxo.package_guid
WHERE dxo.object_type = 'target'
ORDER BY Package,TargetName;

---------------------------------------------------------------
-- Scenario - locate queries with high logical reads
---------------------------------------------------------------

CREATE EVENT SESSION High_Logical_Read_Queries
ON SERVER
ADD EVENT sqlserver.sql_statement_completed
  (ACTION (sqlserver.database_id,
           sqlserver.sql_text)
   WHERE reads > 4000)
ADD TARGET package0.asynchronous_file_target
  (SET filename=N'c:\temp\High_Logical_Read_Queries.xel')
WITH (MAX_DISPATCH_LATENCY = 1 SECONDS);
       
-- Start the event session

ALTER EVENT SESSION High_Logical_Read_Queries
ON SERVER STATE = START;

-- Query the contents of the event record file

SELECT * 
FROM sys.fn_xe_file_target_read_file
('c:\temp\*.xel','c:\temp\*.xem',NULL,NULL);

-- Generate some log entries

USE InsideTSQL2008;
GO
SELECT * FROM Production.Products;
GO
SELECT * FROM Production.Products WHERE unitprice > 10;
GO
SELECT * 
FROM Production.Products AS p
CROSS JOIN Sales.OrderDetails AS od;
GO

-- Query the contents of the event record file again

SELECT * 
FROM sys.fn_xe_file_target_read_file
('c:\temp\*.xel','c:\temp\*.xem',NULL,NULL);
  
-- CASTing the event_data column

SELECT CAST(event_data AS XML) AS EventLog 
FROM sys.fn_xe_file_target_read_file
('c:\temp\*.xel','c:\temp\*.xem',NULL,NULL);
     
-- Obtaining relational values from the query

SELECT EventLog.value('(/event[@name=''sql_statement_completed'']/@timestamp)[1]','datetime') AS LogTime,
       EventLog.value('(/event/data[@name=''reads'']/value)[1]','int') AS Reads,
       EventLog.value('(/event/action[@name=''sql_text'']/value)[1]','varchar(max)') AS SQL_Text
FROM ( SELECT CAST(event_data AS XML) AS EventLog 
       FROM sys.fn_xe_file_target_read_file
       ('c:\temp\*.xel','c:\temp\*.xem',NULL,NULL)
     ) AS LogRecord
ORDER BY LogTime; 
GO

-- Explore current sessions

SELECT [name] AS SessionName,
       total_buffer_size AS BufferSize,
       buffer_policy_desc AS Policy,
       flag_desc AS Flags,
       create_time AS CreateTime
FROM sys.dm_xe_sessions;

-- Exploring system_health

SELECT column_name AS ColumnName,
       column_value AS Value,
       object_type AS ObjectType,
       [object_name] AS ObjectName 
FROM sys.dm_xe_sessions AS s
INNER JOIN sys.dm_xe_session_object_columns AS c
ON s.address = c.event_session_address 
WHERE s.[name] = 'system_health'
ORDER BY c.column_id;

SELECT a.event_name AS EventName,
       CAST(a.event_predicate AS XML) AS Predicate
FROM sys.dm_xe_sessions AS s
INNER JOIN sys.dm_xe_session_events AS a
ON s.address = a.event_session_address 
WHERE s.[name] = 'system_health'
ORDER BY EventName;

SELECT a.event_name AS EventName,
       a.action_name AS ActionName
FROM sys.dm_xe_sessions AS s
INNER JOIN sys.dm_xe_session_event_actions AS a
ON s.address = a.event_session_address 
WHERE s.[name] = 'system_health'
ORDER BY EventName,ActionName;

SELECT t.target_name AS TargetName,
       t.execution_count AS Executions,
       t.execution_duration_ms AS Duration,
       CAST(t.target_data AS XML) AS TargetData
FROM sys.dm_xe_sessions AS s
INNER JOIN sys.dm_xe_session_targets AS t
ON s.address = t.event_session_address 
WHERE s.[name] = 'system_health'
ORDER BY TargetName;

-- Stop the event session

ALTER EVENT SESSION High_Logical_Read_Queries
ON SERVER STATE = STOP;

-- Drop the event session

DROP EVENT SESSION High_Logical_Read_Queries
ON SERVER;

--------------------------------------------------------
-- Notes on alteration of event sessions
--------------------------------------------------------
--ALTER EVENT SESSION High_Logical_Read_Queries ON SERVER
--ADD EVENT sqlserver.database_transaction_begin,
--ADD EVENT sqlserver.database_transaction_end;
--GO

--------------------------------------------------------
-- Auditing
--------------------------------------------------------

USE InsideTSQL2008;
GO

-- list available server audit groups

SELECT DISTINCT a.containing_group_name AS ActionGroup
FROM sys.dm_audit_actions AS a
WHERE a.class_desc = 'SERVER'
ORDER BY ActionGroup;

-- drill into the audit_change_group

SELECT a.[name] AS ActionName,
       a.class_desc AS Class
FROM sys.dm_audit_actions AS a
WHERE a.covering_parent_action_name = 'AUDIT_CHANGE_GROUP'
AND a.parent_class_desc = 'SERVER'
ORDER BY ActionName;

-- list available database audit groups

SELECT DISTINCT a.containing_group_name AS ActionGroup
FROM sys.dm_audit_actions AS a
WHERE a.class_desc = 'DATABASE'
ORDER BY ActionGroup;

-- list actions that can be individually configured

SELECT a.action_id AS ID,
       a.[name] AS ActionName
FROM sys.dm_audit_actions AS a
WHERE a.class_desc = 'DATABASE'
AND a.configuration_level = 'Action'
ORDER BY ActionName;

-------------------------------------------------------
-- Auditing scenario
-------------------------------------------------------

-- Create the Server Audit

USE master;
GO

CREATE SERVER AUDIT InsideTSQL_HR_Audit
TO FILE (FILEPATH = 'c:\temp\HR_Audit',
         MAXSIZE = 2GB,
         MAX_ROLLOVER_FILES = 100)
WITH (QUEUE_DELAY = 0, ON_FAILURE = SHUTDOWN);

-- create a server audit to catch logins and logouts

CREATE SERVER AUDIT SPECIFICATION Login_Logout_Audit
FOR SERVER AUDIT InsideTSQL_HR_Audit
ADD (SUCCESSFUL_LOGIN_GROUP),
ADD (FAILED_LOGIN_GROUP),
ADD (LOGOUT_GROUP)
WITH (STATE = OFF);

-- audit access to the HR schema

USE InsideTSQL2008;
GO

CREATE DATABASE AUDIT SPECIFICATION HR_Schema_Audit
FOR SERVER AUDIT InsideTSQL_HR_Audit
ADD (SELECT ON SCHEMA::HR BY public),
ADD (INSERT ON SCHEMA::HR BY public),
ADD (UPDATE ON SCHEMA::HR BY public),
ADD (DELETE ON SCHEMA::HR BY public),
ADD (EXECUTE ON SCHEMA::HR BY public),
ADD (RECEIVE ON SCHEMA::HR BY public);

-- enable our objects

USE master;
GO

ALTER SERVER AUDIT InsideTSQL_HR_Audit
WITH (STATE = ON);

ALTER SERVER AUDIT SPECIFICATION Login_Logout_Audit
FOR SERVER AUDIT InsideTSQL_HR_Audit
WITH (STATE = ON);

USE InsideTSQL2008;
GO

ALTER DATABASE AUDIT SPECIFICATION HR_Schema_Audit
FOR SERVER AUDIT InsideTSQL_HR_Audit
WITH (STATE = ON);

-- view the contents of the audit

SELECT event_time AS EventTime,
       sequence_number AS Seq,
       action_id AS ID,
       succeeded AS [S/F],
       session_id AS SessionID,
       server_principal_name AS SPrincipal
FROM sys.fn_get_audit_file('c:\temp\HR_Audit\*.sqlaudit',
                           DEFAULT, 
                           DEFAULT);
                           
-- test auditing of the HR schema

SELECT * FROM HR.Employees;

-- look for select entries

SELECT event_time AS EventTime,
       sequence_number AS Seq,
       action_id AS ID,
       succeeded AS [S/F],
       session_id AS SessionID,
       server_principal_name AS SPrincipal,
       [statement] AS [Statement]
FROM sys.fn_get_audit_file('c:\temp\HR_Audit\*.sqlaudit',
                           DEFAULT, 
                           DEFAULT)
WHERE action_id = 'SL'
ORDER BY EventTime;

-- viewing details of the audit objects

SELECT * FROM sys.dm_audit_actions;
SELECT * FROM sys.dm_server_audit_status;
SELECT * FROM sys.dm_audit_class_type_map;

SELECT * FROM sys.server_audits;
SELECT * FROM sys.server_audit_specifications;
SELECT * FROM sys.server_audit_specification_details;
SELECT * FROM sys.database_audit_specifications;
SELECT * FROM sys.database_audit_specification_details;

-- viewing audits via Extended Events infrastructure

SELECT p.[Name] AS PackageName,
       s.[Name] AS SessionName,
       se.event_name AS EventName,
       st.target_name AS TargetName
FROM sys.dm_xe_sessions AS s
INNER JOIN sys.dm_xe_session_events AS se
ON s.address = se.event_session_address 
INNER JOIN sys.dm_xe_packages AS p
ON se.event_package_guid = p.guid 
INNER JOIN sys.dm_xe_session_targets AS st
ON s.address = st.event_session_address
WHERE s.[name] <> 'system_health'
ORDER BY PackageName,SessionName,EventName,TargetName;
GO
---------------------------------------------------------
-- Indirect and Parameterized Access
---------------------------------------------------------

IF OBJECT_ID('Sales.Employees', 'V') IS NOT NULL
  DROP VIEW Sales.Employees;
GO

CREATE VIEW Sales.Employees
AS
  SELECT * FROM HR.Employees;
GO

SELECT * FROM Sales.Employees;

-- recheck select actions

SELECT event_time AS EventTime,
       sequence_number AS Seq,
       action_id AS ID,
       succeeded AS [S/F],
       session_id AS SessionID,
       server_principal_name AS SPrincipal,
       [statement] AS [Statement]
FROM sys.fn_get_audit_file('c:\temp\HR_Audit\*.sqlaudit',
                           DEFAULT, 
                           DEFAULT)
WHERE action_id = 'SL'
ORDER BY EventTime;
GO

-- try a parameterized query

IF OBJECT_ID('Sales.EmployeesByTitle','P') IS NOT NULL
  DROP PROCEDURE Sales.EmployeesByTitle;
GO

CREATE PROCEDURE Sales.EmployeesByTitle
@TitleOfCourtesy nvarchar(25)
AS
  SELECT * 
  FROM HR.Employees AS e
  WHERE e.titleofcourtesy = @TitleOfCourtesy;
GO

EXEC Sales.EmployeesByTitle 'Mrs.';

-- recheck select actions

SELECT event_time AS EventTime,
       sequence_number AS Seq,
       action_id AS ID,
       succeeded AS [S/F],
       session_id AS SessionID,
       server_principal_name AS SPrincipal,
       [statement] AS [Statement]
FROM sys.fn_get_audit_file('c:\temp\HR_Audit\*.sqlaudit',
                           DEFAULT, 
                           DEFAULT)
WHERE action_id = 'SL'
ORDER BY EventTime;
GO

-- remove our audit configuration 

USE master;
GO

ALTER SERVER AUDIT InsideTSQL_HR_Audit
WITH (STATE = OFF);

DROP SERVER AUDIT InsideTSQL_HR_Audit;
GO

ALTER SERVER AUDIT SPECIFICATION Login_Logout_Audit
WITH (STATE = OFF);

DROP SERVER AUDIT SPECIFICATION Login_Logout_Audit;

USE InsideTSQL2008;
GO

ALTER DATABASE AUDIT SPECIFICATION HR_Schema_Audit
WITH (STATE = OFF);

DROP DATABASE AUDIT SPECIFICATION HR_Schema_Audit;
GO

DROP VIEW Sales.Employees;
DROP PROCEDURE Sales.EmployeesByTitle;
GO

-------------------------------------------------------------------
-- Change Tracking
-------------------------------------------------------------------

USE InsideTSQL2008;
GO

ALTER DATABASE InsideTSQL2008
  SET ALLOW_SNAPSHOT_ISOLATION ON;
  
ALTER DATABASE InsideTSQL2008
  SET CHANGE_TRACKING = ON;
  
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
GO

-- view change-tracked databases

SELECT database_id AS ID,
       is_auto_cleanup_on AS AutoCleanup,
       CAST(retention_period AS varchar(10)) 
         + ' ' 
         + retention_period_units_desc  AS RetentionPeriod
FROM sys.change_tracking_databases
ORDER BY ID;

-- enable at the table level

ALTER TABLE HR.Employees
  ENABLE CHANGE_TRACKING;

-- view change-tracked tables
  
SELECT OBJECT_NAME(object_id) AS TableName,
       is_track_columns_updated_on AS ColumnTracking,
       min_valid_version AS MinValidVersion,
       begin_version AS BeginVersion,
       cleanup_version AS CleanupVersion
FROM sys.change_tracking_tables
ORDER BY TableName;

-- internal tables created

SELECT [name] AS TableName,
       type_desc AS TableType,
       internal_type_desc AS [Description]
FROM sys.internal_tables
ORDER BY TableName;

-- modify the employees table

INSERT INTO HR.Employees 
  (firstname,lastname,mgrid,title,titleofcourtesy,
   birthdate,hiredate,[address],city,country,phone)
  VALUES ('Michael','Entin',1,'','Mr.','19490101','20090401',
          '19 some lane','London','UK','n/a'),
         ('John','Chen',1,'','Mr.','19490201','20090401',
          '42 some street','London','UK','n/a'),
         ('Terry','Earls',1,'','Dr.','19490301','20090401',
          '35 some avenue','London','UK','n/a');
         
UPDATE HR.Employees
  SET firstname = 'Peter'
  WHERE firstname = 'Michael' AND lastname = 'Entin';
  
-- view the change tracking current version

SELECT CHANGE_TRACKING_CURRENT_VERSION();

-- make another change

UPDATE HR.Employees
  SET firstname = 'Paul'
  WHERE firstname = 'Peter' AND lastname = 'Entin';

-- view the change tracking current version

SELECT CHANGE_TRACKING_CURRENT_VERSION();

-- avoiding the need for snapshot isolation on the initial sync

SELECT CHANGE_TRACKING_CURRENT_VERSION() AS CurrentVersion,
       empid, lastname, firstname, title, 
       titleofcourtesy, birthdate, hiredate, 
       [address], city, region, postalcode, 
       country, phone, mgrid
FROM HR.Employees;

-- further data changes

INSERT INTO HR.Employees 
  (firstname,lastname,mgrid,title,titleofcourtesy,
   birthdate,hiredate,[address],city,country,phone)
  VALUES ('Bob','Kelly',1,'','Mr.','19490401','20090402',
          '19 some boulevarde','Los Angeles','USA','n/a');

UPDATE HR.Employees 
  SET titleofcourtesy = 'Dr.'
  WHERE firstname = 'John' AND lastname = 'Chen';
           
DELETE FROM HR.Employees 
  WHERE firstname = 'Terry' AND lastname = 'Earls';
  
-- check that our version is recent enough

SELECT CHANGE_TRACKING_MIN_VALID_VERSION(OBJECT_ID(N'HR.Employees','TABLE'));

-- find changes since we last sync'd

SELECT c.empid, c.SYS_CHANGE_OPERATION,
       e.lastname, e.firstname, e.title, 
       e.titleofcourtesy, e.birthdate, e.hiredate, 
       e.[address], e.city, e.region, e.postalcode, 
       e.country, e.phone, e.mgrid
FROM CHANGETABLE(CHANGES HR.Employees,3) AS c
LEFT OUTER JOIN HR.Employees AS e
ON c.empid = e.empid
ORDER BY c.empid;

-- try an earlier version -> 1

SELECT c.empid, c.SYS_CHANGE_OPERATION,
       e.lastname, e.firstname, e.title, 
       e.titleofcourtesy, e.birthdate, e.hiredate, 
       e.[address], e.city, e.region, e.postalcode, 
       e.country, e.phone, e.mgrid
FROM CHANGETABLE(CHANGES HR.Employees,1) AS c
LEFT OUTER JOIN HR.Employees AS e
ON c.empid = e.empid
ORDER BY c.empid;

-- try an earlier version -> 0

SELECT c.empid, c.SYS_CHANGE_OPERATION,
       e.lastname, e.firstname, e.title, 
       e.titleofcourtesy, e.birthdate, e.hiredate, 
       e.[address], e.city, e.region, e.postalcode, 
       e.country, e.phone, e.mgrid
FROM CHANGETABLE(CHANGES HR.Employees,0) AS c
LEFT OUTER JOIN HR.Employees AS e
ON c.empid = e.empid
ORDER BY c.empid;

-- calculate space used

EXEC sp_spaceused 'sys.change_tracking_2105058535';
EXEC sp_spaceused 'sys.syscommittab';

-- version parameter

SELECT e.empid,
       c.SYS_CHANGE_VERSION,
       c.SYS_CHANGE_CONTEXT
FROM HR.Employees AS e
CROSS APPLY CHANGETABLE(VERSION HR.Employees,(empid),(e.empid)) AS c
ORDER BY e.empid;

GO
-- using change tracking context

DECLARE @TrackingContext VARBINARY(128);
DECLARE @UserDetails XML;

SET @UserDetails = (SELECT USER_NAME() AS UserName
                    FOR XML RAW('User'));

SET @TrackingContext = CAST(@UserDetails AS VARBINARY(MAX));

WITH CHANGE_TRACKING_CONTEXT(@TrackingContext)
UPDATE HR.Employees 
  SET titleofcourtesy = 'Mr.'
  WHERE firstname = 'John' AND lastname = 'Chen';
GO
  
-- recheck the context

SELECT e.empid,
       c.SYS_CHANGE_VERSION,
       CAST(c.SYS_CHANGE_CONTEXT AS XML) AS UserDetails
FROM HR.Employees AS e
CROSS APPLY CHANGETABLE(VERSION HR.Employees,(empid),(e.empid)) AS c
ORDER BY e.empid;
GO

DELETE FROM HR.Employees WHERE empid > 9;

DBCC CHECKIDENT(‘HR.Employees’,RESEED,9); 
  
ALTER TABLE HR.Employees
  DISABLE CHANGE_TRACKING;

ALTER DATABASE InsideTSQL2008
  SET CHANGE_TRACKING = OFF;
  
ALTER DATABASE InsideTSQL2008
  SET ALLOW_SNAPSHOT_ISOLATION OFF;

-----------------------------------------------------------
-- Change Data Capture
-----------------------------------------------------------

USE master;
GO

CREATE DATABASE CDC;
GO

USE CDC;
GO

IF OBJECT_ID('dbo.Employees','U') IS NOT NULL
  DROP TABLE dbo.Employees;
GO

CREATE TABLE dbo.Employees
( EmployeeID int IDENTITY(1,1) PRIMARY KEY CLUSTERED,
  FullName nvarchar(50) NOT NULL,
  BadgeNumber nvarchar(20) NOT NULL
);
GO

INSERT dbo.Employees (FullName, BadgeNumber)
  VALUES('John Chen','2343Q'),
        ('Terry Earls','3423B'),
        ('Michael Entin','5234Q'); 
GO

-- enable CDC at the database level

EXEC sp_cdc_enable_db;

-- investigate the new user and schema

SELECT uid, roles, hasdbaccess,islogin,issqluser 
FROM sys.sysusers 
WHERE [name] = 'cdc';

SELECT * FROM sys.schemas WHERE name = 'cdc';

-- investigate the trigger

SELECT [name],[object_id],parent_class_desc,type_desc 
FROM sys.triggers;

SELECT [object_id], type_desc 
FROM sys.trigger_events;

-- enable CDC at the table level -> note: SQL Agent must be running

EXEC sys.sp_cdc_enable_table
  @source_schema = 'dbo',
  @source_name = 'Employees',
  @supports_net_changes = 1,
  @role_name = NULL;

-- view the jobs created

EXEC sp_cdc_help_jobs;

-- make some changes

INSERT dbo.Employees (FullName, BadgeNumber)
  VALUES('Brian Burke','5243Z');
GO

UPDATE dbo.Employees 
  SET FullName = 'Terry Earls'  
  WHERE BadgeNumber = '5243Z';
  
DELETE dbo.Employees WHERE BadgeNumber = '5234Q';
GO


-- query the change table directly

SELECT __$start_lsn,
       __$operation,
       __$update_mask,
       EmployeeID, FullName 
FROM cdc.dbo_Employees_CT
ORDER BY __$start_lsn;

GO

-- access changes via functions

DECLARE @From_LSN binary(10);
SET @From_LSN = sys.fn_cdc_get_min_lsn('dbo_Employees');
DECLARE @To_LSN binary(10);
SET @To_LSN = sys.fn_cdc_get_max_lsn();

SELECT * FROM cdc.fn_cdc_get_all_changes_dbo_Employees
                (@From_LSN,@To_LSN,'all');
SELECT * FROM cdc.fn_cdc_get_net_changes_dbo_Employees
                (@From_LSN,@To_LSN,'all');
GO

-- access using time functions

-- access changes via functions

IF OBJECT_ID('dbo.Get_Employee_Data_Changes','P') IS NOT NULL
  DROP PROCEDURE dbo.Get_Employee_Data_Changes;
GO

CREATE PROCEDURE dbo.Get_Employee_Data_Changes
@FromTime datetime,
@LastTime datetime OUTPUT
AS
  DECLARE @From_LSN binary(10);
  SET @From_LSN = sys.fn_cdc_map_time_to_lsn(
    'smallest greater than or equal', @FromTime);
    
  DECLARE @To_LSN binary(10);
  SET @To_LSN = sys.fn_cdc_get_max_lsn();

  SET @LastTime = sys.fn_cdc_map_lsn_to_time(@To_LSN);
  
  SELECT * FROM cdc.fn_cdc_get_all_changes_dbo_Employees
                (@From_LSN,@To_LSN,'all');
GO

-- get changes in the last day

DECLARE @FromTime datetime = DATEADD(DAY,-1,SYSDATETIME());
DECLARE @LastTime datetime;

EXEC dbo.Get_Employee_Data_Changes @FromTime, @LastTime OUTPUT;
GO

-- add a column

ALTER TABLE dbo.Employees
  ADD CourtesyTitle nvarchar(20) DEFAULT ('Mr');
GO

-- get the changes again

DECLARE @FromTime datetime = DATEADD(DAY,-1,SYSDATETIME());
DECLARE @LastTime datetime;

EXEC dbo.Get_Employee_Data_Changes @FromTime, @LastTime OUTPUT;
GO

-- drop the BadgeNumber column

ALTER TABLE dbo.Employees
  DROP COLUMN BadgeNumber;
GO

-- get the changes again

DECLARE @FromTime datetime = DATEADD(DAY,-1,SYSDATETIME());
DECLARE @LastTime datetime;

EXEC dbo.Get_Employee_Data_Changes @FromTime, @LastTime OUTPUT;
GO

-- another modification

UPDATE dbo.Employees 
  SET FullName = 'Test User'
  WHERE FullName = 'Terry Earls';
GO


-- get the changes again

DECLARE @FromTime datetime = DATEADD(DAY,-1,SYSDATETIME());
DECLARE @LastTime datetime;

EXEC dbo.Get_Employee_Data_Changes @FromTime, @LastTime OUTPUT;
GO

-- check the DDL history

EXEC sys.sp_cdc_get_ddl_history N'dbo_Employees';
GO

-- scanning sessions

SELECT * FROM sys.dm_cdc_log_scan_sessions;
GO

-- view captured columns if not all columns captured

EXEC sys.sp_cdc_get_captured_columns 'dbo.Employees';

-- clean up

EXEC sys.sp_cdc_disable_db;
GO

USE master;
GO

DROP DATABASE CDC;
GO 
