	1. PostgreSQL

	- Installing postgresql-ha via helm-chart for Kong

```
traiano@Traianos-iMac postgresql-ha % ./deploy.sh kong
+ appName=kong
+ namespace=postgres
+ printf 'Creating namespace postgres for kong\n'
Creating namespace postgres for kong
+ kubectl create ns postgres
namespace/postgres created
+ installPackage
+ printf 'Installing the current helm chart for kong\n'
Installing the current helm chart for kong
+ echo helm install kong ./
helm install kong ./
+ helm install kong ./ --namespace postgres
NAME: kong
LAST DEPLOYED: Sun Oct 27 14:12:16 2024
NAMESPACE: postgres
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
CHART NAME: postgresql-ha
CHART VERSION: 14.2.31
APP VERSION: 16.4.0
** Please be patient while the chart is being deployed **
PostgreSQL can be accessed through Pgpool via port 5432 on the following DNS name from within your cluster:

    kong-postgresql-ha-pgpool.postgres.svc.cluster.local

Pgpool acts as a load balancer for PostgreSQL and forward read/write connections to the primary node while read-only connections are forwarded to standby nodes.

To get the password for "kong" run:

    export POSTGRES_PASSWORD=$(kubectl get secret --namespace postgres kong-postgresql-ha-postgresql -o jsonpath="{.data.password}" | base64 -d)

To get the password for "repmgr" run:

    export REPMGR_PASSWORD=$(kubectl get secret --namespace postgres kong-postgresql-ha-postgresql -o jsonpath="{.data.repmgr-password}" | base64 -d)

To connect to your database run the following command:

    kubectl run kong-postgresql-ha-client --rm --tty -i --restart='Never' --namespace postgres --image docker.io/bitnami/postgresql-repmgr:16.4.0-debian-12-r18 --env="PGPASSWORD=$POSTGRES_PASSWORD"  \
        --command -- psql -h kong-postgresql-ha-pgpool -p 5432 -U kong -d kong

To connect to your database from outside the cluster execute the following commands:

    kubectl port-forward --namespace postgres svc/kong-postgresql-ha-pgpool 5432:5432 &
    psql -h 127.0.0.1 -p 5432 -U kong -d kong

WARNING: There are "resources" sections in the chart not set. Using "resourcesPreset" is not recommended for production. For production installations, please set the following values according to your workload needs:
  - pgpool.resources
  - postgresql.resources
  - witness.resources
+info https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/

```

	- Checking Pods:

```
traiano@Traianos-iMac postgresql-ha % kubectl get pods -n postgres 
NAME                                         READY   STATUS    RESTARTS   AGE
kong-postgresql-ha-postgresql-0              1/1     Running   0          112s
kong-postgresql-ha-pgpool-6df8c5d7f4-jxl9k   1/1     Running   0          112s
kong-postgresql-ha-postgresql-2              1/1     Running   0          112s
kong-postgresql-ha-postgresql-1              1/1     Running   0          112s
```

	- Checking pv:
	
```
traiano@Traianos-iMac postgresql-ha % kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                           STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
pvc-a327541b-33dc-4002-99b3-572773a42cfd   8Gi        RWO            Delete           Bound    postgres/data-kong-postgresql-ha-postgresql-0   local-path     <unset>                          5m43s
pvc-87affa43-ad65-4df3-98af-98c20cc7fa4e   8Gi        RWO            Delete           Bound    postgres/data-kong-postgresql-ha-postgresql-2   local-path     <unset>                          5m42s
pvc-0674242a-3bd3-42e5-b096-cf82eeeb2bef   8Gi        RWO            Delete           Bound    postgres/data-kong-postgresql-ha-postgresql-1   local-path     <unset>                          5m41s

```

	- Checking PVC:

```
traiano@Traianos-iMac postgresql-ha % kubectl get pvc -n postgres
NAME                                   STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
data-kong-postgresql-ha-postgresql-0   Bound    pvc-a327541b-33dc-4002-99b3-572773a42cfd   8Gi        RWO            local-path     <unset>                 6m20s
data-kong-postgresql-ha-postgresql-2   Bound    pvc-87affa43-ad65-4df3-98af-98c20cc7fa4e   8Gi        RWO            local-path     <unset>                 6m20s
data-kong-postgresql-ha-postgresql-1   Bound    pvc-0674242a-3bd3-42e5-b096-cf82eeeb2bef   8Gi        RWO            local-path     <unset>                 6m20s

```

	- Connecting to DB:

(DNS resolution?)

```
root@ubuntu:/# ping kong-postgresql-ha-pgpool.postgres.svc.cluster.local
PING kong-postgresql-ha-pgpool.postgres.svc.cluster.local (10.43.25.16): 56 data bytes
64 bytes from 10.43.25.16: icmp_seq=0 ttl=63 time=2.027 ms
64 bytes from 10.43.25.16: icmp_seq=1 ttl=63 time=0.371 ms
64 bytes from 10.43.25.16: icmp_seq=2 ttl=63 time=0.758 ms
^C--- kong-postgresql-ha-pgpool.postgres.svc.cluster.local ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max/stddev = 0.371/1.052/2.027/0.707 ms
root@ubuntu:/# 
```

(TCP connection?)

```
root@ubuntu:/# telnet kong-postgresql-ha-pgpool.postgres.svc.cluster.local 5432
Trying 10.43.25.16...
Connected to kong-postgresql-ha-pgpool.postgres.svc.cluster.local.
Escape character is '^]'.

ds^[[B^[[B^[[B^[[B^[[B^[[B^[[B^[[B^[[B^[[B^[[B
Connection closed by foreign host.
root@ubuntu:/# 
```

(verify password from outside container)

```
traiano@Traianos-iMac kong % export POSTGRES_PASSWORD=$(kubectl get secret --namespace postgres kong-postgresql-ha-postgresql -o jsonpath="{.data.password}" | base64 -d)
traiano@Traianos-iMac kong % echo $POSTGRES_PASSWORD
acn4u4242
```

(postgres cli connectivity?)


```
traiano@Traianos-iMac kong % 
traiano@Traianos-iMac kong %     kubectl run kong-postgresql-ha-client --rm --tty -i --restart='Never' --namespace postgres --image docker.io/bitnami/postgresql-repmgr:16.4.0-debian-12-r18 --env="PGPASSWORD=$POSTGRES_PASSWORD"  \
        --command -- psql -h kong-postgresql-ha-pgpool -p 5432 -U kong -d kong
If you don't see a command prompt, try pressing enter.

kong=> 
kong=> \l
                                                       List of databases
   Name    |  Owner   | Encoding | Locale Provider |   Collate   |    Ctype    | ICU Locale | ICU Rules |   Access privileges   
-----------+----------+----------+-----------------+-------------+-------------+------------+-----------+-----------------------
 kong      | kong     | UTF8     | libc            | en_US.UTF-8 | en_US.UTF-8 |            |           | =Tc/kong             +
           |          |          |                 |             |             |            |           | kong=CTc/kong
 postgres  | postgres | UTF8     | libc            | en_US.UTF-8 | en_US.UTF-8 |            |           | 
 repmgr    | postgres | UTF8     | libc            | en_US.UTF-8 | en_US.UTF-8 |            |           | 
 template0 | postgres | UTF8     | libc            | en_US.UTF-8 | en_US.UTF-8 |            |           | =c/postgres          +
           |          |          |                 |             |             |            |           | postgres=CTc/postgres
 template1 | postgres | UTF8     | libc            | en_US.UTF-8 | en_US.UTF-8 |            |           | =c/postgres          +
           |          |          |                 |             |             |            |           | postgres=CTc/postgres
(5 rows)

kong=> 

```


	- Installing and Testing Kong API Gateway


```
traiano@Traianos-iMac kong % ./deploy.sh 
+ update_kong_configuration
+ helm upgrade kong-cp kong/kong -n kong --values ./values-cp.yaml
Release "kong-cp" has been upgraded. Happy Helming!
NAME: kong-cp
LAST DEPLOYED: Sun Oct 27 16:06:03 2024
NAMESPACE: kong
STATUS: deployed
REVISION: 2
TEST SUITE: None
NOTES:
To connect to Kong, please execute the following commands:

HOST=$(kubectl get svc --namespace kong kong-cp-kong-proxy -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
PORT=$(kubectl get svc --namespace kong kong-cp-kong-proxy -o jsonpath='{.spec.ports[0].port}')
export PROXY_IP=${HOST}:${PORT}
curl $PROXY_IP

Once installed, please follow along the getting started guide to start using
Kong: https://docs.konghq.com/kubernetes-ingress-controller/latest/guides/getting-started/
traiano@Traianos-iMac kong % 

```

	- Check Kong Proxy is there

```
traiano@Traianos-iMac kong % kubectl get svc -n kong
NAME                            TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)                         AGE
kong-cp-kong-clustertelemetry   ClusterIP      10.43.34.248    <none>          8006/TCP                        65m
kong-cp-kong-cluster            ClusterIP      10.43.63.30     <none>          8005/TCP                        65m
kong-cp-kong-admin              NodePort       10.43.248.136   <none>          8001:30701/TCP,8444:30093/TCP   65m
kong-cp-kong-proxy              LoadBalancer   10.43.37.55     192.168.205.2   80:31164/TCP,443:31641/TCP      3m40s
traiano@Traianos-iMac kong % 
```

	- Test kong connection (via kong proxy):
	
	
```
HOST=$(kubectl get svc --namespace kong kong-cp-kong-proxy -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
PORT=$(kubectl get svc --namespace kong kong-cp-kong-proxy -o jsonpath='{.spec.ports[0].port}')
export PROXY_IP=${HOST}:${PORT}
curl $PROXY_IP



```

(For DB: Alternatively try: psql -h localhost -p 5432 -U postgres kong)

(check pod health)


```
traiano@Traianos-iMac kong % kubectl get pods -n kong                                
NAME                                 READY   STATUS      RESTARTS   AGE
kong-cp-kong-init-migrations-z48nw   0/1     Completed   0          27s
	kong-cp-kong-58cddb47d7-mvjnv        1/1     Running     0          27s
traiano@Traianos-iMac kong % 

```

(check kong pod information)

```
kubectl log  kong-cp-kong-58cddb47d7-mvjnv -n kong --follow

```
traiano@Traianos-iMac kong % kubectl logs  kong-cp-kong-58cddb47d7-mvjnv -n kong --follow
Defaulted container "proxy" out of: proxy, clear-stale-pid (init), wait-for-db (init)
2024/10/27 07:04:44 [warn] 1#0: the "user" directive makes sense only if the master process runs with super-user privileges, ignored in /kong_prefix/nginx.conf:7
nginx: [warn] the "user" directive makes sense only if the master process runs with super-user privileges, ignored in /kong_prefix/nginx.conf:7
2024/10/27 07:04:44 [notice] 1#0: [lua] license_helpers.lua:196: read_license_info(): [license-helpers] could not decode license JSON: No license found
2024/10/27 07:04:44 [notice] 1#0: [lua] license_helpers.lua:196: read_license_info(): [license-helpers] could not decode license JSON: No license found
2024/10/27 07:04:44 [notice] 1#0: using the "epoll" event method
2024/10/27 07:04:44 [notice] 1#0: openresty/1.25.3.2
2024/10/27 07:04:44 [notice] 1#0: OS: Linux 6.6.51-0-virt
2024/10/27 07:04:44 [notice] 1#0: getrlimit(RLIMIT_NOFILE): 1048576:1048576
2024/10/27 07:04:44 [notice] 1#0: start worker processes
2024/10/27 07:04:44 [notice] 1#0: start worker process 2533
2024/10/27 07:04:44 [notice] 1#0: start worker process 2534
2024/10/27 07:04:44 [notice] 2533#0: *2 [lua] broker.lua:218: init(): event broker is ready to accept connections on worker #0, context: init_worker_by_lua*
2024/10/27 07:04:44 [notice] 2534#0: *1 [lua] license_helpers.lua:196: read_license_info(): [license-helpers] could not decode license JSON: No license found, context: init_worker_by_lua*
2024/10/27 07:04:44 [notice] 2534#0: *1 [lua] license_helpers.lua:196: read_license_info(): [license-helpers] could not decode license JSON: No license found, context: init_worker_by_lua*
2024/10/27 07:04:44 [notice] 2533#0: *2 [lua] license_helpers.lua:196: read_license_info(): [license-helpers] could not decode license JSON: No license found, context: init_worker_by_lua*
2024/10/27 07:04:44 [notice] 2533#0: *2 [lua] license_helpers.lua:196: read_license_info(): [license-helpers] could not decode license JSON: No license found, context: init_worker_by_lua*
2024/10/27 07:04:45 [notice] 2534#0: *4 [lua] worker.lua:286: communicate(): worker #1 is ready to accept events from unix:/kong_prefix/sockets/we, context: ngx.timer
2024/10/27 07:04:45 [notice] 2533#0: *654 [lua] broker.lua:270: run(): worker #1 connected to events broker (worker pid: 2534), client: unix:, server: kong_worker_events, request: "GET / HTTP/1.1", host: "localhost"
2024/10/27 07:04:45 [notice] 2533#0: *656 [lua] worker.lua:286: communicate(): worker #0 is ready to accept events from unix:/kong_prefix/sockets/we, context: ngx.timer
2024/10/27 07:04:45 [notice] 2533#0: *1298 [lua] broker.lua:270: run(): worker #0 connected to events broker (worker pid: 2533), client: unix:, server: kong_worker_events, request: "GET / HTTP/1.1", host: "localhost"
```

(Inspect the kong database for initial configurations - proof of connection)

```

kong=> \d


public | acls                                          | table    | kong
 public | acme_storage                                  | table    | kong
 public | admins                                        | table    | kong
 public | application_instances                         | table    | kong
 public | applications                                  | table    | kong
 public | audit_objects                                 | table    | kong
 public | audit_requests                                | table    | kong
 public | basicauth_credentials                         | table    | kong
 public | ca_certificates                               | table    | kong
 public | certificates                                  | table    | kong
 public | cluster_events                                | table    | kong
 public | clustering_data_planes                        | table    | kong
 public | clustering_rpc_requests                       | table    | kong
 public | clustering_rpc_requests_id_seq                | sequence | kong
 public | consumer_group_consumers                      | table    | kong
 public | consumer_group_plugins                        | table    | kong
 public | consumer_groups                               | table    | kong
 public | consumer_reset_secrets                        | table    | kong
 public | consumers                                     | table    | kong
 public | credentials                                   | table    | kong
 public | degraphql_routes                              | table    | kong
 public | developers                                    | table    | kong
 public | document_objects                              | table    | kong
 public | event_hooks                                   | table    | kong
 public | files                                         | table    | kong
 public | filter_chains                                 | table    | kong
 public | graphql_ratelimiting_advanced_cost_decoration | table    | kong
 public | group_rbac_roles                              | table    | kong
 public | groups                                        | table    | kong
 public | header_cert_auth_credentials                  | table    | kong
 public | hmacauth_credentials                          | table    | kong
 public | jwt_secrets                                   | table    | kong
 public | jwt_signer_jwks                               | table    | kong
 public | key_sets                                      | table    | kong
 public | keyauth_credentials                           | table    | kong
 public | keyauth_enc_credentials                       | table    | kong
 public | keyring_keys                                  | table    | kong
 public | keyring_meta                                  | table    | kong
 public | keys                                          | table    | kong
 public | konnect_applications                          | table    | kong
 public | legacy_files                                  | table    | kong
 public | license_data                                  | table    | kong
 public | licenses                                      | table    | kong
 public | locks                                         | table    | kong
 public | login_attempts                                | table    | kong
 public | mtls_auth_credentials                         | table    | kong
 public | oauth2_authorization_codes                    | table    | kong
 public | oauth2_credentials                            | table    | kong
 public | oauth2_tokens                                 | table    | kong
 public | oic_issuers                                   | table    | kong
 public | oic_jwks                                      | table    | kong
 public | parameters                                    | table    | kong
 public | plugins                                       | table    | kong
 public | ratelimiting_metrics                          | table    | kong
 public | rbac_role_endpoints                           | table    | kong
 public | rbac_role_entities                            | table    | kong
 public | rbac_roles                                    | table    | kong
 public | rbac_user_groups                              | table    | kong
 public | rbac_user_roles                               | table    | kong
 public | rbac_users                                    | table    | kong
 public | response_ratelimiting_metrics                 | table    | kong
 public | rl_counters                                   | table    | kong
 public | routes                                        | table    | kong
 public | schema_meta                                   | table    | kong
 public | services                                      | table    | kong
 public | sessions                                      | table    | kong
 public | sm_vaults                                     | table    | kong
 public | snis                                          | table    | kong
 public | tags                                          | table    | kong
 public | targets                                       | table    | kong
 public | upstreams                                     | table    | kong
 public | vault_auth_vaults                             | table    | kong
 public | vaults                                        | table    | kong
 public | vitals_code_classes_by_cluster                | table    | kong
 public | vitals_code_classes_by_workspace              | table    | kong
 public | vitals_codes_by_consumer_route                | table    | kong
 public | vitals_codes_by_route                         | table    | kong
 public | vitals_locks                                  | table    | kong
 public | vitals_node_meta                              | table    | kong
 public | vitals_stats_days                             | table    | kong
 public | vitals_stats_hours                            | table    | kong
 public | vitals_stats_minutes                          | table    | kong
 public | vitals_stats_seconds                          | table    | kong
 public | workspace_entities                            | table    | kong
 public | workspace_entity_counters                     | table    | kong
 public | workspaces                                    | table    | kong
 public | ws_migrations_backup                          | table    | kong


```


(Confirmed: the Kong configuration is now stored in a ha pg cluster )


	- Installing the Kong data plane:


```
traiano@192 kong % kubectl get pods -n kong
NAME                                         READY   STATUS      RESTARTS   AGE
kong-cp-kong-pre-upgrade-migrations-jktxz    0/1     Completed   0          32m
kong-cp-kong-post-upgrade-migrations-z96bb   0/1     Completed   0          32m
kong-cp-kong-84f8645c4b-chhpj                1/1     Running     0          32m
ubuntu                                       1/1     Running     0          25m
kong-dp-kong-64d4496b9f-lbh6r                1/1     Running     0          59s
traiano@192 kong % 

```


```
 # Tell the data plane how to connect to the control plane
 cluster_control_plane: kong-cp-kong-cluster.kong.svc.cluster.local:8005
 cluster_telemetry_endpoint: kong-cp-kong-clustertelemetry.kong.svc.cluster.local:8006

```


	- Confirm service endpoint on kubernetes

```
traiano@192 kong % kubectl get ep -n kong
NAME                            ENDPOINTS                           AGE
kong-cp-kong-proxy              10.42.0.230:8000,10.42.0.230:8443   53m
kong-cp-kong-clustertelemetry   10.42.0.230:8006                    115m
kong-cp-kong-admin              10.42.0.230:8001,10.42.0.230:8444   115m
kong-cp-kong-cluster            10.42.0.230:8005                    115m
kong-dp-kong-portal             10.42.0.233:8446,10.42.0.233:8003   22m
kong-dp-kong-portalapi          10.42.0.233:8447,10.42.0.233:8004   22m
kong-dp-kong-proxy              10.42.0.233:8000,10.42.0.233:8443   22m

```


(Testing access to service endpoints of Kong dp and cp)

```
root@ubuntu:/# curl http://10.42.0.233:8000
{
  "message":"no Route matched with those values",
  "request_id":"0cb274715860ec62c520bb3dff3be70e"
}root@ubuntu:/# 
root@ubuntu:/# 
root@ubuntu:/# 
root@ubuntu:/# 
root@ubuntu:/# curl http://10.42.0.233:8000/
{
  "message":"no Route matched with those values",
  "request_id":"6e88a04669bbc97433f2b026b5e0f315"
}root@ubuntu:/# 
root@ubuntu:/# 
root@ubuntu:/# 
root@ubuntu:/# curl http://10.42.0.233:8443/
<html>
<head><title>400 The plain HTTP request was sent to HTTPS port</title></head>
<body>
<center><h1>400 Bad Request</h1></center>
<center>The plain HTTP request was sent to HTTPS port</center>
</body>
</html>
root@ubuntu:/# curl -k http://10.42.0.233:8443/
<html>
<head><title>400 The plain HTTP request was sent to HTTPS port</title></head>
<body>
<center><h1>400 Bad Request</h1></center>
<center>The plain HTTP request was sent to HTTPS port</center>
</body>
</html>
root@ubuntu:/# curl -k https://10.42.0.233:8443/
{
  "message":"no Route matched with those values",
  "request_id":"3e14e240192c3f29b6a57c3dc4f6d01e"
}root@ubuntu:/# 

```



	- Test endpoint accessibility:

```
root@ubuntu:/# curl http://10.42.0.230:8001/mock/anything

{"message":"Not found"}root@ubuntu:/# curl -v http://10.42.0.230:8001/mock/anything
*   Trying 10.42.0.230:8001...
* Connected to 10.42.0.230 (10.42.0.230) port 8001
> GET /mock/anything HTTP/1.1
> Host: 10.42.0.230:8001
> User-Agent: curl/8.5.0
> Accept: */*
> 
< HTTP/1.1 404 Not Found
< Date: Sun, 27 Oct 2024 09:08:07 GMT
< Content-Type: application/json; charset=utf-8
< Connection: keep-alive
< Access-Control-Allow-Origin: *
< X-Kong-Admin-Request-ID: f6f70d04684d8a0490155c73ea62e34f
< Content-Length: 23
< X-Kong-Admin-Latency: 7
< Server: kong/3.8.0.0-enterprise-edition
< 
* Connection #0 to host 10.42.0.230 left intact

```

	Port forward the admin console to localhost:


```
traiano@192 kong %  kubectl port-forward -n kong service/kong-cp-kong-admin 8001
Forwarding from 127.0.0.1:8001 -> 8001
Forwarding from [::1]:8001 -> 8001
Handling connection for 8001
Handling connection for 8001

```

	Create mock service:

```
traiano@Traianos-iMac api-gateway % curl localhost:8001/services -d name=mock  -d url="https://httpbin.konghq.com"

{"path":null,"retries":5,"tls_verify":null,"protocol":"https","tls_verify_depth":null,"tags":null,"ca_certificates":null,"id":"8b0e055d-7d74-45c9-b8b2-1e278483481c","updated_at":1730020266,"client_certificate":null,"write_timeout":60000,"connect_timeout":60000,"read_timeout":60000,"created_at":1730020266,"enabled":true,"host":"httpbin.konghq.com","port":443,"name":"mock"}%                                                                                                                                                                 
traiano@Traianos-iMac api-gateway % 

```

curl localhost:8001/services/mock/routes -d "paths=/mock"


```
traiano@Traianos-iMac api-gateway % curl localhost:8001/services/mock/routes -d "paths=/mock"
{"strip_path":true,"destinations":null,"service":{"id":"8b0e055d-7d74-45c9-b8b2-1e278483481c"},"methods":null,"name":null,"headers":null,"protocols":["http","https"],"tags":null,"id":"3ad2e3be-fd07-4119-a156-7b2161a6ce17","request_buffering":true,"response_buffering":true,"https_redirect_status_code":426,"updated_at":1730020345,"path_handling":"v0","regex_priority":0,"paths":["/mock"],"hosts":null,"created_at":1730020345,"preserve_host":false,"snis":null,"sources":null}%                                                             
traiano@Traianos-iMac api-gateway % 
```


ISSUES: https://docs.konghq.com/gateway/latest/install/kubernetes/proxy/

```


```


	- Finding the proxy IP and port (data plane):


```
PROXY_IP=$(kubectl get service --namespace kong kong-dp-kong-proxy -o jsonpath='{range .status.loadBalancer.ingress[0]}{@.ip}{@.hostname}{end}')

#checking why no external service IP:

traiano@Traianos-iMac api-gateway % kubectl get service --namespace kong kong-dp-kong-proxy
NAME                 TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)                      AGE
kong-dp-kong-proxy   LoadBalancer   10.43.93.84   <pending>     80:31248/TCP,443:30883/TCP   3h1m
traiano@Traianos-iMac api-gateway % 
traiano@Traianos-iMac api-gateway % 

#checking on a pod in the same ns:

```
root@ubuntu:/# 
root@ubuntu:/# curl http://10.43.93.84 
{
  "message":"no Route matched with those values",
  "request_id":"b3019d5ed8d72f25a187b365a0de595c"
}root@ubuntu:/# 
```

#testing with the internal service IP address for the proxy:

```
root@ubuntu:/# curl http://10.43.93.84/mock/anything
{
  "args": {}, 
  "data": "", 
  "files": {}, 
  "form": {}, 
  "headers": {
    "Accept": "*/*", 
    "Connection": "keep-alive", 
    "Host": "httpbin.konghq.com", 
    "User-Agent": "curl/8.5.0", 
    "X-Forwarded-Host": "10.43.93.84", 
    "X-Forwarded-Path": "/mock/anything", 
    "X-Forwarded-Prefix": "/mock", 
    "X-Kong-Request-Id": "4f49e11d4106d95a9ad1ac226954c52f"
  }, 
  "json": null, 
  "method": "GET", 
  "origin": "10.42.0.232", 
  "url": "http://10.43.93.84/anything"
}
```


	- Check the proxy endpoints:

```
traiano@Traianos-iMac api-gateway % kubectl get ep --namespace kong kong-dp-kong-proxy
NAME                 ENDPOINTS                           AGE
kong-dp-kong-proxy   10.42.0.233:8000,10.42.0.233:8443   3h6m
```

	- Testing using the claimed EP URLs:

```
root@ubuntu:/# curl http://10.42.0.233:8000 
{
  "message":"no Route matched with those values",
  "request_id":"f50a877599974c61e7783f3401bdfb66"
}root@ubuntu:/# 


root@ubuntu:/# curl http://10.42.0.233:8000/mock/anything
{
  "args": {}, 
  "data": "", 
  "files": {}, 
  "form": {}, 
  "headers": {
    "Accept": "*/*", 
    "Connection": "keep-alive", 
    "Host": "httpbin.konghq.com", 
    "User-Agent": "curl/8.5.0", 
    "X-Forwarded-Host": "10.42.0.233", 
    "X-Forwarded-Path": "/mock/anything", 
    "X-Forwarded-Prefix": "/mock", 
    "X-Kong-Request-Id": "f2f73844ac99fa7100f9e2756080d90a"
  }, 
  "json": null, 
  "method": "GET", 
  "origin": "10.42.0.232", 
  "url": "http://10.42.0.233/anything"
}
root@ubuntu:/# 

```

#Configuring the Admin APIs

	- Enable the manager option in the helm chart: (https://github.com/Kong/kong-manager/discussions/73)

```
traiano@Traianos-iMac kong % ./deploy-control-plane.sh
+ update_kong_configuration
+ helm upgrade kong-cp kong/kong -n kong --values ./values-cp.yaml
Release "kong-cp" has been upgraded. Happy Helming!
NAME: kong-cp
LAST DEPLOYED: Sun Oct 27 20:14:28 2024
NAMESPACE: kong
STATUS: deployed
REVISION: 3
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























