----- Available Tables: 
	----- nyc_census_blocks (blkid, popn_total, boroname, geom)
	----- nyc_streets(name, type, geom)
	----- nyc_subway_stations (name, geom)
	----- nyc_neighborhoods (name, boroname, geom)


-- 10.1 Exercises

----- "What is the area of the 'West Village' neighborhood?"
SELECT ST_Area(geom)
	FROM nyc_neighborhoods
	WHERE name = 'West Village';

----- "What is the geometry type of 'Pelham St'? The length?"
SELECT 	ST_GeometryType(geom), 
		ST_Length(geom)
	FROM nyc_streets
	WHERE name = 'Pelham St';

----- "What is the GeoJSON representation of the 'Broad St' subway station?"
SELECT ST_AsGeoJSON(geom)
	FROM nyc_subway_stations
	WHERE name = 'Broad St';

----- "What is the total length of streets (in kilometers) in New York City? (Hint: The units of measurement of the spatial data are in meters)"
SELECT Sum(ST_Length(geom)) / 1000
	FROM nyc_streets;

----- "What is the area of Manhattan in acres? (Hint: Both nyc_census_blocks and nyc_neighborhoods have a boroname in them. 1 acre = ~4047 m²)"
SELECT Sum(ST_Area(geom)) / 4047
	FROM nyc_neighborhoods
	WHERE boroname = 'Manhattan';

----- "What is the most westerly subway station?"
select ST_X(geom), name
	FROM nyc_subway_stations
	ORDER BY ST_X(geom)
	LIMIT 1;

----- "How long is 'Columbus Cir' (aka Columbus Cirkle)?"
SELECT ST_Length(geom)
	FROM nyc_streets
	WHERE name = 'Columbus Cir';

----- "What is the length of streets in New York City, summarizied by type in descending order?"
SELECT type, Sum(ST_Length(geom)) AS length
	FROM nyc_streets
	GROUP BY type
	ORDER BY length DESC;
