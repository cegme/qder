-- These are all the function needed to use the bm25 function


 
----------------------------------------------------------------------
-- We need a table to hold the (id,para,token) map
CREATE TABLE tokencounts (id varchar, para int, token varchar);

INSERT INTO TABLE tokencounts
SELECT id, para, (p).token, (p).alias, p, paragraph
FROM(
	SELECT d.id, d.para, d.paragraph, ts_debug(d.paragraph) as p
	FROM NYTDATA d) ts
WHERE (p).alias IN ('asciiword', 'word', 'email', 'numword', 'asciihword', 
	'url', 'file', 'sfloat', 'float', 'int', 'uint', 'version', 
	'tag', 'entity');


--------
-- COPY create the function and copy it to a file
COPY ( 
	SELECT id, para, (p).token, (p).alias
	FROM(
		SELECT d.id, d.para, d.paragraph, ts_debug(d.paragraph) as p
		FROM NYTDATA d) ts
	WHERE (p).alias IN ('asciiword', 'word', 'email', 'numword', 'asciihword', 
		'url', 'file', 'sfloat', 'float', 'int', 'uint', 'version', 
		'tag', 'entity'))
	TO '/var/tmp/nyt_tokens.csv' WITH DELIMITER ',' CSV HEADER;

-- TODO - Alter table and add indexes. It may be helpful to sort the table


----------------------------------------------------------------------

-- Term Frequency tf_{t,d}
CREATE OR REPLACE FUNCTION tf(token varchar, docid varchar)
RETURNS int AS $$
BEGIN
	SELECT count(token) 
	FROM tokencount t
	WHERE id = docid AND t.token = token
END;
$$ LANGUAGE SQL;


----------------------------------------------------------------------

-- Inverse document frequency IDF_q
CREATE OR REPLACE FUNCTION idf(token varchar)
RETURNS double AS $$
DECLARE N int; 
DECLARE n_token int; 
BEGIN
	-- SELECT INTO N count(id) FROM tokencount GROUP BY id;
	-- SELECT INTO n_token count(id) FROM tokencount t WHERE t.token = token GROUP BY id;
	-- RETURN log((N - n_token + 0.5)/(n_token + 0.5)); 
	RETURN ((SELECT count(id) FROM tokencount GROUP BY id) - 
		(SELECT count(id) FROM tokencount t WHERE t.token = token GROUP BY id)+0.5
		/(SELECT count(id) FROM tokencount t WHERE t.token = token GROUP BY id)+0.5)
END;
$$ LANGUAGE plpgsql;



----------------------------------------------------------------------

-- TF-IDF Function
CREATE OR REPLACE FUNCTION tfidf(token varchar, docid, varchar)
RETURNS double AS $$
BEGIN
	SELECT tf(token, docid) * idf(token)
END;
$$ LANGUAGE SQL;


----------------------------------------------------------------------

-- BM25 Ranking
---- http://en.wikipedia.org/wiki/Okapi_BM25
CREATE OR REPLACE FUNCTION bm25(docid varchar, tokens string[], k_1 double, b, double)
RETURNS double AS $$
DECLARE result double := 0.0;
DECLARE q_i varchar;
BEGIN
	FOR q_i IN SELECT unnest(tokens)
	LOOP
		SELECT INTO result 
			SELECT result + (idf(q_i) * (tf(q_i,docid)*(k_1+1)) /
				tf(q_i,docid)+k_1(1-b+b*(
						(SELECT count(token) FROM tokencount WHERE id=docid)/
						(SELECT avg(token) FROM tokencount GROUP BY id))))
	END LOOP;
	RETURN result;
END;
$$ LANGUAGE SQL;




