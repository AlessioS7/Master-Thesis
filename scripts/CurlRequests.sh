export INGRESS_HOST=$(kubectl get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export SECURE_INGRESS_PORT=$(kubectl get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')
export TOKEN=$(curl https://raw.githubusercontent.com/istio/istio/release-1.16/security/tools/jwt/samples/demo.jwt -s)


####### HTTP REQUESTS #######

# # produce three messages to the topic 'my-topic'
# curl -X POST  http://$INGRESS_HOST:$INGRESS_PORT/topics/my-topic -H 'content-type: application/vnd.kafka.json.v2+json' -d '{ "records": [ { "key": "{key1:1}", "value": "{field1:1}" }, { "key": "{key1:12}", "value": "{field1:12}" }, { "key": "{key1:13}", "value": "{field1:13}" } ] }'
# 
# # create a Kafka Bridge consumer in a new consumer group named 'my-topic-consumer-group'
# curl -X POST http://$INGRESS_HOST:$INGRESS_PORT/consumers/my-topic-consumer-group -H 'content-type: application/vnd.kafka.v2+json' -d '{ "name": "my-topic-consumer", "auto.offset.reset": "earliest", "format": "json", "enable.auto.commit": false, "fetch.min.bytes": 512, "consumer.request.timeout.ms": 30000 }'
# 
# # subscribe the consumer to the 'my-topic' topic
# curl -X POST http://$INGRESS_HOST:$INGRESS_PORT/consumers/my-topic-consumer-group/instances/my-topic-consumer/subscription -H 'content-type: application/vnd.kafka.v2+json' -d '{ "topics": [ "my-topic" ] }'
# 
# # retrieving the latest messages from a Kafka Bridge consumer (please note: after creating and subscribing to a Kafka Bridge
# # consumer, a first GET request will return an empty response because the poll operation starts a rebalancing process to assign
# # partitions. For this reason, we need to repeat the request to retrieve messages from the Kafka Bridge consumer)
# curl -X GET http://$INGRESS_HOST:$INGRESS_PORT/consumers/my-topic-consumer-group/instances/my-topic-consumer/records -H 'accept: application/vnd.kafka.json.v2+json'


####### HTTPS REQUESTS #######

 # produce three messages to the topic 'my-topic'
curl -v POST --header "Authorization: Bearer $TOKEN" -HHost:httpbin.example.com --resolve "httpbin.example.com:$SECURE_INGRESS_PORT:$INGRESS_HOST" --cacert security/tlsCertificates/example.com.crt "https://httpbin.example.com:$SECURE_INGRESS_PORT"/topics/my-topic -H 'content-type: application/vnd.kafka.json.v2+json' -d '{ "records": [ { "key": "{key1:71}", "value": "{field1:71}" }, { "key": "{key1:712}", "value": "{field1:712}" }, { "key": "{key1:713}", "value": "{field1:713}" } ] }'

# create a Kafk Bridge consumer in a new consumer group named 'my-topic-consumer-group'
curl -v -X POST --header "Authorization: Bearer $TOKEN" -HHost:httpbin.example.com --resolve "httpbin.example.com:$SECURE_INGRESS_PORT:$INGRESS_HOST" --cacert security/tlsCertificates/example.com.crt "https://httpbin.example.com:$SECURE_INGRESS_PORT"/bridge/consumers/my-topic-consumer-group -H 'content-type: application/vnd.kafka.v2+json' -d '{ "name": "my-topic-consumer", "auto.offset.reset": "earliest", "format": "json", "enable.auto.commit": false, "fetch.min.bytes": 512, "consumer.request.timeout.ms": 30000 }'

# subscribe the consumer to the 'my-topic' topic
curl -v -X POST --header "Authorization: Bearer $TOKEN" -HHost:httpbin.example.com --resolve "httpbin.example.com:$SECURE_INGRESS_PORT:$INGRESS_HOST" --cacert security/tlsCertificates/example.com.crt "https://httpbin.example.com:$SECURE_INGRESS_PORT"/bridge/consumers/my-topic-consumer-group/instances/my-topic-consumer/subscription -H 'content-type: application/vnd.kafka.v2+json' -d '{ "topics": [ "signals" ] }'

# retrieving th" latest messages from a Kafka Bridge consumer (please note: after creating and subscribing to a Kafka Bridge
# consumer, a f" rst GET request will return an empty response because the poll operation starts a rebalancing process to assign
# partitions. F" r this reason, we need to repeat the request to retrieve messages from the Kafka Bridge consumer)
curl -v -X GET  --header "Authorization: Bearer $TOKEN" HHost:httpbin.example.com --resolve "httpbin.example.com:$SECURE_INGRESS_PORT:$INGRESS_HOST" --cacert security/tlsCertificates/example.com.crt "https://httpbin.example.com:$SECURE_INGRESS_PORT"/bridge/consumers/my-topic-consumer-group/instances/my-topic-consumer/records -H 'accept: application/vnd.kafka.json.v2+json'


# get all signals
curl -v -X GET  --header "Authorization: Bearer $TOKEN" HHost:httpbin.example.com --resolve "httpbin.example.com:$SECURE_INGRESS_PORT:$INGRESS_HOST" --cacert security/tlsCertificates/example.com.crt "https://httpbin.example.com:$SECURE_INGRESS_PORT/historical/signals/all" # /A /A/1

# signup
curl -v -X POST HHost:httpbin.example.com -H "Content-Type: application/json" -d '{"username":"abc4","password":"abc4"}' --resolve "httpbin.example.com:$SECURE_INGRESS_PORT:$INGRESS_HOST" --cacert security/tlsCertificates/example.com.crt "https://httpbin.example.com:$SECURE_INGRESS_PORT/auth/signup" # /A /A/1


############
# LOADTEST #
############

npm install -g loadtest

# test without needing JWT 
loadtest -c 2 -n 10 --insecure https://$INGRESS_HOST:$INGRESS_PORT/auth/test

# test jwt generation latency (quite slow but we don't need it to be fast)
loadtest -c 2 -n 10 --insecure -m POST -T 'application/json' --data '{"username":"abc4","password":"abc4"}' https://$INGRESS_HOST:$INGRESS_PORT/auth/login

# test consumers load
loadtest -k --rps 10 --insecure -H "Authorization: Bearer $TOKEN" -m POST -T 'application/vnd.kafka.json.v2+json' --data '{"records":[{"key": { "topic": "signals", "zone_id": "test", "db": "measurements"}, "value" : { "zone_id": "test", "city": "test", "coordinates": "test", "value": "test","timestamp": "test"} }]}' https://$INGRESS_HOST:$SECURE_INGRESS_PORT/bridge/topics/signals
loadtest -k --rps 100 --insecure -H "Authorization: Bearer $TOKEN" -m POST -T 'application/vnd.kafka.json.v2+json' --data '{\"records\":[{\"key\": { \"topic\": \"signals\", \"zone_id\": \"test\", \"db\": \"measurements\"}, \"value\" : { \"zone_id\": \"test\", \"city\": \"test\", \"coordinates\": \"test\", \"value\": \"test\",\"timestamp\": \"test\"} }]}' https://34.168.247.227:443/bridge/topics/signals
