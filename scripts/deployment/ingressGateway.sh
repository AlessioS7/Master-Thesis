# this deploys the service, deployment and other workloads needed for creating the actual gateway
kubectl apply -f kuber/istio-ingressgateway

# this secret will be used in the Gateway configuration file
kubectl create secret tls httpbin-credential \
  --key=security/tlsCertificates/httpbin.example.com.key \
  --cert=security/tlsCertificates/httpbin.example.com.crt

# configure the just created gateway
kubectl apply -f kuber/config-ingress-gateway.yaml

# configure authentication and authorization policies
kubectl apply -f kuber/authentication-policy.yaml
kubectl apply -f kuber/authorization-policy.yaml

# configure your services to only accept mTLS traffic (https://cloud.google.com/service-mesh/docs/security/configuring-mtls?_gl=1*errb11*_ga*NTI1MjUwMDguMTY2MzE5MDk1MQ..*_ga_WH2QY8WWF5*MTY3MDAyNTIyNy45Ny4xLjE2NzAwMjcyMjUuMC4wLjA.&_ga=2.82236562.-52525008.1663190951&_gac=1.182785876.1666307003.Cj0KCQjw48OaBhDWARIsAMd966B0mYfVqGh533PhSIgZ0XjC115pLMdK8AXEqJ6m0WNn8C_v37RWUVEaAv6NEALw_wcB)
kubectl apply -f kuber/peer-authentication-policy.yaml
