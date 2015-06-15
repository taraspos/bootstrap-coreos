#!/bin/bash
### Script to retrieve CLIENT_ID value from coreos hostname
### only if hostname looks like "cores-$CLIENT_ID"
### that's the way hov it sets in the bootstrap.sh script

CLIENT_ID=$(hostname) | grep -o '[0-9]\+'
URL=http://private-anon-4e56b5b1b-mediafiles.apiary-mock.com

curl -i -H "Accept: application/json" $URL/media/?equals=$CLIENT_ID
