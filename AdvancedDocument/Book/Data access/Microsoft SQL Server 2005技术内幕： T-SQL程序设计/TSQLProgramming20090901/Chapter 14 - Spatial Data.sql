---------------------------------------------------------------------
-- Inside Microsoft SQL Server 2008: T-SQL Programming (MSPress, 2009)
-- Chapter 14: Spatial Data
-- Copyright Ed Katibah and Isaac Kunen, 2009
-- All Rights Reserved
---------------------------------------------------------------------

---------------------------------------------------------------------
--THE BASICS
---------------------------------------------------------------------
--Creating a table with a Spatial Column
---------------------------------------------------------------------
USE tempdb;
GO
CREATE TABLE t1 (
ID INT IDENTITY(1,1) PRIMARY KEY,
NAME VARCHAR(64),
GEOM GEOMETRY
);
GO

--TRUNCATE TABLE t1
---------------------------------------------------------------------
--Constructing Spatial Objects from Strings and Inserting into a Table
---------------------------------------------------------------------
--  Point1 with no SRID value specified
INSERT INTO t1 VALUES ('Point1', geometry::Parse('POINT(3 4)'));
--  Point2 OGC constructor with SRID value of 0
INSERT INTO t1 VALUES ('Point2', geometry::Point(5, 3, 0));
-- Line1
INSERT INTO t1 VALUES ('Line1', geometry::STLineFromText('LINESTRING(2 2, 5 5)',0));
-- Line2
INSERT INTO t1 VALUES ('Line2', geometry::STGeomFromText('LINESTRING(5 1, 6 1, 6 2, 7 2, 7 3)',0));
-- Area1
INSERT INTO t1 VALUES ('Area1', geometry::STPolyFromText('POLYGON ((1 1, 4 1, 4 5, 1 5, 1 1))',0));
-- Area2
INSERT INTO t1 VALUES ('Area2', geometry::STGeomFromText('POLYGON ((5 4, 5 7, 8 7, 8 4, 5 4))',1));
-- Query table, return geometry as binary (hex)...
SELECT ID, NAME, GEOM FROM t1;
-- Query table, return geometry as text (WKT)...
SELECT ID, NAME, GEOM.STAsText() AS LOCATION FROM t1;
-- Query table, then select "Spatial results..." in Management Studio
--   Note error message about SRIDs
SELECT ID, NAME, GEOM FROM t1;
-- Update the "bad" SRID value from 1 to 0 for Area2
UPDATE t1
  SET GEOM.STSrid = 0
    WHERE NAME = 'Area2';
-- Query table, then select "Spatial results..." in Management Studio.
--   Everything works as expected this time...
SELECT ID, NAME, GEOM FROM t1;
-- Use the "buffer" trick to make points visible...
SELECT ID,NAME,GEOM FROM t1
UNION ALL
SELECT ID,NAME,GEOM.STBuffer(.1)
  FROM t1
WHERE GEOM.InstanceOf('Point')=1;

/*---------------------------------------------------------------------
-- Creating a spatial index
---------------------------------------------------------------------
CREATE SPATIAL INDEX t1_geom_sidx
   ON t1(GEOM)
   USING GEOMETRY_GRID
   WITH (
     BOUNDING_BOX = (
		xmin=0, 
		ymin=0, 
		xmax=9, 
		ymax=8),
     GRIDS = (MEDIUM, MEDIUM, MEDIUM, MEDIUM),
     CELLS_PER_OBJECT = 16,
     PAD_INDEX = ON );
*/
---------------------------------------------------------------------
-- Basic Object Interaction Tests
---------------------------------------------------------------------
USE tempdb
GO

DROP TABLE Points;
DROP TABLE Lines;
DROP TABLE Polygons;

USE tempdb;
GO
CREATE TABLE Points (
ID INT IDENTITY(1,1) PRIMARY KEY,
NAME VARCHAR(64),
GEOM GEOMETRY
);
GO
CREATE TABLE Lines (
ID INT IDENTITY(1,1) PRIMARY KEY,
NAME VARCHAR(64),
GEOM GEOMETRY
);
GO
CREATE TABLE Polygons (
ID INT IDENTITY(1,1) PRIMARY KEY,
NAME VARCHAR(64),
GEOM GEOMETRY
);
GO

--populate tables with data
INSERT INTO Points VALUES('Point1', geometry::Parse('POINT(3 4)'));
INSERT INTO Points VALUES('Point2', geometry::STGeomFromText('POINT(5 3)',0));
INSERT INTO Points VALUES('Point3', geometry::STGeomFromText('POINT(5 2)',0));
INSERT INTO Points VALUES('Point4', geometry::STGeomFromText('POINT(2 4.7)',0));
INSERT INTO Points VALUES('Point5', geometry::STGeomFromText('POINT(4.1 2)',0));
INSERT INTO Lines VALUES('Line1', geometry::STGeomFromText('LINESTRING(2 2, 5 5)',0));
INSERT INTO Lines VALUES('Line2', geometry::STGeomFromText('LINESTRING(5 1, 6 1, 6 2, 7 2, 7 3)',0));
INSERT INTO Lines VALUES('Line3', geometry::STGeomFromText('LINESTRING(4 7, 5 1.5)',0));
INSERT INTO Polygons VALUES('Area1', geometry::STGeomFromText('POLYGON ((1 1, 4 1, 4 5, 1 5,1 1))',0));
INSERT INTO Polygons VALUES('Area2', geometry::STGeomFromText('POLYGON ((5 4, 5 7, 8 7, 8 4, 5 4))',0));
INSERT INTO Polygons VALUES('Area3', geometry::STGeomFromText('POLYGON ((2 3, 6 3, 6 6, 2 6, 2 3))',0));
GO

--Illustration in Management Studio...
SELECT GEOM.STBuffer(.1) FROM Points
UNION ALL
SELECT GEOM.STBuffer(.02) FROM Lines
UNION ALL
SELECT GEOM .STBuffer(.02) FROM Polygons;
GO

--which points intersect the polygon Area1
DECLARE @polygon GEOMETRY;
SET @polygon = (SELECT GEOM FROM Polygons WHERE NAME = 'Area1');
SELECT NAME FROM Points WHERE @polygon.STIntersects(GEOM)=1;
GO
-- OUTPUT:
--
-- NAME
-- -----
-- Point1
-- Point4

--which polygons intersect Line1:
DECLARE @line GEOMETRY;
SET @line = (SELECT GEOM FROM Lines WHERE NAME = 'Line1');
SELECT NAME FROM Polygons WHERE @line.STIntersects(GEOM)=1;
GO
-- OUTPUT:
--
-- NAME
-- -----
-- Area1
-- Area2
-- Area3

--test for the opposite of intersection: disjointness using the STDisjoint() method:
DECLARE @line GEOMETRY;
SET @line = (SELECT GEOM FROM Lines WHERE NAME = 'Line1');
DECLARE @area GEOMETRY;
SET @area = (SELECT GEOM FROM Polygons WHERE NAME = 'Area2');
SELECT @line.STDisjoint(@area) AS Disjoint;
GO
-- OUTPUT:
--
-- Disjoint
-- --------
-- 0

--We can ask the same question about Line2 and Area2:
DECLARE @line GEOMETRY;
DECLARE @area GEOMETRY;
SET @line = (SELECT GEOM FROM Lines WHERE NAME = 'Line2');
SET @area = (SELECT GEOM FROM Polygons WHERE NAME = 'Area2');
SELECT @line.STDisjoint(@area) AS Disjoint;
GO
-- OUTPUT:
--
-- Disjoint
-- --------
-- 1

---------------------------------------------------------------------
-- Basic Spatial Operations 
---------------------------------------------------------------------
-- Intersecting Spatial Objects
---------------------------------------------------------------------
--make a new spatial object that is the intersection of polygons Area1 and Area3 and display well-known text for the resulting object:
DECLARE @area1 GEOMETRY;
DECLARE @area3 GEOMETRY;
SET @area1 = (SELECT GEOM FROM Polygons WHERE NAME = 'Area1');
SET @area3 = (SELECT GEOM FROM Polygons WHERE NAME = 'Area3');
SELECT @area1.STIntersection(@area3).STAsText() AS Well_Known_Text;
GO
-- OUTPUT:
--
-- Well_Known_Text
-- -----------------------------------
-- POLYGON ((2 3, 4 3, 4 5, 2 5, 2 3))

--Figure 14-9 query
DECLARE @area1 GEOMETRY;
DECLARE @area3 GEOMETRY;
DECLARE @line1 GEOMETRY;
DECLARE @line3 GEOMETRY;
SET @line1 = GEOMETRY::STGeomFromText('LINESTRING (1 1, 4 1, 4 5, 1 5, 1 1)',0);
SET @line3 = GEOMETRY::STGeomFromText('LINESTRING (2 3, 6 3, 6 6, 2 6, 2 3)',0);
SET @area1 = (SELECT GEOM FROM Polygons WHERE NAME = 'Area1');
SET @area3 = (SELECT GEOM FROM Polygons WHERE NAME = 'Area3');
SELECT 'Intersection',@area1.STIntersection(@area3) as GEOM
UNION ALL
SELECT '', @line1.STBuffer(.02)
UNION ALL
SELECT '', @line3.STBuffer(.02);
GO

--Intersection of Area 1 and Area2 text results
DECLARE @area1 GEOMETRY;
DECLARE @area2 GEOMETRY;
SET @area1 = (SELECT GEOM FROM Polygons WHERE NAME = 'Area1');
SET @area2 = (SELECT GEOM FROM Polygons WHERE NAME = 'Area2');
SELECT @area1.STIntersection(@area2).STAsText() AS Well_Known_Text;
GO
-- OUTPUT:
--
-- Well_Known_Text
-- ------------------------
-- GEOMETRYCOLLECTION EMPTY

--intersect a polygon and a point:
DECLARE @area1 GEOMETRY;
DECLARE @point1 GEOMETRY;
SET @area1 = (SELECT GEOM FROM Polygons WHERE NAME = 'Area1');
SET @point1 = (SELECT GEOM FROM Points WHERE NAME = 'Point1');
SELECT @area1.STIntersection(@point1).STAsText() AS Well_Known_Text;
GO
-- OUTPUT:
--
-- Well_Known_Text
-- ---------------
-- POINT (3 4)

---------------------------------------------------------------------
--Union of Spatial Objects
---------------------------------------------------------------------
--union two objects of similar types, in this case points:
DECLARE @point1 GEOMETRY;
DECLARE @point2 GEOMETRY;
SET @point1 = (SELECT GEOM FROM Points WHERE NAME = 'Point1');
SET @point2 = (SELECT GEOM FROM Points WHERE NAME = 'Point2');
SELECT @point1.STUnion(@point2).STAsText() AS Well_Known_Text;
GO
-- OUTPUT:
--
-- Well_Known_Text
-- -------------------------
-- MULTIPOINT ((3 4), (5 3))

--union objects of different types:
DECLARE @point1 GEOMETRY;
DECLARE @line1 GEOMETRY;
SET @point1 = (SELECT GEOM FROM Points WHERE NAME = 'Point1');
SET @line1 = (SELECT GEOM FROM Lines WHERE NAME = 'Line1');
SELECT @point1.STUnion(@line1).STAsText() AS Well_Known_Text;
GO
-- OUTPUT:
--
-- Well_Known_Text
-- -------------------------------------------------------
-- GEOMETRYCOLLECTION (POINT (3 4), LINESTRING (5 5, 2 2))

--union two objects, one of which lies wholly within the other?  For example, if we union Point1 with Area1, we may expect another GEOMETRYCOLLECTION:
DECLARE @point1 GEOMETRY;
DECLARE @area1 GEOMETRY;
DECLARE @union1 GEOMETRY;
SET @point1 = (SELECT GEOM FROM Points WHERE NAME = 'Point1');
SET @area1 = (SELECT GEOM FROM Polygons WHERE NAME = 'Area1');
SET @union1 = @area1.STUnion(@point1);
SELECT @union1.STAsText() AS Well_Known_Text;
GO
-- OUTPUT:
--
-- Well_Known_Text
-- -----------------------------------
-- POLYGON ((1 1, 4 1, 4 5, 1 5, 1 1))

--Union dissimilar objects that overlap
DECLARE @line1 GEOMETRY;
DECLARE @area1 GEOMETRY;
SET @line1 = (SELECT GEOM FROM Lines WHERE NAME = 'Line1');
SET @area1 = (SELECT GEOM FROM Polygons WHERE NAME = 'Area1');
SELECT @line1.STUnion(@area1).STAsText() AS Well_Known_Text;
GO
-- OUTPUT:
--
-- Well_Known_Text
-- -------------------------------------------------------------------------------
-- GEOMETRYCOLLECTION (LINESTRING (5 5,4 4), POLYGON ((1 1,4 1,4 4,4 5,1 5,1 1)))

---------------------------------------------------------------------
-- Generalization of Spatial Objects
---------------------------------------------------------------------
DECLARE @small_triangle GEOMETRY;
DECLARE @thin_polygon GEOMETRY;
DECLARE @jagged_line GEOMETRY;
SET @small_triangle = geometry::STGeomFromText(
  'POLYGON((9 1,10 1,9.5 2,9 1))',0);
SET @thin_polygon = geometry::STGeomFromText(
  'POLYGON((1 2.5,19 2.5,19 3,1 3,1 2.5))',0);
SET @jagged_line = geometry::STGeomFromText(
  'LINESTRING(1 5,2 5,3 8,4 5,5 6,5 5,6 6,6 5,8 8,8 5,9 6,10 5,
    11 6,12 4,13 7,14 5,15 6,15 4,16 7,16 5,18 8,18 5,19 5)',0);
GO

--Display the three spatial objects:
DECLARE @small_triangle GEOMETRY;
DECLARE @thin_polygon GEOMETRY;
DECLARE @jagged_line GEOMETRY;
SET @small_triangle = geometry::STGeomFromText(
  'POLYGON((9 1,10 1,9.5 2,9 1))',0);
SET @thin_polygon = geometry::STGeomFromText(
  'POLYGON((1 2.5,19 2.5,19 3,1 3,1 2.5))',0);
SET @jagged_line = geometry::STGeomFromText(
  'LINESTRING(1 5,2 5,3 8,4 5,5 6,5 5,6 6,6 5,8 8,8 5,9 6,10 5,
    11 6,12 4,13 7,14 5,15 6,15 4,16 7,16 5,18 8,18 5,19 5)',0);
SELECT @small_triangle
UNION ALL
SELECT @thin_polygon
UNION ALL
SELECT @jagged_line;
GO

--Reduce the geometries with a tolerance of 2:
DECLARE @small_triangle GEOMETRY;
DECLARE @thin_polygon GEOMETRY;
DECLARE @jagged_line GEOMETRY;
SET @small_triangle  = GEOMETRY::STGeomFromText(
  'POLYGON((9 1,10 1,9.5 2,9 1))',0);
SET @thin_polygon = GEOMETRY::STGeomFromText(
  'POLYGON((1 2.5,19 2.5,19 3,1 3,1 2.5))',0);
SET @jagged_line = GEOMETRY::STGeomFromText(
  'LINESTRING(1 5,2 5,3 8,4 5,5 6,5 5,6 6,6 5,8 8,8 5,9 6,10 5,
    11 6,12 4,13 7,14 5,15 6,15 4,16 7,16 5,18 8,18 5,19 5)',0);

SET @small_triangle = @small_triangle.Reduce(2);
SET @thin_polygon = @thin_polygon.Reduce(2);
SET @jagged_line = @jagged_line.Reduce(2);
GO

--Figure 14-14: reduce the geometries using a tolerance parameter value of 2:
DECLARE @small_triangle GEOMETRY;
DECLARE @thin_polygon GEOMETRY;
DECLARE @jagged_line GEOMETRY;
SET @small_triangle = geometry::STGeomFromText(
  'POLYGON((9 1,10 1,9.5 2,9 1))',0);
SET @thin_polygon = geometry::STGeomFromText(
  'POLYGON((1 2.5,19 2.5,19 3,1 3,1 2.5))',0);
SET @jagged_line = geometry::STGeomFromText(
  'LINESTRING(1 5,2 5,3 8,4 5,5 6,5 5,6 6,6 5,8 8,8 5,9 6,10 5,
    11 6,12 4,13 7,14 5,15 6,15 4,16 7,16 5,18 8,18 5,19 5)',0);
    
SET @small_triangle = @small_triangle.Reduce(2);
SET @thin_polygon = @thin_polygon.Reduce(2);
SET @jagged_line = @jagged_line.Reduce(2);

SELECT @small_triangle
UNION ALL
SELECT @thin_polygon
UNION ALL
SELECT @jagged_line;
GO

--Text representation: reduce the geometries using a parameter value of 2:
DECLARE @small_triangle GEOMETRY;
DECLARE @thin_polygon GEOMETRY;
DECLARE @jagged_line GEOMETRY;
SET @small_triangle  = GEOMETRY::STGeomFromText(
  'POLYGON((9 1,10 1,9.5 2,9 1))',0);
SET @thin_polygon = GEOMETRY::STGeomFromText(
  'POLYGON((1 2.5,19 2.5,19 3,1 3,1 2.5))',0);
SET @jagged_line = GEOMETRY::STGeomFromText(
  'LINESTRING(1 5,2 5,3 8,4 5,5 6,5 5,6 6,6 5,8 8,8 5,9 6,10 5,
    11 6,12 4,13 7,14 5,15 6,15 4,16 7,16 5,18 8,18 5,19 5)',0);

SET @small_triangle = @small_triangle.Reduce(2);
SET @thin_polygon = @thin_polygon.Reduce(2);
SET @jagged_line = @jagged_line.Reduce(2);

SELECT @small_triangle.STAsText() AS Well_Known_Text;
SELECT @thin_polygon. STAsText() AS Well_Known_Text;
--SELECT @jagged_line.STAsText() AS Well_Known_Text;
GO
-- OUTPUT:
--
-- Well_Known_Text
-- ---------------
-- LINESTRING (19 3, 1 2.5)
-- POINT (9 1)

---------------------------------------------------------------------
--PROXIMITY QUERIES
---------------------------------------------------------------------
--Distance Tests Between Spatial Objects
---------------------------------------------------------------------
--Figure 14-16 query:
SELECT ID,NAME,GEOM.STBuffer(.075) FROM Points
UNION ALL
SELECT ID,NAME,GEOM.STBuffer(.0175) FROM Lines
UNION ALL
SELECT ID,NAME,GEOM FROM Polygons
UNION ALL
SELECT ID,NAME,GEOM.STBuffer(.4) FROM Lines WHERE NAME = 'Line3'
--UNION ALL
--SELECT ID,NAME,GEOM FROM Points;
GO

--Using the STDistance() method, we can determine what points are within .4 units of distance from Line3:
DECLARE @line GEOMETRY;
SET @line = (SELECT GEOM FROM Lines WHERE NAME = 'Line3');
SELECT NAME FROM Points WHERE @line.STDistance(GEOM) <= .4;
GO
-- OUTPUT: 
--
-- NAME
-- ----
-- Point2
-- Point3

--which polygons are within .4 units of Line3:
DECLARE @line GEOMETRY
SET @line = (SELECT GEOM FROM Lines WHERE NAME = 'Line3');
SELECT NAME FROM Polygons WHERE @line.STDistance(GEOM) <= .4;
GO
-- OUTPUT: 
--
-- NAME
-- -----
-- Area1
-- Area3

--We can also compute how far objects are away from each other.  For instance, we can find exactly how far Line3 is from Point2:
DECLARE @Line3 GEOMETRY =
  (SELECT GEOM FROM Lines WHERE NAME = 'Line3');
DECLARE @Point2 GEOMETRY =
  (SELECT GEOM FROM Points WHERE NAME = 'Point2');
SELECT @Point2.STDistance(@Line3) AS Distance;
GO
-- OUTPUT: 
--
-- Distance
-- -----------------
-- 0.268328157299975

--The distance is computed between two points is an intuitive concept, but how is the distance between two complex objects—e.g., between a LINESTRING and a POLYGON—defined?  The distance computed is the minimum distance between the objects.  The following T-SQL computes the minimum distance between Line3 and Area2:
DECLARE @Line3 GEOMETRY =
  (SELECT GEOM FROM Lines WHERE NAME = 'Line3');
DECLARE @Area2 GEOMETRY =
  (SELECT GEOM FROM Polygons WHERE NAME = 'Area2');
SELECT @Area2.STDistance(@Line3) AS Distance;
GO
-- OUTPUT: 
--
-- Distance
-- -----------------
-- 0.447213595499958

--If two objects intersect, this distance is 0:
DECLARE @Line3 GEOMETRY =
  (SELECT GEOM FROM Lines WHERE NAME = 'Line3');
DECLARE @Line1 GEOMETRY =
  (SELECT GEOM FROM Lines WHERE NAME = 'Line1');
SELECT @Line1.STDistance(@Line3) AS Distance;
GO
-- OUTPUT: 
--
-- Distance
-- --------
-- 0

---------------------------------------------------------------------
--Spatial Buffers
---------------------------------------------------------------------
--buffer a point object
DECLARE @point GEOMETRY;
DECLARE @buffer GEOMETRY
SET @point = (SELECT GEOM FROM Points WHERE NAME = 'Point1');
SET @buffer = @point.STBuffer(1);
SELECT @buffer AS Buffer;
GO

--Figure 14-17: buffer a point object
DECLARE @point GEOMETRY;
DECLARE @buffer GEOMETRY
SET @point = (SELECT GEOM FROM Points WHERE NAME = 'Point1');
SET @buffer = @point.STBuffer(1);
SELECT @buffer
UNION ALL
SELECT @point.STBuffer(.05)
UNION ALL
SELECT @point;
GO

--buffer Area1 by .4 units:
DECLARE @area GEOMETRY;
DECLARE @buffer GEOMETRY;
SET @area = (SELECT GEOM FROM Polygons WHERE NAME = 'Area1');
SELECT @buffer = @area.STBuffer(.4);
SELECT @buffer;
GO

--Figure 14-18, buffer Area1 by .4 units:
-- use Select label column: Description
DECLARE @area GEOMETRY;
DECLARE @buffer GEOMETRY;
SET @area = (SELECT GEOM FROM Polygons WHERE NAME = 'Area1');
SET @buffer = (SELECT @area.STBuffer(.4));
DECLARE @interior GEOMETRY;
SET @interior = (SELECT @area.STExteriorRing());
SELECT ' ' AS Description,@buffer
UNION ALL
SELECT 'Area1 Polygon Boundary' AS Description,@interior;
GO

---------------------------------------------------------------------
--Comparing Spatial Buffers to Distance-based Calculations to Test Proximity
---------------------------------------------------------------------
--proximity test to determine which points intersect a buffered polygon around Area1:
DECLARE @area GEOMETRY;
DECLARE @buffer GEOMETRY;
SET @area = (SELECT GEOM FROM Polygons WHERE NAME = 'Area1');
SET @buffer = @area.STBuffer(.4);
SELECT NAME FROM Points WHERE GEOM.STIntersects(@buffer)=1;
GO
-- OUTPUT:
--
-- NAME
-- ----
-- Point1
-- Point4
-- Point5

--same query as above, using STDistance(), presented earlier:
DECLARE @polygon GEOMETRY;
SET @polygon = (SELECT GEOM FROM Polygons WHERE NAME = 'Area1');
SELECT NAME FROM Points WHERE @polygon.STDistance(GEOM) <= .4;
GO
-- OUTPUT:
--
-- NAME
-- ----
-- Point1
-- Point4
-- Point5

--The first method creates a region, .4 units wide, around  the 
--outside and the inside of the Area1 polygon boundary.  
--This is done by constructing two new buffer objects, 
--one .4 units larger and one .4 units smaller and taking 
--their difference with the STDifference() method. 
--The new region is intersected against the Points table:
DECLARE @area GEOMETRY;
DECLARE @region GEOMETRY;
DECLARE @distance FLOAT;
SET @distance = .4;
SET @area = (SELECT GEOM FROM Polygons WHERE NAME = 'Area1');
SET @region = @area.STBuffer(@distance).STDifference(@area.STBuffer(@distance * -1));
SELECT NAME
  FROM Points
    WHERE GEOM.STIntersects(@region)=1;
GO
-- OUTPUT
--
-- NAME
-- ----
-- Point4
-- Point5

--The second method uses the STExteriorRing() method to convert 
--the Area1 boundary into a LINESTRING.  The STDistance() method 
--is then used to find all points within .4 units of the --
--LINESTRING:
DECLARE @area GEOMETRY;
DECLARE @distance FLOAT = .4;
SET @area = (SELECT GEOM FROM Polygons WHERE NAME = 'Area1');
SELECT NAME
  FROM Points
    WHERE GEOM.STDistance(@area.STBoundary()) <= @distance;
GO
-- OUTPUT
--
-- NAME
-- ----
-- Point4
-- Point5

--Substituting STExteriorRing() for STDistance()...
DECLARE @area GEOMETRY;
DECLARE @distance FLOAT = .4;
SET @area = (SELECT GEOM FROM Polygons WHERE NAME = 'Area1');
SELECT NAME 
  FROM Points 
    WHERE GEOM.STDistance(@area.STExteriorRing()) <= @distance;
GO
-- OUTPUT
--
-- NAME
-- ----
-- Point4
-- Point5    

--Figure 14-19 query:
DECLARE @area GEOMETRY;
DECLARE @distance FLOAT = .4;
DECLARE @boundary GEOMETRY;
DECLARE @region GEOMETRY;
SET @area = (SELECT GEOM FROM Polygons WHERE NAME = 'Area1');
SET @region = @area.STBuffer(@distance).STDifference(@area.STBuffer(@distance * -1));
SET @boundary = (SELECT @area.STBoundary());
SELECT ' ' AS Description, GEOM FROM Points 
UNION ALL
SELECT ' ' AS Description, GEOM.STBuffer(.1) FROM Points 
UNION ALL
SELECT 'Area1 Polygon Boundary' AS Description,@boundary
UNION ALL
SELECT ' ' AS Description, @region;s
GO
       
---------------------------------------------------------------------
-- THE GEOGRAPHY TYPE
---------------------------------------------------------------------
-- The Geography Type and SRIDS
---------------------------------------------------------------------
-- Query illustrating differences with companion GEOMETRY-based query
--
-- The companion GEOMETRY-based table was named t1.  For this exercise
-- the table is named g1
---------------------------------------------------------------------

USE tempdb;
GO

CREATE TABLE g1 (
ID INT IDENTITY(1,1) PRIMARY KEY,
NAME VARCHAR(64),
GEOG GEOGRAPHY
);
GO

--Constructing Spatial Objects from Strings and Inserting into a Table
--  Point1 with no SRID value specified

INSERT INTO g1 VALUES('Point1', geography::Parse('POINT(3 4)'));
GO

--Let’s retrieve the SRID value for GEOG and verify the default SRID value:
SELECT GEOG.STSrid AS SRID FROM g1 WHERE NAME = 'Point1';
GO
-- OUTPUT
--
-- SRID
-- ----
-- 4326
 
--Let’s take a more detailed look at SRID 4326 as defined in the sys.spatial_reference_systems view:
SELECT * FROM sys.spatial_reference_systems
WHERE spatial_reference_id = 4326;
GO
-- OUTPUT:
--
--spatial_reference_id	authority_name	authorized_spatial_reference_id	                                                                                   well_known_text	                                                            unit_of_measure	unit_conversion_factor
--                4326	          EPSG	                           4326	 GEOGCS["WGS 84", DATUM["World Geodetic System 1984", ELLIPSOID["WGS 84", 6378137, 298.257223563]], PRIMEM["Greenwich", 0], UNIT["Degree", 0.0174532925199433]]	          metre	                     1

-- Continue populating the rest of the the table, g1...
--  Point2 non-OGC constructor with SRID value of 4326 (note: input order is ("latitude", "longitude", "srid")
INSERT INTO g1 VALUES ('Point2', geography::Point(3,5,4326));
--Insert using OGC-compliant constructors
-- Line1
INSERT INTO g1 VALUES
  ('Line1', geography::STLineFromText('LINESTRING(2 2, 5 5)',4326));
-- Line2
INSERT INTO g1 VALUES
  ('Line2', geography::STGeomFromText('LINESTRING(5 1, 6 1, 6 2, 7 2, 7 3)',4326));
GO

--The Geography Type and Coordinate Ordering
-- Area1
INSERT INTO g1 VALUES
  ('Area1', geography::STPolyFromText('POLYGON ((1 1, 4 1, 4 5, 1 5, 1 1))',4326));
-- Area2
INSERT INTO g1 VALUES
  ('Area2', geography::STGeomFromText('POLYGON ((5 4, 5 7, 8 7, 8 4, 5 4))',4326));
GO
--OUTPUT: ERROR!  Invalid geography instance?
--Problem: polygon exterior ring coordinate ordering...
--Fix by reording coordinates...
INSERT INTO g1 VALUES
  ('Area2', geography::STGeomFromText('POLYGON ((5 4, 8 4, 8 7, 5 7, 5 4))',4326));
GO

--SPATIAL DATA VALIDITY
--Data Validity Issues With Geometry Data

USE tempdb;
GO

CREATE TABLE Polygons_Valid (
ID INT IDENTITY(1,1) PRIMARY KEY,
NAME VARCHAR(64),
GEOM GEOMETRY
);	

--Next, we insert an invalid polygon:
INSERT INTO Polygons_Valid
VALUES('Area1',
  geometry::STGeomFromText(
    'POLYGON((1 1, 1 3, 2 3, 4 1, 5 1, 5 3, 4 3, 2 1, 1 1))',0)); 
GO   
    
--Here is the test to see whether this is a valid polygon:
DECLARE @geometry GEOMETRY;
SET @geometry = (SELECT GEOM FROM Polygons_Valid WHERE NAME = 'Area1');
SELECT @geometry.STIsValid() AS IS_VALID_GEOMETRY;
GO
-- OUTPUT:
--
-- IS_VALID_GEOMETRY
-- -----------------
-- 0

--If we try to execute a spatial operation against this instance—for example, a test to see whether a point intersects it—we get an error:
DECLARE @point GEOMETRY;
DECLARE @polygon GEOMETRY;
SET @point = geometry::Parse('POINT(1 2)');
SET @polygon = (SELECT GEOM FROM Polygons_Valid WHERE NAME = 'Area1');
SELECT NAME FROM Polygons_Valid WHERE @polygon.STIntersects(@point)=1;
GO
-- OUTPUT:
--
-- Error Message: System.ArgumentException: 24144

--Let’s run MakeValid() and see what it does:
DECLARE @polygon GEOMETRY;
SET @polygon = (SELECT GEOM FROM Polygons_Valid WHERE NAME = 'Area1');
SELECT @polygon.MakeValid().STAsText() AS WKT;
-- OUTPUT:
--
--WKT
-- ---------------------------------------------------------------------------------
-- MULTIPOLYGON (((4 1, 5 1, 5 3, 4 3, 3 2, 4 1)), ((1 1, 2 1, 3 2, 2 3, 1 3, 1 1)))

--Caution note on MakeValid():
DECLARE @polygon GEOMETRY;
SET @polygon = GEOMETRY::STGeomFromText('POLYGON((1 1, 1 2, 2 2, 2 1, 1 1, 1 2, 2 2, 2 1, 1 1))',0);
SELECT @polygon.STIsValid() AS IS_VALID_GEOMETRY;
SELECT @polygon.MakeValid().STAsText() AS WKT;
GO
-- OUTPUT:
--
-- IS_VALID_GEOMETRY
-- -----------------
-- 0
--
-- WKT
-- ------------------------------------
-- LINESTRING (1 1, 2 1, 2 2, 1 2, 1 1)


/*
--=================================================================================
-- The following geography-based T-SQL queries are not in Chapter 14, Spatial Data.
-- They perform same basic functionality as the geometry-basedqueries  in the the 
-- THE BASICS, GEOMETRY queries section.
--=================================================================================
-- Query table, return geometry as binary (hex)...
SELECT ID, NAME, GEOG FROM g1;
GO
-- Query table, return geometry as text (WKT)...
SELECT ID, NAME, GEOG.STAsText() FROM g1;
GO

-- Query table, then select "Spatial results..." in Management Studio
--   Note error message about SRIDs
SELECT ID, NAME, GEOG FROM g1;
GO
-- Update the "bad" SRID value from 1 to 0 for Area2
UPDATE g1 
  SET GEOG.STSrid = 4326 WHERE NAME = 'Area2'
GO

-- Query table, then select "Spatial results..." in Management Studio.
--   Everything works as expected this time...
SELECT ID, NAME, GEOG FROM g1;
-- Use the "buffer" trick to make points visible...
SELECT ID,NAME,GEOG FROM g1
UNION ALL
SELECT ID,NAME,GEOG.STBuffer(10000) -- distance is not specified in meters...
  FROM g1 
    WHERE GEOG.InstanceOf('Point')=1;
GO

-- Create spatial index
CREATE SPATIAL INDEX g1_geog_sidx
   ON g1(GEOG)
   USING GEOGRAPHY_GRID
   WITH (
     GRIDS = (MEDIUM, MEDIUM, MEDIUM, MEDIUM),
     CELLS_PER_OBJECT = 16,
     PAD_INDEX = ON );
GO

--Spatial –Basic Object Interaction Tests for the geography data type

CREATE TABLE PointsG (
ID INT IDENTITY(1,1) PRIMARY KEY,
NAME VARCHAR(64),
GEOG GEOGRAPHY
);
GO

CREATE TABLE LinesG (
ID INT IDENTITY(1,1) PRIMARY KEY,
NAME VARCHAR(64),
GEOG GEOGRAPHY
);
GO

CREATE TABLE PolygonsG (
ID INT IDENTITY(1,1) PRIMARY KEY,
NAME VARCHAR(64),
GEOG GEOGRAPHY
);
GO

INSERT INTO PointsG VALUES('Point1', GEOGRAPHY::Parse('POINT(3 4)'));
GO

--Let's check the default SRID valid, since previous insert did not specify SRID
SELECT geog.STSrid FROM PointsG WHERE NAME = 'Point1'
--Result: 4326

INSERT INTO PointsG VALUES('Point2', GEOGRAPHY::STGeomFromText('POINT(5 3)',4326));
INSERT INTO PointsG VALUES('Point3', GEOGRAPHY::STGeomFromText('POINT(5 2)',4326));
INSERT INTO PointsG VALUES('Point4', GEOGRAPHY::STGeomFromText('POINT(2 4.7)',4326));
INSERT INTO PointsG VALUES('Point5', GEOGRAPHY::STGeomFromText('POINT(4.1 2)',4326));
INSERT INTO LinesG VALUES('Line1', GEOGRAPHY::STGeomFromText('LINESTRING(2 2, 5 5)',4326));
INSERT INTO LinesG VALUES('Line2', GEOGRAPHY::STGeomFromText('LINESTRING(5 1, 6 1, 6 2, 7 2, 7 3)',4326));
INSERT INTO LinesG VALUES('Line3', GEOGRAPHY::STGeomFromText('LINESTRING(4 7, 5 1.5)',4326));
INSERT INTO PolygonsG VALUES('Area1', GEOGRAPHY::STGeomFromText('POLYGON ((1 1, 4 1, 4 5, 1 5, 1 1))',4326));
GO
--This insert will fail due to ring order
INSERT INTO PolygonsG VALUES('Area2', GEOGRAPHY::STGeomFromText('POLYGON ((5 4, 5 7, 8 7, 8 4, 5 4))',4326));
GO
--Orient ring correct for geography type and try again...
INSERT INTO PolygonsG VALUES('Area2', GEOGRAPHY::STGeomFromText('POLYGON ((5 4, 8 4, 8 7, 5 7, 5 4))',4326));
GO
INSERT INTO PolygonsG VALUES('Area3', GEOGRAPHY::STGeomFromText('POLYGON ((2 3, 6 3, 6 6, 2 6, 2 3))',4326));
GO

-- Spatial Index Construction
-- PointsG
CREATE SPATIAL INDEX geog_mmmm16_sidx
   ON PointsG(GEOG)
   USING GEOGRAPHY_GRID
   WITH (
     GRIDS = (MEDIUM, MEDIUM, MEDIUM, MEDIUM),
     CELLS_PER_OBJECT = 16,
     PAD_INDEX = ON );
GO
     
-- LinesG
CREATE SPATIAL INDEX geog_mmmm16_sidx
   ON LinesG(GEOG)
   USING GEOGRAPHY_GRID
   WITH (
     GRIDS = (MEDIUM, MEDIUM, MEDIUM, MEDIUM),
     CELLS_PER_OBJECT = 16,
     PAD_INDEX = ON );
GO
    
-- PolygonsG
CREATE SPATIAL INDEX geog_mmmm16_sidx
   ON PolygonsG(GEOG)
   USING GEOGRAPHY_GRID
   WITH (
     GRIDS = (MEDIUM, MEDIUM, MEDIUM, MEDIUM),
     CELLS_PER_OBJECT = 16,
     PAD_INDEX = ON );
GO

--Illustration in Management Studio...
SELECT ID,NAME,GEOG.STBuffer(8000) FROM PointsG
UNION ALL
SELECT ID,NAME,GEOG.STBuffer(3000) FROM LinesG
UNION ALL
SELECT ID,NAME,GEOG FROM PolygonsG
--UNION ALL
--SELECT ID,NAME,GEOM FROM Points
GO

--which points intersect the polygon Area1
DECLARE @p GEOGRAPHY;
SET @p = (SELECT GEOG FROM PolygonsG WHERE NAME = 'Area1');
SELECT NAME FROM PointsG WHERE @p.STIntersects(GEOG)=1;
--OUTPUT:
--
-- NAME
-- ------
-- Point1
-- Point4

--which polygons intersect Line1:
DECLARE @l GEOGRAPHY;
SET @l = (SELECT @l = GEOG FROM LinesG WHERE NAME = 'Line1');
SELECT NAME FROM PolygonsG WHERE @l.STIntersects(GEOG)=1;
--OUTPUT:
--
-- NAME
-- ------
-- Area1
-- Area2
-- Area3

--test for the opposite of intersection: disjointness using the STDisjoint() method:
DECLARE @l GEOGRAPHY;
DECLARE @a GEOGRAPHY;
SET @l = (SELECT GEOG FROM LinesG WHERE NAME = 'Line1');
SET @a = (SELECT GEOG FROM PolygonsG WHERE NAME = 'Area2');
SELECT @l.STDisjoint(@a) AS DISJOINT;
--OUTPUT:
--
-- DISJOINT
-- --------
-- 0

--We can ask the same question about Line2 and Area2:
DECLARE @l GEOGRAPHY;
DECLARE @a GEOGRAPHY;
SET @l = (SELECT GEOG FROM LinesG WHERE NAME = 'Line2');
SET @a = (SELECT GEOG FROM PolygonsG WHERE NAME = 'Area2');
SELECT @l.STDisjoint(@a) AS DISJOINT;
GO
--OUTPUT:
--
-- DISJOINT
-- --------
-- 1


--Basic Spatial Operations 

--make a new spatial object that is the intersection of polygons Area1 and Area3 and 
--  display well-known text for the resulting object:
DECLARE @a1 GEOGRAPHY;
DECLARE @a3 GEOGRAPHY;
SET @a1 = (SELECT GEOG FROM PolygonsG WHERE NAME = 'Area1');
SET @a3 = (SELECT GEOG FROM PolygonsG WHERE NAME = 'Area3');
SELECT @a1.STIntersection(@a3).STAsText();
GO
--OUTPUT:
--
-- POLYGON ((2.0000000390850325 5.0015157594800819, 2 3, 3.9999999656756859 3.0018253242418766, 
--           4 5, 2.0000000390850325 5.0015157594800819))

--accompanying illustration query
DECLARE @a1 GEOGRAPHY;
DECLARE @a3 GEOGRAPHY;
DECLARE @l1 GEOGRAPHY;
DECLARE @l3 GEOGRAPHY;
SET @l1 = GEOGRAPHY::STGeomFromText('LINESTRING (1 1, 4 1, 4 5, 1 5, 1 1)',4326);
SET @l3 = GEOGRAPHY::STGeomFromText('LINESTRING (2 3, 6 3, 6 6, 2 6, 2 3)',4326);
SET @a1 = (SELECT GEOG FROM PolygonsG WHERE NAME = 'Area1');
SET @a3 = (SELECT GEOG FROM PolygonsG WHERE NAME = 'Area3');
SELECT 'Intersection',@a1.STIntersection(@a3) as GEOG
UNION ALL
SELECT '', @l1.STBuffer(4000)
UNION ALL
SELECT '', @l3.STBuffer(4000);
GO

--Intersection of Area1 and Area 2
DECLARE @a1 GEOGRAPHY;
DECLARE @a2 GEOGRAPHY;
SET @a1 = (SELECT GEOG FROM PolygonsG WHERE NAME = 'Area1');
SET @a2 = (SELECT GEOG FROM PolygonsG WHERE NAME = 'Area2');
SELECT @a1
UNION ALL
SELECT @a2;
GO

--Intersection of Area 1 and Area2 text results
DECLARE @a1 GEOGRAPHY;
DECLARE @a2 GEOGRAPHY;
SET @a1 = (SELECT GEOG FROM PolygonsG WHERE NAME = 'Area1');
SET @a2 = (SELECT GEOG FROM PolygonsG WHERE NAME = 'Area2');
SELECT @a1.STIntersection(@a2).STAsText() AS WELL_KNOWN_TEXT;
GO
-- OUTPUT:
-- 
-- WELL_KNOWN_TEXT
-- ------------------------
-- GEOMETRYCOLLECTION EMPTY

--intersect a polygon and a point:
DECLARE @a1 GEOGRAPHY;
DECLARE @p1 GEOGRAPHY;
SET @a1 = (SELECT GEOG FROM PolygonsG WHERE NAME = 'Area1');
SET @p1 = (SELECT GEOG FROM PointsG WHERE NAME = 'Point1');
SELECT @a1.STIntersection(@p1).STAsText() AS WELL_KNOWN_TEXT;
GO
-- OUTPUT:
-- 
-- WELL_KNOWN_TEXT
-- ------------------------
-- POINT (3 4)

--Unioning Spatial Objects
--join two objects of similar types, in this case points:
DECLARE @p1 GEOGRAPHY;
DECLARE @p2 GEOGRAPHY;
SET @p1 = (SELECT GEOG FROM PointsG WHERE NAME = 'Point1');
SET @p2 = (SELECT GEOG FROM PointsG WHERE NAME = 'Point2');
SELECT @p1.STUnion(@p2).STAsText() AS WELL_KNOWN_TEXT;
GO
-- OUTPUT:
--
-- WELL_KNOWN_TEXT
-- -------------------------
-- MULTIPOINT ((3 4), (5 3))

--union objects of different types:
DECLARE @p1 GEOGRAPHY;
DECLARE @l1 GEOGRAPHY;
SET @p1 = (SELECT GEOG FROM PointsG WHERE NAME = 'Point1');
SET @l1 = (SELECT GEOG FROM LinesG WHERE NAME = 'Line1');
SELECT @p1.STUnion(@l1).STAsText() AS WELL_KNOWN_TEXT;
GO
-- OUTPUT:
--
-- WELL_KNOWN_TEXT
-- -------------------------------------------------------
-- GEOMETRYCOLLECTION (POINT (3 4), LINESTRING (5 5, 2 2))

--union two objects, one of which lies wholly within the other?  For example, if we union Point1 with Area1, we may expect another GEOMETRYCOLLECTION:
DECLARE @p1 GEOGRAPHY;
DECLARE @a1 GEOGRAPHY;
DECLARE @u1 GEOGRAPHY;
SET @p1 = (SELECT GEOG FROM PointsG WHERE NAME = 'Point1');
SET @a1 = (SELECT GEOG FROM PolygonsG WHERE NAME = 'Area1');
SET @u1 = @a1.STUnion(@p1)
SELECT @u1.STAsText() AS WELL_KNOWN_TEXT;
GO
-- OUTPUT:
--
-- WELL_KNOWN_TEXT
-- -------------------------------------------------------
-- POLYGON ((1.0000000137113865 5.0000000216721414, 1 1, 4.0000000118474217 1.000000043553106, 4 5, 
--           1.0000000137113865 5.0000000216721414))

--Union dissimilar objects that overlap
DECLARE @l1 GEOGRAPHY;
DECLARE @a1 GEOGRAPHY;
SET @l1 = (SELECT GEOG FROM LinesG WHERE NAME = 'Line1');
SET @a1 = (SELECT GEOG FROM PolygonsG WHERE NAME = 'Area1');
SELECT @l1.STUnion(@a1).STAsText() AS WELL_KNOWN_TEXT;
GO
-- OUTPUT:
--
-- WELL_KNOWN_TEXT
-- -------------------------------------------------------
-- GEOMETRYCOLLECTION (LINESTRING (5 5, 3.99999999706441 4.0033502715966662), 
--                     POLYGON ((0.99999999284575924 4.9999999778743245, 1 1, 
--                               4.0000000499128312 1.0000000017675168, 3.99999999706441 4.0033502715966662, 
--                               4 5, 0.99999999284575924 4.9999999778743245)))

-- GENERALIZATION OF SPATIAL OBJECTS
--T-SQL to create example
DECLARE @st GEOGRAPHY;
DECLARE @tp GEOGRAPHY;
DECLARE @ls GEOGRAPHY;
SET @st = GEOGRAPHY::STGeomFromText(
  'POLYGON((9 1,10 1,9.5 2,9 1))',4326); -- small triangle
SET @tp = GEOGRAPHY::STGeomFromText(
  'POLYGON((1 2.5,19 2.5,19 3,1 3,1 2.5))',4326); --thin, linear polygon
SET @ls = GEOGRAPHY::STGeomFromText(
  'LINESTRING(1 5,2 5,3 8,4 5,5 6,5 5,6 6,6 5,8 8,8 5,9 6,10 5,
    11 6,12 4,13 7,14 5,15 6,15 4,16 7,16 5,18 8,18 5,19 5)',4326); --jagged line
SELECT @st
UNION ALL
SELECT @tp
UNION ALL
SELECT @ls;
GO

--Illustration: reduce the geometries using a parameter value of 200000:
DECLARE @st GEOGRAPHY;
DECLARE @tp GEOGRAPHY;
DECLARE @ls GEOGRAPHY;
SET @st = GEOGRAPHY::STGeomFromText(
  'POLYGON((9 1,10 1,9.5 2,9 1))',4326); -- small triangle
SET @tp = GEOGRAPHY::STGeomFromText(
  'POLYGON((1 2.5,19 2.5,19 3,1 3,1 2.5))',4326); --thin, linear polygon
SET @ls = GEOGRAPHY::STGeomFromText(
  'LINESTRING(1 5,2 5,3 8,4 5,5 6,5 5,6 6,6 5,8 8,8 5,9 6,10 5,
    11 6,12 4,13 7,14 5,15 6,15 4,16 7,16 5,18 8,18 5,19 5)',4326); --jagged line
SELECT @st.Reduce(200000).STBuffer(20000)
UNION ALL
SELECT @st.Reduce(200000)
UNION ALL
SELECT @tp.Reduce(200000)
UNION ALL
SELECT @ls.Reduce(200000);
GO

--Text representation: reduce the geometries using a parameter value of 200000:
DECLARE @st GEOGRAPHY;
DECLARE @tp GEOGRAPHY;
DECLARE @ls GEOGRAPHY;
SET @st = GEOGRAPHY::STGeomFromText(
  'POLYGON((9 1,10 1,9.5 2,9 1))',4326); -- small triangle
SET @tp = GEOGRAPHY::STGeomFromText(
  'POLYGON((1 2.5,19 2.5,19 3,1 3,1 2.5))',4326); --thin, linear polygon
SET @ls = GEOGRAPHY::STGeomFromText(
  'LINESTRING(1 5,2 5,3 8,4 5,5 6,5 5,6 6,6 5,8 8,8 5,9 6,10 5,
    11 6,12 4,13 7,14 5,15 6,15 4,16 7,16 5,18 8,18 5,19 5)',4326); --jagged line
SELECT @st.Reduce(200000).STAsText() AS ST_WELL_KNOWN_TEXT;
SELECT @tp.Reduce(200000).STAsText() AS TP_WELL_KNOWN_TEXT;
SELECT @ls.Reduce(200000).STAsText() AS LS_WELL_KNOWN_TEXT;
GO
-- OUTPUT:
--
-- ST_WELL_KNOWN_TEXT
-- ------------------
-- POINT (9 1)
--
-- TP_WELL_KNOWN_TEXT
-- -----------------------------------------------------------------------------------------
-- LINESTRING (19.000003042978857 3.000002041936364, 0.99999698970906747 2.4999979121179225)
--
-- LS_WELL_KNOWN_TEXT
-- ------------------------------------------------------------------
-- LINESTRING (1 5, 3 8, 6 5, 8 8, 8 5, 12 4, 13 7, 15 4, 18 8, 19 5)

--Distance Tests Between Spatial Objects
--Using the STDistance() method, we can determine what points are within 40000 meters of distance from Area1:
DECLARE @l GEOGRAPHY;
SET @l = (SELECT GEOG FROM PolygonsG WHERE NAME = 'Area1');
SELECT NAME FROM PointsG WHERE @l.STDistance(GEOG) <= 40000;
GO
-- OUTPUT:
--
-- NAME
-- ------
-- Point1
-- Point4
-- Point5

--which polygons are within 40000 meters of Line3:
DECLARE @l GEOGRAPHY;
SET @l = (SELECT GEOG FROM LinesG WHERE NAME = 'Line3');
SELECT NAME FROM PolygonsG WHERE @l.STDistance(GEOG) < 40000;
GO
-- OUTPUT:
--
-- NAME
-- -----
-- Area1
-- Area3

--We can also compute how far objects are away from each other.  
--  For instance, we can find exactly how far Line3 is from Point2:
DECLARE @d FLOAT;
SET @d = (SELECT GEOG.STDistance((SELECT GEOG FROM LinesG WHERE NAME = 'Line3'))
  FROM PointsG WHERE NAME = 'Point2');
SELECT @d AS DISTANCE;
GO
-- OUTPUT:
--
-- DISTANCE
-- -----------------------
-- 29686.7048249508 meters

--The distance is computed between two points is an intuitive concept, 
--  but how is the distance between two complex objects—e.g., between a LINESTRING and a POLYGON—defined?  
--  The distance computed is the minimum distance between the objects.  
--  The following T-SQL computes the minimum distance between Line3 and Area2:
DECLARE @d FLOAT;
SET @d = (SELECT GEOG.STDistance((SELECT GEOG FROM LinesG WHERE NAME = 'Line3')) FROM 
  PolygonsG WHERE NAME = 'Area2');
SELECT @d AS DISTANCE;
GO
-- OUTPUT:
--
-- DISTANCE
-- -----------------------
-- 49468.4719843208 meters

--If two objects intersect, this distance is 0:
DECLARE @d FLOAT;
SET @d = (SELECT GEOG.STDistance((SELECT GEOG FROM LinesG 
  WHERE NAME = 'Line3')) FROM LinesG WHERE NAME = 'Line1');
SELECT @d AS DISTANCE;
GO
-- OUTPUT:
--
-- DISTANCE
-- --------
-- 0

--Spatial Buffers

--buffer a point object
DECLARE @a GEOGRAPHY;
DECLARE @b GEOGRAPHY;
SET @a = (SELECT GEOG FROM PointsG WHERE NAME = 'Point1');
SET @b = @a.STBuffer(8000);
SELECT @b;
GO

--illustration: buffer a point object
DECLARE @a GEOGRAPHY;
DECLARE @b GEOGRAPHY;
SET @a = (SELECT @a = GEOG FROM PointsG WHERE NAME = 'Point1');
SET @b = @a.STBuffer(1);
SELECT @b
UNION ALL
SELECT @a.STBuffer(.05)
UNION ALL
SELECT @a;
GO

--buffer Area1 by 40000 meters:
DECLARE @a GEOGRAPHY;
DECLARE @b GEOGRAPHY;
SET @a = (SELECT GEOG FROM PolygonsG WHERE NAME = 'Area1');
SET @b = (SELECT @a.STBuffer(40000));
SELECT @b;
GO

--Illustration: buffer Area1 by 40000 meters:
DECLARE @a GEOGRAPHY;
DECLARE @b GEOGRAPHY;
DECLARE @e GEOGRAPHY;
SET @a = (SELECT GEOG FROM PolygonsG WHERE NAME = 'Area1');
SET @b = (SELECT @a.STBuffer(40000));
SET @e = (SELECT @a.RingN(1));
SELECT ' ',@b
UNION ALL
SELECT 'Original Area1 Polygon Boundary',@e;
GO

--Comparing Spatial Buffers to Distance-based Calculations to Test Proximity

--proximity test to determine which points intersect a buffered polygon around Area1:
DECLARE @a GEOGRAPHY;
DECLARE @b GEOGRAPHY;
SET @a = (SELECT GEOG FROM PolygonsG WHERE NAME = 'Area1');
SET @b = @a.STBuffer(40000);
SELECT NAME FROM PointsG WHERE GEOG.STIntersects(@b)=1;
GO
-- OUTPUT:
--
-- NAME
-- ------
-- Point1
-- Point4
-- Point5

--same query as above, using STDistance(), presented earlier:
DECLARE @l GEOGRAPHY;
SET @l = (SELECT GEOG FROM PolygonsG WHERE NAME = 'Area1');
SELECT NAME FROM PointsG WHERE @l.STDistance(GEOG) <= 40000;
GO
-- OUTPUT:
--
-- NAME
-- ------
-- Point1
-- Point4
-- Point5

--The first method creates a zone, 40000 meters wide, around the 
--outside and the inside of the Area1 polygon boundary.  
--This is done by constructing two new buffer objects, 
--one 40000 units larger and one 40000 units smaller and taking 
--their difference with the STDifference() method. 
--The new zone is intersected against the Points table:
DECLARE @a GEOGRAPHY;
DECLARE @z GEOGRAPHY;
DECLARE @d FLOAT;
SET @d = 40000;
SET @a = (SELECT @a = GEOG FROM PolygonsG WHERE NAME = 'Area1');
SET @z = @a.STBuffer(@d).STDifference(@a.STBuffer(@d * -1));
SELECT NAME 
  FROM PointsG 
    WHERE GEOG.STIntersects(@z)=1;
GO
-- OUTPUT:
--
-- NAME
-- ------
-- Point4
-- Point5

--The second method uses the RingN() (STExteriorRing() was used in the geometry example)
--method to convert the Area1 boundary into a LINESTRING.  The STDistance() method 
--is then used to find all points within 40000 units of the LINESTRING:
DECLARE @a GEOGRAPHY;
DECLARE @d FLOAT = 40000;
SET @a = (SELECT GEOG FROM PolygonsG WHERE NAME = 'Area1');
SELECT NAME 
  FROM PointsG 
    WHERE GEOG.STDistance(@a.RingN(1)) <= @d;
GO
-- OUTPUT:
--
-- NAME
-- ------
-- Point4
-- Point5

---------------------------------------------------------------------
-- SPATIAL DATA VALIDITY
---------------------------------------------------------------------
-- Data Validity Issues With Geometry Data
---------------------------------------------------------------------
--   ...create new table for invalid polygon...
CREATE TABLE Polygons_Valid (
ID INT IDENTITY(1,1) PRIMARY KEY,
NAME VARCHAR(64),
GEOM GEOMETRY);	
GO

-- ...insert invalid polygon
INSERT INTO Polygons_Valid 
VALUES('Area1', 
  GEOMETRY::STGeomFromText(
    'POLYGON((1 1, 1 3, 2 3, 4 1, 5 1, 5 3, 4 3, 2 1, 1 1))',0));
GO

-- ...test to see if this is a valid polygon:
DECLARE @g GEOMETRY;
SET @g = (SELECT GEOM FROM Polygons_Valid WHERE NAME = 'Area1');
SELECT @g.STIsValid() AS IS_VALID;
GO
--OUTPUT:
--
-- IS_VALID
-- --------
-- 0

-- ...try to execute a spatial operation against this instance
--    — for example, test to see if a point intersects it—we get an error:
DECLARE @p GEOMETRY;
DECLARE @g GEOMETRY;
SET @p = geometry::Parse('POINT(1 2)');
SET @g = (SELECT GEOM FROM Polygons_Valid WHERE NAME = 'Area1');
SELECT NAME FROM Polygons_Valid WHERE @g.STIntersects(@p)=1;
GO
-- OUTPUT:
--
-- Error! ...instance is not valid

-- ...run MakeValid() to correct..
DECLARE @g GEOMETRY;
SET @g = (SELECT GEOM FROM Polygons_Valid WHERE NAME = 'Area1');
SELECT @g.MakeValid().STAsText() AS WELL_KNOWN_TEXT;
GO
-- OUTPUT:
--
-- WELL_KNOWN_TEXT
-- --------------------------------------------------------------------------------
-- MULTIPOLYGON (((4 1, 5 1, 5 3, 4 3, 3 2, 4 1)),((1 1, 2 1, 3 2, 2 3, 1 3, 1 1)))
*/

---------------------------------------------------------------------
-- MEASURING LENGTH AND AREA
---------------------------------------------------------------------
-- Comparing Length Measurements Between Geometry and Geography Instances
---------------------------------------------------------------------
--First, we consider spatial objects that are small relative to the earth’s surface.  
--In this case, we are using a short (approximately 400-meter) road from the 
--Highways table, Massachusetts State Route 25:
USE Sample_USA;
GO

SELECT ID,
       GEOM.STLength() AS GEOM_LENGTH,
       GEOG.STLength() AS GEOG_LENGTH,
       GEOG.STLength() - GEOM.STLength() AS LENGTH_DIFFERENCE
  FROM Highways
    WHERE ID = 566;
GO
-- OUTPUT:
--
-- ID  GEOM_LENGTH         GEOG_LENGTH         LENGTH_DIFFERENCE
-- --- ----------------    ----------------    -----------------
-- 566 412.271253468018    412.677965834253    0.406712366235695

--What happens if we choose a much longer highway segment, such as Interstate 5, 
--which travels from the Mexican to the Canadian border through the states of 
--California, Oregon and Washington?
SELECT ID,
       GEOM.STLength() AS GEOM_LENGTH,
       GEOG.STLength() AS GEOG_LENGTH,
       (GEOG.STLength() - GEOM.STLength()) / 1000 AS LENGTH_DIFFERENCE_KM
  FROM Highways
    WHERE ID = 378;
GO
-- OUTPUT:
--
-- ID   GEOM_LENGTH      GEOG_LENGTH       LENGTH_DIFFERENCE_KM
-- ---  ---------------  ----------------  --------------------
-- 378  2227919.0649429  2234410.65035147  6.49158540857723

---------------------------------------------------------------------
-- Comparing Area Measurements Between Geometry and Geography Instances
---------------------------------------------------------------------
-- ...difference between area calculations using geometry and geography values for the same object.  
-- ...use the Zipcodes table as the source of a small area: the zip code 72445 
--   (City of Minturn, Lawrence County, Arkansas):
SELECT ID,
       ZCTA,
       GEOM.STArea() AS GEOM_AREA,
       GEOG.STArea() AS GEOG_AREA,
       (GEOG.STArea() - GEOM.STArea()) AS AREA_DIFFERENCE
  FROM Zipcodes
    WHERE ZCTA = '72445';
GO
--OUTPUT:
--
-- ID    ZCTA   GEOM_AREA         GEOG_AREA         AREA_DIFFERENCE
-- ----  -----  ----------------  ----------------  -----------------
-- 3227  72445  5267.81079759607  5268.57512617111  0.764328575045511

-- ...perform a similar calculation on State of Arkansas polygon, contained in the States table:
SELECT ID, NAME_1,
       GEOM.STArea() AS GEOM_AREA,
       GEOG.STArea() AS GEOG_AREA,
       (GEOG.STArea() - GEOM.STArea()) / (1000 * 1000) AS AREA_DIFFERENCE_KM_SQ
  FROM States
    WHERE NAME_1 = 'Arkansas';
GO
--  OUTPUT:
--
--  ID  NAME_1    GEOM_AREA         GEOG_AREA         AREA_DIFFERENCE_KM_SQ
--  --------  ----------------  ----------------  ---------------------
--  4   Arkansas  137703845304.298  137691014780.597  -12.8305237011719


---------------------------------------------------------------------
--INDEXING SPATIAL DATA
---------------------------------------------------------------------
--Spatial Indexing Basics
---------------------------------------------------------------------
--Simple spatial query:

USE Sample_USA;
GO

DECLARE @point GEOMETRY;
SET @point = geometry::Point(8010033.78, 3314652.47, 32768);

SELECT *
  FROM Zipcodes
    WHERE GEOM.STIntersects(@point) = 1;
GO

--Using Spatial Indexes
USE Sample_USA;
GO

/*--Drop index if previously created
DROP INDEX ZIPCODES_GEOM_IDX
  ON Zipcodes;
GO
*/

CREATE SPATIAL INDEX ZIPCODES_GEOM_IDX
  ON Zipcodes(GEOM)
    USING GEOMETRY_GRID
    WITH (
      BOUNDING_BOX = (
      XMIN= 2801277,
      YMIN= 217712,
      XMAX= 13305064,
      YMAX= 6446996),
      GRIDS = (MEDIUM, MEDIUM, MEDIUM, MEDIUM),
      CELLS_PER_OBJECT = 16
);

-- Calculating and setting bounds for geometry index
DECLARE @boundBox GEOMETRY;
SELECT @boundBox = dbo.GeometryEnvelopeAggregate(GEOM)
  FROM Zipcodes;
SELECT
  FLOOR(@boundBox.STPointN(1).STX) AS MinX,
  FLOOR(@boundBox.STPointN(1).STY) AS MinY,
  CEILING(@boundBox.STPointN(3).STX) AS MaxX,
  CEILING(@boundBox.STPointN(3).STY) AS MaxY;
GO
-- OUTPUT:
--
-- XMIN     YMIN    XMAX      YMAX
-- -------  ------  --------  -------
-- 2801277  217712  13305064  6446996

--Geometry Index using defaults
DROP INDEX ZIPCODES_GEOM_IDX ON Zipcodes;
GO

CREATE SPATIAL INDEX ZIPCODES_GEOM_IDX
  ON Zipcodes(GEOM)
    USING GEOMETRY_GRID
    WITH (
      BOUNDING_BOX = (
      XMIN= 2801277,
      YMIN= 217712,
      XMAX= 13305064,
      YMAX= 6446996)
);
GO

--Geography Indexes

/*--Drop index if previously created
DROP INDEX ZIPCODES_GEOG_IDX ON Zipcodes;
GO
*/

CREATE SPATIAL INDEX ZIPCODES_GEOG_IDX
  ON Zipcodes(GEOG)
    USING GEOGRAPHY_GRID
    WITH (
      GRIDS = (MEDIUM, MEDIUM, MEDIUM, MEDIUM),
      CELLS_PER_OBJECT = 16
);
GO

--As with the GEOMETRY indexes, the preceding syntax 
--  can be simplified if the default options are desired:
DROP INDEX ZIPCODES_GEOG_IDX ON Zipcodes;
GO

CREATE SPATIAL INDEX ZIPCODES_GEOG_IDX
  ON Zipcodes(GEOG);
GO

--Query Plans

--Select Query, non-indexed plan...
DROP INDEX ZIPCODES_GEOM_IDX ON Zipcodes;
GO

DECLARE @point GEOMETRY;
SET @point = geometry::Point(8010033.78, 3314652.47, 32768);

SELECT *
  FROM Zipcodes
  WHERE GEOM.STIntersects(@point) = 1;
GO

--Select Query, spatially-indexed plan...
CREATE SPATIAL INDEX ZIPCODES_GEOM_IDX
  ON Zipcodes(GEOM)
    USING GEOMETRY_GRID
    WITH (
      BOUNDING_BOX = (
      XMIN= 2801277,
      YMIN= 217712,
      XMAX= 13305064,
      YMAX= 6446996)
);
GO

DECLARE @point GEOMETRY;
SET @point = geometry::Point(8010033.78, 3314652.47, 32768);

SELECT *
  FROM Zipcodes
  WHERE GEOM.STIntersects(@point) = 1;
GO

--The spatial index can be used in an index hint just like any other 
--  index. For example, to force the use of the GEOMETRY index in our 
--  query, we would write:
DECLARE @point GEOMETRY;
SET @point = geometry::Point(8010033.78, 3314652.47, 32768);

SELECT *
  FROM Zipcodes WITH (INDEX (ZIPCODES_GEOM_IDX))
    WHERE GEOM.STIntersects(@point) = 1;
GO

---------------------------------------------------------------------
--USING SPATIAL TO SOLVE PROBLEMS
---------------------------------------------------------------------
---------------------------------------------------------------------
--Loading Spatial Data From Text Files
---------------------------------------------------------------------

--TEXT_SAMPLE.txt
--1	Massacre Bay	52.8266667	173.22	
--2	Maniac Hill	    51.9583333	177.5097222 
--3	Lunatic Lake	51.9402778	177.4708333

--Create table
USE tempdb;
GO

CREATE TABLE Text_Sample(
  ID INT PRIMARY KEY,
  NAME VARCHAR(64),
  LATITUDE FLOAT,
  LONGITUDE FLOAT
);
GO

--TRUNCATE TABLE Text_Sample

--Bulk Insert TEXT_SAMPLE.txt table
BULK
  INSERT Text_Sample
    FROM 'C:\temp\TEXT_SAMPLE.txt'
      WITH (
        FIELDTERMINATOR = '\t',
        ROWTERMINATOR = '\n'
);
GO

--Here are the rows loaded into the table from BULK INSERT:
SELECT * FROM Text_Sample;
GO
-- OUTPUT:
--
-- ID   NAME          LATITUDE     LONGITUDE
-- --   ------------  ----------   -----------
-- 1    Massacre Bay  52.8266667   173.22
-- 2    Maniac Hill   51.9583333   177.5097222
-- 3    Lunatic Lake  51.9402778   177.4708333

--Add geography column
ALTER TABLE Text_Sample 
  ADD GEOG GEOGRAPHY NULL; 
GO  

--Update geography column using a non-OGC compliant point constructor method
UPDATE Text_Sample
  SET GEOG = geography::Point(LATITUDE,LONGITUDE,4326);
GO

--Display the resulting table
SELECT ID, NAME, LATITUDE, LONGITUDE, GEOG.STAsText() AS GEOG from Text_Sample;
GO     
-- OUTPUT:
--
-- ID	NAME	      LATITUDE	    LONGITUDE	GEOG
-- ---	------------  ----------    ---------   -----------------------------
-- 1	Massacre Bay  52.8266667	173.22	    POINT (173.22 52.8266667)
-- 2	Maniac Hill	  51.9583333	177.5097222	POINT (177.5097222 51.9583333)
-- 3	Lunatic Lake  51.9402778	177.4708333	POINT (177.4708333 51.9402778)
   
---------------------------------------------------------------------
-- WORKING WITH GEOGRAPHY DATA VALIDITY ISSUES
---------------------------------------------------------------------
-- MakeValid
---------------------------------------------------------------------
USE tempdb;
GO

UPDATE t1
  SET GEOM = GEOM.MakeValid();
GO

---------------------------------------------------------------------
-- Forcing Polygon Ring Reorientation
---------------------------------------------------------------------
UPDATE t1
  SET GEOM = GEOM.MakeValid().STUnion(GEOM.STStartPoint());
GO

---------------------------------------------------------------------
-- Moving Geometry Data To Geography Data
---------------------------------------------------------------------
-- Create a new table with GEOGRAPHY column
CREATE TABLE t2 (
  ID INTEGER,
  GEOG GEOGRAPHY);
GO
-- Convert from GEOMETRY to GEOGRAPHY using Well Known Text
INSERT INTO t2
  SELECT t1.ID, geography::STGeomFromText(t1.GEOM.STAsText(),4326)
  FROM t1;
GO

-- Convert from GEOMETRY to GEOGRAPHY using Well Known Binary
INSERT INTO t2
  SELECT t1.ID, geography::STGeomFromWKB(t1.GEOM.STAsBinary(),4326)
  FROM t1;
GO

---------------------------------------------------------------------
-- MakeValidGeography
---------------------------------------------------------------------
DROP TABLE t2
GO

-- Create a newtable with Geography column 
CREATE TABLE t2 (
  NAME VARCHAR(64),
  GEOM GEOMETRY,
  GEOG GEOGRAPHY);
GO

-- Insert as a GEOMETRY with the polygon exterior ring in reverse order from
-- GEOGRAPHY's exterior ring requirement
INSERT INTO t2 VALUES
  ('Area2', geometry::STGeomFromText('POLYGON ((5 4, 5 7, 8 7, 8 4, 5 4))',4326),NULL);
GO
 
-- Convert from GEOMETRY to GEOGRAPHY using MakeValidGeographyFromGeometry
-- Make sure to register the dbo.MakeValidGeographyFromGeometry from the SQLSpatialTools.dll
-- at http://sqlspatialtools.codeplex.com/
-- Note that this function is already included in the Sample_USA database
UPDATE t2
  SET GEOG = dbo.MakeValidGeographyFromGeometry(GEOM);
GO

---------------------------------------------------------------------
-- FINDING SITE LOCATIONS WITHIN GEOGRAPHIC REGIONS
---------------------------------------------------------------------
-- Find High Schools Within 2KM of Interstate 5 In King County, Washington State
---------------------------------------------------------------------
USE Sample_USA;
GO

DECLARE @i5 GEOGRAPHY;
DECLARE @kc GEOGRAPHY;
DECLARE @buf GEOGRAPHY;
SET @i5 = (
  SELECT GEOG FROM Highways
    WHERE SIGNT = 'I' AND SIGNN = '5');
SET @kc = (
  SELECT GEOG FROM Counties
  WHERE NAME_1 = 'Washington' AND NAME_2 = 'King');
SET @i5 = @i5.STIntersection(@kc); -- Clip I5 to King County
SET @buf = @i5.STBuffer(2000); -- buffer clipped I5 by 2 KM
SET @buf = @buf.STIntersection(@kc); -- Clip I5 buffer to King County
SELECT geonameid, name, feature_code
  FROM GeoNames
    WHERE feature_code = 'SCH'
      AND name LIKE '% High %'
      AND name NOT LIKE '% Junior %'
      AND GEOG.STIntersects(@buf) = 1
      ORDER BY name;
GO
-- OUTPUT:
--
-- geonameid  name                            feature_code
-- ---------  ------------------------------  ---------------
-- 5787513    Blanchet High School            SCH
-- 5790315    Cleveland High School           SCH
-- 5793415    Edison High School              SCH
-- 5793988    Evergreen Lutheran High School  SCH
-- 5794240    Federal Way High School         SCH
-- 5794857    Foster High School              SCH
-- 5795273    Garfield High School            SCH
-- 5795504    Glacier High School             SCH
-- 5798335    Ingraham High School            SCH
-- 5800987    Lincoln High School             SCH
-- 5804101    Mount Ranier High School        SCH
-- 5805435    ODea High School                SCH
-- 5807827    Rainier Beach High School       SCH
-- 5808781    Roosevelt High School           SCH
-- 5810300    Shorecrest High School          SCH
-- 5810307    Shorewood High School           SCH
-- 5813367    Thomas Jefferson high School    SCH
-- 5814362    Tyee High School                SCH

---------------------------------------------------------------------
-- Find schools within 4 km of the intersection of Interstates 5 and 405 
-- in King County, Washington
---------------------------------------------------------------------
DECLARE @kc GEOGRAPHY;
DECLARE @i405 GEOGRAPHY;
DECLARE @i5 GEOGRAPHY;
DECLARE @int GEOGRAPHY;
SET @kc = (SELECT GEOG FROM Counties WHERE NAME_1 = 'Washington' AND NAME_2 = 'King');
SET @i405 = (SELECT GEOG FROM Highways WHERE SIGNT = 'I' AND SIGNN = '405');
SET @i5 = (SELECT GEOG FROM Highways WHERE SIGNT = 'I' AND SIGNN = '5');
SET @i5 = @i5.STIntersection(@kc); -- Clip I5 to King County
SET @int = @i5.STIntersection(@i405);
SELECT geonameid, name, feature_code
  FROM GeoNames
    WHERE feature_code = 'SCH' and
          GEOG.STDistance(@int) <= 4000
          ORDER BY name;
GO
-- OUTPUT:
--
-- geonameid name                               feature_code
-- --------- ------------------------------     ------------
-- 5787926   Bow Lake Elementary School         SCH
-- 5788996   Campbell Hill Elementary School    SCH
-- 5789326   Cascade View Elementary School     SCH
-- 5790027   Chinook Middle School              SCH
-- 5793080   Earlington School                  SCH
-- 5794857   Foster High School                 SCH
-- 5795504   Glacier High School                SCH
-- 5802942   McMicken Heights Elementary School SCH
-- 5808436   Riverton Heights Elementary School SCH
-- 5810333   Showalter Middle School            SCH
-- 5810745   Skyway Christian School            SCH
-- 5813407   Thorndyke Elementary School        SCH
-- 5814044   Tukwila Elementary School          SCH
-- 5814362   Tyee High School                   SCH
-- 5814573   Valley View Elementary School      SCH

---------------------------------------------------------------------
--NEAREST NEIGHBOR SEARCHES
---------------------------------------------------------------------
USE Sample_USA;
GO

--Create a Numbers Table with 20 entries
SELECT TOP 20 IDENTITY(int,1,1) AS n INTO Nums FROM master..spt_values a, master..spt_values b
CREATE UNIQUE CLUSTERED INDEX idx_1 ON Nums(n) --Index numbers
GO

DECLARE @input GEOGRAPHY = 'POINT (-147 61)';
DECLARE @start FLOAT = 10000;
WITH NearestNeighbor AS(
  SELECT TOP 1 WITH TIES
    *, b.GEOG.STDistance(@input) AS dist
  FROM Nums n JOIN GeoNames b WITH(INDEX(geog_hhhh_16_sidx)) -- index hint
  ON b.GEOG.STDistance(@input) < @start*POWER(CAST(2 AS FLOAT),n.n)
  WHERE n <= 20
  ORDER BY n
)
SELECT TOP 1 geonameid, name, feature_code, admin1_code, dist
FROM NearestNeighbor
ORDER BY n, dist;
GO
-- OUTPUT:
-- 
-- geonameid name             feature_code admin1_code dist
-- --------  ---------------- ------------ ----------- ----------------
-- 5870476   Number One River STM          AK          646.306152781609

--Find The 10 Nearest GeoNames Data Around A Point Location
DECLARE @input GEOGRAPHY = 'POINT (-147 61)';
DECLARE @start FLOAT = 1000;
WITH NearestNeighbor AS(
  SELECT TOP 10 WITH TIES
    *, b.GEOG.STDistance(@input) AS dist
  FROM Nums n JOIN GeoNames b WITH(INDEX(geog_hhhh_16_sidx)) -- index hint
  ON b.GEOG.STDistance(@input) < @start*POWER(CAST(2 AS FLOAT),n.n)
  AND b.GEOG.STDistance(@input) >=
    CASE WHEN n = 1 THEN 0 ELSE @start*POWER(CAST(2 AS FLOAT),n.n-1) END
  WHERE n <= 20
  ORDER BY n
)
SELECT TOP 10 geonameid, name, feature_code, admin1_code, dist
  FROM NearestNeighbor
  ORDER BY n, dist;
GO
-- OUTPUT:
-- 
-- geonameid name              feature_code admin1_code dist
-- --------- ----------------- ------------ ----------- ----------------
-- 5870476   Number One River  STM          AK          646.306152781609
-- 5863866   Heather Bay       BAY          AK          842.85121182881
-- 5865122   Jade Harbor       BAY          AK          3523.94025462351
-- 5863873   Heather Island    ISL          AK          3729.62714753577
-- 5861649   Emerald Cove      BAY          AK          5523.29937034676
-- 5859736   Columbia Bay      BAY          AK          5558.74879079016
-- 5868070   Lutris Pass       CHN          AK          5578.08228008006
-- 5862561   Mount Freemantle  MT           AK          6089.41763362949
-- 5873004   Round Mountain    MT           AK          6171.84197013513


--Find Zipcodes Around A Point Location
DECLARE @input GEOGRAPHY = 'POINT (-147 61)';
DECLARE @start FLOAT = 10000;
WITH NearestNeighbor AS
(
    SELECT TOP 10 WITH TIES *, b.GEOG.STDistance(@input) AS dist
    FROM Nums n JOIN Zipcodes b WITH(INDEX(geog_hhhh_256_sidx))
    ON b.GEOG.STDistance(@input) < @start*POWER(2,n.n)
      AND b.GEOG.STDistance(@input) >=
    CASE WHEN n = 1 THEN 0 ELSE @start*POWER(2,n.n-1) END
    ORDER BY n
)
  SELECT TOP 10 ID, ZCTA, dist
  FROM NearestNeighbor
  ORDER BY n, dist;
GO
--OUTPUT:
--
-- ID   ZCTA  dist
-- ---- ----- ----------------
-- 1642 996XX 0
-- 1955 99686 11633.5438436035
-- 1914 996XX 14565.4268010367
-- 1954 99677 17449.3494959674
-- 1908 995HH 18127.8398133392
-- 1901 99686 25423.8744552156
-- 1902 99686 35328.0560592605
-- 2005 996XX 38489.6097305924
-- 1734 99686 41477.7718586985
-- 1919 996XX 41782.8127303003

------------------------------------------------------------------
-- SPATIAL JOINS
------------------------------------------------------------------
-- Create a subset of the GeoNames table 
USE Sample_USA;
GO

/* Drop table if it already exists
DROP TABLE GeoNames_CA;
GO
*/

SELECT * INTO GeoNames_CA FROM GeoNames a
WHERE a.admin1_code = 'CA'
GO
-- OUTPUT:
--
-- 110525 row(s) affected

-- Join the GeoNames_CA table with the Zipcodes table on common geographic location 
SELECT g.geonameid, g.name, z.ZCTA
  FROM GeoNames_CA g
  JOIN Zipcodes z WITH(INDEX(geog_hhhh_256_sidx))
  ON z.GEOG.STIntersects(g.GEOG) = 1;
GO
-- OUTPUT:
--
-- 109176 row(s) affected

--Add column ZCTA column to table GeoNames_CA
ALTER TABLE GeoNames_CA
  ADD ZCTA nvarchar(255) NULL;
GO

--Update the GeoNames_CA table with zipcodes from the Zipcodes ZCTA column using a left outer join
UPDATE g
  SET g.ZCTA = z.ZCTA
FROM GeoNames_CA g
  JOIN dbo.Zipcodes z WITH(INDEX(geog_hhhh_256_sidx))
    ON (z.GEOG.STIntersects(g.GEOG) = 1);
GO
-- OUTPUT:
--
-- 109176 row(s) affected

--Visualize the null matches
SELECT GEOG FROM GeoNames_CA WHERE ZCTA IS NULL
UNION ALL
SELECT GEOG from States WHERE NAME_1 = 'California';
GO

---------------------------------------------------------------
-- PROCESSING SPATIAL DATA
---------------------------------------------------------------
-- Processing the Highways Table In The Sample_USA Database
---------------------------------------------------------------
-- The Workflow
---------------------------------------------------------------
-- Step 1. Create <your database>
-- Setp 2. Load BTS shapefile (nhpnlin.shp) into table HIGHWAYS_Temp
--         using your favorite shapefile loader...
--         Just make sure that you load the spatial data into a
--         geometry column named GEOM, set the SRID for all values
--         loaded into that column to 4326 and have a primary key
--         for the table named ID.
--
--         The BTS shapefile is included with the Sample_USA data
--         in the zip archive: BTS_shapefile.zip (which you will
--         need to unzip prior to loading).
---------------------------------------------------------------
USE [<your database>];
GO

--Validate geometry data
UPDATE HIGHWAYS_TEMP
  SET GEOM = GEOM.MakeValid()
    WHERE GEOM.STIsValid() = 0;
GO
-- OUTPUT:
--
-- 3 row(s) affected

-- Add geography column
ALTER TABLE HIGHWAYS_TEMP
  ADD GEOG GEOGRAPHY NULL;
GO

-- Update geography column using MakeValidGeographyFromGeometry() from the CodePlex SQL Server Spatial Tools assembly
UPDATE HIGHWAYS_TEMP
  SET GEOG = dbo.MakeValidGeographyFromGeometry(GEOM);
GO
-- OUTPUT:
--
-- 176191 row(s) affected

-- Create final Highways table
CREATE TABLE Highways(
  ID INTEGER IDENTITY(1,1) NOT NULL,
  CTFIPS INTEGER NULL,
  STFIPS INTEGER NULL,
  SIGNT NVARCHAR(255) NOT NULL,
  SIGNN NVARCHAR(255) NOT NULL,
  GEOG GEOGRAPHY NOT NULL,
  GEOM GEOMETRY NOT NULL,
CONSTRAINT PK_ID_HIGHWAYS PRIMARY KEY CLUSTERED (ID ASC)
);
GO

-- Create Route Aggregates
--
-- Aggregate Interstate and US Highways...

DECLARE @emptyLS GEOMETRY = geometry::Parse('LINESTRING EMPTY');
INSERT INTO Highways
SELECT NULL, NULL, COL1, COL2,
  dbo.GeographyUnionAggregate(INTERMEDIATEAGG), @emptyLS
FROM
(
   SELECT SIGNT1 AS COL1, SIGNN1 AS COL2,
           dbo.GeographyUnionAggregate(GEOG) AS INTERMEDIATEAGG
     FROM HIGHWAYS_TEMP
     WHERE (SIGNT1 = 'I' OR SIGNT1 = 'U')
      AND (GEOG IS NOT NULL)
       GROUP BY SIGNT1, SIGNN1
 
   UNION ALL

   SELECT SIGNT2, SIGNN2,
           dbo.GeographyUnionAggregate(GEOG)
    FROM HIGHWAYS_TEMP
    WHERE (SIGNT2 = 'I' OR SIGNT2 = 'U')
     AND (GEOG IS NOT NULL)
      GROUP BY SIGNT2, SIGNN2
  
   UNION ALL

   SELECT SIGNT3, SIGNN3,
           dbo.GeographyUnionAggregate(GEOG)
    FROM HIGHWAYS_TEMP
    WHERE (SIGNT3 = 'I' OR SIGNT3 = 'U')
     AND (GEOG IS NOT NULL)
      GROUP BY SIGNT3, SIGNN3

) AS DERIVED_TABLE
WHERE INTERMEDIATEAGG IS NOT NULL
GROUP BY COL1, COL2
HAVING dbo.GeographyUnionAggregate(INTERMEDIATEAGG) IS NOT NULL;
GO
-- OUTPUT:
--
-- 462 row(s) affected

-- Aggregate State Highways...
DECLARE @emptyLS GEOMETRY = geometry::Parse('LINESTRING EMPTY');
INSERT INTO Highways
SELECT NULL, COL0, COL1, COL2, dbo.GeographyUnionAggregate(INTERMEDIATEAGG), @emptyLS
FROM
(
   SELECT STFIPS AS COL0, SIGNT1 AS COL1, SIGNN1 AS COL2, dbo.GeographyUnionAggregate(GEOG) AS INTERMEDIATEAGG
    FROM HIGHWAYS_TEMP 
    WHERE (SIGNT1 = 'S') AND (GEOG IS NOT NULL)
      GROUP BY STFIPS, SIGNT1, SIGNN1 

   UNION ALL

   SELECT STFIPS, SIGNT2, SIGNN2, dbo.GeographyUnionAggregate(GEOG)
    FROM HIGHWAYS_TEMP 
    WHERE (SIGNT2 = 'S') AND (GEOG IS NOT NULL)
      GROUP BY STFIPS, SIGNT2, SIGNN2

   UNION ALL

   SELECT STFIPS, SIGNT3, SIGNN3, dbo.GeographyUnionAggregate(GEOG)
    FROM HIGHWAYS_TEMP 
    WHERE (SIGNT3 = 'S') AND (GEOG IS NOT NULL)
      GROUP BY STFIPS, SIGNT3, SIGNN3
) AS DERIVED_TABLE
WHERE INTERMEDIATEAGG IS NOT NULL
GROUP BY COL0, COL1, COL2
HAVING dbo.GeographyUnionAggregate(INTERMEDIATEAGG) IS NOT NULL;
GO
-- OUTPUT:
--
-- 6843 row(s) affected

-- Aggregate County routes...
DECLARE @emptyLS GEOMETRY = geometry::Parse('LINESTRING EMPTY');
INSERT INTO Highways
SELECT COL0, COL1, COL2, COL3, dbo.GeographyUnionAggregate(INTERMEDIATEAGG), @emptyLS
FROM
(
   SELECT CTFIPS AS COL0, STFIPS AS COL1, SIGNT1 AS COL2, SIGNN1 AS COL3, dbo.GeographyUnionAggregate(GEOG) AS INTERMEDIATEAGG
    FROM HIGHWAYS_TEMP 
    WHERE (SIGNT1 = 'C') AND (GEOG IS NOT NULL)
      GROUP BY STFIPS, CTFIPS, SIGNT1, SIGNN1 

   UNION ALL

   SELECT CTFIPS, STFIPS, SIGNT2, SIGNN2, dbo.GeographyUnionAggregate(GEOG)
    FROM HIGHWAYS_TEMP 
    WHERE (SIGNT2 = 'C') AND (GEOG IS NOT NULL)
      GROUP BY STFIPS, CTFIPS, SIGNT2, SIGNN2

   UNION ALL

   SELECT CTFIPS, STFIPS, SIGNT3, SIGNN3, dbo.GeographyUnionAggregate(GEOG)
    FROM HIGHWAYS_TEMP 
    WHERE (SIGNT3 = 'C') AND (GEOG IS NOT NULL)
      GROUP BY STFIPS, CTFIPS, SIGNT3, SIGNN3
) AS DERIVED_TABLE
WHERE INTERMEDIATEAGG IS NOT NULL
GROUP BY COL1, COL0, COL2, COL3
HAVING dbo.GeographyUnionAggregate(INTERMEDIATEAGG) IS NOT NULL;
GO
-- OUTPUT:
--
-- 1057 row(s) affected

--Set a constraint on the GEOG column for SRID = 4326 (WGS 84)
ALTER TABLE Highways
ADD CONSTRAINT enforce_geog_srid CHECK (GEOG.STSrid = 4326)
GO

--Create the Spatial Index on GEOG Column
CREATE SPATIAL INDEX geog_mmmm_1024_sidx
   ON HIGHWAYS(GEOG)
   USING GEOGRAPHY_GRID
   WITH (
    GRIDS = (MEDIUM, MEDIUM, MEDIUM, MEDIUM),
    CELLS_PER_OBJECT = 1024,
    PAD_INDEX = ON );
GO

--Query used to test the Spatial Index on GEOG Column
DECLARE @g GEOGRAPHY
SET @g = GEOGRAPHY::STGeomFromText('POLYGON((
     -99 40, -97 40, -97 42, -99 42, -99 40))',4326)
SET STATISTICS TIME ON
SELECT * FROM HIGHWAYS WITH(INDEX(geog_mmmm_1024_sidx))
  WHERE @g.STIntersects(GEOG)=1
SET STATISTICS TIME OFF;
GO 
-- OUTPUT:
--
-- (32 row(s) affected)
--  SQL Server Execution Times:
--  CPU time = 48 ms,  elapsed time = 84 ms.

--Populating Highways with a Single Query
-- 
-- Despite the non-normalized structure of HIGHWAYS_TEMP and the 
-- use of NULLs in the route specifiers of Highways, it’s nonetheless 
-- possible to populate Highways with a single INSERT statement. Here 
-- is such a statement, which uses UNPIVOT (twice) to normalize the 
-- data and CASE to replace CTFIPS and STFIPS with NULL when required:

-- Re-create final Highways table
DROP TABLE Highways;
GO

CREATE TABLE Highways(
  ID INTEGER IDENTITY(1,1) NOT NULL,
  CTFIPS INTEGER NULL,
  STFIPS INTEGER NULL,
  SIGNT NVARCHAR(255) NOT NULL,
  SIGNN NVARCHAR(255) NOT NULL,
  GEOG GEOGRAPHY NOT NULL,
  GEOM GEOMETRY NOT NULL,
CONSTRAINT PK_ID_HIGHWAYS PRIMARY KEY CLUSTERED (ID ASC)
);
GO

DECLARE @emptyLS GEOMETRY = geometry::Parse('LINESTRING EMPTY');
INSERT INTO Highways
SELECT
  CASE WHEN SIGNT = 'C' THEN CTFIPS END AS CTFIPS,
  CASE WHEN SIGNT IN ('C','S') THEN STFIPS END AS STFIPS,
  SIGNT, SIGNN,
  dbo.GeographyUnionAggregate(GEOG) AS GEOG,
  @emptyLS AS GEOM
FROM (
  SELECT
    CTFIPS, STFIPS, SIGNT1, SIGNN1, SIGNT2, SIGNN2, SIGNT3, SIGNN3, GEOG
  FROM HIGHWAYS_TEMP
) AS HT UNPIVOT (
    SIGNT FOR SignTNum IN (SIGNT1, SIGNT2, SIGNT3)
  ) S UNPIVOT (
    SIGNN FOR SignNNum IN (SIGNN1, SIGNN2, SIGNN3)
  ) as U
WHERE RIGHT(SignTNum,1) = RIGHT(SignNNum,1)
AND SIGNT IN ('I','U','C','S')
AND GEOG IS NOT NULL
GROUP BY
  CASE WHEN SIGNT = 'C' THEN CTFIPS END,
  CASE WHEN SIGNT IN ('C','S') THEN STFIPS END,
  SIGNT, SIGNN;
GO
-- OUTPUT:
--
-- (8362 row(s) affected)

-------------------------------------------------------------------
-- EXTENDING SPATIAL
-------------------------------------------------------------------
/*
//We begin our code by including two required assemblies.  Microsoft.SqlServer.Types 
//contains our spatial types; Microsoft.SqlServer.Server contains the required 
//SqlUserDefinedAggregate property.  We then begin our aggregate, which will have its 
//format set to UserDefined and its size set to −1 in order to accommodate a SqlGeography instance.
//using Microsoft.SqlServer.Types;
//using Microsoft.SqlServer.Server;

[SqlUserDefinedAggregate(
    Format.UserDefined,
    IsInvariantToDuplicates=true,
    IsInvariantToNulls=false,
    IsInvariantToOrder=true,
    IsNullIfEmpty=true,
    MaxByteSize=-1
)]
public class UnionAgg:IBinarySerialize
{	
    SqlGeography union = SqlGeography.Null;

//Next, since this aggregate uses UserDefined serialization, we must provide Read and Write 
//methods.  This is fairly boilerplate:
    public void Read(System.IO.BinaryReader r)
    {
        union = SqlGeography.Null;
        union.Read(r);
    }

    public void Write(System.IO.BinaryWriter w)
    {
        union.Write(w);
    }

//Finally, we provide our core aggregate methods.  The logic is very simple: keep a running 
//result by unioning each new value seen in the Accumulate methods.  The Merge method simply 
//finds the union of the running value with that of the other aggretate.

    public void Init()
    {
        union = SqlGeography.Null;
    }

    public void Accumulate(SqlGeography geog)
    {
        if (union.IsNull) union = geog;
        else union = union.STUnion(geog);
    }

    public void Merge(UnionAgg other)
    {
        union = union.STUnion(other.union);
    }

    public SqlGeography Terminate()
    {
        return union;
    }
}
*/

--Register the User Defined Aggregate: Union and Dissolve
USE [<database to enable with assembly>]
GO

-- deploy UnionAgg 
-- UnionAgg.dll has been compiled to c:\temp directory

-- drop aggregate, if it exists
IF OBJECT_ID('dbo.UnionAgg', 'AF') IS NOT NULL
	DROP AGGREGATE UnionAgg;

-- drop assembly if it exists	
IF ASSEMBLYPROPERTY('UnionAgg', 'SimpleName') IS NOT NULL
	DROP ASSEMBLY UnionAgg;
GO

CREATE ASSEMBLY UnionAgg
 FROM 'c:\temp\UnionAgg.dll'
GO 

CREATE AGGREGATE dbo.UnionAgg(@g GEOGRAPHY)
  RETURNS GEOGRAPHY
  EXTERNAL NAME UnionAgg.UnionAgg
GO

-- once the aggregate is registered as UnionAgg, we can run union a geography column containing points:
CREATE TABLE #sample_table (
 id INT IDENTITY PRIMARY KEY,
 geog GEOGRAPHY
);

-- insert three points
-- SRID defaults to 4326
INSERT INTO #sample_table VALUES('POINT(1 2)'), ('POINT(2 3)'), ('POINT(3 4)');
GO

SELECT * FROM #sample_table
GO

-- use the aggregate
DECLARE @g GEOGRAPHY
SELECT @g = dbo.UnionAgg(geog) FROM #sample_table
SELECT @g.ToString()
GO
--Results: MULTIPOINT ((3 4), (2 3), (1 2))

-- Combining this aggregate union with a standard SQL GROUP BY statement, 
-- we can perform an operation often known as a dissolve.  
-- Using the Counties table from the Sample_USA database we dissolve the 
-- 58 California Counties into a single California spatial object:
--Initial query
USE Sample_USA;
GO
--California Counties query (from left-hand side of Figure 14-30
SELECT * FROM Counties WHERE NAME_1 = 'California';
GO
--California State aggregate (from right-hand side of Figure 14-30
SELECT NAME_1, dbo.UnionAgg(geog)
  FROM Counties WHERE NAME_1 = 'California'
    GROUP BY NAME_1;
GO


---------------------------------------------------------------------------
--Sinks and Builders: Linear Transformations
---------------------------------------------------------------------------
/*
//Let’s now begin our linear transformation sink.  First, our sink’s constructor 
//will take another sink as its target.  Each of the sink methods will call the 
//target, making any changes to the data as they pass through.  This construction 
//is what will allow us to chain sinks in the future.  In addition, we need the four 
//parameters that define our linear transformation:
//using Microsoft.SqlServer.Types;

class LinearTransformationSink : IGeometrySink
{
    IGeometrySink target;
    double a, b, c, d;

    public LinearTransformationSink(IGeometrySink target, 
        double a, double b, double c, double d)
    {
        this.target = target;
        this.a = a;
        this.b = b;
        this.c = c;
        this.d = d;
    }

//Next we begin implementing our actual sink methods.  The SetSrid and BeginGeometry 
//calls will make no changes, and simply pass through to the target sink:
    public void SetSrid(int srid)
    {
        target.SetSrid(srid);
    }

    public void BeginGeometry(OpenGisGeometryType type)
    {
        target.BeginGeometry(type);
    }

//BeginFigure and AddLine perform the actual linear transformation work.  
We encapsulate the transformations themselves in a pair of methods so we 
don’t have to repeat the code:
    double TransformX(double x, double y)
    {
        return a * x + b * y;
    }

    double TransformY(double x, double y)
    {
        return c * x + d * y;
    }

    public void BeginFigure(double x, double y, double? z, double? m)
    {
        target.BeginFigure(TransformX(x, y), TransformY(x, y), z, m);
    }

    public void AddLine(double x, double y, double? z, double? m)
    {
        target.AddLine(TransformX(x, y), TransformY(x, y), z, m);
    }

//Finally, we can finish our sink.  The EndFigure and EndGeometry calls again 
//simply pass through to the target:
public void EndFigure()
  {
        target.EndFigure();
    }

    public void EndGeometry()
    {
        target.EndGeometry();
    }
  }

//This concludes the LinearTransformationSink.  But we cannot use the sink directly 
//within SQL Server, nor is it particularly convenient to use from the CLR.  To complete 
//the example, we wrap the sink in a function that connects two sinks—our transformer and 
//a SqlGeometryBuilder—into a pipeline and then runs this pipeline:
//using Microsoft.SqlServer.Types;

public class Functions
{
    public static SqlGeometry LinearTransformation(SqlGeometry geom, 
        double a, double b, double c, double d)
    {
        // build a pipeline
        SqlGeometryBuilder builder = new SqlGeometryBuilder();
        LinearTransformationSink transformer = 
                new LinearTransformationSink(builder, a, b, c, d);
        
        // run the pipeline
        geom.Populate(transformer);

        // return the result
        return builder.ConstructedGeometry;
    }
}
*/

USE [<database to enable with assembly>]
GO

--Register the new function
-- drop function, if it exists
IF OBJECT_ID('dbo.LinearTransformation', 'FS') IS NOT NULL
	DROP FUNCTION dbo.LinearTransformation;

-- drop assembly if it exists	
IF ASSEMBLYPROPERTY('transformer', 'SimpleName') IS NOT NULL
	DROP ASSEMBLY transformer;
GO

CREATE ASSEMBLY transformer
 FROM 'c:\temp\GeometryLinearTransform.dll'
GO

CREATE FUNCTION dbo.LinearTransformation(
 @g GEOMETRY,
 @x FLOAT,
 @y FLOAT,
 @z FLOAT,
 @m FLOAT
 )
RETURNS GEOMETRY
AS
EXTERNAL NAME transformer.Functions.LinearTransformation;
GO

--Here is an example of the new T-SQL function LinearTransformation in use:
DECLARE @g GEOMETRY
SET @g = 'POLYGON((0 0, 5 0, 5 5, 0 5, 0 0))'
SELECT dbo.LinearTransformation(@g, 2, 3, 4, 5).ToString() AS TransformedWKT     
GO
-- OUTPUT:
--
-- Transformed WKT
-- -----------------------------------------
-- POLYGON ((0 0, 10 20, 25 45, 15 25, 0 0))






