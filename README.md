# Intro
This is an NGINX module to check for a valid JWT and proxy to an upstream server or redirect to a login page.

## Building
To build the Docker image
```bash
docker build . -t nginx-jwt
```
This process will compile the module from sources locate on ```lib``` folder. It will generate a share object call ngx_http_auth_jwt_module.so. This object will be copied to an nginx image.

## Starting
```bash
docker run -p 8000:8000 nginx-jwt
```

## Dependencies
This module depends on the [JWT C Library](https://github.com/benmcollins/libjwt)

Transitively, that library depends on a JSON Parser called
[Jansson](https://github.com/akheron/jansson) as well as the OpenSSL library.

## NGINX Directives
This module requires several new `nginx.conf` directives,
which can be specified in on the `main` `server` or `location` level.

```
auth_jwt_key "00112233445566778899AABBCCDDEEFF00112233445566778899AABBCCDDEEFF"; # see docs for format based on algorithm
auth_jwt_loginurl "https://yourdomain.com/loginpage";
auth_jwt_enabled on;
auth_jwt_algorithm HS256; # or RS256
auth_jwt_scope my_scope;  
auth_jwt_validate_email on;  # or off
```

The default algorithm is 'HS256', for symmetric key validation.  When using HS256, the value for `auth_jwt_key` should be specified in binhex format.  It is recommended to use at least 256 bits of data (32 pairs of hex characters or 64 characters in total) as in the example above.  Note that using more than 512 bits will not increase the security.  For key guidelines please see NIST Special Publication 800-107 Recommendation for Applications Using Approved Hash Algorithms, Section 5.3.2 The HMAC Key.

The configuration also supports the `auth_jwt_algorithm` 'RS256', for RSA 256-bit public key validation. If using "auth_jwt_algorithm RS256;", then the `auth_jwt_key` field must be set to your public key.
That is the public key, rather than a PEM certificate.  I.e.:

```
auth_jwt_key "-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0aPPpS7ufs0bGbW9+OFQ
RvJwb58fhi2BuHMd7Ys6m8D1jHW/AhDYrYVZtUnA60lxwSJ/ZKreYOQMlNyZfdqA
rhYyyUkedDn8e0WsDvH+ocY0cMcxCCN5jItCwhIbIkTO6WEGrDgWTY57UfWDqbMZ
4lMn42f77OKFoxsOA6CVvpsvrprBPIRPa25H2bJHODHEtDr/H519Y681/eCyeQE/
1ibKL2cMN49O7nRAAaUNoFcO89Uc+GKofcad1TTwtTIwmSMbCLVkzGeExBCrBTQo
wO6AxLijfWV/JnVxNMUiobiKGc/PP6T5PI70Uv67Y4FzzWTuhqmREb3/BlcbPwtM
oQIDAQAB
-----END PUBLIC KEY-----";
```

A typical use would be to specify the key and loginurl on the main level
and then only turn on the locations that you want to secure (not the login page).
Unauthorized requests are given 302 "Moved Temporarily" responses with a location of the specified loginurl.

```
auth_jwt_redirect            off;
```
If you prefer to return 401 Unauthorized, you may turn `auth_jwt_redirect` off.

```
auth_jwt_validation_type AUTHORIZATION;
auth_jwt_validation_type COOKIE=rampartjwt;
```
By default the authorization header is used to provide a JWT for validation.
However, you may use the `auth_jwt_validation_type` configuration to specify the name of a cookie that provides the JWT.

```
auth_jwt_validate_email off;
```
By default, the module will attempt to validate the email address field of the JWT, then set the x-email header of the
session, and will log an error if it isn't found.  To disable this behavior, for instance if you are using a different
user identifier property such as 'sub', set `auth_jwt_validate_email` to the value `off`.

By default the auth_jwt_scope directive will be empty, in case it will be set then its value will be compare with the scopes 
present on token if some of them match with the value the request will be authorized, otherwise the request 
will be rejected.
