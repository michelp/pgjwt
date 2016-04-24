BEGIN;
DROP SCHEMA IF EXISTS jwt CASCADE;
CREATE SCHEMA jwt;


CREATE OR REPLACE FUNCTION jwt.url_encode(data bytea) RETURNS text LANGUAGE sql AS $$
    SELECT translate(encode(data, 'base64'), '+/=', '-_');
$$;

CREATE OR REPLACE FUNCTION jwt.url_decode(data text) RETURNS bytea LANGUAGE sql AS $$
WITH t AS (SELECT translate(data, '-_', '+/')),
     rem AS (SELECT length((select * from t)) % 4)
    SELECT decode((select * from t)
         || CASE WHEN (select * from rem) > 0 THEN repeat('=', (4 - (select * from rem))) ELSE '' END, 'base64');
$$;


CREATE OR REPLACE FUNCTION jwt.sign(data text, secret text, algorithm text DEFAULT 'sha256')
RETURNS text LANGUAGE sql AS $$
SELECT jwt.url_encode(hmac(data, secret, algorithm));
$$;

CREATE OR REPLACE FUNCTION jwt.encode(payload json, secret text, algorithm text DEFAULT 'sha256')
RETURNS text LANGUAGE sql AS $$
WITH header AS (SELECT jwt.url_encode(convert_to('{"alg":"HS256","typ":"JWT"}', 'utf8'))),
     payload AS (SELECT jwt.url_encode(convert_to(payload::text, 'utf8'))),
     signables AS (SELECT (SELECT * FROM header) || '.' || (SELECT * FROM payload))
SELECT
    (SELECT * FROM signables)
    || '.' ||
    jwt.sign((SELECT * FROM signables), secret, algorithm);
$$;

CREATE OR REPLACE FUNCTION jwt.verify(token text, secret text, algorithm text DEFAULT 'sha256')
RETURNS boolean LANGUAGE sql AS $$
    SELECT false;
$$;

CREATE OR REPLACE FUNCTION jwt.decode(token text, secret text, algorithm text DEFAULT 'sha256')
RETURNS table(header json, payload json, signature text) LANGUAGE sql AS $$
    SELECT '{}'::json, '{}'::json, 'signed'::text;
$$;



COMMIT;
