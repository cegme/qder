
-- Ideas of this implementation of a bloom filter taken from
-- http://antognini.ch/papers/BloomFilters20080620.pdf

-- DROP TYPE cgrant_bf;
CREATE TYPE cgrant_bf AS (
	vec boolean[], -- array svec or regular array
	m INT, -- array size
	k INT, -- k number of hash functions
	seeds integer[] -- array with hash function seeds
);

------------------------------------------------------------------------------
-- DROP FUNCTION cgrant_bf_init(m INT, k INT);
CREATE OR REPLACE FUNCTION cgrant_bf_init(m INT, k INT) RETURNS cgrant_bf AS 
$$
DECLARE thearray boolean[];
DECLARE thehash integer[];
DECLARE bloomfilter cgrant_bf;
BEGIN
	SELECT ARRAY(SELECT FALSE FROM generate_series(1,m))::boolean[] INTO thearray; 
	SELECT ARRAY(SELECT generate_series(1,k))::integer[] INTO thehash;
	bloomfilter := ROW(
		thearray,
		m,
		k,
		thehash
	);
	RETURN bloomfilter;
END;
$$ LANGUAGE plpgsql IMMUTABLE;


------------------------------------------------------------------------------
DROP FUNCTION cgrant_hash1(text);
CREATE FUNCTION cgrant_hash1(s text) RETURNS integer AS
$$
	return hash(s) -- TODO can we have a non plpython hash function
$$ LANGUAGE plpythonu IMMUTABLE;

------------------------------------------------------------------------------
-- hashpjw 
DROP FUNCTION cgrant_hash2 (text);
CREATE FUNCTION cgrant_hash2(s text) RETURNS numeric AS
$$
DECLARE 
	val integer := 0;
	tmp integer;
	sarray char[];
BEGIN
	sarray := regexp_split_to_array(s,'');
	FOR c IN 1..char_length(s) LOOP
		val := (val << 4) + ascii(sarray[c]);
		tmp := val & 0xf0000000;
		IF tmp != 0 THEN
			val := val # (tmp >> 24);
			val := val # tmp;
		END IF;
	END LOOP;
	RETURN val;
END;
$$ LANGUAGE plpgsql;

------------------------------------------------------------------------------
DROP FUNCTION cgrant_hashindices(text, int, int);
CREATE FUNCTION cgrant_hashindices(s text, k int, m int) RETURNS integer[] AS
$$
DECLARE ind integer[];
BEGIN
	FOR i IN 1..k LOOP
		ind[i] := abs(hashtext(text) + i * cgrant_hash2(text)) % m + 1;
	END LOOP;
	RETURN ind;
END;
$$ LANGUAGE plpgsql;


------------------------------------------------------------------------------
-- Insert values into the hash function
-- HT to http://www.coolsnap.net/kevin/?p=13
-- h_i(val) = (h1(val) + i * h2(val)) % m
CREATE OR REPLACE FUNCTION cgrant_bf_add_value(s text, _bf cgrant_bf) 
RETURNS cgrant_bf AS
$$
DECLARE ind integer;
DECLARE bf cgrant_bf;
BEGIN
	bf := _bf;
	FOR i IN 1..bf.k LOOP
		--ind := (abs(cgrant_hash1(s) + i * cgrant_hash2(s)) % bf.m) + 1;
		ind := (abs(hashtext(s) + i * cgrant_hash2(s)) % bf.m) + 1;
		bf.vec[ind] := TRUE;
	END LOOP;
	RETURN bf;
END;
$$ LANGUAGE plpgsql;

------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION cgrant_bf_contains(s text, bf cgrant_bf)
RETURNS boolean AS
$$
DECLARE ind integer;
BEGIN
	FOR i in 1..bf.k LOOP
		--ind := (abs(cgrant_hash1(s) + i * cgrant_hash2(s)) % bf.m) + 1;
		ind := (abs(hashtext(s) + i * cgrant_hash2(s)) % bf.m) + 1;
		IF NOT bf.vec[ind] THEN
			RETURN FALSE;
		END IF;
	END LOOP;
	RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION test_bf(m int, k int) RETURNS integer AS
$$
DECLARE bf cgrant_bf;
DECLARE b boolean;
BEGIN
	bf := cgrant_bf_init(m,k);
	b := FALSE;
	bf := cgrant_bf_add_value('Christan', bf);
	b := cgrant_bf_contains('Chris', bf);
	RAISE NOTICE E'Chris in there %? \n', b; 
	b := cgrant_bf_contains('Christan', bf);
	RAISE NOTICE E'Christ in there %? \n', b;
	RETURN 0;
END;
$$ LANGUAGE plpgsql;


------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Here we insert some documents and bloom filters and test insertion/retrieval
-- We will insert tweets
------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION test_bf2() RETURNS integer AS
$$
DECLARE t1 CONSTANT text := E'Cardinals fall further behind in wild-card race (Sacramento Bee): Share With Friends:  |  | Top News - World... http://t.co/ZqbjVynq';
DECLARE t2 CONSTANT text := E'Goooood job red raiders! Way to kick ass #wreckem';
DECLARE t3 CONSTANT text := E'Work at 5am. the things I do to watch the redskins game on time';
DECLARE t4 CONSTANT text := E'I know we better beat the fuckin falcons tomorrow...';
DECLARE t5 CONSTANT text := E'Madden NFL 12 Review http://t.co/ZPqQidXf [news]';
DECLARE b1 cgrant_bf;
DECLARE b2 cgrant_bf;
DECLARE b3 cgrant_bf;
DECLARE b4 cgrant_bf;
DECLARE b5 cgrant_bf;
DECLARE t text;
BEGIN
	b1 := cgrant_bf_init(10000,30);
	-- b2 := cgrant_bf_init(10000,30);
	-- b3 := cgrant_bf_init(10000,30);
	-- b4 := cgrant_bf_init(10000,30);
	-- b5 := cgrant_bf_init(10000,30);
	FOR t IN SELECT token FROM cgrant_make_qgram(1, 3, t1) LOOP
		RAISE NOTICE '3grams %', t ;
		b1 := cgrant_bf_add_value(t, b1);
	END LOOP; 
	RAISE NOTICE 'b1 size %, text size %', pg_column_size(b1), pg_column_size(t1);
	RAISE NOTICE '%', cgrant_bf_contains('Can', b1);
	-- TODO create more difficult test for the bloom filter
	RETURN 0;
END;
$$ LANGUAGE plpgsql;




