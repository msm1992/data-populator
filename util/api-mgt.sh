#!/bin/sh

#$1 - create access_token
#$2 - api payload
create_api() {
  local api_id=$(curl -k -X POST -H "Authorization: Bearer $1" -H "Content-Type: application/json" -d @$2 "https://127.0.0.1:9443/api/am/publisher/v2/apis" | jq -r '.id')
  echo $api_id
}

#$1 - create access_token
#$2 - swagger payload (ex: swagger.yaml)
#$3 - additional api properties
import_openapi() {
    local api_id=$(curl -k -H "Authorization: Bearer $1" -F file=@$2 -F additionalProperties=@$3 "https://127.0.0.1:9443/api/am/publisher/v2/apis/import-openapi" | jq -r '.id')
    echo $api_id
}

#$1 - api-id
#$2 - access-token (with apim:publish scope)
publish_api() {
  echo "Publishing API $1"
  curl -v -k -H "Authorization: Bearer $2" -X POST "https://localhost:9443/api/am/publisher/v2/apis/change-lifecycle?apiId=$1&action=Publish"
  sleep 5
}

import_wsdl() {
  local api_id=$(curl -k -H "Authorization: Bearer $1" -F "url=$2" -F additionalProperties=@$3 "https://127.0.0.1:9443/api/am/publisher/v2/apis/import-wsdl" | jq -r '.id')
  echo $api_id
}

import_graphql_schema() {
    local api_id=$(curl -k -H "Authorization: Bearer $1" -F file=@$2 -F additionalProperties=@$3 "https://127.0.0.1:9443/api/am/publisher/v2/apis/import-graphql-schema" | jq -r '.id')
    echo $api_id
}


add_document() {
    update_document_payload $3 $4 $5 $6 $7
    local doc_id=$(curl -k -X POST -H "Authorization: Bearer $1" -H "Content-Type: application/json" -d @./resources/doc-data.json "https://127.0.0.1:9443/api/am/publisher/v2/apis/$2/documents" | jq -r '.documentId')
    echo $doc_id
}

create_revision() {
    local revision_id=$(curl -k -X POST -H "Authorization: Bearer $1" -H "Content-Type: application/json" -d @$2 "https://127.0.0.1:9443/api/am/publisher/v2/apis/$3/revisions" | jq -r '.id')
    echo $revision_id
}

deploy_revision() {
  curl -v -k -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $1" -d @$4 "https://127.0.0.1:9443/api/am/publisher/v2/apis/$2/deploy-revision?revisionId=$3"
}

update_document_payload() {
  eval "cat >./resources/doc-data.json <<EOF
  {
  \"name\": \"$1\",
  \"type\": \"HOWTO\",
  \"summary\": \"$2\",
  \"sourceType\": \"$3\",
  \"inlineContent\": \"\",
  \"visibility\": \"API_LEVEL\",
  \"sourceUrl\": \"$5\",
  \"createdBy\": \"$4\"
  }"
}


#curl -v -k -X POST -H "Authorization: Bearer e2d4d2aa-42e5-3106-a3de-9a5e75e575be" "https://127.0.0.1:9443/api/am/publisher/v2/apis/77ee3557-1c09-4a99-b360-fe277a48fb48/deploy-revision?revisionId=a55b3f98-7813-4f91-aff9-bf3defc887e8"
#hello - "c0bd7b9f-eb80-4ebb-9fb3-f8071eb2322e"
#deploy_revision "6e023d68-b71d-3fd6-b6f9-c9990679fc53" "c0bd7b9f-eb80-4ebb-9fb3-f8071eb2322e" "5fc67396-d8bd-45bd-ac46-fdab82f80a1b"
#create_revision "6e023d68-b71d-3fd6-b6f9-c9990679fc53" "../resources/revision-data.json" "c0bd7b9f-eb80-4ebb-9fb3-f8071eb2322e"
#curl -k -X POST -H "Authorization: Bearer $1" -H "Content-Type: application/json" -d @$2 "https://127.0.0.1:9443/api/am/publisher/v2/apis/$3/revisions"
#curl -k -X GET -H "Authorization: Bearer 0edf5cc5-d900-340d-aca2-524920254cbf" "https://127.0.0.1:9443/api/am/publisher/v2/apis"
#import_graphql_schema "a83ab738-84ce-33fc-8aab-8522fd196589" "../resources/schema_graphql.graphql" "../resources/starwars-data.json"
#import_wsdl "ffc683c8-fa28-39f3-9d33-13ae5239bbb6" "https://ws.cdyne.com/phoneverify/phoneverify.asmx?wsdl" "../resources/soap-data.json"
#create_api "625258ae-d143-38a0-918f-9fa82f7a9ccd" "../resources/hello-api.json"
