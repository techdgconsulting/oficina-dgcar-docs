# Evidencia - Autenticacao CPF E Senha

Endpoint:

```text
POST /auth/cpf
```

Payload:

```json
{
  "cpf": "52398614808",
  "senha": "Cliente@123"
}
```

Evidencias:

- resposta `200 OK`;
- `tokenType=Bearer`;
- `accessToken` preenchido;
- JWT decodificado com `tipo=CLIENTE`;
- JWT com `sub` contendo CPF normalizado;
- erro `400` sem senha;
- erro `401` com senha incorreta.
