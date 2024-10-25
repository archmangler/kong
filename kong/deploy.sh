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


#deploy_helm

#deploy_kong_secrets

prepare_mtls_certificate
