
-- A function to create qgrams from strings in postgres
-- Taken from http://pages.stern.nyu.edu/~panos/datacleaning/qgrams.sql

aREATE OR REPLACE FUNCTION cgrant_make_qgram(docid INT, q INT, words TEXT) 
RETURNS TABLE (docid INT, pos INT, token text) AS $$
DECLARE 
  slen INT := length(words);
  fpads TEXT := '\#\#\#\#\#\#\#';
  bpads TEXT := '\%\%\%\%\%\%\%';
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
