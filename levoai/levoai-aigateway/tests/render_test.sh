#!/usr/bin/env bash
# Render-level regression tests for the aigateway chart.
#
# Pins the guardrail sizing invariant: a data plane with ML models gets the
# models.resources sizing (4 CPU) *together with* a 1-session ONNX pool. If the
# CPU limit renders without LEVOAI_ONNX_SESSION_POOL_SIZE, llm-bastion sizes
# its pool to the core count and every session is a full model copy, which
# OOM-killed the pod on spec-building-e2e. Also pins that the controller and a
# model-less data plane keep the lightweight top-level `resources`.
#
# Usage: helm/aigateway/tests/render_test.sh   (needs helm on PATH)
set -euo pipefail

CHART="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
failures=0

render() { helm template t "$CHART" --show-only templates/deployment.yaml "$@"; }

# Value of env var $1 in the rendered manifest on stdin ("" if absent).
env_value() {
  awk -v name="$1" '
    $0 ~ "- name: " name "$" { getline; sub(/^ *value: */, ""); gsub(/"/, ""); print; exit }'
}

# "<requests.cpu> <requests.memory> <limits.cpu> <limits.memory>" of container $1.
container_resources() {
  awk -v c="$1" '
    $0 ~ "^        - name: " c "$" { inc = 1; next }
    inc && /^        - name: / { inc = 0 }
    inc && /^          resources:/ { inr = 1; next }
    inr && !/^            / { exit }
    inr && /^            limits:/ { sec = "limits"; next }
    inr && /^            requests:/ { sec = "requests"; next }
    inr { v = $2; gsub(/"/, "", v); r[sec "." substr($1, 1, length($1) - 1)] = v }
    END { print r["requests.cpu"], r["requests.memory"], r["limits.cpu"], r["limits.memory"] }'
}

check() { # name, expected, actual
  if [[ "$2" == "$3" ]]; then
    echo "ok   $1"
  else
    echo "FAIL $1: expected '$2', got '$3'"
    failures=$((failures + 1))
  fi
}

# Defaults: guardrail sizing with a pinned pool, canonical and legacy names.
out=$(render)
check "defaults: data plane resources" "500m 7Gi 4 10Gi" "$(container_resources proxy <<<"$out")"
check "defaults: session pool size" "1" "$(env_value LEVOAI_ONNX_SESSION_POOL_SIZE <<<"$out")"
check "defaults: intra-op threads" "2" "$(env_value LEVOAI_GUARDRAILS_ONNX_INTRA_THREADS <<<"$out")"
check "defaults: legacy intra-op threads" "2" "$(env_value LLM_BASTION_ONNX_INTRA_THREADS <<<"$out")"

# Overrides flow through to every spelling.
out=$(render --set models.onnx.sessionPoolSize=2 --set models.onnx.intraThreads=3)
check "override: session pool size" "2" "$(env_value LEVOAI_ONNX_SESSION_POOL_SIZE <<<"$out")"
check "override: intra-op threads" "3" "$(env_value LEVOAI_GUARDRAILS_ONNX_INTRA_THREADS <<<"$out")"
check "override: legacy intra-op threads" "3" "$(env_value LLM_BASTION_ONNX_INTRA_THREADS <<<"$out")"

# No models: no ONNX tuning, lightweight top-level resources.
out=$(render --set models.enabled=false)
check "models off: no session pool env" "" "$(env_value LEVOAI_ONNX_SESSION_POOL_SIZE <<<"$out")"
check "models off: no intra-op env" "" "$(env_value LEVOAI_GUARDRAILS_ONNX_INTRA_THREADS <<<"$out")"
check "models off: no legacy intra-op env" "" "$(env_value LLM_BASTION_ONNX_INTRA_THREADS <<<"$out")"
check "models off: data plane resources" "500m 4Gi 1000m 8Gi" "$(container_resources proxy <<<"$out")"

# ONNX block removed: no tuning env, sizing unaffected.
out=$(render --set models.onnx=null)
check "onnx null: no session pool env" "" "$(env_value LEVOAI_ONNX_SESSION_POOL_SIZE <<<"$out")"
check "onnx null: no intra-op env" "" "$(env_value LEVOAI_GUARDRAILS_ONNX_INTRA_THREADS <<<"$out")"

# models.resources opted out: data plane falls back to top-level resources.
# (null, not {}: Helm merges an empty map into the defaults instead of
# replacing them.)
out=$(render --set models.resources=null)
check "models.resources null: data plane resources" "500m 4Gi 1000m 8Gi" "$(container_resources proxy <<<"$out")"

# Controller mode keeps the top-level resources.
out=$(render --set controller.enabled=true)
check "controller: resources" "500m 4Gi 1000m 8Gi" "$(container_resources controller <<<"$out")"

# Schema rejects a zero-sized pool and zero threads.
for bad in models.onnx.sessionPoolSize=0 models.onnx.intraThreads=0; do
  if render --set "$bad" >/dev/null 2>&1; then
    check "schema rejects $bad" "rejected" "accepted"
  else
    check "schema rejects $bad" "rejected" "rejected"
  fi
done

if ((failures > 0)); then
  echo "$failures chart render check(s) failed"
  exit 1
fi
echo "all chart render checks passed"
