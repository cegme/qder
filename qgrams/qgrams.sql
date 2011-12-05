
-- A function to create qgrams from strings in postgres
-- Taken from http://pages.stern.nyu.edu/~panos/datacleaning/qgrams.sql

CREATE OR REPLACE FUNCTION cgrant_make_qgram(docid integer, q integer, words TEXT) 
RETURNS TABLE (docid integer, pos integer, token text) AS $$
DECLARE 
  slen INT := length(words);
  fpads TEXT := E'#######';
  bpads TEXT := E'%%%%%%%';
BEGIN
  RETURN QUERY SELECT docid, g, substr(substr(fpads,1,q-1) || upper(words) || substr(bpads,1,q-1), g, q)
    FROM generate_series(1, slen+q-1) AS g 
    WHERE g <= slen + q-1;
END;
$$ LANGUAGE plpgsql STRICT IMMUTABLE;

/*
SELECT cgrant_make_qgram(1, 3, 'Hello');
 cgrant_make_qgram 
-------------------
 (1,1,##H)
 (1,2,#HE)
 (1,3,HEL)
 (1,4,ELL)
 (1,5,LLO)
 (1,6,LO%)
 (1,7,O%%)
(7 rows)
*/


-- Compares two strings by creating qgrams
CREATE OR REPLACE FUNCTION cgrant_compare(doc_id1 integer, s1 text, doc_id2 integer, s2 text, k integer) RETURNS TABLE (token text, token text) AS
$$
DECLARE s1len integer;
DECLARE s2len integer;
DECLARE qlen integer := 3;
BEGIN
	SELECT INTO s1len char_length FROM char_length(s1);
	SELECT INTO s2len char_length FROM char_length(s2);
	RAISE NOTICE 's1len: %, s2len: %', s1len, s2len;
	RETURN QUERY	
		SELECT d1.token, d2.token
		FROM cgrant_make_qgram(doc_id1, qlen, s1) as d1,
		cgrant_make_qgram(doc_id2, qlen, s2) as d2
		WHERE d1.token = d2.token AND abs(d1.pos - d2.pos) < k
		GROUP BY d1.token, d2.token;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

/*
select cgrant_compare(0, 'The big black dog', 1, 'The bigger black dog', 4);
*/



CREATE OR REPLACE FUNCTION cgrant_distance(doc_id1 integer, s1 text, doc_id2 integer, s2 text, k integer) RETURNS decimal AS
$$
DECLARE s1len integer;
DECLARE s2len integer;
DECLARE qlen integer := 3;
DECLARE overlap decimal;
BEGIN
	SELECT INTO s1len char_length FROM char_length(s1);
	SELECT INTO s2len char_length FROM char_length(s2);
	overlap := count(*) FROM
		(SELECT d1.token, d2.token
			FROM cgrant_make_qgram(doc_id1, qlen, s1) as d1,
			cgrant_make_qgram(doc_id2, qlen, s2) as d2
			WHERE d1.token = d2.token AND abs(d1.pos - d2.pos) < k
			GROUP BY d1.token, d2.token) as q;
	-- RAISE NOTICE 'overlap: %', overlap;
	IF s1len < s2len THEN
		RETURN overlap / (s1len+qlen-1);
	ELSE
		RETURN overlap / (s2len+qlen-1);
	END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;



