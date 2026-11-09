----- Spatial joins are the bread-and-butter of spatial databases. They allow you to combine information from different tables by using spatial relationships as the join key. 
----- Much of what we think of as “standard GIS analysis” can be expressed as spatial joins.
----- In the previous section, we explored spatial relationships using a two-step process: 
----- first we extracted a subway station point for ‘Broad St’; then, we used that point to ask further questions such as “what neighborhood is the ‘Broad St’ station in?”
----- Using a spatial join, we can answer the question in one step, retrieving information about the subway station and the neighborhood that contains it:
SELECT
	SUBWAYS.NAME AS SUBWAY_NAME,
	NEIGHBORHOODS.NAME AS NEIGHBORHOOD_NAME,
	NEIGHBORHOODS.BORONAME AS BOROUGH
FROM
	NYC_NEIGHBORHOODS AS NEIGHBORHOODS
	JOIN NYC_SUBWAY_STATIONS AS SUBWAYS ON ST_CONTAINS (NEIGHBORHOODS.GEOM, SUBWAYS.GEOM)
WHERE
	SUBWAYS.NAME = 'Broad St';


-- 13.1 Join & Summarize

----- The combination of a JOIN with a GROUP BY provides the kind of analysis that is usually done in a GIS system.
----- For example: “What is the population and racial make-up of the neighborhoods of Manhattan?” 
----- Here we have a question that combines information from about population from the census with the boundaries of neighborhoods, with a restriction to just one borough of Manhattan:
SELECT
	NEIGHBORHOODS.NAME AS NEIGHBORHOOD_NAME,
	SUM(CENSUS.POPN_TOTAL) AS POPULATION,
	100.0 * SUM(CENSUS.POPN_WHITE) / SUM(CENSUS.POPN_TOTAL) AS WHITE_PCT,
	100.0 * SUM(CENSUS.POPN_BLACK) / SUM(CENSUS.POPN_TOTAL) AS BLACK_PCT
FROM
	NYC_NEIGHBORHOODS AS NEIGHBORHOODS
	JOIN NYC_CENSUS_BLOCKS AS CENSUS ON ST_INTERSECTS (NEIGHBORHOODS.GEOM, CENSUS.GEOM)
WHERE
	NEIGHBORHOODS.BORONAME = 'Manhattan'
GROUP BY
	NEIGHBORHOODS.NAME
ORDER BY
	WHITE_PCT DESC;

----- What’s going on here? Notionally (the actual evaluation order is optimized under the covers by the database) this is what happens:
	----- 1. The JOIN clause creates a virtual table that includes columns from both the neighborhoods and census tables.
	----- 2. The WHERE clause filters our virtual table to just rows in Manhattan.
	----- 3. The remaining rows are grouped by the neighborhood name and fed through the aggregation function to Sum() the population values.
	----- 4. After a little arithmetic and formatting (e.g., GROUP BY, ORDER BY) on the final numbers, our query spits out the percentages.

----- We can also use distance tests as a join key, to create summarized “all items within a radius” queries. Let’s explore the racial geography of New York using distance queries.
----- First, let’s get the baseline racial make-up of the city:
SELECT
	100.0 * Sum(popn_white) / Sum(popn_total) AS white_pct,
	100.0 * Sum(popn_black) / Sum(popn_total) AS black_pct,
	Sum(popn_total) AS popn_total
FROM nyc_census_blocks;

----- So, of the 8M people in New York, about 44% are recorded as “white” and 26% are recorded as “black”.
----- Duke Ellington once sang that “You / must take the A-train / To / go to Sugar Hill way up in Harlem.” 
----- As we saw earlier, Harlem has far and away the highest African-American population in Manhattan (80.5%). Is the same true of Duke’s A-train?

----- First, note that the contents of the nyc_subway_stations table routes field is what we are interested in to find the A-train. The values in there are a little complex:
SELECT DISTINCT routes from nyc_subway_stations;	-- DISTINCT = eliminate duplicate rows

----- So to find the A-train, we will want any row in routes that has an ‘A’ in it. 
----- We can do this a number of ways, but today we will use the fact that strpos(routes,'A') will return a non-zero number only if ‘A’ is in the routes field:
SELECT DISTINCT routes
FROM nyc_subway_stations AS subways
WHERE strpos(subways.routes, 'A') > 0;

----- Let’s summarize the racial make-up of within 200 meters of the A-train line:
SELECT
  100.0 * Sum(popn_white) / Sum(popn_total) AS white_pct,
  100.0 * Sum(popn_black) / Sum(popn_total) AS black_pct,
  Sum(popn_total) AS popn_total
FROM nyc_census_blocks AS census
JOIN nyc_subway_stations AS subways
	ON ST_DWIthin(census.geom, subways.geom, 200)
WHERE strpos(subways.routes, 'A') > 0;


-- 13.2 Advanced Join

----- In the last section we saw that the A-train didn’t serve a population that differed much from the racial make-up of the rest of the city. 
----- Are there any trains that have a non-average racial make-up?

----- To answer that question, we’ll add another join to our query, so that we can simultaneously calculate the make-up of many subway lines at once. 
----- To do that, we’ll need to create a new table that enumerates all the lines we want to summarize:
CREATE TABLE subway_lines ( route char(1) );
INSERT INTO subway_lines (route) VALUES
  ('A'),('B'),('C'),('D'),('E'),('F'),('G'),
  ('J'),('L'),('M'),('N'),('Q'),('R'),('S'),
  ('Z'),('1'),('2'),('3'),('4'),('5'),('6'),
  ('7');

----- Now we can join the table of subway lines onto our original query:
SELECT
  lines.route,
  100.0 * Sum(popn_white) / Sum(popn_total) AS white_pct,
  100.0 * Sum(popn_black) / Sum(popn_total) AS black_pct,
  Sum(popn_total) AS popn_total
FROM nyc_census_blocks AS census
JOIN nyc_subway_stations AS subways
	ON ST_DWithin(census.geom, subways.geom, 200)
JOIN subway_lines AS lines
	ON strpos(subways.routes, lines.route) > 0
GROUP BY lines.route
ORDER BY black_pct DESC;

----- As before, the joins create a virtual table of all the possible combinations available within the constraints of the JOIN ON restrictions, 
----- and those rows are then fed into a GROUP summary. The spatial magic is in the ST_DWithin function, that ensures only census blocks close to the appropriate subway stations 
----- are included in the calculation.


-- 13.3 Function List
----- ST_Contains(geometry A, geometry B): Returns true if and only if no points of B lie in the exterior of A, and at least one point of the interior of B lies in the interior of A.
----- ST_DWithin(geometry A, geometry B, radius): Returns true if the geometries are within the specified distance of one another.
----- ST_Intersects(geometry A, geometry B): Returns TRUE if the Geometries/Geography “spatially intersect” - (share any portion of space) and FALSE if they don’t (they are Disjoint).
----- round(v numeric, s integer): PostgreSQL math function that rounds to s decimal places
----- strpos(string, substring): PostgreSQL string function that returns an integer location of a specified substring.
----- sum(expression): PostgreSQL aggregate function that returns the sum of records in a set of records.