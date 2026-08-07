{{/*
Generate the name of the resource. Defaults to the exact pre-existing behavior
(chart name, "-scheduled" suffix when scheduled: true) so an upgrade of an
existing single-instance install with fullnameOverride unset does not rename —
and therefore does not recreate — its Deployment.

Set fullnameOverride to run more than one testrunner release in the same
namespace: each concurrent release must use a distinct value, since the
default name never varies by Helm release name.
*/}}
{{- define "testrunner.name" -}}
{{- $base := default .Chart.Name .Values.fullnameOverride -}}
{{- if .Values.scheduled }}
  {{- printf "%s-scheduled" $base | trunc 63 | trimSuffix "-" -}}
{{- else -}}
  {{- $base | trunc 63 | trimSuffix "-" -}}
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
