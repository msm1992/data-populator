#!/bin/sh
source ./util/add-tenant.sh
source ./util/user-mgt.sh
source ./util/access-token.sh
source ./util/api-mgt.sh

tenants=("abc1.com" "efg1.com")
roles_permissions=("custom_publisher:/permission/admin/manage/api/publish"
                   "custom_creator:/permission/admin/manage/api/create"
                   "custom_subscriber:/permission/admin/manage/api/subscribe"
                  )
user_roles=("publisher_user:custom_publisher" "creator_user:custom_creator" "subscriber_user:custom_subscriber")

publisher_rest_api="https://localhost:9443/api/am/publisher/v1"
store_rest_api="https://localhost:9443/api/am/store/v1"
admin_rest_api="https://localhost:9443/api/am/admin/v1"

###############################################################FUNCTIONS###########################################################

add_documents_to_api() {
  local inline_doc_id=$(add_document $1 $2 "Inline-Doc" "inline" "INLINE" $3)
  curl -k -H "Authorization: Bearer $1" -F "inlineContent=This is an inline document" "$publisher_rest_api/apis/$2/documents/$inline_doc_id/content"

  local markdown_doc_id=$(add_document $1 $2 "Markdown-Doc" "Markdown" "MARKDOWN" $3)
  curl -k -H "Authorization: Bearer $1" -F "inlineContent=# This is a markdown document" "$publisher_rest_api/apis/$2/documents/$markdown_doc_id/content"

  add_document $1 $2 "URL-Doc" "url" "URL" $3 "https://en.wikipedia.org/wiki/API"

  local file_doc_id=$(add_document $1 $2 "File-Doc" "file" "FILE" $3)
  curl -k -H "Authorization: Bearer $1" -F file=@./resources/file.pdf "$publisher_rest_api/apis/$2/documents/$file_doc_id/content"
}

###################################################################################################################################
bold=$("----------------Data Population for APIM 4.0.0------------------------------------------------------------------------------" bold)

echo $bold
echo "----------------------------------------------------------------------------------------------------------------------------"

echo "\n\nRunning data populate client for APIM 4.0.0"

echo "\n\nAdding tenants--------------------------------------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------------------------------------------------"
for tenant in ${tenants[@]}; do
  echo "\ntenantDomain - $tenant"
  add_tenant "$tenant"
done

echo "\n\n\nAdding Roles---------------------------------------------------------------------------------------------------------------"
echo "-----------------------------------------------------------------------------------------------------------------------------"

#Adding "carbon.super" to represent super tenant
tenants=("carbon.super" "abc1.com" "efg1.com")
for tenant in ${tenants[@]}; do
  for role_permission_string in "${roles_permissions[@]}" ; do
      role=${role_permission_string%%:*}
      permission=${role_permission_string#*:}

      add_role $role $permission "@$tenant"
  done
done

echo "\n\n\nAdding Users---------------------------------------------------------------------------------------------------------------"
echo "-----------------------------------------------------------------------------------------------------------------------------"
#Adding users under super tenant
for tenant in ${tenants[@]}; do
  for user_roles_string in "${user_roles[@]}" ; do
      user=${user_roles_string%%:*}
      role=${user_roles_string#*:}

      add_user $user $role "@$tenant"
  done
done

echo "\n\n\nUpdate Role Aliases---------------------------------------------------------------------------------------------------------"
echo "-----------------------------------------------------------------------------------------------------------------------------"
for tenant in ${tenants[@]}; do
  #get dcr token for tenant admin
  access_token=$(get_access_token "admin@$tenant" "$tenant-admin" "admin" "apim:admin")

  #update role aliases
  update_role_alias $access_token
done

echo "\n\n\nCreate APIs------------------------------------------------------------------------------------------------------------"
echo "-----------------------------------------------------------------------------------------------------------------------------"
for tenant in ${tenants[@]}; do
   publisher_user="publisher_user@$tenant"
   creator_user="creator_user@$tenant"

   create_access_token=$(get_access_token $creator_user "$tenant-create" "pass123" "apim:api_view apim:api_create")
   publish_access_token=$(get_access_token $publisher_user "$tenant-publish" "pass123" "apim:api_publish apim:document_create")

   #create and publish ghibli api
   echo "\n\nCreating Rest API with ./resources/ghibli-data.json"
   api_id=$(import_openapi $create_access_token "./resources/swagger.yaml" "./resources/ghibli-data.json")
   publish_api $api_id $publish_access_token
   #attach documents
   add_documents_to_api $publish_access_token $api_id $creator_user

   #create and publish hello api
   echo "\n\nCreating Rest API with ./resources/hello-api.json"
   api_id=$(create_api $create_access_token "./resources/hello-api.json")
   publish_api $api_id $publish_access_token
   #attach documents
   add_documents_to_api $publish_access_token $api_id $creator_user

   #create WSDL apis
   echo "\n\nCreating SOAP API"
   api_id=$(import_wsdl $create_access_token "https://ws.cdyne.com/phoneverify/phoneverify.asmx?wsdl" "./resources/soap-data.json")
   publish_api $api_id $publish_access_token
   #attach documents
   add_documents_to_api $publish_access_token $api_id $creator_user

   #create GRAPHQL apis
   echo "\n\nCreating GraphQL API - StarWars"
   api_id=$(import_graphql_schema $create_access_token "./resources/schema_graphql.graphql" "./resources/starwars-data.json")
   publish_api $api_id $publish_access_token
   #attach documents
   #add_documents_to_api $publish_access_token $api_id $creator_user

done
