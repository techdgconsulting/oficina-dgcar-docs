# Evidencia - Gateway E API Protegida

Fluxo:

```text
CPF + senha -> API Gateway -> Lambda -> JWT CLIENTE -> API Gateway -> API Spring Boot
```

Chamadas esperadas:

```text
GET /api/ordens-servico/numero/OS-2026-00001
Authorization: Bearer <jwt-cliente>
```

Evidencias:

- chamada com token valido retorna `200`;
- chamada sem token retorna `401`;
- chamada para OS de outro CPF retorna `403`;
- tentativa de abrir OS com token `CLIENTE` retorna `403`.
