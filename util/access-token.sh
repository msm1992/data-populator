#!/bin/bash

update_client_request() {
  eval "cat >./resources/payload.json <<EOF
  {
      \"callbackUrl\": \"wso2.org\",
      \"clientName\": \"$2\",
      \"tokenScope\": \"Production\",
      \"owner\": \"$1\",
      \"grantType\": \"password refresh_token\",
      \"saasApp\": true
  }"
}

#echo $client_credentials
#$1 - username
#$2 - app name
#$3 - pw
#4 - scope list (apim:api_view apim:api_publish apim:api_create apim:subscribe)
get_access_token() {
    update_client_request $1 $2
    client_credentials=$(curl -k -u $1:$3 -H "Content-Type: application/json" -d @./resources/payload.json "https://localhost:9443/client-registration/v0.17/register"| jq -r '.clientId + ":" + .clientSecret')
    access_token=$(curl -k -d "grant_type=password&username=$1&password=$3&scope=$4" -u $client_credentials "https://localhost:9443/oauth2/token" | jq -r '.access_token')
    echo $access_token
}

#access_token=$(get_access_token "admin" "Test" "admin" "apim:api_view apim:api_publish apim:api_create apim:subscribe")

curl -k -d "grant_type=password&username=creator_user@carbon.super&password=pass123&scope=apim:api_view apim:api_create" -u GRSNcal5Nv4nEMF7BwPetrIYsC8a:w8fgjaLPhJkH4zws26IyTdFnTV0a "https://localhost:9443/oauth2/token"
