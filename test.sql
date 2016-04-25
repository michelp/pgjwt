BEGIN;
SELECT plan(12);

select
  is(jwt.sign('{"sub":"1234567890","name":"John Doe","admin":true}', 'secret'),
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ');

select
  is(jwt.sign('{"sub":"1234567890","name":"John Doe","admin":true}', 'secret', 'HS256'),
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ');

select throws_ok($$
  select jwt.sign('{"sub":"1234567890","name":"John Doe","admin":true}', 'secret', 'bogus')
  $$,
  '22023',
  'Cannot use "": No such hash algorithm',
  'sign() should raise on bogus algorithm'
  );

SELECT throws_ok(
    $$SELECT header::text, payload::text, valid from jwt.verify(
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ',
    'secret', 'bogus')$$,
    '22023',
    'Cannot use "": No such hash algorithm',
    'verify() should raise on bogus algorithm'
);

SELECT results_eq(
    $$SELECT header::text, payload::text, valid from jwt.verify(
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ',
    'secret')$$,
    $$VALUES ('{"alg":"HS256","typ":"JWT"}', '{"sub":"1234567890","name":"John Doe","admin":true}', true)$$,
    'verify() should return return data marked valid'
);

SELECT results_eq(
    $$SELECT header::text, payload::text, valid from jwt.verify(
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ',
    'badsecret')$$,
    $$VALUES ('{"alg":"HS256","typ":"JWT"}', '{"sub":"1234567890","name":"John Doe","admin":true}', false)$$,
    'verify() should return return data marked invalid'
);

select
  is(jwt.sign('{"sub":"1234567890","name":"John Doe","admin":true}', 'secret', 'HS384'),
  E'eyJhbGciOiJIUzM4NCIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.DtVnCyiYCsCbg8gUP-579IC2GJ7P3CtFw6nfTTPw-0lZUzqgWAo9QIQElyxOpoRm');

SELECT results_eq(
    $$SELECT header::text, payload::text, valid from jwt.verify(
    E'eyJhbGciOiJIUzM4NCIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.DtVnCyiYCsCbg8gUP-579IC2GJ7P3CtFw6nfTTPw-0lZUzqgWAo9QIQElyxOpoRm',
    'secret', 'HS384')$$,
    $$VALUES ('{"alg":"HS384","typ":"JWT"}', '{"sub":"1234567890","name":"John Doe","admin":true}', true)$$,
    'verify() should return return data marked valid'
);

SELECT results_eq(
    $$SELECT header::text, payload::text, valid from jwt.verify(
    E'eyJhbGciOiJIUzM4NCIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.DtVnCyiYCsCbg8gUP-579IC2GJ7P3CtFw6nfTTPw-0lZUzqgWAo9QIQElyxOpoRm',
    'badsecret', 'HS384')$$,
    $$VALUES ('{"alg":"HS384","typ":"JWT"}', '{"sub":"1234567890","name":"John Doe","admin":true}', false)$$,
    'verify() should return return data marked invalid'
);

select
  is(jwt.sign('{"sub":"1234567890","name":"John Doe","admin":true}', 'secret', 'HS512'),
  E'eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.YI0rUGDq5XdRw8vW2sDLRNFMN8Waol03iSFH8I4iLzuYK7FKHaQYWzPt0BJFGrAmKJ6SjY0mJIMZ\nqNQJFVpkuw');

SELECT results_eq(
    $$SELECT header::text, payload::text, valid from jwt.verify(
    E'eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.YI0rUGDq5XdRw8vW2sDLRNFMN8Waol03iSFH8I4iLzuYK7FKHaQYWzPt0BJFGrAmKJ6SjY0mJIMZ\nqNQJFVpkuw',
    'secret', 'HS512')$$,
    $$VALUES ('{"alg":"HS512","typ":"JWT"}', '{"sub":"1234567890","name":"John Doe","admin":true}', true)$$,
    'verify() should return return data marked valid'
);

SELECT results_eq(
    $$SELECT header::text, payload::text, valid from jwt.verify(
    E'eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.YI0rUGDq5XdRw8vW2sDLRNFMN8Waol03iSFH8I4iLzuYK7FKHaQYWzPt0BJFGrAmKJ6SjY0mJIMZ\nqNQJFVpkuw',
    'badsecret', 'HS512')$$,
    $$VALUES ('{"alg":"HS512","typ":"JWT"}', '{"sub":"1234567890","name":"John Doe","admin":true}', false)$$,
    'verify() should return return data marked invalid'
);


SELECT * from finish();
ROLLBACK;
