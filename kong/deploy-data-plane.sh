#!/bin/bash
set -ex

function deploy_helm () {
  printf "Preparing Helm charts ...\n"
  helm repo add kong https://charts.konghq.com
  helm repo update
}

function deploy_kong_secrets () {
  printf "Preparing kong Free License ...\n"
  kubectl create namespace kong
  kubectl create secret generic kong-enterprise-license --from-literal=license="'{}'" -n kong
}

function prepare_mtls_certificate () {
  printf "Preparing Long TLS certificate for mTLS ...\n"
  openssl req -new -x509 -nodes -newkey ec:<(openssl ecparam -name secp384r1) -keyout ./tls.key -out ./tls.crt -days 1095 -subj "/CN=kong_clustering"
}

function create_mtls_secret () {
  printf "creating kubernetes secret for mTLS certificate ...\n"
  kubectl create secret tls kong-cluster-cert --cert=./tls.crt --key=./tls.key -n kong
}

function create_kong_release () {
  helm install kong-dp kong/kong -n kong --values ./values-dp.yaml
}

function delete_kong_release () {
  helm uninstall kong-dp -n kong
}

function update_kong_configuration () {
  helm upgrade kong-dp kong/kong -n kong --values ./values-dp.yaml
}

#deploy_helm

#deploy_kong_secrets

#prepare_mtls_certificate

#create_mtls_secret

create_kong_release

#delete_kong_release

#update_kong_configuration

