
-- These are queries that can be used to sample the tweet table
CREATE TABLE tweets_10000 AS
	SELECT * FROM tweets WHERE .0001 > RANDOM();
	-- Works in 85831.289 ms

CREATE TABLE tweets_1000 AS
	SELECT * FROM tweets WHERE .001 > RANDOM();
	-- Works in 84180.452 ms

CREATE TABLE tweets_100 AS
	SELECT * FROM tweets WHERE .01 > RANDOM();
	-- Works in 85490.646 ms

CREATE TABLE tweets_10 AS
	SELECT * FROM tweets WHERE .1 > RANDOM();
	-- Works in 93642.119 ms

