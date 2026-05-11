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

{{/*
Models helpers — mirrors aigateway chart helpers for consistency.
*/}}

{{- define "sidecar-injector.models.enabled" -}}
{{- if and .Values.models .Values.models.enabled }}true{{- else }}false{{- end }}
{{- end }}

{{- define "sidecar-injector.models.mountPath" -}}
{{- if and .Values.models .Values.models.mountPath }}{{ .Values.models.mountPath }}{{- else }}/opt/models{{- end }}
{{- end }}

{{- define "sidecar-injector.models.persistence.enabled" -}}
{{- if and .Values.models .Values.models.persistence .Values.models.persistence.enabled }}true{{- else }}false{{- end }}
{{- end }}

{{- define "sidecar-injector.models.persistence.existingClaim" -}}
{{- if and .Values.models .Values.models.persistence .Values.models.persistence.existingClaim }}{{ .Values.models.persistence.existingClaim }}{{- end }}
{{- end }}

{{- define "sidecar-injector.models.persistence.storageClass" -}}
{{- if and .Values.models .Values.models.persistence .Values.models.persistence.storageClass }}{{ .Values.models.persistence.storageClass }}{{- end }}
{{- end }}

{{- define "sidecar-injector.models.persistence.size" -}}
{{- if and .Values.models .Values.models.persistence .Values.models.persistence.size }}{{ .Values.models.persistence.size }}{{- else }}10Gi{{- end }}
{{- end }}

{{- define "sidecar-injector.models.persistence.accessModes" -}}
{{- if and .Values.models .Values.models.persistence .Values.models.persistence.accessModes }}
{{- range .Values.models.persistence.accessModes }}
- {{ . }}
{{- end }}
{{- else }}
- ReadWriteMany
{{- end }}
{{- end }}

{{- define "sidecar-injector.models.pvcName" -}}
{{- if and .Values.models .Values.models.persistence .Values.models.persistence.existingClaim }}
{{- .Values.models.persistence.existingClaim }}
{{- else }}
{{- printf "%s-models" (include "sidecar-injector.fullname" .) }}
{{- end }}
{{- end }}

{{- define "sidecar-injector.models.initContainer.image" -}}
{{- $registry := "" }}
{{- $repo := "levoai/ai-guardrails-models" }}
{{- $tag := "latest" }}
{{- if and .Values.models .Values.models.initContainer .Values.models.initContainer.image }}
  {{- $registry = default "" .Values.models.initContainer.image.registry }}
  {{- $repo = default "levoai/ai-guardrails-models" .Values.models.initContainer.image.repository }}
  {{- $tag = default "latest" .Values.models.initContainer.image.tag }}
{{- end }}
{{- if $registry }}{{ printf "%s/%s:%s" $registry $repo $tag }}{{- else }}{{ printf "%s:%s" $repo $tag }}{{- end }}
{{- end }}

{{- define "sidecar-injector.models.loaderJob.imagePullPolicy" -}}
{{- if and .Values.models .Values.models.loaderJob .Values.models.loaderJob.imagePullPolicy }}{{ .Values.models.loaderJob.imagePullPolicy }}{{- else }}Always{{- end }}
{{- end }}

{{- define "sidecar-injector.models.loaderJob.ttlSecondsAfterFinished" -}}
{{- if and .Values.models .Values.models.loaderJob .Values.models.loaderJob.ttlSecondsAfterFinished }}{{ .Values.models.loaderJob.ttlSecondsAfterFinished }}{{- else }}3600{{- end }}
{{- end }}

{{- define "sidecar-injector.models.loaderJob.backoffLimit" -}}
{{- if and .Values.models .Values.models.loaderJob .Values.models.loaderJob.backoffLimit }}{{ .Values.models.loaderJob.backoffLimit }}{{- else }}3{{- end }}
{{- end }}

{{- define "sidecar-injector.models.loaderJob.activeDeadlineSeconds" -}}
{{- if and .Values.models .Values.models.loaderJob .Values.models.loaderJob.activeDeadlineSeconds }}{{ .Values.models.loaderJob.activeDeadlineSeconds }}{{- else }}1800{{- end }}
{{- end }}
