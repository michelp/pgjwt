BEGIN;
DROP SCHEMA IF EXISTS jwt CASCADE;
CREATE SCHEMA jwt;


CREATE OR REPLACE FUNCTION jwt.encode(data bytea) RETURNS text LANGUAGE sql AS $$
    SELECT translate(encode(data, 'base64'), '+/=', '-_');
$$;

CREATE OR REPLACE FUNCTION jwt.decode(data text) RETURNS bytea LANGUAGE sql AS $$
    SELECT decode(translate(data, '-_', '+/') || '=', 'base64');
$$;


CREATE OR REPLACE FUNCTION jwt.sign(data text, secret text, algorithm text DEFAULT 'sha256')
RETURNS text LANGUAGE sql AS $$
SELECT jwt.encode(hmac(data, secret, algorithm));
$$;

CREATE OR REPLACE FUNCTION jwt.jwt(payload json, secret text, algorithm text DEFAULT 'sha256')
RETURNS text LANGUAGE sql AS $$
WITH header AS (SELECT jwt.encode(convert_to('{"alg":"HS256","typ":"JWT"}', 'utf8'))),
     payload AS (SELECT jwt.encode(convert_to(payload::text, 'utf8'))),
     signables AS (SELECT (SELECT * FROM header) || '.' || (SELECT * FROM payload))
SELECT
    (SELECT * FROM signables)
    || '.' ||
    jwt.sign((SELECT * FROM signables), secret, algorithm);
$$;

COMMIT;
