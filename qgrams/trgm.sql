CREATE INDEX CONCURRENTLY trgm_twtext_gin ON tweets USING gin (twtext gin_trgm_ops);

-- Enron
-- employee liust
--psql -a -c "CREATE INDEX CONCURRENTLY trgm_firstname_gin ON employeelist USING gin (firstname gin_trgm_ops);" enron 

--psql -a -c "CREATE INDEX CONCURRENTLY trgm_lastname_gin ON employeelist USING gin (lastname gin_trgm_ops);" enron 

--psql -a -c "CREATE INDEX CONCURRENTLY trgm_email_id_gin ON employeelist USING gin (email_id gin_trgm_ops);" enron 

-- message
--psql -a -c "CREATE INDEX CONCURRENTLY trgm_sender_gin ON message USING gin (sender gin_trgm_ops);" enron 

--psql -a -c "CREATE INDEX CONCURRENTLY trgm_subject_gin ON message USING gin (subject gin_trgm_ops);" enron 

--psql -a -c "CREATE INDEX CONCURRENTLY trgm_body_gin ON message USING gin (body gin_trgm_ops);" enron 

