\set ECHO none
\set QUIET 1

\pset format unaligned
\pset tuples_only true
\pset pager

\set ON_ERROR_ROLLBACK 1
\set ON_ERROR_STOP true
\set QUIET 1

CREATE EXTENSION pgcrypto;
CREATE EXTENSION pgtap;
CREATE EXTENSION pgjwt;

BEGIN;
SELECT plan(23);
    
SELECT
  is(sign('{"sub":"1234567890","name":"John Doe","admin":true}', 'secret'),
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ');


SELECT
  is(sign('{"sub":"1234567890","name":"John Doe","admin":true}', 'secret', 'HS256'),
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ');


SELECT
  throws_ok($$
    SELECT sign('{"sub":"1234567890","name":"John Doe","admin":true}', 'secret', 'bogus')
    $$,
    '22023',
    'Cannot use "": No such hash algorithm',
    'sign() should raise on bogus algorithm'
    );


SELECT
  throws_ok(
    $$SELECT header::text, payload::text, valid FROM verify(
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ',
    'secret', 'bogus')$$,
    '22023',
    'Cannot use "": No such hash algorithm',
    'verify() should raise on bogus algorithm'
);


SELECT throws_ok( -- bogus header
    $$SELECT header::text, payload::text, valid FROM verify(
    'eyJhbGciOiJIUzI1NiIBOGUScCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ',
    'secret', 'HS256')$$
    );


SELECT
  throws_ok( -- bogus payload
    $$SELECT header::text, payload::text, valid FROM verify(
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaBOGUS9lIiwiYWRtaW4iOnRydWV9.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ',
    'secret', 'HS256')$$
);


SELECT
  results_eq(
    $$SELECT header::text, payload::text, valid FROM verify(
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ',
    'secret')$$,
    $$VALUES ('{"alg":"HS256","typ":"JWT"}', '{"sub":"1234567890","name":"John Doe","admin":true}', true)$$,
    'verify() should return return data marked valid'
);


SELECT results_eq(
    $$SELECT header::text, payload::text, valid FROM verify(
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ',
    'badsecret')$$,
    $$VALUES ('{"alg":"HS256","typ":"JWT"}', '{"sub":"1234567890","name":"John Doe","admin":true}', false)$$,
    'verify() should return return data marked invalid'
);


SELECT
  is(sign('{"sub":"1234567890","name":"John Doe","admin":true}', 'secret', 'HS384'),
  E'eyJhbGciOiJIUzM4NCIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.DtVnCyiYCsCbg8gUP-579IC2GJ7P3CtFw6nfTTPw-0lZUzqgWAo9QIQElyxOpoRm');


SELECT
  results_eq(
    $$SELECT header::text, payload::text, valid FROM verify(
    E'eyJhbGciOiJIUzM4NCIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.DtVnCyiYCsCbg8gUP-579IC2GJ7P3CtFw6nfTTPw-0lZUzqgWAo9QIQElyxOpoRm',
    'secret', 'HS384')$$,
    $$VALUES ('{"alg":"HS384","typ":"JWT"}', '{"sub":"1234567890","name":"John Doe","admin":true}', true)$$,
    'verify() should return return data marked valid'
);


SELECT
  results_eq(
    $$SELECT header::text, payload::text, valid FROM verify(
    E'eyJhbGciOiJIUzM4NCIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.DtVnCyiYCsCbg8gUP-579IC2GJ7P3CtFw6nfTTPw-0lZUzqgWAo9QIQElyxOpoRm',
    'badsecret', 'HS384')$$,
    $$VALUES ('{"alg":"HS384","typ":"JWT"}', '{"sub":"1234567890","name":"John Doe","admin":true}', false)$$,
    'verify() should return return data marked invalid'
);


SELECT
  is(sign('{"sub":"1234567890","name":"John Doe","admin":true}', 'secret', 'HS512'),
  E'eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.YI0rUGDq5XdRw8vW2sDLRNFMN8Waol03iSFH8I4iLzuYK7FKHaQYWzPt0BJFGrAmKJ6SjY0mJIMZqNQJFVpkuw');


SELECT
  results_eq(
    $$SELECT header::text, payload::text, valid FROM verify(
    E'eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.YI0rUGDq5XdRw8vW2sDLRNFMN8Waol03iSFH8I4iLzuYK7FKHaQYWzPt0BJFGrAmKJ6SjY0mJIMZqNQJFVpkuw',
    'secret', 'HS512')$$,
    $$VALUES ('{"alg":"HS512","typ":"JWT"}', '{"sub":"1234567890","name":"John Doe","admin":true}', true)$$,
    'verify() should return return data marked valid'
);


SELECT
  results_eq(
    $$SELECT header::text, payload::text, valid FROM verify(
    E'eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.YI0rUGDq5XdRw8vW2sDLRNFMN8Waol03iSFH8I4iLzuYK7FKHaQYWzPt0BJFGrAmKJ6SjY0mJIMZqNQJFVpkuw',
    'badsecret', 'HS512')$$,
    $$VALUES ('{"alg":"HS512","typ":"JWT"}', '{"sub":"1234567890","name":"John Doe","admin":true}', false)$$,
    'verify() should return return data marked invalid'
);


SELECT
  results_eq(
    $$SELECT header::text, payload::text, valid FROM verify(
    E'eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJuYmYiOiJuby1kb3VibGUifQ.6TDHvMKq3Z67KaexRMuhoQ20sYSj9jConcUCO3g2bGyHXACq-FPkJIRAsy1xX90fWKieIAW_tz-4bbFLwwOTPg',
    'secret', 'HS512')$$,
    $$VALUES ('{"alg":"HS512","typ":"JWT"}', '{"nbf":"no-double"}', true)$$,
    'verify() should ignore a nbf claim with a invalid value'
);


SELECT
  results_eq(
    $$SELECT header::text, payload::text, valid FROM verify(
    E'eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOiI3NXoifQ.nfXYiSNNdYNsLrQp5Zry9p0xDCh_CkMSY1dOdqDCLc1YrDxrItwEmZIlTi3BBO8_9OCameSKMyGysYGDCNoaRg',
    'secret', 'HS512')$$,
    $$VALUES ('{"alg":"HS512","typ":"JWT"}', '{"exp":"75z"}', true)$$,
    'verify() should ignore a exp claim with a invalid value'
);


SELECT
  results_eq(
    $$SELECT valid
    FROM verify(sign(json_build_object('nbf', EXTRACT (EPOCH FROM CURRENT_TIMESTAMP) + 1), 'secret', 'HS512'), 'secret', 'HS512')$$,
    $$VALUES (false)$$,
    'verify() should not verify a jwt checked before its nbf claim'
);


SELECT
  results_eq(
    $$SELECT valid
    FROM verify(sign(json_build_object('nbf', EXTRACT (EPOCH FROM CURRENT_TIMESTAMP) - 1), 'secret', 'HS512'), 'secret', 'HS512')$$,
    $$VALUES (true)$$,
    'verify() should verify a jwt checked after its nbf claim'
);


SELECT
  results_eq(
    $$SELECT valid
    FROM verify(sign(json_build_object('exp', EXTRACT (EPOCH FROM CURRENT_TIMESTAMP) - 1), 'secret', 'HS512'), 'secret', 'HS512')$$,
    $$VALUES (false)$$,
    'verify() should not verify a jwt checked after its exp claim'
);


SELECT
  results_eq(
    $$SELECT valid
    FROM verify(sign(json_build_object('exp', EXTRACT (EPOCH FROM CURRENT_TIMESTAMP) + 1), 'secret', 'HS512'), 'secret', 'HS512')$$,
    $$VALUES (true)$$,
    'verify() should verify a jwt checked before its exp claim'
);



SELECT
  results_eq(
    $$SELECT valid
    FROM verify(sign(json_build_object('exp', EXTRACT (EPOCH FROM CURRENT_TIMESTAMP) + 1), 'secret', 'HS512'), 'secret', 'HS512')$$,
    $$VALUES (true)$$,
    'verify() should verify a jwt checked before its exp claim'
);

SELECT
  results_eq(
    $$SELECT valid
    FROM verify(sign(
      json_build_object(
        'nbf', EXTRACT (EPOCH FROM CURRENT_TIMESTAMP) - 3,
        'exp', EXTRACT (EPOCH FROM CURRENT_TIMESTAMP) - 1
      ),
      'secret', 'HS512'), 'secret', 'HS512')$$,
    $$VALUES (false)$$,
    'verify() should not verify a jwt checked outside of its claimed nbf-exp range'
);


SELECT
  results_eq(
    $$SELECT valid
    FROM verify(
      sign(
        json_build_object(
          'nbf', EXTRACT (EPOCH FROM CURRENT_TIMESTAMP) - 3,
          'exp', EXTRACT (EPOCH FROM CURRENT_TIMESTAMP) + 3
        ),
        'secret', 'HS512'
      ),
      'secret', 'HS512')$$,
    $$VALUES (true)$$,
    'verify() should verify a jwt checked within its claimed nbf-exp range'
);


SELECT * FROM finish();
ROLLBACK;
