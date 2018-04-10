#!/bin/bash


CREDFILE=~/credentials/haskellblog.json

export CLIENT_ID=$(cat $CREDFILE | jq -r '.web.client_id')
export CLIENT_SECRET=$(cat $CREDFILE | jq -r '.web.client_secret')

echo $CLIENT_ID
echo $CLIENT_SECRET

stack runhaskell app/main.hs
