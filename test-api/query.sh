#!/bin/bash
DOMAIN_NAME=$1
TOKEN=$2

curl -X POST http://$DOMAIN_NAME/query \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"query":"query { getItems { id tenant data } }"}'