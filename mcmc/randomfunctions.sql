
-- Random generation functions
-- Taken from: http://www.koders.com/java/fid514FC67F03BE1153B01D5A6985515E6FF80ECCDF.aspx

------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION cgrant_rand_int(low integer, high integer) 
RETURNS integer AS 
$$
BEGIN
	RETURN low + floor((high-low+1) * random());
END;
$$ LANGUAGE plpgsql VOLATILE;

------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION cgrant_rand_uniform(low decimal, high decimal)
RETURNS decimal AS
$$
BEGIN
	RETURN low + (high-low)*random();
END;
$$ LANGUAGE plpgsql VOLATILE;


------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION cgrant_rand_normal(mu decimal, sigma decimal)
RETURNS decimal AS 
$$
BEGIN 
	RETURN mu + sigma*cos(2*pi()*random()) * sqrt(-2*log(random()));
END;
$$ LANGUAGE plpgsql VOLATILE;


------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION cgrant_rand_exponential(lambda decimal)
RETURNS decimal AS
$$ 
BEGIN
	RETURN -1/lambda*log(random());
END;
$$ LANGUAGE plpgsql VOLATILE;


------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION cgrant_rand_beta(a decimal, b decimal)
RETURNS decimal AS
$$
DECLARE try_x decimal;
DECLARE try_y decimal;
BEGIN
	LOOP
		try_x := pow(random(), 1/a);
		try_y := pow(random(), 1/b);
		EXIT WHEN (try_x + try_y) > 1;
	END LOOP;	
	RETURN try_x/(try_x + try_y);
END;
$$ LANGUAGE plpgsql VOLATILE;





