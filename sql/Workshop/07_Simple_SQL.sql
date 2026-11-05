-- “What are the names of all the neighborhoods in New York City?”
SELECT name FROM nyc_neighborhoods;

-- “What are the names of all the neighborhoods in Brooklyn?”
SELECT name															
  FROM nyc_neighborhoods
  WHERE boroname = 'Brooklyn';

-- “What is the number of letters in the names of all the neighborhoods in Brooklyn?”
SELECT char_length(name)											
  FROM nyc_neighborhoods
  WHERE boroname = 'Brooklyn';

-- “What is the average number of letters and standard deviation of number of letters in the names of all the neighborhoods in Brooklyn?”
SELECT avg(char_length(name)), stddev(char_length(name))			
  FROM nyc_neighborhoods
  WHERE boroname = 'Brooklyn';

-- “What is the average number of letters in the names of all the neighborhoods in New York City, reported by borough?”
SELECT boroname, avg(char_length(name)), stddev(char_length(name))	
  FROM nyc_neighborhoods
  GROUP BY boroname;