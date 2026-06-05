#!/bin/bash

set -euo pipefail

echo "[debian] Installing Kubernetes tooling..."

########################################
# DEPENDENCIES
########################################

apt install -y \
  curl \
  wget \
  gnupg \
  ca-certificates

########################################
# KUBECTL
########################################

KUBECTL_VERSION="$(curl -L -s https://dl.k8s.io/release/stable.txt)"

curl -LO \
"https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/arm64/kubectl"

install -o root -g root -m 0755 \
kubectl /usr/local/bin/kubectl

rm -f kubectl

########################################
# HELM
########################################

curl -fsSL \
https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
| bash

########################################
# VERIFY
########################################

echo
echo "[debian] Kubernetes tooling versions:"
echo

kubectl version --client
helm version

echo
echo "[debian] Kubernetes tooling installed"

