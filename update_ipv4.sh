#!/bin/bash
# !!! Warning !!! Work only if hostname have only one AAAA record set 
# Update an existiung ipv6 record with ipv6 seen by ifconfig.io
OVH_CONSUMER_KEY=XXXXXX
OVH_APP_KEY=XXXXXXX
OVH_APP_SECRET=XXXXX
DOMAIN_NAME="domaine-name.mydomain"
HTTP_METHOD="GET"
txt_type="A"
txt_field="hostname"
txt_value="$(curl -s4 ifconfig.io)"

# get record id
HTTP_QUERY="https://eu.api.ovh.com/1.0/domain/zone/${DOMAIN_NAME}/record?fieldType=${txt_type}&subDomain=${txt_field}"
HTTP_BODY=""
TIME=$(curl -s https://api.ovh.com/1.0/auth/time)
CLEAR_SIGN=$OVH_APP_SECRET"+"$OVH_CONSUMER_KEY"+"$HTTP_METHOD"+"$HTTP_QUERY"+"$HTTP_BODY"+"$TIME
SIG='$1$'$(echo -n $CLEAR_SIGN | openssl dgst -sha1 -hex | cut -f 2 -d ' ' )
record_id=$(curl -s -o /dev/null -X $HTTP_METHOD \
$HTTP_QUERY \
-H "Content-Type: application/json" \
-H "X-Ovh-Application: ${OVH_APP_KEY}" \
-H "X-Ovh-Timestamp: ${TIME}" \
-H "X-Ovh-Signature: ${SIG}" \
-H "X-Ovh-Consumer: ${OVH_CONSUMER_KEY}" \
--data "${HTTP_BODY}")
record_id=${record_id:1:-1}

# update record using record id
HTTP_METHOD="PUT"
HTTP_QUERY="https://eu.api.ovh.com/1.0/domain/zone/${DOMAIN_NAME}/record/${record_id}"
HTTP_BODY={"\"subDomain\"":"\"$txt_field\"","\"target\"":"\"$txt_value\""};
TIME=$(curl -s https://api.ovh.com/1.0/auth/time)
CLEAR_SIGN=$OVH_APP_SECRET"+"$OVH_CONSUMER_KEY"+"$HTTP_METHOD"+"$HTTP_QUERY"+"$HTTP_BODY"+"$TIME
SIG='$1$'$(echo -n $CLEAR_SIGN | openssl dgst -sha1 -hex | cut -f 2 -d ' ' )

curl -s -o /dev/null -X $HTTP_METHOD \
$HTTP_QUERY \
-H "Content-Type: application/json" \
-H "X-Ovh-Application: ${OVH_APP_KEY}" \
-H "X-Ovh-Timestamp: ${TIME}" \
-H "X-Ovh-Signature: ${SIG}" \
-H "X-Ovh-Consumer: ${OVH_CONSUMER_KEY}" \
--data "${HTTP_BODY}"
