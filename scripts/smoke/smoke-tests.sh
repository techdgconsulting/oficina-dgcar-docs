#!/usr/bin/env bash
set -euo pipefail

gateway_url="${GATEWAY_BASE_URL:-}"
cpf="${CLIENT_TEST_CPF:-}"
password="${CLIENT_TEST_PASSWORD:-}"
os_number="${CLIENT_TEST_OS_NUMBER:-}"

missing=()
[ -z "$gateway_url" ] && missing+=("GATEWAY_BASE_URL")
[ -z "$cpf" ] && missing+=("CLIENT_TEST_CPF")
[ -z "$password" ] && missing+=("CLIENT_TEST_PASSWORD")
[ -z "$os_number" ] && missing+=("CLIENT_TEST_OS_NUMBER")

if [ "${#missing[@]}" -gt 0 ]; then
  echo "::error::Variaveis de smoke test ausentes: ${missing[*]}."
  exit 1
fi

auth_payload="$(jq -n --arg cpf "$cpf" --arg senha "$password" '{cpf: $cpf, senha: $senha}')"
auth_response="$(curl -fsS -X POST "$gateway_url/auth/cpf" -H 'Content-Type: application/json' -d "$auth_payload")"
token="$(printf '%s' "$auth_response" | jq -r '.accessToken // empty')"

if [ -z "$token" ]; then
  echo "::error::Autenticacao por CPF + senha nao retornou accessToken."
  printf '%s\n' "$auth_response"
  exit 1
fi

echo "Autenticacao por CPF + senha retornou JWT CLIENTE."

curl -fsS "$gateway_url/api/ordens-servico/numero/$os_number" \
  -H "Authorization: Bearer $token" >/dev/null
echo "Consulta protegida por numero de OS retornou sucesso."

status_without_token="$(curl -sS -o /tmp/no-token-response.txt -w '%{http_code}' "$gateway_url/api/ordens-servico/numero/$os_number")"
if [ "$status_without_token" != "401" ] && [ "$status_without_token" != "403" ]; then
  echo "::error::Consulta sem token retornou $status_without_token; esperado 401 ou 403."
  cat /tmp/no-token-response.txt
  exit 1
fi

echo "Consulta sem JWT foi bloqueada com HTTP $status_without_token."
