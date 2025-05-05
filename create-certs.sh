mkdir -p nginx/certs
# openssl req -x509 -nodes -days 365 \
#     -newkey rsa:2048 \
#     -keyout nginx/certs/privkey.pem \
#     -out nginx/certs/fullchain.pem \
#     -subj "/C=JP/ST=Tokyo/L=Chiyoda-ku/O=Example/OU=IT Department/CN=example.com"

openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout nginx/certs/privkey.pem \
    -out nginx/certs/fullchain.pem \
    -subj "/C=JP/ST=Tokyo/L=Chiyoda-ku/O=Example/OU=IT" \
    -addext "subjectAltName=DNS:localhost,DNS:example.com,DNS:*.example.com"
