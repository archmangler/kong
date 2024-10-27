# Installing and Configuring Kong 
=================================


# First time deployment

* After customising <> you should be able to run deploy.sh:

```
traiano@Traianos-iMac kong % ./deploy.sh 
+ create_kong_release
+ helm install kong-cp kong/kong -n kong --values ./values-cp.yaml
NAME: kong-cp
LAST DEPLOYED: Fri Oct 25 22:39:47 2024
NAMESPACE: kong
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
To connect to Kong, please execute the following commands:

HOST=$(kubectl get svc --namespace kong kong-cp-kong-proxy -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
PORT=$(kubectl get svc --namespace kong kong-cp-kong-proxy -o jsonpath='{.spec.ports[0].port}')
export PROXY_IP=${HOST}:${PORT}
curl $PROXY_IP

Once installed, please follow along the getting started guide to start using
Kong: https://docs.konghq.com/kubernetes-ingress-controller/latest/guides/getting-started/
```

* NOTE: You may choose to customise `deploy.sh`.

# References

* Installation: https://docs.konghq.com/gateway/latest/install/kubernetes/proxy/



