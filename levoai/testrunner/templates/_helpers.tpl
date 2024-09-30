{{/*
Generate the name of the resource based on the chart name.
*/}}
{{- define "testrunner.name" -}}
{{- if .Values.scheduled }}
  {{- printf "%s-scheduled" .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
  {{- printf "%s" .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
