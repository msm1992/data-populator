#!/bin/sh
source ./util/add-tenant.sh
source ./util/user-mgt.sh
source ./util/access-token.sh
source ./util/api-mgt.sh

tenants=("abcd.com" "efgh.com")
roles_permissions=("custom_publisher:/permission/admin/manage/api/publish"
                   "custom_creator:/permission/admin/manage/api/create"
                   "custom_subscriber:/permission/admin/manage/api/subscribe"
                  )
user_roles=("publisher_user:custom_publisher" "creator_user:custom_creator" "subscriber_user:custom_subscriber")

echo "----------------Data Population for APIM 4.0.0------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------------------------------------------------"

echo "Running data populate client for APIM 4.0.0"

echo "Adding tenants--------------------------------------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------------------------------------------------"
for tenant in ${tenants[@]}; do
  echo "\ntenantDomain - $tenant"
  add_tenant "$tenant"
done

echo "\nAdding Roles----------------------------------------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------------------------------------------------"

#Adding "carbon.super" to represent super tenant
tenants=("carbon.super" "abcd.com" "efgh.com")
for tenant in ${tenants[@]}; do
  for role_permission_string in "${roles_permissions[@]}" ; do
      role=${role_permission_string%%:*}
      permission=${role_permission_string#*:}

      add_role $role $permission "@$tenant"
  done
done

echo "\nAdding Users----------------------------------------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------------------------------------------------"
#Adding users under super tenant
for tenant in ${tenants[@]}; do
  for user_roles_string in "${user_roles[@]}" ; do
      user=${user_roles_string%%:*}
      role=${user_roles_string#*:}

      add_user $user $role "@$tenant"
  done
done

echo "\Update Role Aliases----------------------------------------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------------------------------------------------"
for tenant in ${tenants[@]}; do
  #get dcr token for tenant admin
  access_token=$(get_access_token "admin@$tenant" "$tenant-admin" "admin" "apim:admin")

  #update role aliases
  update_role_alias $access_token
done

echo "\Create REST APIs----------------------------------------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------------------------------------------------"
for tenant in ${tenants[@]}; do
   publisher_user="publisher_user@$tenant"
   creator_user="creator_user@$tenant"

   create_access_token=$(get_access_token $creator_user "$tenant-create" "pass123" "apim:api_view apim:api_create")
   echo "TOKEN - $create_access_token"
   publish_access_token=$(get_access_token $publisher_user "$tenant-publish" "pass123" "apim:api_publish")

   #create ghibli api
   create_and_publish_api $create_access_token "./resources/swagger.yaml" "./resources/ghibli-data.json" $publish_access_token
done
