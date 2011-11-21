
-- Ideas of this implementation of a bloom filter taken from
-- http://antognini.ch/papers/BloomFilters20080620.pdf

-- DROP TYPE cgrant_bf;
CREATE TYPE cgrant_bf AS (
	vec boolean[], -- array svec or regular array
	m INT, -- array size
	k INT, -- k number of hash functions
	seeds integer[] -- array with hash function seeds
);

-- DROP FUNCTION cgrant_bf_init(m INT, k INT);
CREATE OR REPLACE FUNCTION cgrant_bf_init(m INT, k INT) RETURNS cgrant_bf AS 
$$
DECLARE thearray boolean[];
DECLARE thehash integer[];
DECLARE bloomfilter cgrant_bf;
BEGIN
	SELECT ARRAY(SELECT FALSE FROM generate_series(0,m))::boolean[] INTO thearray; 
	SELECT ARRAY(SELECT generate_series(0,k))::integer[] INTO thehash;
	bloomfilter := ROW(
		thearray,
		m,
		k,
		thehash
	);
	RETURN bloomfilter;
END;
$$ LANGUAGE plpgsql IMMUTABLE;


/*DROP FUNCTION cgrant_hash1(text);
CREATE FUNCTION cgrant_hash1(s text) RETURNS integer AS
$$
	return hash(s)
$$ LANGUAGE plpythonu;
*/

-- hashpjw
DROP FUNCTION cgrant_hash2 (text);
CREATE FUNCTION cgrant_hash2(s text) RETURNS integer AS
$$
	val = 0
	for c in s:
		val = (val << 4) + ord(c)
		tmp = val & 0xf0000000
		if tmp != 0:
			val = val ^ (tmp >> 24)
			val = val ^ tmp
	return val
$$ LANGUAGE plpythonu;


DROP FUNCTION cgrant_hashindices(text, int, int);
CREATE FUNCTION cgrant_hashindices(s text, k int, m int) RETURNS integer[] AS
$$
	indices = []
	rv = plpy.execute("SELECT g, cgrant_hash2($1) AS h2 FROM generate_series(1,$2) AS g", [s, k+1 ])
	for i in xrange(1, k + 1):
		indices.append((hash(s) + i * rv['h2']) % m)
	return indices
$$ LANGUAGE plpythonu;


-- Insert values into the hash function
-- HT to http://www.coolsnap.net/kevin/?p=13
-- h_i(val) = (h1(val) + i * h2(val)) % m
CREATE OR REPLACE FUNCTION cgrant_bf_add_value(s text, bf cgrant_bf) 
RETURNS cgrant_bf AS
$$
	rv = plpy.execute("SELECT cgrant_hasindices($1, $2, $3)", [s, bf['k'], bf['m']])
	bf['vec'] = map(lambda x: True if x[0] in rv[0] else x[1], enumerate(bf['vec']))
	return bf
-- add value to the bf
$$ LANGUAGE plpythonu;


CREATE OR REPLACE FUNCTION cgrant_bf_contains(s text, bf cgrant_bf)
RETURNS boolean AS
$$

	rv = plpy.execute("SELECT cgrant_hasindices($1, $2, $3)", [s, bf['k'], bf['m']])
	return all(rv[0])
$$ LANGUAGE plpythonu;




