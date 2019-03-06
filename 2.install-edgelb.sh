#!/usr/bin/env bash
#Add repos
dcos package repo add --index=0 edgelb https://downloads.mesosphere.com/edgelb/v1.2.3/assets/stub-universe-edgelb.json
dcos package repo add --index=0 edgelb-pool https://downloads.mesosphere.com/edgelb-pool/v1.2.3/assets/stub-universe-edgelb-pool.json 

#Create keypair, service account, & secret
dcos security org service-accounts keypair edge-lb-private-key.pem edge-lb-public-key.pem
dcos security org service-accounts create -p edge-lb-public-key.pem -d "Edge-LB service account" edge-lb-principal || true
dcos security org service-accounts show edge-lb-principal
dcos security secrets create-sa-secret --strict edge-lb-private-key.pem edge-lb-principal dcos-edgelb/edge-lb-secret || true
dcos security secrets list /

## Adminrouter permissions
dcos security org users grant edge-lb-principal dcos:adminrouter:service:marathon full
dcos security org users grant edge-lb-principal dcos:adminrouter:package full
dcos security org users grant edge-lb-principal dcos:adminrouter:service:edgelb full
dcos security org users grant edge-lb-principal dcos:service:marathon:marathon:services:/dcos-edgelb full
### Per pool


## Master permissions for scheduler and mesos listener
dcos security org users grant edge-lb-principal dcos:mesos:master:endpoint:path:/api/v1 full
dcos security org users grant edge-lb-principal dcos:mesos:master:endpoint:path:/api/v1/scheduler full
dcos security org users grant edge-lb-principal dcos:mesos:master:framework:principal:edge-lb-principal full
dcos security org users grant edge-lb-principal dcos:mesos:master:framework:role full
dcos security org users grant edge-lb-principal dcos:mesos:master:reservation:principal:edge-lb-principal full
dcos security org users grant edge-lb-principal dcos:mesos:master:reservation:role full
dcos security org users grant edge-lb-principal dcos:mesos:master:volume:principal:edge-lb-principal full
dcos security org users grant edge-lb-principal dcos:mesos:master:volume:role full
dcos security org users grant edge-lb-principal dcos:mesos:master:task:user:root full
dcos security org users grant edge-lb-principal dcos:mesos:master:task:kubernetes-cluster1 full
tee edgelb-options.json <<EOF
{
    "service": {
        "secretName": "dcos-edgelb/edge-lb-secret",
        "principal": "edge-lb-principal",
        "mesosProtocol": "https"
    }
}
EOF
#Removed:        "apiserverProtocol": "http",
echo "Waiting for deployments to finish"
until ! dcos marathon deployment list > /dev/null 2>&1; do
    sleep 1
done

dcos package install --options=edgelb-options.json edgelb --yes

