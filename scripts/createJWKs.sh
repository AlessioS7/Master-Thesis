#!/bin/sh
# 'openssl' works only using the git bash

# mkdird security/jwks
cd security/jwks

# generate private key
openssl genrsa -out privatekey.pem 2048

# extract public key from private key
openssl rsa -in privatekey.pem -pubout -out publickey.pem

# generate jwk from public key (we need to add manually '"kid":"myKeyId"')
pem-jwk publickey.pem

# convert private key to pkcs8 format in order to import it from Java
openssl pkcs8 -topk8 -in privatekey.pem -inform pem -out privatekeypkcs8.pem -outform pem -nocrypt