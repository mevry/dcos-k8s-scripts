#!/usr/bin/env bash
dcos package install dcos-enterprise-cli --yes

#Create keypair, service account, & secret
dcos security org service-accounts keypair mke-priv.pem mke-pub.pem
dcos security org service-accounts create -p mke-pub.pem -d 'Kubernetes service account' kubernetes
dcos security secrets create-sa-secret mke-priv.pem kubernetes kubernetes/sa

#Grant permissions
dcos security org users grant kubernetes dcos:mesos:master:reservation:role:kubernetes-role create
dcos security org users grant kubernetes dcos:mesos:master:framework:role:kubernetes-role create
dcos security org users grant kubernetes dcos:mesos:master:task:user:nobody create

tee mke-options.json <<EOF
{
    "service": {
        "service_account": "kubernetes",
        "service_account_secret": "kubernetes/sa"
    }
}
EOF

#Install with mke-options.json
dcos package install --yes kubernetes --options=mke-options.json
