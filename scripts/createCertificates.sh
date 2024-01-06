cd security
mkdir tlsCertificates

# generate self-signed certificate and associated private key with Organization 'example Inc' and Common Name 'example.com'
# this is the certificate authority which signs the gateway certificate
openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -subj '/O=example Inc./CN=example.com' -keyout tlsCertificates/example.com.key -out tlsCertificates/example.com.crt

# generate the not signed certificate and associated private key for our TLS gateway 
# (CommonName=httpbin.example.com/Organization=httpbin organization)
openssl req -out tlsCertificates/httpbin.example.com.csr -newkey rsa:2048 -nodes -keyout tlsCertificates/httpbin.example.com.key -subj "/CN=httpbin.example.com/O=httpbin organization"

# sign the gateway certificate with the certificate authority private key
openssl x509 -req -sha256 -days 365 -CA tlsCertificates/example.com.crt -CAkey tlsCertificates/example.com.key -set_serial 0 -in tlsCertificates/httpbin.example.com.csr -out tlsCertificates/httpbin.example.com.crt
