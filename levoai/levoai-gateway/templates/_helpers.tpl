{{/*
Expand the name of the chart.
*/}}
{{- define "aigateway.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "aigateway.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "aigateway.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "aigateway.labels" -}}
helm.sh/chart: {{ include "aigateway.chart" . }}
{{ include "aigateway.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "aigateway.selectorLabels" -}}
aigateway: aigateway
app.kubernetes.io/name: {{ include "aigateway.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "aigateway.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "aigateway.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Validate validation level and return the validated value.
Supported values: "standard" or "strict" (case-insensitive).
*/}}
{{- define "aigateway.validationLevel" -}}
{{- $level := .Values.validation.level | lower | trimAll " " -}}
{{- if or (eq $level "standard") (eq $level "strict") -}}
{{- $level -}}
{{- else -}}
{{- printf "ERROR: Invalid validation.level '%s'. Must be 'standard' or 'strict' (case-insensitive). Current value: '%s'" $level .Values.validation.level | fail -}}
{{- end -}}
{{- end }}

{{/*
=============================================================================
Nil-safe value accessors
These helpers provide safe access to nested values with sensible defaults,
preventing nil pointer errors when using --reuse-values with partial configs.
=============================================================================
*/}}

{{/*
Controller helpers
*/}}
{{- define "aigateway.controller.enabled" -}}
{{- if .Values.controller }}
{{- .Values.controller.enabled | default false }}
{{- else }}
{{- false }}
{{- end }}
{{- end }}

{{/*
Data Plane helpers
*/}}
{{- define "aigateway.dataPlane.replicaCount" -}}
{{- if .Values.dataPlane }}
{{- .Values.dataPlane.replicaCount | default 1 }}
{{- else }}
{{- 1 }}
{{- end }}
{{- end }}

{{- define "aigateway.dataPlane.adminAddr" -}}
{{- if .Values.dataPlane }}
{{- .Values.dataPlane.adminAddr | default "0.0.0.0:15000" }}
{{- else }}
{{- "0.0.0.0:15000" }}
{{- end }}
{{- end }}

{{- define "aigateway.dataPlane.service.type" -}}
{{- if .Values.dataPlane }}
{{- if .Values.dataPlane.service }}
{{- .Values.dataPlane.service.type | default "LoadBalancer" }}
{{- else }}
{{- "LoadBalancer" }}
{{- end }}
{{- else }}
{{- "LoadBalancer" }}
{{- end }}
{{- end }}

{{- define "aigateway.dataPlane.service.port" -}}
{{- if .Values.dataPlane }}
{{- if .Values.dataPlane.service }}
{{- .Values.dataPlane.service.port | default 8080 }}
{{- else }}
{{- 8080 }}
{{- end }}
{{- else }}
{{- 8080 }}
{{- end }}
{{- end }}

{{- define "aigateway.dataPlane.image.registry" -}}
{{- if .Values.dataPlane }}
{{- if .Values.dataPlane.image }}
{{- .Values.dataPlane.image.registry | default "ghcr.io" }}
{{- else }}
{{- "ghcr.io" }}
{{- end }}
{{- else }}
{{- "ghcr.io" }}
{{- end }}
{{- end }}

{{- define "aigateway.dataPlane.image.repository" -}}
{{- if .Values.dataPlane }}
{{- if .Values.dataPlane.image }}
{{- .Values.dataPlane.image.repository | default "levoai/aigateway" }}
{{- else }}
{{- "levoai/aigateway" }}
{{- end }}
{{- else }}
{{- "levoai/aigateway" }}
{{- end }}
{{- end }}

{{- define "aigateway.dataPlane.image.tag" -}}
{{- if .Values.dataPlane }}
{{- if .Values.dataPlane.image }}
{{- .Values.dataPlane.image.tag | default .Chart.AppVersion }}
{{- else }}
{{- .Chart.AppVersion }}
{{- end }}
{{- else }}
{{- .Chart.AppVersion }}
{{- end }}
{{- end }}

{{- define "aigateway.dataPlane.image.pullPolicy" -}}
{{- if .Values.dataPlane }}
{{- if .Values.dataPlane.image }}
{{- .Values.dataPlane.image.pullPolicy | default "IfNotPresent" }}
{{- else }}
{{- "IfNotPresent" }}
{{- end }}
{{- else }}
{{- "IfNotPresent" }}
{{- end }}
{{- end }}

{{- define "aigateway.dataPlane.image" -}}
{{- printf "%s/%s:%s" (include "aigateway.dataPlane.image.registry" .) (include "aigateway.dataPlane.image.repository" .) (include "aigateway.dataPlane.image.tag" .) }}
{{- end }}

{{/*
Config helpers - SaaS
*/}}
{{- define "aigateway.config.saas.enabled" -}}
{{- if .Values.config }}
{{- if .Values.config.saas }}
{{- .Values.config.saas.enabled | default false }}
{{- else }}
{{- false }}
{{- end }}
{{- else }}
{{- false }}
{{- end }}
{{- end }}

{{- define "aigateway.config.saas.url" -}}
{{- if .Values.config }}
{{- if .Values.config.saas }}
{{- .Values.config.saas.url | default "https://api.levo.ai" }}
{{- else }}
{{- "https://api.levo.ai" }}
{{- end }}
{{- else }}
{{- "https://api.levo.ai" }}
{{- end }}
{{- end }}

{{- define "aigateway.config.saas.environmentId" -}}
{{- if .Values.config }}
{{- if .Values.config.saas }}
{{- .Values.config.saas.environmentId | default "" }}
{{- else }}
{{- "" }}
{{- end }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}

{{- define "aigateway.config.saas.pollInterval" -}}
{{- if .Values.config }}
{{- if .Values.config.saas }}
{{- .Values.config.saas.pollInterval | default "60s" }}
{{- else }}
{{- "60s" }}
{{- end }}
{{- else }}
{{- "60s" }}
{{- end }}
{{- end }}

{{- define "aigateway.config.saas.refreshToken" -}}
{{- if .Values.config }}
{{- if .Values.config.saas }}
{{- .Values.config.saas.refreshToken | default "" }}
{{- else }}
{{- "" }}
{{- end }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}

{{- define "aigateway.config.saas.alertWebhookUrl" -}}
{{- if .Values.config }}
{{- if .Values.config.saas }}
{{- .Values.config.saas.alertWebhookUrl | default "" }}
{{- else }}
{{- "" }}
{{- end }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}

{{/*
Config helpers - ConfigMap
*/}}
{{- define "aigateway.config.configMap.enabled" -}}
{{- if .Values.config }}
{{- if .Values.config.configMap }}
{{- .Values.config.configMap.enabled | default false }}
{{- else }}
{{- false }}
{{- end }}
{{- else }}
{{- false }}
{{- end }}
{{- end }}

{{- define "aigateway.config.configMap.name" -}}
{{- if .Values.config }}
{{- if .Values.config.configMap }}
{{- .Values.config.configMap.name | default "agentgateway-config" }}
{{- else }}
{{- "agentgateway-config" }}
{{- end }}
{{- else }}
{{- "agentgateway-config" }}
{{- end }}
{{- end }}

{{- define "aigateway.config.configMap.create" -}}
{{- if .Values.config }}
{{- if .Values.config.configMap }}
{{- .Values.config.configMap.create | default false }}
{{- else }}
{{- false }}
{{- end }}
{{- else }}
{{- false }}
{{- end }}
{{- end }}

{{/*
Models helpers
*/}}
{{- define "aigateway.models.enabled" -}}
{{- if .Values.models }}
{{- .Values.models.enabled | default false }}
{{- else }}
{{- false }}
{{- end }}
{{- end }}

{{- define "aigateway.models.mountPath" -}}
{{- if .Values.models }}
{{- .Values.models.mountPath | default "/opt/models" }}
{{- else }}
{{- "/opt/models" }}
{{- end }}
{{- end }}

{{- define "aigateway.models.persistence.enabled" -}}
{{- if .Values.models }}
{{- if .Values.models.persistence }}
{{- .Values.models.persistence.enabled | default false }}
{{- else }}
{{- false }}
{{- end }}
{{- else }}
{{- false }}
{{- end }}
{{- end }}

{{- define "aigateway.models.persistence.existingClaim" -}}
{{- if .Values.models }}
{{- if .Values.models.persistence }}
{{- .Values.models.persistence.existingClaim | default "" }}
{{- else }}
{{- "" }}
{{- end }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}

{{- define "aigateway.models.persistence.storageClass" -}}
{{- if .Values.models }}
{{- if .Values.models.persistence }}
{{- .Values.models.persistence.storageClass | default "" }}
{{- else }}
{{- "" }}
{{- end }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}

{{- define "aigateway.models.persistence.size" -}}
{{- if .Values.models }}
{{- if .Values.models.persistence }}
{{- .Values.models.persistence.size | default "10Gi" }}
{{- else }}
{{- "10Gi" }}
{{- end }}
{{- else }}
{{- "10Gi" }}
{{- end }}
{{- end }}

{{- define "aigateway.models.persistence.accessModes" -}}
{{- if .Values.models }}
{{- if .Values.models.persistence }}
{{- if .Values.models.persistence.accessModes }}
{{- toYaml .Values.models.persistence.accessModes }}
{{- else }}
- ReadOnlyMany
{{- end }}
{{- else }}
- ReadOnlyMany
{{- end }}
{{- else }}
- ReadOnlyMany
{{- end }}
{{- end }}

{{- define "aigateway.models.initContainer.image" -}}
{{- if and .Values.models .Values.models.initContainer .Values.models.initContainer.image }}
  {{- if kindIs "string" .Values.models.initContainer.image }}
    {{- .Values.models.initContainer.image }}
  {{- else }}
    {{- $img := .Values.models.initContainer.image }}
    {{- printf "%s/%s:%s" ($img.registry | default "docker.io") ($img.repository | default "levoai/ai-guardrails-models") ($img.tag | default "latest") }}
  {{- end }}
{{- else }}
  {{- "docker.io/levoai/ai-guardrails-models:latest" }}
{{- end }}
{{- end }}

{{- define "aigateway.models.initContainer.imagePullPolicy" -}}
{{- if and .Values.models .Values.models.initContainer -}}
{{- .Values.models.initContainer.imagePullPolicy | default "IfNotPresent" }}
{{- else -}}
{{- "IfNotPresent" }}
{{- end }}
{{- end }}

{{- define "aigateway.models.loaderJob.imagePullPolicy" -}}
{{- if and .Values.models .Values.models.loaderJob -}}
{{- .Values.models.loaderJob.imagePullPolicy | default "Always" }}
{{- else -}}
{{- "Always" }}
{{- end -}}
{{- end }}

{{- define "aigateway.models.loaderJob.ttlSecondsAfterFinished" -}}
{{- if .Values.models }}
{{- if .Values.models.loaderJob }}
{{- .Values.models.loaderJob.ttlSecondsAfterFinished | default 3600 }}
{{- else }}
{{- 3600 }}
{{- end }}
{{- else }}
{{- 3600 }}
{{- end }}
{{- end }}

{{- define "aigateway.models.loaderJob.backoffLimit" -}}
{{- if .Values.models }}
{{- if .Values.models.loaderJob }}
{{- .Values.models.loaderJob.backoffLimit | default 3 }}
{{- else }}
{{- 3 }}
{{- end }}
{{- else }}
{{- 3 }}
{{- end }}
{{- end }}

{{- define "aigateway.models.loaderJob.activeDeadlineSeconds" -}}
{{- if .Values.models }}
{{- if .Values.models.loaderJob }}
{{- .Values.models.loaderJob.activeDeadlineSeconds | default 1800 }}
{{- else }}
{{- 1800 }}
{{- end }}
{{- else }}
{{- 1800 }}
{{- end }}
{{- end }}

{{/*
Deployment name helper - returns correct name based on mode
*/}}
{{- define "aigateway.deploymentName" -}}
{{- if eq (include "aigateway.controller.enabled" .) "true" }}
{{- printf "%s-controller" (include "aigateway.fullname" .) }}
{{- else }}
{{- include "aigateway.fullname" . }}
{{- end }}
{{- end }}

{{/*
PVC name for models
*/}}
{{- define "aigateway.models.pvcName" -}}
{{- $existingClaim := include "aigateway.models.persistence.existingClaim" . }}
{{- if $existingClaim }}
{{- $existingClaim }}
{{- else }}
{{- printf "%s-models" (include "aigateway.fullname" .) }}
{{- end }}
{{- end }}
