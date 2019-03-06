#!/usr/bin/env bash

kubectl create deployment nginx --image=nginx
sleep 10
kubectl expose deployment nginx --type=NodePort --target-port=80 --port=8080
ENDPOINT_PORT=kubectl get svc nginx | grep nginx | awk '{print $5}' | cut -f2 -d: | cut -f1 -d/
echo ${EDGELB_PORT} 

tee nginx.json <<EOF
{
    "apiVersion": "V2",
    "name": "nginx",
    "count": 1,
    "autoCertificate": true,
    "haproxy": {
        "frontends": [{
                "bindPort": 8080,
                "protocol": "TCP",
                "linkBackend": {
                    "defaultBackend": "kubernetes-cluster1"
                }
            }
        ],
        "backends": [{
                "name": "kubernetes-cluster1",
                "protocol": "TCP",
                "services": [{
                    "mesos": {
                        "frameworkName": "kubernetes-cluster1",
                        "taskNamePattern": "kube-node-.*"
                    },
                    "endpoint": {
                        "port": ${ENDPOINT_PORT},
			"type": "AUTO_IP"
                    }
                }]
            }
        ],
        "stats": {
            "bindPort": 6091
        }
    }
}
EOF
