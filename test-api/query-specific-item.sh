#!/bin/bash
DOMAIN_NAME=$1
ITEM_ID=$2
TOKEN=$3

curl -X POST http://$DOMAIN_NAME/query \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"query\":\"query { getItem(id: \\\"$ITEM_ID\\\") { id tenant data } }\"}"