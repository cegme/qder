
-- Ideas of this implementation of a bloom filter taken from
-- http://antognini.ch/papers/BloomFilters20080620.pdf

-- DROP TYPE cgrant_bf;
CREATE TYPE cgrant_bf AS (
	vec boolean[], -- array svec or regular array
	m INT, -- array size
	k INT, -- k number of hash functions
	seeds integer[] -- array with hash function seeds
);

DROP FUNCTION cgrant_bf_init(m INT, k INT);
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
$$ LANGUAGE plpgsql;


-- CREATE OR REPLACE FUNCTION cgrant_bf_add_value() -- add value to the bf
-- CREATE OR REPLACE FUNCTION cgrant_bf_contains() -- contains


