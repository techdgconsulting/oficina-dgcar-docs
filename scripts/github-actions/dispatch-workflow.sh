#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 --repo owner/repo --workflow file.yml --ref branch --field key=value [--field key=value ...]"
}

repo=""
workflow=""
ref="main"
fields=()

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
    --ref)
      ref="$2"
      shift 2
      ;;
    --field)
      fields+=("-f" "$2")
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

marker_dir="${RUNNER_TEMP:-/tmp}/oficina-dgcar-workflow-markers"
mkdir -p "$marker_dir"
marker_file="$marker_dir/$(printf '%s_%s' "$repo" "$workflow" | tr '/.' '__').before"

previous_run_id="$(gh run list \
  --repo "$repo" \
  --workflow "$workflow" \
  --event workflow_dispatch \
  --limit 1 \
  --json databaseId \
  -q '.[0].databaseId // empty')"

printf '%s' "$previous_run_id" > "$marker_file"

echo "Disparando $workflow em $repo na ref $ref."
gh workflow run "$workflow" --repo "$repo" --ref "$ref" "${fields[@]}"
