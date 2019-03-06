#!/usr/bin/env bash
#Retrieve Public IP
export EDGELB_PUBLIC_AGENT_IP=$(dcos task exec -it edgelb-pool-0-server curl ifconfig.co | awk -v RS='\r' '{print $0}')

#remove existing kube configs
sudo rm -rf ~/.kube

#configure
dcos kubernetes cluster kubeconfig --insecure-skip-tls-verify --context-name=kubernetes-cluster1 --cluster-name=kubernetes-cluster1 --apiserver-url=https://${EDGELB_PUBLIC_AGENT_IP}:6443
