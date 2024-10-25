#!/bin/bash

function deploy_helm () {
  helm repo add kong https://charts.konghq.com
  helm repo update
}

function deploy_kong_secrets () {
  kubectl create namespace kong
  kubectl create secret generic kong-enterprise-license --from-literal=license="'{}'" -n kong
}

