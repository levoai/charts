{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "levoai.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "levoai.fullname" -}}
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
{{- define "levoai.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "levoai.labels" -}}
helm.sh/chart: {{ include "levoai.chart" . }}
{{ include "levoai.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "levoai.selectorLabels" -}}
app.kubernetes.io/name: {{ include "levoai.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "levoai.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "levoai.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Validates that the levoai-satellite secret exists and has required keys.
Skips validation if no cluster is detected (e.g., during CI or helm template).
*/}}
{{- define "levoai.validatesecrets" -}}
  {{- if .Capabilities.APIVersions.Has "v1/Secret" }}
    {{- /* Only validate during actual install/upgrade operations, not during chart operations */ -}}
    {{- if or .Release.IsInstall .Release.IsUpgrade }}
      {{- $secret := lookup "v1" "Secret" .Release.Namespace "levoai-satellite" }}
      {{- if not $secret }}
        {{- fail (printf "ERROR: Secret 'levoai-satellite' must exist. Create it with:\n  kubectl create secret generic levoai-satellite --from-literal=refresh-token=YOUR_TOKEN -n %s" .Release.Namespace) }}
      {{- end }}
      {{- $refreshToken := index $secret.data "refresh-token" }}
      {{- if not $refreshToken }}
        {{- fail "ERROR: Secret 'levoai-satellite' must contain 'refresh-token' key" }}
      {{- end }}
      {{- if eq (toString $refreshToken) "" }}
        {{- fail "ERROR: Secret 'levoai-satellite' refresh-token cannot be empty" }}
      {{- end }}
    {{- end }}
  {{- else }}
    {{- /* Skip validation in CI / helm template */ -}}
  {{- end }}
{{- end }}


