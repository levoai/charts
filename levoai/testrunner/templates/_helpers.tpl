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

{{- define "calculateConfigChecksum" -}}
{{- $secretMounts := .Values.secretMounts | toJson }}
{{- $globalLevoSecretMounts := .Values.global.levo.secretMounts | toJson }}
{{- $configMapMounts := .Values.configMapMounts | toJson}}
{{- $globalLevoConfigMapMounts := .Values.global.levo.configMapMounts | toJson }}
{{- $extraEnv := .Values.extraEnv | toJson }}
{{- $globalLevoEnv := .Values.global.levo.env | toJson }}
{{- $extraEnvVars := .Values.extraEnvVars | toJson }}
{{- $extraEnvVarsCM := .Values.extraEnvVarsCM | toJson }}
{{- $extraEnvVarsSecret := .Values.extraEnvVarsSecret | toJson }}

{{- printf "%s%s%s%s%s%s%s" $secretMounts $globalLevoSecretMounts $extraEnv $globalLevoEnv $extraEnvVars $extraEnvVarsCM $extraEnvVarsSecret | sha256sum | trim }}
{{- end -}}
