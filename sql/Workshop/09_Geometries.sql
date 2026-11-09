-- 9.1 Introduction

--- 1: create table 
--- 2: insert geometries (point, line, polygon, polygon with hole, collection)
--- 3: select inserted rows & display
CREATE TABLE geometries (name varchar, geom geometry); 

INSERT INTO geometries VALUES
  ('Point', 'POINT(0 0)'),
  ('Linestring', 'LINESTRING(0 0, 1 1, 2 1, 2 2)'),
  ('Polygon', 'POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))'),
  ('PolygonWithHole', 'POLYGON((0 0, 10 0, 10 10, 0 10, 0 0),(1 1, 1 2, 2 2, 2 1, 1 1))'),
  ('Collection', 'GEOMETRYCOLLECTION(POINT(2 0),POLYGON((0 0, 1 0, 1 1, 0 1, 0 0)))');

SELECT name, ST_AsText(geom) FROM geometries;


-- 9.2 Metadata Tables

----- PostGIS provides 2 tables to track/report on the geometry types available in the database
	----- spatial_ref_sys: defines all spatial reference systems 
	----- geometry_columns: provides a listing of all "features" & basic details

--- "Let's have a look at the geometry_columns table in our database"
SELECT * FROM geometry_columns;

----- f_table_catalog, f_table_schema, and f_table_name provide the fully qualified name of the feature table containing a given geometry. 
----- Because PostgreSQL doesn’t make use of catalogs, f_table_catalog will tend to be empty.
	----- f_geometry_column: the name of the column that geometry containing column – for feature tables with multiple geometry columns, there will be one record for each.
	----- coord_dimension & srid: define the the dimension of the geometry (2-, 3- or 4-dimensional) and the Spatial Reference system identifier that refers to the spatial_ref_sys table respectively.
	----- The type column defines the type of geometry as described below; we’ve seen Point and Linestring types so far.

--- Example: Define SRID 
ALTER TABLE nyc_neighborhoods
	ALTER COLUMN geom
	TYPE geometry(MultiPolygon, 26918)
	USING ST_SetSRID(geom, 26918);


-- 9.3 Representing Real World Objects

----- Our example table contains a mixture of different geometry types. We can collect general information about each object using functions that read the geometry metadata:
	----- ST_GeometryType(geometry): returns the type of the geometry
	----- ST_NDims(geometry): returns the number of dimensions of the geometry
	----- ST_SRID(geometry): returns the spatial reference identifier number of the geometry

SELECT name, ST_GeometryType(geom), ST_NDims(geom), ST_SRID(geom)
	FROM geometries;


--- 9.3.1 Points

SELECT ST_AsText(geom)
	FROM geometries
	WHERE name = 'Point';

----- Some of the specific spatial functions for working with points are:
	----- ST_X(geometry): returns the X ordinate
	----- ST_Y(geometry): returns the Y ordinate

----- So, we can read the ordinates from a point like this:
SELECT ST_X(geom), ST_Y(geom)
	FROM geometries
	WHERE name = 'Point';

----- The New York City subway stations (nyc_subway_stations) table is a data set represented as points. 
----- The following SQL query will return the geometry associated with one point (in the ST_AsText column):
SELECT name, ST_AsText(geom)
	FROM nyc_subway_stations
	LIMIT 1;


--- 9.3.2 Linestrings

----- The street network for New York (nyc_streets) was loaded earlier in the workshop. This dataset contains details such as name, and type. 
----- A single real world street may consist of many linestrings, each representing a segment of road with different attributes.
----- The following SQL query will return the geometry associated with one linestring (in the ST_AsText column)
SELECT ST_AsText(geom)
	FROM geometries
	WHERE name = 'Linestring';

----- Some of the specific spatial functions for working with linestrings are:
	----- ST_Length(geometry): returns the length of the linestring
	----- ST_StartPoint(geometry): returns the first coordinate as a point
	----- ST_EndPoint(geometry): returns the last coordinate as a point
	----- ST_NPoints(geometry): returns the number of coordinates in the linestring

----- So, the length of our linestring is:
SELECT ST_Length(geom)
		FROM geometries
		WHERE name = 'Linestring';


--- 9.3.3 Polygons

----- The following SQL query will return the geometry associated with one polygon (in the ST_AsText column):
SELECT name, ST_AsText(geom)
	FROM geometries
	WHERE name LIKE 'Polygon%';

----- Note: Rather than using an = sign in our WHERE clause, we are using the LIKE operator to carry out a string matching operation. 
----- You may be used to the ``*`` symbol as a “glob” for pattern matching, but in SQL the ``%`` symbol is used, along with the LIKE operator to tell the system to do globbing.
	
----- Some of the specific spatial functions for working with polygons are:
	----- ST_Area(geometry): returns the area of the polygons
	----- ST_NRings(geometry): returns the number of rings (usually 1, more if there are holes)
	----- ST_ExteriorRing(geometry): returns the outer ring as a linestring
	----- ST_InteriorRingN(geometry,n): returns a specified interior ring as a linestring
	----- ST_Perimeter(geometry): returns the length of all the rings

----- We can calculate the area of our polygons using the area function:
SELECT name, ST_Area(geom), geom
	FROM geometries
	WHERE name LIKE 'Polygon%';


--- 9.3.4 Collections

----- There are four collection types, which group multiple simple geometries into sets:
	----- MultiPoint: a collection of points
	----- MultiLineString: a collection of linestrings
	----- MultiPolygon: a collection of polygons
	----- GeometryCollection: a heterogeneous collection of any geometry (including other collections)

----- Our example collection contains a polygon and a point:
SELECT name, ST_AsText(geom), geom
	FROM geometries
	WHERE name = 'Collection';

----- Some of the specific spatial functions for working with collections are:
	----- ST_NumGeometries(geometry): returns the number of parts in the collection
	----- ST_GeometryN(geometry,n): returns the specified part
	----- ST_Area(geometry): returns the total area of all polygonal parts
	----- ST_Length(geometry): returns the total length of all linear parts


-- 9.4 Geometry Input and Output

----- Within the database, geometries are stored on disk in a format only used by the PostGIS program. 
----- In order for external programs to insert and retrieve useful geometries, they need to be converted into a format that other applications can understand. 
----- Fortunately, PostGIS supports emitting and consuming geometries in a large number of formats:
	----- Well-known text (WKT)
		----- ST_GeomFromText(text, srid) returns geometry
		----- ST_AsText(geometry) returns text
		----- ST_AsEWKT(geometry) returns text
	----- Well-known binary (WKB)
		----- ST_GeomFromWKB(bytea) returns geometry
		----- ST_AsBinary(geometry) returns bytea
		----- ST_AsEWKB(geometry) returns bytea
	----- Geographic Mark-up Language (GML)
		----- ST_GeomFromGML(text) returns geometry
		----- ST_AsGML(geometry) returns text
	----- Keyhole Mark-up Language (KML)
		----- ST_GeomFromKML(text) returns geometry
		----- ST_AsKML(geometry) returns text
	----- GeoJSON
		----- ST_AsGeoJSON(geometry) returns text
		----- Scalable Vector Graphics (SVG)
		----- ST_AsSVG(geometry) returns text


----- The most common use of a constructor is to turn a text representation of a geometry into an internal representation:

	----- Note that in addition to a text parameter with a geometry representation, we also have a numeric parameter providing the SRID of the geometry.

	----- The following SQL query shows an example of WKB representation (the call to encode() is required to convert the binary output into an ASCII form for printing):
SELECT encode(
  ST_AsBinary(ST_GeometryFromText('LINESTRING(0 0,1 0)')),
  'hex');
)

----- For the purposes of this workshop we will continue to use WKT to ensure you can read and understand the geometries we’re viewing. 
----- However, most actual processes, such as viewing data in a GIS application, transferring data to a web service, or processing data remotely, WKB is the format of choice.

----- Since WKT and WKB were defined in the SFSQL specification, they do not handle 3- or 4-dimensional geometries. 
----- For these cases PostGIS has defined the Extended Well Known Text (EWKT) and Extended Well Known Binary (EWKB) formats. 
----- These provide the same formatting capabilities of WKT and WKB with the added dimensionality.

----- Here is an example of a 3D linestring in WKT:
SELECT ST_AsText(ST_GeometryFromText('LINESTRING(0 0 0,1 0 0,1 1 2)'));

----- Note that the text representation changes! This is because the text input routine for PostGIS is liberal in what it consumes. It will consume
	----- hex-encoded EWKB,
	----- extended well-known text, and
	----- ISO standard well-known text.

----- On the output side, the ST_AsText function is conservative, and only emits ISO standard well-known text.

----- In addition to the ST_GeometryFromText function, there are many other ways to create geometries from well-known text or similar formatted inputs:
-- Using ST_GeomFromText with the SRID parameter
SELECT ST_GeomFromText('POINT(2 2)',4326);

-- Using ST_GeomFromText without the SRID parameter
SELECT ST_SetSRID(ST_GeomFromText('POINT(2 2)'),4326);

-- Using a ST_Make* function
SELECT ST_SetSRID(ST_MakePoint(2, 2), 4326);

-- Using PostgreSQL casting syntax and ISO WKT
SELECT ST_SetSRID('POINT(2 2)'::geometry, 4326);

-- Using PostgreSQL casting syntax and extended WKT
SELECT 'SRID=4326;POINT(2 2)'::geometry;

----- In addition to emitters for the various forms (WKT, WKB, GML, KML, JSON, SVG), PostGIS also has consumers for four (WKT, WKB, GML, KML). 
----- Most applications use the WKT or WKB geometry creation functions, but the others work too. Here’s an example that consumes GML and output JSON:
SELECT ST_AsGeoJSON(ST_GeomFromGML('<gml:Point><gml:coordinates>1,1</gml:coordinates></gml:Point>'));


-- 9.5 Casting From Text

-----The WKT strings we’ve see so far have been of type ‘text’ and we have been converting them to type ‘geometry’ using PostGIS functions like ST_GeomFromText().

----- PostgreSQL includes a short form syntax that allows data to be converted from one type to another, the casting syntax, oldata::newtype. 
----- So for example, this SQL converts a double into a text string:
SELECT 0.9::text;

----- Less trivially, this SQL converts a WKT string into a geometry:
SELECT 'POINT(0 0)'::geometry;

----- One thing to note about using casting to create geometries: unless you specify the SRID, you will get a geometry with an unknown SRID. 
----- You can specify the SRID using the “extended” well-known text form, which includes an SRID block at the front:
SELECT 'SRID=4326; POINT(0 0)'::geometry;

----- It’s very common to use the casting notation when working with WKT, as well as geometry and geography columns (see Geography; Module 18).


-- 9.6 Funtion List
	----- ST_Area: Returns the area of the surface if it is a polygon or multi-polygon. For “geometry” type area is in SRID units. For “geography” area is in square meters.
	----- ST_AsText: Returns the Well-Known Text (WKT) representation of the geometry/geography without SRID metadata.
	----- ST_AsBinary: Returns the Well-Known Binary (WKB) representation of the geometry/geography without SRID meta data.
	----- ST_EndPoint: Returns the last point of a LINESTRING geometry as a POINT.
	----- ST_AsEWKB: Returns the Well-Known Binary (WKB) representation of the geometry with SRID meta data.
	----- ST_AsEWKT: Returns the Well-Known Text (WKT) representation of the geometry with SRID meta data.
	----- ST_AsGeoJSON: Returns the geometry as a GeoJSON element.
	----- ST_AsGML: Returns the geometry as a GML version 2 or 3 element.
	----- ST_AsKML: Returns the geometry as a KML element. Several variants. Default version=2, default precision=15.
	----- ST_AsSVG: Returns a Geometry in SVG path data given a geometry or geography object.
	----- ST_ExteriorRing: Returns a line string representing the exterior ring of the POLYGON geometry. Return NULL if the geometry is not a polygon. Will not work with MULTIPOLYGON
	----- ST_GeometryN: Returns the 1-based Nth geometry if the geometry is a GEOMETRYCOLLECTION, MULTIPOINT, MULTILINESTRING, MULTICURVE or MULTIPOLYGON. Otherwise, return NULL.
	----- ST_GeomFromGML: Takes as input GML representation of geometry and outputs a PostGIS geometry object.
	----- ST_GeomFromKML: Takes as input KML representation of geometry and outputs a PostGIS geometry object
	----- ST_GeomFromText: Returns a specified ST_Geometry value from Well-Known Text representation (WKT).
	----- ST_GeomFromWKB: Creates a geometry instance from a Well-Known Binary geometry representation (WKB) and optional SRID.
	----- ST_GeometryType: Returns the geometry type of the ST_Geometry value.
	----- ST_InteriorRingN: Returns the Nth interior linestring ring of the polygon geometry. Return NULL if the geometry is not a polygon or the given N is out of range.
	----- ST_Length: Returns the 2d length of the geometry if it is a linestring or multilinestring. geometry are in units of spatial reference and geography are in meters (default spheroid)
	----- ST_NDims: Returns coordinate dimension of the geometry as a small int. Values are: 2,3 or 4.
	----- ST_NPoints: Returns the number of points (vertexes) in a geometry.
	----- ST_NRings: If the geometry is a polygon or multi-polygon returns the number of rings.
	----- ST_NumGeometries: If geometry is a GEOMETRYCOLLECTION (or MULTI*) returns the number of geometries, otherwise return NULL.
	----- ST_Perimeter: Returns the length measurement of the boundary of an ST_Surface or ST_MultiSurface value. (Polygon, Multipolygon)
	----- ST_SRID: Returns the spatial reference identifier for the ST_Geometry as defined in spatial_ref_sys table.
	----- ST_StartPoint: Returns the first point of a LINESTRING geometry as a POINT.
	----- ST_X: Returns the X coordinate of the point, or NULL if not available. Input must be a point.
	----- ST_Y: Returns the Y coordinate of the point, or NULL if not available. Input must be a point.