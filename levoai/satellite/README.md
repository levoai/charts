# Levoai Satellite

This chart installs Levoai Satellite, which consists of the on-prem
components for Levoai.

## Installation

```sh
# Create levoai namespace
kubectl create ns levoai

# Install
helm repo add levoai https://charts.levo.ai
helm install levoai-satellite levoai/satellite

# Upgrade
helm repo update
helm upgrade levoai-satellite levoai/satellite

# Uninstall
helm uninstall levoai-satellite

# Remove levoai namespace
kubectl delete ns levoai
```
