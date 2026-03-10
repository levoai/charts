{{/*
Calculate configuration checksum for pod annotations
*/}}
{{- define "calculateConfigChecksum" -}}
{{- $secretMounts := .Values.secretMounts | toJson | default "{}" }}
{{- $globalLevoSecretMounts := "{}" }}
{{- if hasKey .Values "global" }}
{{- if hasKey .Values.global "levo" }}
{{- if hasKey .Values.global.levo "secretMounts" }}
{{- $globalLevoSecretMounts = .Values.global.levo.secretMounts | toJson }}
{{- end }}
{{- end }}
{{- end }}
{{- $configMapMounts := .Values.configMapMounts | toJson | default "{}" }}
{{- $globalLevoConfigMapMounts := "{}" }}
{{- if hasKey .Values "global" }}
{{- if hasKey .Values.global "levo" }}
{{- if hasKey .Values.global.levo "configMapMounts" }}
{{- $globalLevoConfigMapMounts = .Values.global.levo.configMapMounts | toJson }}
{{- end }}
{{- end }}
{{- end }}
{{- $extraEnv := .Values.extraEnv | toJson | default "{}" }}
{{- $globalLevoEnv := "{}" }}
{{- if hasKey .Values "global" }}
{{- if hasKey .Values.global "levo" }}
{{- if hasKey .Values.global.levo "env" }}
{{- $globalLevoEnv = .Values.global.levo.env | toJson }}
{{- end }}
{{- end }}
{{- end }}
{{- $extraEnvVars := .Values.extraEnvVars | toJson | default "[]" }}
{{- $extraEnvVarsCM := .Values.extraEnvVarsCM | default "" }}
{{- $extraEnvVarsSecret := .Values.extraEnvVarsSecret | default "" }}
{{- $config := .Values.config | toJson | default "{}" }}
{{- printf "%s%s%s%s%s%s%s%s%s" $secretMounts $globalLevoSecretMounts $configMapMounts $globalLevoConfigMapMounts $extraEnv $globalLevoEnv $extraEnvVars $extraEnvVarsCM $extraEnvVarsSecret $config | sha256sum | trim }}
{{- end }}
