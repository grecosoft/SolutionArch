{{/* Naming Conventions */}}

{{- define "solution.name"  }}
{{- .Values.solution | lower }}
{{- end }}

{{- define "solution.envName" }}
{{- get .Values.envNames .Values.environment }}
{{- end }}

{{- define "service.name"  }}
{{- .Values.service | lower }}
{{- end }}

{{- define "service.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "service.image" }}
{{- printf "%s/%s/%s:%s" .Values.image.registry (include "solution.name" .) (include "service.name" .) .Values.image.tag }}
{{- end }}

{{/* Common labels */}}

{{- define "service.labels" -}}
helm.sh/chart: {{ include "service.chart" . }}
{{ include "service.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- if .Values.extraLabels }}
{{ toYaml .Values.extraLabels }}
{{- end }}
{{- end }}

{{/* Selector labels */}}

{{- define "service.selectorLabels" -}}
app.kubernetes.io/name: {{ include "service.name" . }}
{{- end }}















