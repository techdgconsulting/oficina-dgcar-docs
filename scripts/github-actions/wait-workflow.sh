#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 --repo owner/repo --workflow file.yml [--timeout-seconds 3600]"
}

repo=""
workflow=""
timeout_seconds="3600"
poll_seconds="20"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --repo)
      repo="$2"
      shift 2
      ;;
    --workflow)
      workflow="$2"
      shift 2
      ;;
    --timeout-seconds)
      timeout_seconds="$2"
      shift 2
      ;;
    --poll-seconds)
      poll_seconds="$2"
      shift 2
      ;;
    *)
      usage
      exit 2
      ;;
  esac
done

if [ -z "$repo" ] || [ -z "$workflow" ]; then
  usage
  exit 2
fi

if [ -z "${GH_TOKEN:-}" ]; then
  echo "::error::GH_TOKEN nao configurado. O orquestrador precisa do secret GH_AUTOMATION_TOKEN."
  exit 1
fi

deadline=$((SECONDS + timeout_seconds))
run_id=""
marker_dir="${RUNNER_TEMP:-/tmp}/oficina-dgcar-workflow-markers"
marker_file="$marker_dir/$(printf '%s_%s' "$repo" "$workflow" | tr '/.' '__').before"
previous_run_id=""

if [ -f "$marker_file" ]; then
  previous_run_id="$(cat "$marker_file")"
fi

while [ "$SECONDS" -lt "$deadline" ]; do
  run_id="$(gh run list \
    --repo "$repo" \
    --workflow "$workflow" \
    --event workflow_dispatch \
    --limit 10 \
    --json databaseId \
    -q ".[] | select((.databaseId | tostring) != \"$previous_run_id\") | .databaseId" | head -n 1)"

  if [ -n "$run_id" ]; then
    break
  fi

  echo "Aguardando criacao da execucao de $workflow em $repo."
  sleep "$poll_seconds"
done

if [ -z "$run_id" ]; then
  echo "::error::Nenhuma execucao workflow_dispatch encontrada para $workflow em $repo."
  exit 1
fi

echo "Acompanhando execucao $run_id de $workflow em $repo."

while [ "$SECONDS" -lt "$deadline" ]; do
  status="$(gh run view "$run_id" --repo "$repo" --json status -q '.status')"
  conclusion="$(gh run view "$run_id" --repo "$repo" --json conclusion -q '.conclusion // empty')"

  echo "$repo/$workflow run $run_id: status=$status conclusion=${conclusion:-aguardando}"

  if [ "$status" = "completed" ]; then
    if [ "$conclusion" = "success" ]; then
      exit 0
    fi

    gh run view "$run_id" --repo "$repo" --log-failed || true
    echo "::error::$repo/$workflow finalizou com conclusion=$conclusion."
    exit 1
  fi

  sleep "$poll_seconds"
done

echo "::error::Timeout aguardando $repo/$workflow run $run_id."
exit 1
