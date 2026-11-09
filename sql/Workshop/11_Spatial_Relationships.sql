----- So far we have only used spatial functions that measure (ST_Area, ST_Length), serialize (ST_GeomFromText) or deserialize (ST_AsGML) geometries. 
----- What these functions have in common is that they only work on one geometry at a time.

----- Spatial databases are powerful because they not only store geometry, they also have the ability to compare relationships between geometries.

----- Questions like “Which are the closest bike racks to a park?” or “Where are the intersections of subway lines and streets?” can only be answered by comparing geometries representing the bike racks, streets, and subway lines.

----- The OGC standard defines the following set of methods to compare geometries.


-- 11.1 ST_Equals

----- ST_Equals(geometry A, geometry B): tests the spatial equality of two geometries.
	----- Returns 'true' if two geometries of the same type have identical x,y coordinate values.

----- First, lets's retrieve a representation of a point from our nyc_subway_stations table:
SELECT name, geom
	FROM nyc_subway_stations
	WHERE name = 'Broad St';

	----- Then, plug the geometry representation back into ST_Equals test:
SELECT name
	FROM nyc_subway_stations
	WHERE ST_Equals(
		geom, 
		'0101000020266900000EEBD4CF27CF2141BC17D69516315141');


-- 11.2 ST_Intersects, ST_Disjoint, ST_Crosses, ST_Overlaps

----- ST_Intersects, ST_Crosses & ST_Overlaps: test whether the interiors of the geometries intersect.
----- ST_Intersects(geometry A, geometry B) returns t (TRUE) if the two shapes have any space in common, i.e., if their boundaries or interiors intersect.

----- The opposite of ST_Intersects is ST_Disjoint(geometry A , geometry B). If two geometries are disjoint, they do not intersect, and vice-versa. 
----- In fact, it is often more efficient to test “not intersects” than to test “disjoint” because the intersects tests can be spatially indexed, while the disjoint test cannot.

----- For multipoint/polygon, multipoint/linestring, linestring/linestring, linestring/polygon, and linestring/multipolygon comparisons, 
----- ST_Crosses(geometry A, geometry B) returns t (TRUE) if the intersection results in a geometry whose dimension is one less than the maximum dimension 
----- of the two source geometries and the intersection set is interior to both source geometries.

----- ST_Overlaps(geometry A, geometry B) compares two geometries of the same dimension and returns TRUE if their intersection set results in a geometry different 
----- from both but of the same dimension.


----- Let’s take our Broad Street subway station and determine its neighborhood using the ST_Intersects function:
SELECT name, ST_AsText(geom)
	FROM nyc_subway_stations
	WHERE name = 'Broad St';

SELECT name, boroname
	FROM nyc_neighborhoods
	WHERE ST_Intersects(geom, ST_GeomFromText('POINT(583571 4506714)', 26918));


-- 11.3 ST_Touches

----- ST_Touches tests whether two geometries touch at their boundaries, but do not intersect in their interiors
----- ST_Touches(geometry A, geometry B) returns TRUE if either of the geometries’ boundaries intersect or if only one of the geometry’s interiors intersects the other’s boundary.


-- 11.4 ST_Within & ST_Contains

----- ST_Within and ST_Contains test whether one geometry is fully within the other.

----- ST_Within(geometry A , geometry B) returns TRUE if the first geometry is completely within the second geometry.
	----- A in B?
----- ST_Contains(geometry A, geometry B) returns TRUE if the second geometry is completely contained by the first geometry.
	----- B in A?


-- 11.5 ST_Distance & ST_DWithin

----- An extremely common GIS question is “find all the stuff within distance X of this other stuff”.

----- The ST_Distance(geometry A, geometry B) calculates the shortest distance between two geometries and returns it as a float. 
----- This is useful for actually reporting back the distance between objects:
SELECT ST_Distance(
	ST_GeometryFromText('POINT(0 5)'),
	ST_GeometryFromText('LINESTRING(-2 2, 2 2)'));

----- For testing whether two objects are within a distance of one another, the ST_DWithin function provides an index-accelerated true/false test. 
----- This is useful for questions like “how many trees are within a 500 meter buffer of the road?”. 
----- You don’t have to calculate an actual buffer, you just have to test the distance relationship.

----- Using our Broad Street subway station again, we can find the streets nearby (within 10 meters of) the subway stop:
SELECT name
	FROM nyc_streets
	WHERE ST_DWithin(
		geom, 
		ST_GeomFromText('POINT(583571 4506714)', 26918),
        10
      );


-- 11.6 Function List

----- ST_Contains(geometry A, geometry B): Returns true if and only if no points of B lie in the exterior of A, and at least one point of the interior of B lies in the interior of A.
----- ST_Crosses(geometry A, geometry B): Returns TRUE if the supplied geometries have some, but not all, interior points in common.
----- ST_Disjoint(geometry A , geometry B): Returns TRUE if the Geometries do not “spatially intersect” - if they do not share any space together.
----- ST_Distance(geometry A, geometry B): Returns the 2-dimensional cartesian minimum distance (based on spatial ref) between two geometries in projected units.
----- ST_DWithin(geometry A, geometry B, radius): Returns true if the geometries are within the specified distance (radius) of one another.
----- ST_Equals(geometry A, geometry B): Returns true if the given geometries represent the same geometry. Directionality is ignored.
----- ST_Intersects(geometry A, geometry B): Returns TRUE if the Geometries/Geography “spatially intersect” - (share any portion of space) and FALSE if they don’t (they are Disjoint).
----- ST_Overlaps(geometry A, geometry B): Returns TRUE if the Geometries share space, are of the same dimension, but are not completely contained by each other.
----- ST_Touches(geometry A, geometry B): Returns TRUE if the geometries have at least one point in common, but their interiors do not intersect.
----- ST_Wihin(geometry A , geometry B): Returns true if the geometry A is completely inside geometry B
