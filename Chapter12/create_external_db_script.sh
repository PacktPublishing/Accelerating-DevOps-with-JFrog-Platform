#!/bin/bash

ARTIFACTORY_PASSWORD="NlTJ9y1RfDMuJZo"
XRAY_PASSWORD="Ejn8PynIlu906XE"
DISTRIBUTION_PASSWORD="wYH5Qi8DfACSvwf"
INSIGHT_PASSWORD="F7FFlKyFDLvMIfU"
PIPELINES_PASSWORD="nFbVdOlDJZI74V6"
NAMESPACE="jfrog-platform-example"

# Create secret for external database
cat > JFrogPlatform_k8s_db_secret.yaml <<EOF
---
apiVersion: v1
kind: Secret
metadata:
  name: postgres-init-scripts
  namespace: $NAMESPACE
type: Opaque
stringData:
  database.sql: |
    CREATE USER "artifactory" WITH PASSWORD '$ARTIFACTORY_PASSWORD'; 
    CREATE USER "xray" WITH PASSWORD '$XRAY_PASSWORD'; 
    CREATE USER "distribution" WITH PASSWORD '$DISTRIBUTION_PASSWORD'; 
    CREATE USER "insight" WITH PASSWORD '$INSIGHT_PASSWORD'; 
    CREATE USER "apiuser" WITH PASSWORD '$PIPELINES_PASSWORD'; 
    CREATE DATABASE artifactory ENCODING='UTF8'; 
    CREATE DATABASE xray ENCODING='UTF8'; 
    CREATE DATABASE distribution ENCODING='UTF8'; 
    CREATE DATABASE insight ENCODING='UTF8'; 
    CREATE DATABASE pipelinesdb ENCODING='UTF8'; 
    GRANT ALL PRIVILEGES ON DATABASE artifactory TO artifactory; 
    GRANT ALL PRIVILEGES ON DATABASE xray TO xray; 
    GRANT ALL PRIVILEGES ON DATABASE distribution TO distribution; 
    GRANT ALL PRIVILEGES ON DATABASE insight TO insight; 
    GRANT ALL PRIVILEGES ON DATABASE pipelinesdb TO apiuser;
EOF
# Deploy
kubectl create -f JFrogPlatform_k8s_db_secret.yaml