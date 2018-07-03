#!/bin/bash

## example input to check check_ssl_f5.sh
echo 'sys file ssl-cert 2018.crt {
    expiration-string "Oct 13 12:34:11 2018 GMT"
}
sys file ssl-cert GlobalSign_-_Extended_Validation_CA_-_SHA256.crt {
    expiration-string "Sep 21 00:00:00 2026 GMT"
}
sys file ssl-cert GlobalSign_-_Organization_Validation_CA_-_SHA256_-_G2.crt {
    expiration-string "Feb 20 10:00:00 2024 GMT"
}
sys file ssl-cert GlobalSign_-_Root.crt {
    expiration-string "Mar 18 10:00:00 2018 GMT"
}
sys file ssl-cert testsrv.crt {
    expiration-string "Dec 18 14:23:50 2019 GMT"
}

sys file ssl-cert lol.crt {
    expiration-string "Jul 18 13:20:10 2018 GMT"
}

sys file ssl-cert cert.crt {
    expiration-string "Jun 18 12:30:11 2017 GMT"
}

sys file ssl-cert test2.crt {
    expiration-string "Apr 18 11:50:12 2017 GMT"
}

sys file ssl-cert test2.crt {
    expiration-string "May 18 01:55:15 2017 GMT"
}' 
