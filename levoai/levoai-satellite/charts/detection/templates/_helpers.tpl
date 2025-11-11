{{- define "calculateConfigChecksum" -}}
{{- $env := .Values.env | toJson }}

{{- printf "%s%s%s%s%s%s%s"  $env | sha256sum | trim }}
{{- end -}}
