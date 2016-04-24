BEGIN;
DROP SCHEMA IF EXISTS jwt CASCADE;
CREATE SCHEMA jwt;


CREATE OR REPLACE FUNCTION jwt.base64_urlencode(data bytea) RETURNS text LANGUAGE sql AS $$
    SELECT translate(encode(data, 'base64'), '+/=', '-_');
$$;

CREATE OR REPLACE FUNCTION jwt.base64_urldecode(data text) RETURNS text LANGUAGE sql AS $$
    SELECT convert_from(decode(translate(data, '-_', '+/') || '=', 'base64'), 'utf8')
$$;


CREATE OR REPLACE FUNCTION jwt.sign(data text, secret text, algorithm text DEFAULT 'sha256') 
RETURNS text LANGUAGE sql AS $$
SELECT jwt.base64_urlencode(hmac(data, secret, algorithm));
$$;

CREATE OR REPLACE FUNCTION jwt.encode(payload json, secret text, algorithm text DEFAULT 'sha256') 
RETURNS text LANGUAGE sql AS $$
WITH header AS (SELECT jwt.base64_urlencode('{"alg": "HS256", "typ": "JWT"}')),
     payload AS (SELECT jwt.base64_urlencode(convert_to(payload::text, 'utf8')))
SELECT (SELECT * FROM header) 
    || '.' || 
    (SELECT * FROM payload) 
    || '.' || 
    jwt.sign((SELECT * FROM header) || '.' || (SELECT * FROM payload), 
             secret, algorithm);
$$;

COMMIT;

