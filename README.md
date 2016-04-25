# pgjwt
PostgreSQL implementation of [JSON Web Tokens](https://jwt.io/)

Install
-------

    'psql -f jwt.sql'

Note that this file will DROP and CREATE a new schema called 'jwt'.


Usage
-----

To create a token, call jwt.encode('{...json...}', '<secret key>'):

    => select jwt.encode('{"sub":"1234567890","name":"John Doe","admin":true}', 'secret');
                                                                            encode
    -------------------------------------------------------------------------------------------------------------------------------------------------------
     eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ

Decoding a token will return its, header, payload, and a boolean
indicating that the signature is valid:

    => select * from jwt.decode('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ', 'secret');
               header            |                       payload                       | valid
    -----------------------------+-----------------------------------------------------+-------
     {"alg":"HS256","typ":"JWT"} | {"sub":"1234567890","name":"John Doe","admin":true} | t
