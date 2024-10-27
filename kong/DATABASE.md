# Notes on connecting to and managing the Kong management database


```
 kubectl run kong-postgresql-ha-client --rm --tty -i --restart='Never' --namespace postgres --image docker.io/bitnami/postgresql-repmgr:16.4.0-debian-12-r18 --env="PGPASSWORD=$POSTGRES_PASSWORD"  \
        --command -- psql -h kong-postgresql-ha-pgpool -p 5432 -U kong -d kong

```
