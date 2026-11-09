----- "What is the geometry value for the street named ‘Atlantic Commons’?"
SELECT ST_AsText(geom)
	FROM nyc_streets
	WHERE name = 'Atlantic Commons';

----- "What neighborhood and borough is Atlantic Commons in?"
SELECT n.name, n.boroname
	FROM nyc_neighborhoods AS n, nyc_streets AS s
	WHERE ST_Intersects(n.geom, s.geom) AND s.name = 'Atlantic Commons';

	----- Or:
SELECT n.name, n.boroname
	FROM nyc_neighborhoods AS n
	JOIN nyc_streets AS s
		ON ST_Intersects(n.geom, s.geom)
	WHERE s.name = 'Atlantic Commons';

----- "What streets does Atlantic Commons join with?"
SELECT s.name
	FROM nyc_streets AS s
	JOIN nyc_streets AS ac
		ON ST_DWithin(s.geom, ac.geom, 0.1)	-- Join streets wihin 10cm-buffer
	WHERE ac.name = 'Atlantic Commons'
		AND s.gid <> ac.gid;	-- Avoid self-match

----- "Approximately how many people live on (within 50 meters of) Atlantic Commons?"
SELECT Sum(c.popn_total)
	FROM nyc_census_blocks AS c 
	JOIN nyc_streets as s
		ON ST_DWithin(c.geom, s.geom, 50.0)
	WHERE s.name = 'Atlantic Commons';


