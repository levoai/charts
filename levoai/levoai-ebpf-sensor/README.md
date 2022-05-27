# Levoai eBPF Sensor

This chart installs Levoai eBPF Sensor, which consists of the on-prem
components for Levoai.

## Installation

```sh
# Create levoai namespace
kubectl create ns levoai

# Install
helm repo add levoai https://charts.levoa.ai
helm install levoai-sensor levoai/levoai-ebpf-sensor

# Upgrade
helm repo update
helm upgrade levoai-sensor levoai/levoai-ebpf-sensor

# Uninstall
helm uninstall levoai-sensor

# Remove levoai namespace
kubectl delete ns levoai
```
