#!/bin/sh
kubectl apply -f kuber/kafka-bridge.yaml
kubectl apply -f kuber/kafka-connect.yaml
helm install community-operator mongodb/community-operator
kubectl apply -f kuber/mongodb-replicaset.yaml
kubectl apply -f kuber/mongo-sink-connector.yaml

# commands to upgrade to encrypted version (can't work with Autopilot)
# kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.10.0/cert-manager.crds.yaml
# helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.10.0 --set installCRDs=true
# helm upgrade community-operator mongodb/community-operator --set resource.tls.useCertManager=true --set createResource=true --set resource.tls.enabled=true

# command to access mongo console
# kubectl get secret mongodb-admin-my-user -o json | jq -r '.data | with_entries(.value |= @base64d)'
# kubectl exec -it mongodb-0 -c mongod -- bash
#   mongo "mongodb+srv://my-user:my-user@mongodb-svc.default.svc.cluster.local/admin?replicaSet=mongodb&ssl=false"

