#!/bin/bash
set -x
appName="$1"
namespace="postgres"

function removePackage () {
  printf "Removing the current helm chart for ${appName}\n"
  helm uninstall $appName --ignore-not-found --namespace ${namespace} 
}

function installPackage () {
  printf "Installing the current helm chart for ${appName}\n"
  echo helm install $appName ./
  helm install $appName ./  --namespace ${namespace}
}

printf "Creating namespace $namespace for ${appName}\n"
kubectl create ns ${namespace}

#first remove the package then install it again
#this is to deal with the idempotency issues 
#in the Helm tooling
#removePackage
installPackage
