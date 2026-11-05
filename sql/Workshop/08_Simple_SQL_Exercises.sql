-- "How many records are in the nyc_streets table?"
SELECT Count(*)
	FROM nyc_streets;

-- "How many streets in NYC start with ‘B’?"
SELECT Count(*)
	FROM nyc_streets
	WHERE name LIKE 'B%';

-- "What is the population of the City of New York?"
SELECT Sum(popn_total) AS population
	FROM nyc_census_blocks;

-- "What is the population of the Bronx?"
SELECT Sum(popn_total) AS population
	FROM nyc_census_blocks
	WHERE boroname = 'The Bronx';

-- "How many “neighborhoods” are in each borough?"
SELECT boroname, Count(*)
  FROM nyc_neighborhoods
  GROUP BY boroname;

-- "For each borough, what percentage of the population is white?"
SELECT
  boroname,
  100.0 * Sum(popn_white)/Sum(popn_total) AS white_pct
FROM nyc_census_blocks
GROUP BY boroname;