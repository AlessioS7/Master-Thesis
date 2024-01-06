#!/bin/sh
# we're commenting these commands because we have to wait for the first command to complete for the other two to work properly (we could use "kubectl wait ...")
# kubectl apply -f kuber/kafka-persistent.yaml
# kubectl apply -f kuber/my-topic.yaml
# kubectl apply -f kuber/user-tls-auth.yaml
KAFKA_CLUSTER_NAME="my-kafka"
KAFKA_USER_1="kafka-tls-client-credentials"

rm KafkaClients/src/main/resources/myTrustStore
rm KafkaClients/src/main/resources/kafka-auth-keystore.jks

kubectl get secret ${KAFKA_CLUSTER_NAME}-cluster-ca-cert -o jsonpath='{.data.ca\.crt}' | base64 --decode > KafkaClients/src/main/resources/ca.crt
kubectl get secret ${KAFKA_CLUSTER_NAME}-cluster-ca-cert -o jsonpath='{.data.ca\.password}' | base64 --decode > KafkaClients/src/main/resources/ca.password
keytool -import -file KafkaClients/src/main/resources/ca.crt -alias KafkaCA -keystore KafkaClients/src/main/resources/myTrustStore -keypass changeit

kubectl get secret $KAFKA_USER_1 -o jsonpath='{.data.user\.crt}' | base64 --decode > KafkaClients/src/main/resources/user.crt
kubectl get secret $KAFKA_USER_1 -o jsonpath='{.data.user\.key}' | base64 --decode > KafkaClients/src/main/resources/user.key
kubectl get secret $KAFKA_USER_1 -o jsonpath='{.data.user\.p12}' | base64 --decode > KafkaClients/src/main/resources/user.p12
kubectl get secret $KAFKA_USER_1 -o jsonpath='{.data.user\.password}' | base64 --decode > KafkaClients/src/main/resources/user.password
USER_PASSWORD=$(cat KafkaClients/src/main/resources/user.password)
keytool -importkeystore -deststorepass changeit2 -destkeystore KafkaClients/src/main/resources/kafka-auth-keystore.jks -srckeystore KafkaClients/src/main/resources/user.p12 -srcstoretype PKCS12 -srcstorepass $USER_PASSWORD
