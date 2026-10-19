# ADR-008: Stack Tecnológico do Projeto

**Status:** Aceito  
**Data:** 2026-05-22  
**Revisão das dependências:** 2026-10-19
**Autor:** Diego Gonzalez  
**Contexto do Projeto:** Sistema de Oficina Mecânica DGCar - Pós-graduação FIAP

## Contexto

O projeto exige uma plataforma backend consolidada, com suporte a DDD tático, persistência relacional, segurança, documentação de API e cobertura de testes. As escolhas de linguagem, framework e bibliotecas de suporte precisam ser registradas e justificadas para garantir rastreabilidade das decisões.

> As decisões de PostgreSQL, JWT, Flyway, Docker e Gateway de Pagamento possuem ADRs dedicadas (ADR-003 a ADR-007). Esta ADR cobre o restante do stack não documentado anteriormente.

---

## Decisões

### 1. Linguagem: Java 17 (LTS)

**Decisão:** Java 17, versão LTS (Long-Term Support) da plataforma.

| Alternativa | Motivo da rejeição |
|-------------|-------------------|
| Java 21 (LTS) | Versão mais recente mas com suporte ainda em consolidação no ecossistema Spring Boot 3.x na época da decisão |
| Kotlin | Curva de aprendizado adicional; Java é a linguagem base do curso FIAP |
| Java 11 | LTS anterior; sem records, sealed classes e melhorias de switch |

**Consequências:** Records do Java 14+ usados em requests, commands e results imutáveis. `var` reduz verbosidade. Suporte garantido até 2029.

---

### 2. Framework: Spring Boot 4.0.8

**Decisão:** Spring Boot 4.0.8 como framework principal.

**Justificativas:**
- Autoconfiguração elimina XML e reduz boilerplate de infraestrutura
- Integração nativa com Spring Data JPA, Spring Security e Spring Web MVC
- Java 17 permanece definido no POM da aplicação
- Ecossistema maduro, amplamente adotado na indústria

| Alternativa | Motivo da rejeição |
|-------------|-------------------|
| Quarkus | Curva de aprendizado; menor adoção na academia |
| Micronaut | Idem |
| Spring Boot 2.x | Suporte encerrado; não compatível com Jakarta EE 9+ |

---

### 3. Build Tool: Maven

**Decisão:** Apache Maven com herança de `spring-boot-starter-parent`.

**Justificativas:**
- Gerenciamento de versões de dependências via BOM do Spring Boot (evita conflitos)
- Ampla adoção e documentação consolidada
- Integração nativa com IDEs e CI/CD

| Alternativa | Motivo da rejeição |
|-------------|-------------------|
| Gradle | Sintaxe mais flexível mas com maior complexidade de configuração para iniciantes |

---

### 4. Redução de Boilerplate: Lombok

**Decisão:** Project Lombok para geração de código em tempo de compilação.

**Anotações utilizadas:**

| Anotação | Uso |
|----------|-----|
| `@Getter` | Gera getters para todos os campos |
| `@Builder` | Padrão Builder para construção de objetos |
| `@NoArgsConstructor(access = PROTECTED)` | Construtor protegido exigido pelo JPA |
| `@AllArgsConstructor` | Construtor com todos os campos (Builder) |
| `@RequiredArgsConstructor` | Injeção de dependências via construtor em controllers, use cases e adapters |
| `@Slf4j` | Logger SLF4J injetado automaticamente |
| `@EqualsAndHashCode` | Value Objects (CpfCnpj, Placa, Quantidade) |

**Consequências:** Código de domínio mais limpo e focado em regras de negócio. Lombok é excluído do artefato final (`<optional>true</optional>`).

---

### 5. Documentação de API: SpringDoc OpenAPI 3.0.3

**Decisão:** `springdoc-openapi-starter-webmvc-ui` versão 3.0.3 para geração automática do contrato OpenAPI e interface Swagger UI.

**Acesso em desenvolvimento:** `http://localhost:8080/swagger-ui.html`

**Justificativas:**
- Geração automática a partir das anotações `@RestController` e `@RequestMapping`
- `@Operation` e `@Tag` enriquecem a documentação sem overhead de manutenção
- A linha SpringDoc 3.x acompanha a migração da aplicação para Spring Boot 4.x

| Alternativa | Motivo da rejeição |
|-------------|-------------------|
| Springfox | Descoontinuado; incompatível com Spring Boot 3 |
| Documentação manual (Postman/YAML) | Existe como complemento (`postman/`), não como substituto |

---

### 6. Biblioteca JWT: JJWT 0.12.6

**Decisão:** `io.jsonwebtoken:jjwt-api/impl/jackson` versão 0.12.6 como implementação da geração e validação de tokens JWT.

> A estratégia JWT (stateless, HMAC-SHA256) está documentada em **ADR-004**.

**Justificativas:**
- API fluente e tipada para criação de claims e parsing
- Suporte a HMAC-SHA256 (`HS256`) com chave segura de 256 bits
- Versão 0.12.x reescrita com API simplificada em relação à 0.11.x

---

### 7. Cobertura de Testes: JaCoCo 0.8.12

**Decisão:** JaCoCo Maven Plugin versão 0.8.12 para coleta e relatório de cobertura de código.

**Configuração:**
- Relatório gerado em `target/site/jacoco/` a cada `mvn test`
- Exclusão configurada: `OficinaMecanicaDGCARApplication` (ponto de entrada)

**Justificativas:**
- Integrado ao ciclo `test` do Maven sem configuração adicional
- Relatório HTML navegável por classe e linha
- Padrão de mercado para projetos Java/Maven

---

### 8. Testes de Integração com PostgreSQL: Testcontainers

**Decisão:** manter `org.testcontainers:testcontainers-junit-jupiter` + `org.testcontainers:testcontainers-postgresql` declarados como dependências de teste para evolução futura da suíte com PostgreSQL real em container Docker.

**Justificativas:**
- Elimina dependência de banco de dados externo quando testes de integração com PostgreSQL forem adicionados
- PostgreSQL real no teste aumenta fidelidade com o ambiente principal em comparação ao H2
- Integração com JUnit Jupiter via `@Testcontainers` + `@Container`

**Estado atual:** a suíte automatizada atual não usa Testcontainers; os testes rodam com H2 em memória no perfil `test`. O uso de Testcontainers permanece como extensão planejada para cenários de CI/CD que precisem validar migrations, constraints e dialeto PostgreSQL.

| Alternativa | Motivo da rejeição |
|-------------|-------------------|
| H2 em modo compatibilidade | Dialeto PostgreSQL incompleto; comportamentos divergentes em constraints e tipos |
| Banco externo fixo | Cria dependência de infraestrutura externa; não reprodutível em CI |

---

### 9. Relatórios de Teste: Allure 2.27.0

**Decisão:** `io.qameta.allure:allure-junit5` versão 2.27.0 + `allure-maven` plugin 2.12.0 para geração de relatórios de testes enriquecidos.

**Justificativas:**
- Relatórios HTML navegáveis com agrupamento por `@Epic`, `@Feature` e `@Story`
- Integração com JUnit Jupiter via anotações declarativas nos testes
- Geração automática junto ao ciclo `mvn test` via maven-surefire-plugin

---

### 10. Banco In-Memory para Dev Local: H2

**Decisão:** H2 Database em `scope runtime` como banco alternativo para execução local sem Docker e para a suíte automatizada atual.

**Escopo:** perfis `dev` e `test`, ambos com schema recriado pelo Hibernate (`ddl-auto=create-drop`) e Flyway desabilitado, conforme `application.yml`.

---

### 11. Notificações por E-mail: Spring Mail / SMTP

**Decisão:** `spring-boot-starter-mail` como infraestrutura de envio de e-mail, isolada pela porta `EmailNotificacaoPort`.

**Justificativas:**
- Permite envio real por SMTP sem acoplar a camada de aplicação ao Spring Mail.
- Mantém a Clean Architecture: use cases dependem de `EmailNotificacaoPort`, e a infraestrutura escolhe o adapter ativo.
- Suporta execução local em modo `LOG`, envio real em modo `SMTP` e desativação controlada por configuração.
- Atende ao requisito de comunicação informativa ao cliente sobre mudanças de status da OS e ao fluxo de decisão externa de orçamento.

**Configuração atual:**
- `OFICINA_EMAIL_MODE=LOG`: registra destinatário, assunto e corpo em log, sem envio real.
- `OFICINA_EMAIL_MODE=SMTP`: envia e-mail real via `JavaMailSender`.
- `OFICINA_EMAIL_ENABLED=false`: ignora notificações de forma explícita, sem quebrar transições da OS.

| Alternativa | Motivo da rejeição |
|-------------|-------------------|
| Envio direto no use case com `JavaMailSender` | Acoplaria a aplicação ao framework de infraestrutura |
| AWS SES direto nesta etapa | Exige configuração de domínio/e-mail verificado e credenciais AWS; fica como evolução natural para implantação em nuvem |
| Apenas log/mock | Suficiente para testes locais, mas não atende ao requisito de envio real por SMTP |

---

### 12. Infraestrutura e Deploy: Terraform, Kubernetes, AWS e GitHub Actions

**Decisão:** manter a definição de infraestrutura e deploy versionada no repositório, usando Terraform para provisionamento AWS, Kubernetes para execução da aplicação, Amazon EKS como cluster gerenciado, Amazon ECR para imagens Docker, Amazon RDS PostgreSQL para banco gerenciado, Amazon S3 para backend remoto do Terraform state e GitHub Actions para CI/CD.

> Os fundamentos da infraestrutura estão em [ADR-019](ADR-019-infraestrutura-aws-terraform-kubernetes.md). Esta ADR resume a escolha do stack; parâmetros e procedimentos atuais são mantidos nas ADRs específicas e nos READMEs técnicos indicados naquele registro.

**Justificativas:**
- Terraform permite provisionamento reprodutível da infraestrutura AWS.
- Kubernetes/EKS padroniza execução, exposição, health checks e escalabilidade da aplicação.
- ECR centraliza imagens Docker versionadas e consumidas pelo cluster.
- RDS PostgreSQL aproxima o ambiente em nuvem do banco relacional principal definido na ADR-003.
- S3 como backend remoto preserva o `terraform.tfstate` entre execuções locais e pipelines.
- GitHub Actions separa o provisionamento completo manual em infra-k8s (`provision-homolog.yml`/`provision-prod.yml`) do deploy da API (`app-cd.yml`). Banco e Lambda usam seus próprios workflows por dispatch. `infra.yml` é a referência histórica anterior à separação dos repositórios.

**Configuração atual:**
- Terraform `>= 1.6.0`
- Provider AWS `~> 5.0`
- Cluster Kubernetes gerenciado por Amazon EKS
- Imagem Docker publicada no Amazon ECR
- Banco da aplicação em Amazon RDS PostgreSQL
- State remoto do Terraform em Amazon S3
- CI/CD com GitHub Actions

---

## Revisão de dependências após análise Trivy

A revisão de 19/10/2026 reflete a configuração local do [POM da API](https://github.com/techdgconsulting/oficina-dgcar-api/blob/homolog/pom.xml). A migração substitui a configuração anterior com Spring Boot 3.5.16 e SpringDoc 2.8.17. A data original da ADR registra a decisão inicial.

| Componente | Configuração atual no POM |
|---|---|
| Spring Boot parent | `4.0.8` |
| Jackson BOM principal | `3.1.7` (`jackson-bom.version`) |
| Jackson 2 BOM | `2.22.3` (`jackson-2-bom.version`) |
| Tomcat | `11.0.27` (`tomcat.version`) |
| SpringDoc OpenAPI | `3.0.3` |
| Apache Commons Lang | `3.18.0` (`commons-lang3.version`) |
| Driver JDBC PostgreSQL | `42.7.12` (`postgresql.version`) |

Os BOMs Jackson 3 e Jackson 2 gerenciam as dependências das respectivas linhas. O starter web passa a ser `spring-boot-starter-webmvc`; a integração Flyway usa `spring-boot-starter-flyway` e `flyway-database-postgresql`. Os starters de testes e artefatos Testcontainers atuais estão na [ADR-009](ADR-009-estrategia-testes.md).

O parent e os overrides do POM determinam as versões gerenciadas. O escopo e as evidências das varreduras estão na [ADR-012](ADR-012-varreduras-seguranca-owasp-zap-trivy.md).

## Resumo do Stack

| Camada | Tecnologia | Versão |
|--------|-----------|--------|
| Linguagem | Java | 17 (LTS) |
| Framework | Spring Boot | 4.0.8 |
| Build | Maven | (spring-boot-starter-parent) |
| Web | Spring Web MVC | (managed) |
| Persistência | Spring Data JPA / Hibernate | (managed) |
| Segurança | Spring Security | (managed) |
| JWT | JJWT | 0.12.6 |
| Banco Produção | PostgreSQL | 16 (ADR-003) |
| Banco Dev | H2 | (managed) |
| Migrations | Flyway | (managed + ADR-005) |
| Boilerplate | Lombok | (managed) |
| Documentação API | SpringDoc OpenAPI | 3.0.3 |
| Cobertura | JaCoCo | 0.8.12 |
| Relatórios de Teste | Allure | 2.27.0 |
| Testes Integração | Testcontainers | Declarado para evolução futura |
| E-mail | Spring Mail / SMTP | (managed) |
| Containerização | Docker / Docker Compose | (ADR-006) |
| Infraestrutura como Código | Terraform + AWS Provider | Terraform >= 1.6.0 / AWS Provider ~> 5.0 |
| Kubernetes | Kubernetes + Amazon EKS + Kustomize | (ADR-019) |
| Cloud AWS | EKS, ECR, RDS PostgreSQL, S3, IAM, VPC e Security Groups | (ADR-019) |
| CI/CD | GitHub Actions | Workflows por repositório; gatilhos nos READMEs técnicos |
