{{- define "protection.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "protection.serviceAccountName" -}}
{{- if .Values.serviceAccount.name }}
{{ .Values.serviceAccount.name | trunc 63 | trimSuffix "-" -}}
{{- else }}
{{ include "protection.name" . }}-sa
{{- end }}
{{- end }}
