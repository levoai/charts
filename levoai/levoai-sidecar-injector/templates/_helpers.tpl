{{/*
Expand the name of the chart.
*/}}
{{- define "sidecar-injector.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "sidecar-injector.fullname" -}}
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
{{- define "sidecar-injector.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "sidecar-injector.labels" -}}
helm.sh/chart: {{ include "sidecar-injector.chart" . }}
{{ include "sidecar-injector.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "sidecar-injector.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sidecar-injector.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: sidecar-injector
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "sidecar-injector.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "sidecar-injector.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Injector image
*/}}
{{- define "sidecar-injector.image" -}}
{{- printf "%s/%s:%s" .Values.image.registry .Values.image.repository (default .Chart.AppVersion .Values.image.tag) }}
{{- end }}

{{/*
Sidecar image (for the injector config)
*/}}
{{- define "sidecar-injector.sidecarImage" -}}
{{- printf "%s/%s:%s" (default "docker.io" .Values.sidecar.image.registry) .Values.sidecar.image.repository (default .Chart.AppVersion .Values.sidecar.image.tag) }}
{{- end }}

{{/*
Webhook service name
*/}}
{{- define "sidecar-injector.webhookServiceName" -}}
{{- printf "%s-webhook" (include "sidecar-injector.fullname" .) }}
{{- end }}
