#!/bin/sh

add_tenant() {
    echo "Adding Tenant $1----------------------------------------------"

    # Update tenant domain in tenant request
    update_tenant_request $1
    curl -v -k -H "Content-Type: text/xml;charset=UTF-8;"  -H "SOAPAction:urn:addTenant" --basic -u "admin:admin" --data @./resources/tenant.xml https://localhost:9443/services/TenantMgtAdminService.TenantMgtAdminServiceHttpsSoap11Endpoint
}

update_tenant_request() {
  tenant_domain=$1
  eval "cat >./resources/tenant.xml <<EOF
  <soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ser=\"http://services.mgt.tenant.carbon.wso2.org\" xmlns:xsd=\"http://beans.common.stratos.carbon.wso2.org/xsd\">
     <soapenv:Header/>
     <soapenv:Body>
        <ser:addTenant>
           <ser:tenantInfoBean>
              <xsd:admin>admin</xsd:admin>
              <xsd:adminPassword>admin</xsd:adminPassword>
              <xsd:firstname>admin</xsd:firstname>
              <xsd:lastname>admin</xsd:lastname>
              <xsd:email>admin@gmail.com</xsd:email>
              <xsd:tenantDomain>${tenant_domain}</xsd:tenantDomain>
           </ser:tenantInfoBean>
        </ser:addTenant>
     </soapenv:Body>
  </soapenv:Envelope>"
}
