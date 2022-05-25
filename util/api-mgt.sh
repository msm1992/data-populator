#!/bin/sh

#$1 - create access_token
#$2 - swagger payload (ex: swagger.yaml)
#$3 - additional api properties
#$4 - publish access token
create_and_publish_api() {
    echo "Creating Rest API with $2"
    echo "access-token:$1"
    local api_id=$(curl -k -H "Authorization: Bearer $1" -F file=@$2 -F additionalProperties=@$3 "https://127.0.0.1:9443/api/am/publisher/v2/apis/import-openapi" | jq -r '.id')
    echo "Publishing API $api_id"
    curl -v -k -H "Authorization: Bearer $4" -X POST "https://localhost:9443/api/am/publisher/v2/apis/change-lifecycle?apiId=${api_id}&action=Publish"
    sleep 5
}
