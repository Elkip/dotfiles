#! /bin/bash

#######################################################################
## Script name: java_cert_renewal.sh
## Purpose: Certificate Auto-Renewal specifically configured for 
## when a website has 2 SSL certificates. Example used is epf.usps.gov
##
## Parameters:
## In (Optional): None
## Out: 0 (SUCCESS)            1 (FAIL)      
##
## Initial Creation: Mitchell Henschel 04/20/2022
##
#######################################################################

echo 'Start java_cert_renewal'
# If any command fails exit the script
set -e

KEYSTORE=/config/keystore.PKCS12

echo 'Searching for old crt files to remove...'
CERT_PTH=/vitria/build/kit/config
CERT1="cert1.crt"
CERT2="cert2.crt"

if [ -f "$CERT_PTH/$CERT1" ] ; then
    rm "$CERT_PTH/$CERT1"
fi
if [ -f "$CERT_PTH/$CERT2" ] ; then
    rm "$CERT_PTH/$CERT2"
fi

OLD_SHA256_1=`openssl x509 -fingerprint -noout -sha256 -in <(openssl s_client -connect epf.usps.gov:443 < /dev/null 2>/dev/null) | cut -d "=" -f2  | sha256sum`
OLD_SHA256_2=`openssl x509 -fingerprint -noout -sha256 -in <(openssl s_client -showcerts -connect epf.usps.gov:443 < /dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' | awk '/^-----BEGIN CERTIFICATE-----$/ {
     file = "usps_cert" ++count[$1] ".crt";
 } 
 {
    if (file == "usps_cert2.crt") {
        print ;
    }
 }') | cut -d "=" -f2 | sha256sum`

echo 'Downloading certificates...'
cd $CERT_PTH
openssl s_client -showcerts -connect epf.usps.gov:443</dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' | awk '/^-----BEGIN CERTIFICATE-----$/ {
     file = "usps_cert" ++count[$1] ".crt";
 } 
 {
    if (file == "") {
        file = "junk.txt";
    }
    print > file
 }'

echo 'Verifying SHA256 checksum with current certificate signature...'
NEW_SHA256_1=`openssl x509 -noout -fingerprint -sha256 -in $CERT_PTH/$CERT1 | cut -d "=" -f2 | sha256sum`
NEW_SHA256_2=`openssl x509 -noout -fingerprint -sha256 -in $CERT_PTH/$CERT2 | cut -d "=" -f2 | sha256sum`

if [ "$OLD_SHA256_1" == "$NEW_SHA256_1" ] && [ "$OLD_SHA256_2" == "$NEW_SHA256_2" ]; then
    echo 'Success'
else
    echo 'CERT1 - OLD: ' $OLD_SHA256_1 ' NEW: ' $NEW_SHA256_1
    echo 'CERT2 - OLD: ' $OLD_SHA256_2 ' NEW: ' $NEW_SHA256_2
    echo 'SHA256 checksums do not match. Exiting...'
    exit 1
fi

echo 'Removing old certificates...'
keytool -delete -alias epfuspsgov1 -keystore $KEYSTORE -storepass $KEYPASS 2>&1
keytool -delete -alias epfuspsgov2 -keystore $KEYSTORE -storepass $KEYPASS 2>&1
echo 'Importing new certificates...'
keytool -import -trustcacerts -keystore $KEYSTORE -storepass $KEYPASS -noprompt -alias epfuspsgov1 -file $CERT_PTH/$CERT1 2>&1
keytool -import -trustcacerts -keystore $KEYSTORE -storepass $KEYPASS -noprompt -alias epfuspsgov2 -file $CERT_PTH/$CERT2 2>&1
echo 'Cleaning up...'
rm "$CERT_PTH/$CERT1"
rm "$CERT_PTH/$CERT2"
echo 'Done!'
exit 0
