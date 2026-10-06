# Plano De Separação De Repositórios - Tech Challenge 3

## Objetivo

Este documento orienta a extração controlada do repositório atual da Oficina Mecânica DGCar para quatro repositórios especializados exigidos pelo Tech Challenge 3.

O repositório atual deve permanecer como origem histórica da evolução do projeto. A separação deve preservar rastreabilidade, evitar perda de documentação, pipelines e configurações, e manter relação explícita entre os artefatos extraídos e sua origem. A execução física da separação somente deve ocorrer após aprovação formal do plano, confirmação dos nomes dos repositórios e definição das estratégias operacionais de runtime, state, secrets e pipelines.

## Repositórios Alvo

## `oficina-dgcar-auth-lambda`

Responsabilidade:

- Lambda de autenticação por CPF.
- Validação de CPF.
- Consulta de cliente/status no PostgreSQL.
- Emissão de JWT de cliente externo.
- Testes automatizados.
- Pipeline de deploy.
- README próprio.

## `oficina-dgcar-infra-k8s`

Responsabilidade:

- Terraform do EKS.
- Terraform do ECR.
- API Gateway.
- Integração API Gateway -> aplicação no EKS.
- Integração API Gateway -> Lambda Auth CPF, quando aplicável.
- Manifests Kubernetes ou Kustomize/Helm.
- HPA, namespace, service, deployment base.
- Pipeline de infraestrutura Kubernetes.
- README próprio.

## `oficina-dgcar-infra-db`

Responsabilidade:

- Terraform do RDS PostgreSQL.
- Subnet group.
- Security groups de banco.
- Parâmetros do banco.
- Outputs necessários para aplicação, Lambda e infraestrutura K8s.
- Documentação de backup, sizing, conexão e segurança.
- Pipeline de infraestrutura de banco.
- README próprio.

## `oficina-dgcar-api`

Responsabilidade:

- Aplicação principal Spring Boot.
- Código Java.
- Dockerfile.
- Postman/Swagger.
- Testes automatizados.
- Pipeline build/test/scan/push/deploy.
- Documentação da API.
- Referência aos manifests ou integração com o repo `oficina-dgcar-infra-k8s`.
- README próprio.

## Matriz Origem/Destino

| Origem atual | Destino recomendado | Motivo | Observação |
|---|---|---|---|
| `src/**` | `oficina-dgcar-api` | Contém o código-fonte Java, testes, migrations Flyway e configuração da aplicação Spring Boot. | Deve ser extraído sem alteração funcional. As migrations permanecem com a aplicação por representarem versionamento do schema consumido pela API. |
| `pom.xml` | `oficina-dgcar-api` | Define build Maven, dependências, plugins, testes e empacotamento da aplicação. | Deve acompanhar o código Java e os testes automatizados. |
| `Dockerfile` | `oficina-dgcar-api` | Define a imagem da aplicação principal. | A pipeline da aplicação deve usar este artefato para build e publicação no ECR. |
| `docker-compose.yml` | `oficina-dgcar-api` | Apoia execução local da aplicação e banco de desenvolvimento. | Pode permanecer como recurso local de desenvolvimento; não substitui o banco gerenciado em nuvem. |
| `api-requests.http` | `oficina-dgcar-api` | Contém exemplos de consumo das APIs. | Deve ser mantido próximo ao contrato HTTP da aplicação. |
| `postman/**` | `oficina-dgcar-api` | Contém collections de validação funcional e fluxos de API. | Deve acompanhar Swagger/OpenAPI e documentação de endpoints. |
| `k8s/**` | `oficina-dgcar-infra-k8s` | Contém manifests Kubernetes, namespace, deployment, service, configmap, secret example, HPA e Kustomize. | Caso se decida por overlays mínimos no repo da aplicação, manter apenas referências ou overlays de release em `oficina-dgcar-api`; a base operacional deve ficar em `oficina-dgcar-infra-k8s`. |
| `infra/**` | `oficina-dgcar-infra-k8s` e `oficina-dgcar-infra-db` | A pasta concentra Terraform de infraestrutura compartilhada, exigindo separação por responsabilidade. | Recursos de EKS, ECR, API Gateway, IAM operacional do cluster, VPC compartilhada e integrações devem ir para `oficina-dgcar-infra-k8s`; recursos de RDS PostgreSQL, subnet group, security groups específicos do banco, parâmetros e outputs do banco devem ir para `oficina-dgcar-infra-db`. |
| `.github/workflows/app-cd.yml` | `oficina-dgcar-api` | Pipeline atual de build, testes, imagem Docker e deploy da aplicação. | Deve ser adaptada no repositório de destino para consumir outputs da infraestrutura e publicar imagem no registry definido. |
| `.github/workflows/infra.yml` | `oficina-dgcar-infra-k8s` e `oficina-dgcar-infra-db` | Pipeline atual de Terraform deve ser dividida por escopo de infraestrutura. | O fluxo de banco deve validar/aplicar RDS e outputs; o fluxo de K8s deve validar/aplicar EKS/ECR/API Gateway/manifests. |
| `docs/ADRS/**` | Referência central no repo histórico; cópia mínima nos quatro repositórios | ADRs registram decisões arquiteturais permanentes, muitas delas transversais. | Recomenda-se manter a fonte canônica inicialmente no repositório histórico e duplicar apenas ADRs diretamente necessárias em cada README, com link para a origem. |
| `docs/RFCS/**` | Referência central no repo histórico; cópia mínima nos quatro repositórios | RFCs explicam decisões técnicas e propostas de evolução. | Evitar divergência por duplicação integral. Usar referências relativas no repo histórico e links remotos após criação dos repositórios. |
| `docs/diagramas/**` | Referência central no repo histórico; cópia seletiva conforme responsabilidade | Diagramas C4, PlantUML e arquitetura cloud apoiam a visão transversal. | Diagramas específicos de API ficam com `oficina-dgcar-api`; diagramas de cloud e deploy podem ser referenciados por infra K8s e infra DB. |
| `docs/infraestrutura/**` | Referência central no repo histórico; cópia seletiva para `oficina-dgcar-infra-k8s` e `oficina-dgcar-infra-db` | Documenta operação, HPA, infraestrutura e este plano de separação. | Este plano permanece no repo histórico como documento orientador da extração. |
| `docs/requisitos/**` | `oficina-dgcar-api` com referência no repo histórico | Requisitos funcionais e não funcionais orientam comportamento da aplicação. | Pode ser referenciado pelos demais repositórios quando impactar autenticação, observabilidade ou infraestrutura. |
| `docs/ReportOWASP/**` | `oficina-dgcar-api` | Evidências de DAST estão associadas à superfície HTTP da aplicação. | Pode haver referência nos READMEs de segurança dos demais repositórios. |
| `docs/ReportTRIVY/**` | `oficina-dgcar-api` | Evidências de scan da imagem Docker pertencem à aplicação principal. | Scans futuros de imagens auxiliares devem ficar no repositório responsável por cada imagem. |
| `allure-report.ps1` | `oficina-dgcar-api` | Script de apoio à geração de relatório de testes da aplicação. | Deve acompanhar a suíte Maven e documentação de testes. |
| `README.md` | Base para README dos quatro repositórios e preservação no repo histórico | Contém visão geral, operação local, infraestrutura, testes e links documentais. | Deve ser decomposto em READMEs específicos, mantendo este README como referência histórica da transição. |

## Dependências Entre Repositórios

- `oficina-dgcar-infra-db` produz outputs consumidos por `oficina-dgcar-api`, `oficina-dgcar-auth-lambda` e `oficina-dgcar-infra-k8s`.
- `oficina-dgcar-auth-lambda` depende de conectividade com o banco, variáveis de ambiente, segredo de assinatura JWT e política de acesso aos dados de cliente.
- `oficina-dgcar-infra-k8s` depende da imagem publicada pela `oficina-dgcar-api` para atualizar deployments no cluster.
- `oficina-dgcar-api` depende do ECR/EKS, da URL do banco, das credenciais operacionais e dos contratos de rede disponibilizados pela infraestrutura.
- API Gateway depende da Lambda de autenticação e do backend da aplicação para roteamento de fluxos protegidos e públicos.

## Ordem Recomendada De Extração

1. Criar repositórios vazios com README base.
2. Extrair `oficina-dgcar-api`.
3. Extrair `oficina-dgcar-infra-db`.
4. Extrair `oficina-dgcar-infra-k8s`.
5. Criar `oficina-dgcar-auth-lambda`.
6. Ajustar pipelines por repositório.
7. Validar documentação cruzada.
8. Preservar o repositório atual como histórico.

## Estratégia De Branches E Proteção

- `main` deve ser protegida e representar a linha estável de produção.
- Pull Request deve ser obrigatório para qualquer merge em `main`.
- Checks obrigatórios devem incluir build, testes, validação Terraform, validação Kubernetes, lint ou análise equivalente conforme o repositório.
- A homologação deve usar branch dedicada, como `homolog`, ou environment dedicado no GitHub Actions.
- A produção deve ser promovida por merge em `main`, tag versionada ou release, conforme criticidade do repositório.
- GitHub Secrets devem ser segregados por repositório e por ambiente.
- GitHub Actions Environments devem controlar aprovações, secrets e histórico de deploy para homologação e produção.

## CI/CD Esperado Por Repositório

| Repositório | Pipeline PR | Pipeline homologação | Pipeline produção |
|---|---|---|---|
| `oficina-dgcar-auth-lambda` | Validar runtime, instalar dependências, executar testes, empacotar artefato e validar segurança básica. | Publicar versão em ambiente de homologação, configurar variáveis e validar endpoint de autenticação por CPF. | Publicar versão estável, atualizar alias/versão da Lambda e validar emissão de JWT. |
| `oficina-dgcar-infra-k8s` | Executar `terraform fmt`, `terraform validate`, plano sem apply e validação dos manifests Kubernetes. | Aplicar infraestrutura de homologação, atualizar manifests base e validar conectividade com API Gateway/EKS. | Aplicar infraestrutura de produção com aprovação de environment e evidência do plano Terraform. |
| `oficina-dgcar-infra-db` | Executar `terraform fmt`, `terraform validate` e plano sem apply para RDS, subnet group, security groups e parâmetros. | Provisionar ou atualizar banco de homologação e publicar outputs controlados. | Provisionar ou atualizar banco de produção com aprovação, backup configurado e outputs versionados. |
| `oficina-dgcar-api` | Executar build Maven, testes, cobertura, análise de segurança e build de imagem sem deploy. | Publicar imagem, atualizar deployment em homologação e validar healthcheck/Swagger. | Publicar imagem versionada, promover release e atualizar deployment de produção com rollout controlado. |

## README Mínimo Por Repositório

Cada repositório deve possuir README próprio contendo:

- Propósito e escopo do repositório.
- Tecnologias utilizadas.
- Variáveis de ambiente e GitHub Secrets necessários.
- Passos de execução local, quando aplicável.
- Passos de deploy.
- Diagrama da arquitetura específica do repositório.
- Links para Swagger/Postman ou endpoints, quando aplicável.
- Relação com os demais repositórios e dependências de entrada/saída.

## Cuidados De Rastreabilidade

- Preservar o histórico no repositório atual como referência da transição.
- Registrar commit e branch de origem usados em cada extração.
- Manter links entre ADRs/RFCs e os repositórios especializados.
- Evitar divergência entre documentação duplicada, definindo uma fonte canônica para decisões transversais.
- Manter o repositório atual como referência histórica até que os quatro repositórios estejam criados, revisados e operacionais.

## Critérios Para Executar A Separação Física

A separação física somente deve iniciar quando:

- Este plano for revisado e aprovado.
- Os nomes dos repositórios forem confirmados.
- O runtime da Lambda for escolhido.
- A estratégia de Terraform state for definida.
- A estratégia de secrets for definida.
- As pipelines mínimas forem acordadas.

## Decisões Documentadas

- A aplicação principal, seu Dockerfile, testes, Swagger/Postman e evidências de API devem compor `oficina-dgcar-api`.
- A infraestrutura Kubernetes, EKS, ECR, API Gateway e manifests devem compor `oficina-dgcar-infra-k8s`.
- A infraestrutura de RDS PostgreSQL deve compor `oficina-dgcar-infra-db`.
- A autenticação externa por CPF deve ser isolada em `oficina-dgcar-auth-lambda`.
- A documentação arquitetural transversal deve permanecer inicialmente centralizada no repositório histórico, com cópias mínimas e links nos repositórios especializados.
- A extração física depende de aprovação e não deve ocorrer como consequência automática deste documento.
