#!/bin/sh

add_user() {
    echo "\nAdding User $1$3----------------------------------------------"

    # Update role details in role request
    update_add_user_request $1 $2
    curl -v -k -H "Content-Type: text/xml;charset=UTF-8"  -H "SOAPAction:urn:addUser" --basic -u "admin$3:admin" --data @./resources/user.xml https://sachinid.local:9443/services/UserAdmin.UserAdminHttpsSoap11Endpoint
}

add_role() {
    echo "\nAdding Role $1 of $3----------------------------------------------"

    # Update role details in role request
    update_role_request $1 $2
    curl -v -k -H "Content-Type: text/xml;charset=UTF-8"  -H "SOAPAction:urn:addRole" --basic -u "admin$3:admin" --data @./resources/role.xml https://sachinid.local:9443/services/UserAdmin.UserAdminHttpsSoap11Endpoint
}

update_role_alias() {
    curl -v -k -X PUT -H "Authorization: Bearer $1" -H "Content-Type: application/json" -d @./resources/role-aliases.json "https://127.0.0.1:9443/api/am/admin/v2/system-scopes/role-aliases"

}

update_role_request() {
  role_name=$1
  role_permission=$2
  eval "cat >./resources/role.xml <<EOF
  <soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsd=\"http://org.apache.axis2/xsd\">
     <soapenv:Header/>
     <soapenv:Body>
        <xsd:addRole>
           <xsd:roleName>${role_name}</xsd:roleName>
           <xsd:permissions>/permission/admin/login</xsd:permissions>
           <xsd:permissions>${role_permission}</xsd:permissions>
           <xsd:isSharedRole>false</xsd:isSharedRole>
        </xsd:addRole>
     </soapenv:Body>
  </soapenv:Envelope>"
}

update_add_user_request(){
  user_name=$1
  role_name=$2
  eval "cat >./resources/user.xml <<EOF
  <soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsd=\"http://org.apache.axis2/xsd\" xmlns:xsd1=\"http://common.mgt.user.carbon.wso2.org/xsd\">
   <soapenv:Header/>
   <soapenv:Body>
      <xsd:addUser>
         <xsd:userName>${user_name}</xsd:userName>
         <xsd:password>pass123</xsd:password>
         <xsd:roles>${role_name}</xsd:roles>
      </xsd:addUser>
   </soapenv:Body>
  </soapenv:Envelope>"
}
