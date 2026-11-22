#!/bin/bash
# crypto_demo.sh: hashing and symmetric encryption with OpenSSL
echo "Final marks: Ali 78, Sara 85" > marks.txt
# fingerprint of the file
sha256sum marks.txt
# encrypt
openssl enc -aes-256-cbc -pbkdf2 -salt -in marks.txt -out marks.enc
# decrypt
openssl enc -d -aes-256-cbc -pbkdf2 -in marks.enc -out marks_dec.txt
# same fingerprint as before
sha256sum marks_dec.txt
