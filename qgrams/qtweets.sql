-- This function creates a qgram index for a tweets table

--DROP FUNCTION cgrant_create_qtweets();
--DROP INDEX qtweets_gram_index;
--DROP TABLE qtweets;
CREATE TABLE qtweets (
	docid numeric,
	pos numeric,
	gram text,
	PRIMARY KEY (docid, pos, gram)
);

CREATE INDEX CONCURRENTLY qtweets_gram_index ON qtweets USING hash (gram);

CREATE OR REPLACE FUNCTION cgrant_create_qtweets()
RETURNS boolean AS 
$$
DECLARE tweet tweets%rowtype;
DECLARE q numeric := 3;
BEGIN
	FOR tweet IN SELECT * FROM tweets -- LIMIT 3 -- use this to test
	LOOP
		INSERT INTO qtweets SELECT docid, pos, token AS gram FROM cgrant_make_qgram(tweet.id, q, tweet.twtext);
	END LOOP;
	RETURN true;
END
$$ LANGUAGE plpgsql VOLATILE;


-- To run this you have to first drop the qtweets table and index
-- DROP TABLE qtweets;
-- DROP INDEX qtweets_gram_index;
-- SELECT cgrant_create_qtweets();

-- SELECT count(docid)  from qtweets group by docid;



-- tweets_10000
CREATE TABLE qtweets_10000 (
  docid numeric,
  pos numeric,
  gram text,
  PRIMARY KEY (docid, pos, gram)
);

CREATE OR REPLACE FUNCTION cgrant_create_qtweets_10000()
RETURNS boolean AS
$$
DECLARE tweet tweets_10000%rowtype;
DECLARE q numeric := 3;
BEGIN
  FOR tweet IN SELECT * FROM tweets_10000 -- LIMIT 3 -- use this to test
  LOOP
    INSERT INTO qtweets_10000 SELECT docid, pos, token AS gram FROM cgrant_make_qgram(tweet.id, q, tweet.twtext);
  END LOOP;
  RETURN true;
END
$$ LANGUAGE plpgsql VOLATILE;
-- CREATE INDEX CONCURRENTLY qtweets_10000_gram_index ON qtweets_10000 USING hash (gram);


-- tweets_1000
CREATE TABLE qtweets_1000 (
  docid numeric,
  pos numeric,
  gram text,
  PRIMARY KEY (docid, pos, gram)
);

CREATE OR REPLACE FUNCTION cgrant_create_qtweets_1000()
RETURNS boolean AS
$$
DECLARE tweet tweets_1000%rowtype;
DECLARE q numeric := 3;
BEGIN
  FOR tweet IN SELECT * FROM tweets_1000 -- LIMIT 3 -- use this to test
  LOOP
    INSERT INTO qtweets_1000 SELECT docid, pos, token AS gram FROM cgrant_make_qgram(tweet.id, q, tweet.twtext);
  END LOOP;
  RETURN true;
END
$$ LANGUAGE plpgsql VOLATILE;
-- CREATE INDEX CONCURRENTLY qtweets_1000_gram_index ON qtweets_1000 USING hash (gram);


-- tweets_100
CREATE TABLE qtweets_100 (
  docid numeric,
  pos numeric,
  gram text,
  PRIMARY KEY (docid, pos, gram)
);

CREATE OR REPLACE FUNCTION cgrant_create_qtweets_100()
RETURNS boolean AS
$$
DECLARE tweet tweets_100%rowtype;
DECLARE q numeric := 3;
BEGIN
  FOR tweet IN SELECT * FROM tweets_100 -- LIMIT 3 -- use this to test
  LOOP
    INSERT INTO qtweets_100 SELECT docid, pos, token AS gram FROM cgrant_make_qgram(tweet.id, q, tweet.twtext);
  END LOOP;
  RETURN true;
END
$$ LANGUAGE plpgsql VOLATILE;
-- CREATE INDEX CONCURRENTLY qtweets_100_gram_index ON qtweets_100 USING hash (gram);


-- tweets_10
CREATE TABLE qtweets_10 (
  docid numeric,
  pos numeric,
  gram text,
  PRIMARY KEY (docid, pos, gram)
);

CREATE OR REPLACE FUNCTION cgrant_create_qtweets_10()
RETURNS boolean AS
$$
DECLARE tweet tweets_10%rowtype;
DECLARE q numeric := 3;
BEGIN
  FOR tweet IN SELECT * FROM tweets_10 -- LIMIT 3 -- use this to test
  LOOP
    INSERT INTO qtweets_10 SELECT docid, pos, token AS gram FROM cgrant_make_qgram(tweet.id, q, tweet.twtext);
  END LOOP;
  RETURN true;
END
$$ LANGUAGE plpgsql VOLATILE;

