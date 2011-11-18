
-- Ideas of this implementation of a bloom filter taken from
-- http://antognini.ch/papers/BloomFilters20080620.pdf

CREATE OR REPLACE TYPE cgrant_bf AS (
	-- array svec or regular array
	-- array size
	-- k number of hash functions
	-- array with hash function seeds <-- This could be created by the system
	-- 
);

CREATE OR REPLACE FUNCTION cgrant_bf_init(m INT, k INT) RETURNS cgrant_bf AS 
$$
DECLARE
	m_array = -- Make an m-dimentional array with all FALSE values
	k_seeds = -- Add an array of k random seed vals
BEGIN
	RETURN cgrant_bf(m_array, m, k, k_seeds);
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION cgrant_bf_add_value() -- add value to the bf
CREATE OR REPLACE FUNCTION cgrant_bf_contains() -- contains
