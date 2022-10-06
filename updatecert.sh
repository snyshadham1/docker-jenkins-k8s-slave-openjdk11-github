#!/bin/bash

$JAVA_HOME/bin/keytool -import -keystore $JAVA_HOME/lib/security/cacerts -file /etc/pki/ca-trust/source/anchors/Salesforce_Internal_Root_CA_1.pem -alias salesforce_int_root -storepass changeit -noprompt
$JAVA_HOME/bin/keytool -import -keystore $JAVA_HOME/lib/security/cacerts -file /etc/pki/ca-trust/source/anchors/Salesforce_Internal_Root_CA_2_Infra.pem -alias salesforce_infra -storepass changeit -noprompt
$JAVA_HOME/bin/keytool -import -keystore $JAVA_HOME/lib/security/cacerts -file /etc/pki/ca-trust/source/anchors/Salesforce_Internal_Root_CA_2_Security.pem -alias salesforce_security -storepass changeit -noprompt
$JAVA_HOME/bin/keytool -import -keystore $JAVA_HOME/lib/security/cacerts -file /etc/pki/ca-trust/source/anchors/Salesforce_Legacy_CASFM-00.pem -alias salesforce_legacy -storepass changeit -noprompt
$JAVA_HOME/bin/keytool -import -keystore $JAVA_HOME/lib/security/cacerts -file /etc/pki/ca-trust/source/anchors/Salesforce_Internal_Root_CA_3.pem -alias salesforce_magister -storepass changeit -noprompt

/bin/update-ca-trust
