helm install strimzi-kafka strimzi/strimzi-kafka-operator

# we're commenting these commands because we have to wait for the first command to complete for the other two to work properly (we could use "kubectl wait ...")
kubectl apply -f kuber/kafka-persistent.yaml
kubectl apply -f kuber/test-topic.yaml
kubectl apply -f kuber/signals-topic.yaml
# kubectl apply -f kuber/temperature-topic.yaml
# kubectl apply -f kuber/humidity-topic.yaml
# kubectl apply -f kuber/light-topic.yaml

# can bridge be instantiated before the completition of kafka core
# kubectl apply -f kuber/kafka-bridge.yaml

# kubectl apply -f kuber/user-tls-auth.yaml # not needed anymore if we're using istio authentication
# kubectl apply -f kuber/kafka-connect.yaml # doesn't work properly because it's instanciated before Kafka