-- "What subway station is in 'Little Italy'? What subway route is it on?"
SELECT subway.name, subway.routes
FROM nyc_subway_stations AS subway
JOIN nyc_neighborhoods as neighborhoods
	ON ST_Contains(neighborhoods.geom, subway.geom)
WHERE neighborhoods.name = 'Little Italy';

-- "What are all the neighborhoods served by the 6-train?"
SELECT DISTINCT n.name, n.boroname
FROM nyc_neighborhoods AS n
JOIN nyc_subway_stations AS s
	ON ST_Contains(n.geom, s.geom)
WHERE strpos(s.routes, '6') > 0;

-- "After 9/11, the 'Battery Park' neighborhood was off limits for several days. How many people had to be evacuated?"
SELECT Sum(c.popn_total)
FROM nyc_census_blocks as c
JOIN nyc_neighborhoods as n
	ON ST_Intersects(c.geom, n.geom)
WHERE n.name = 'Battery Park';

-- "What neighborhood has the highest population density (persons/km²)?"
SELECT 
	n.name, 
	Sum(c.popn_total) / (ST_Area(n.geom) / 1000000) AS popn_per_sqkm
FROM nyc_census_blocks AS c
JOIN nyc_neighborhoods AS n
	ON ST_Intersects(c.geom, n.geom)
GROUP BY n.name, n.geom
ORDER BY popn_per_sqkm DESC LIMIT 1;