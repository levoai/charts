# Levoai Satellite

This chart installs Levoai Satellite, which consists of the on-prem
components for Levoai.

## Installation

```sh
# Install levoai helm repo
helm repo add levoai https://charts.levo.ai

# Create levoai namespace and Install levoai satellite
helm install -n levoai levoai-satellite levoai/levoai-satellite  --create-namespace --set global.levoai.app_name=<YOUR_APP_NAME>  --set global.levoai_config_override.onprem-api.refresh-token=<LEVOAI_REFRESH_TOKEN>

# Upgrade
helm repo update
helm upgrade --install -n levoai levoai-satellite levoai/levoai-satellite

# Uninstall
helm uninstall -n levoai levoai-satellite

# Remove levoai namespace
kubectl delete ns levoai
```
