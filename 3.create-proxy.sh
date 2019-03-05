#!/usr/bin/env bash
dcos security org users grant edge-lb-principal dcos:adminrouter:service:dcos-edgelb/pools/edgelb-kubernetes-cluster-proxy-basic full
tee edgelb-kubernetes-cluster-proxy-basic.json <<EOF
{
    "apiVersion": "V2",
    "name": "edgelb-kubernetes-cluster-proxy-basic",
    "count": 1,
    "autoCertificate": true,
    "haproxy": {
        "frontends": [{
                "bindPort": 6443,
                "protocol": "HTTPS",
                "certificates": [
                    "\$AUTOCERT"
                ],
                "linkBackend": {
                    "defaultBackend": "kubernetes-cluster1"
                }
            }
        ],
        "backends": [{
                "name": "kubernetes-cluster1",
                "protocol": "HTTPS",
                "services": [{
                    "mesos": {
                        "frameworkName": "kubernetes-cluster1",
                        "taskNamePattern": "kube-control-plane"
                    },
                    "endpoint": {
                        "portName": "apiserver"
                    }
                }]
            }
        ],
        "stats": {
            "bindPort": 6090
        }
    }
}
EOF
dcos edgelb create edgelb-kubernetes-cluster-proxy-basic.json
