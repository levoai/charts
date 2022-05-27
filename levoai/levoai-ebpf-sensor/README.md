# Levoai eBPF Sensor

This chart installs Levoai eBPF Sensor, which consists of the on-prem
components for Levoai.

## Installation

```sh
# Create levoai namespace
kubectl create ns levoai

# Install
helm repo add levoai https://charts.levo.ai
helm install -n levoai levoai-sensor levoai/levoai-ebpf-sensor

# Upgrade
helm repo update
helm upgrade --install -n levoai levoai-sensor levoai/levoai-ebpf-sensor

# Uninstall
helm uninstall -n levoai levoai-sensor

# Remove levoai namespace
kubectl delete ns levoai
```
