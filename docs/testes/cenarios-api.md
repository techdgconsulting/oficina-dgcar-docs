# Cenários executados na API

Inventário dos XMLs Surefire do artefato `test-reports` da [execução da CI](https://github.com/techdgconsulting/oficina-dgcar-api/actions/runs/39315344562), revisão `8a50bf0`. São **402 casos em 56 suítes**, todos aprovados. Os nomes são preservados como aparecem no relatório, incluindo invocações parametrizadas.

[Resultados e cobertura JaCoCo](README.md).

## AuthControllerTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/adapters/in/web/controller/AuthControllerTest.java) — **7 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `deveRegistrar` — aprovado.
- `registroDuplicado_retornaBadRequest` — aprovado.
- `registrarComRoleInvalida_retorna400` — aprovado.
- `deveLogar` — aprovado.
- `loginSemCampos_retorna400` — aprovado.
- `loginComCredenciaisInvalidas_retorna401` — aprovado.
- `deveRegistrarComRoleExplicita` — aprovado.

</details>

## ClienteControllerTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/adapters/in/web/controller/ClienteControllerTest.java) — **14 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `excluirClienteComVeiculos_retorna422` — aprovado.
- `excluirClienteNaoEncontrado_retorna404` — aprovado.
- `deveAtualizar` — aprovado.
- `deveBuscarPorId` — aprovado.
- `semAutenticacao_retorna401` — aprovado.
- `deveExcluir` — aprovado.
- `deveListarTodos` — aprovado.
- `clienteNaoEncontrado_retorna404` — aprovado.
- `buscarPorDocumentoNaoEncontrado_retorna404` — aprovado.
- `atualizarClienteNaoEncontrado_retorna404` — aprovado.
- `excluirClienteComOrdensDeServico_retorna422` — aprovado.
- `deveBuscarPorDocumento` — aprovado.
- `deveCriarCliente` — aprovado.
- `criarClienteComDocumentoDuplicado_retorna422` — aprovado.

</details>

## GlobalExceptionHandlerTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/adapters/in/web/controller/GlobalExceptionHandlerTest.java) — **19 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `handleEntityNotFound_retorna404` — aprovado.
- `handleJsonInvalido_retorna400` — aprovado.
- `handleNoResource_retorna404` — aprovado.
- `handleBindException_retorna400` — aprovado.
- `handleMediaTypeNotSupported_retorna415` — aprovado.
- `handleMissingPathVariable_retorna400` — aprovado.
- `handleBadCredentials_retorna401` — aprovado.
- `handleMethodNotSupported_retorna405` — aprovado.
- `handleIllegalArg_retorna400` — aprovado.
- `handleConstraintViolation_retorna400` — aprovado.
- `handleGenerico_retorna500` — aprovado.
- `handleTypeMismatch_retorna400` — aprovado.
- `handleDataIntegrity_retorna400` — aprovado.
- `handleMissingRequestParameter_retorna400` — aprovado.
- `handleIllegalState_retorna409` — aprovado.
- `handleNegocio_retorna422` — aprovado.
- `handleDocumentoInvalido_retorna422` — aprovado.
- `handleMediaTypeNotAcceptable_retorna406` — aprovado.
- `handleNotFound_retorna404` — aprovado.

</details>

## OrcamentoDecisaoClienteControllerTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/adapters/in/web/controller/OrcamentoDecisaoClienteControllerTest.java) — **2 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `deveAprovarOrcamentoPorTokenSemJwt` — aprovado.
- `deveRecusarOrcamentoPorTokenSemJwt` — aprovado.

</details>

## OrdemDeServicoControllerTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/adapters/in/web/controller/OrdemDeServicoControllerTest.java) — **37 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `deveConsultarStatusPorId` — aprovado.
- `deveCriarOSCompleta` — aprovado.
- `deveBloquearCriacaoOSCompletaPorClienteExterno` — aprovado.
- `deveListarFilaOperacional` — aprovado.
- `mecanicoPodefazerDiagnostico` — aprovado.
- `statusPorNumeroSemTokenRetorna401` — aprovado.
- `deveAdicionarItensNaOS` — aprovado.
- `tempoMedioExecucaoSemDados` — aprovado.
- `illegalArgument_retorna400` — aprovado.
- `listarFilaSemAutenticacao_retorna401` — aprovado.
- `deveListarPorStatus` — aprovado.
- `gerarOrcamento` — aprovado.
- `deveEntregarVeiculo` — aprovado.
- `registrarPagamento` — aprovado.
- `deveBuscarPorId` — aprovado.
- `semAutenticacao_retorna401` — aprovado.
- `clienteRejeitaOrcamento` — aprovado.
- `clienteDeveConsultarStatusDaPropriaOSPorNumero` — aprovado.
- `osNaoEncontrada_retorna404` — aprovado.
- `deveRetornarMetricasOS` — aprovado.
- `clienteAprovaOrcamento` — aprovado.
- `clienteNaoDeveConsultarStatusDeOutroClientePorNumero` — aprovado.
- `erroGenerico_retorna500` — aprovado.
- `clienteDeveConsultarPropriaOSPorNumero` — aprovado.
- `iniciarDiagnosticoTransicaoInvalida_retorna409` — aprovado.
- `deveListarTodas` — aprovado.
- `tempoMedioExecucao` — aprovado.
- `finalizarServico` — aprovado.
- `iniciarDiagnostico` — aprovado.
- `clienteNaoDeveConsultarOSDeOutroClientePorNumero` — aprovado.
- `deveBuscarPorNumero` — aprovado.
- `erroNegocio_retorna422` — aprovado.
- `mecanicoNaoPodeAbrirOS_retorna403` — aprovado.
- `deveNotificarClienteSobreOrcamento` — aprovado.
- `atendenteNaoPodeIniciarDiagnostico_retorna403` — aprovado.
- `clienteConsultaOS` — aprovado.
- `deveCriarOS` — aprovado.

</details>

## PecaControllerTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/adapters/in/web/controller/PecaControllerTest.java) — **16 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `deveBaixarEstoque` — aprovado.
- `pecaNaoEncontrada_retorna404` — aprovado.
- `estoqueBaixo` — aprovado.
- `pecaNaoEncontradaAoAtualizar_retorna404` — aprovado.
- `deveRejeitarPayloadSuspeitoAoCriar` — aprovado.
- `deveAtualizar` — aprovado.
- `semAutenticacao_retorna401` — aprovado.
- `deveExcluir` — aprovado.
- `deveCriar` — aprovado.
- `deveBuscar` — aprovado.
- `deveListar` — aprovado.
- `deveSanitizarPayloadSuspeitoNoEstoqueBaixo` — aprovado.
- `pecaNaoEncontradaAoExcluir_retorna404` — aprovado.
- `atendenteNaoPodeGerirPecas_retorna403` — aprovado.
- `deveSanitizarPayloadSuspeitoNaListagem` — aprovado.
- `deveReporEstoque` — aprovado.

</details>

## SanitizedErrorControllerTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/adapters/in/web/controller/SanitizedErrorControllerTest.java) — **9 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `encaminhamentoDeErroSemStatusPreservaFalhaInterna` — aprovado.
- `erroPadrao404NaoExpoePath` — aprovado.
- `acessoDiretoNaoRepresentaFalhaInterna(String)[1]` — aprovado.
- `acessoDiretoNaoRepresentaFalhaInterna(String)[2]` — aprovado.
- `acessoDiretoNaoRepresentaFalhaInterna(String)[3]` — aprovado.
- `acessoDiretoNaoRepresentaFalhaInterna(String)[4]` — aprovado.
- `acessoDiretoNaoRepresentaFalhaInterna(String)[5]` — aprovado.
- `acessoDiretoHeadRetorna404` — aprovado.
- `erroPadraoNaoExpoeCamposSensiveis` — aprovado.

</details>

## ServicoControllerTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/adapters/in/web/controller/ServicoControllerTest.java) — **11 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `deveRejeitarPayloadSuspeitoAoCriar` — aprovado.
- `deveAtualizar` — aprovado.
- `servicoNaoEncontrado_retorna404` — aprovado.
- `servicoNaoEncontradoAoAtualizar_retorna404` — aprovado.
- `semAutenticacao_retorna401` — aprovado.
- `deveExcluir` — aprovado.
- `deveCriar` — aprovado.
- `deveBuscar` — aprovado.
- `deveListar` — aprovado.
- `deveSanitizarPayloadSuspeitoNaListagem` — aprovado.
- `servicoNaoEncontradoAoExcluir_retorna404` — aprovado.

</details>

## VeiculoControllerTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/adapters/in/web/controller/VeiculoControllerTest.java) — **12 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `veiculoNaoEncontradoAoExcluir_retorna404` — aprovado.
- `deveAtualizar` — aprovado.
- `clienteNaoEncontradoAoCriarVeiculo_retorna404` — aprovado.
- `placaDuplicada_retorna422` — aprovado.
- `semAutenticacao_retorna401` — aprovado.
- `deveExcluir` — aprovado.
- `deveCriar` — aprovado.
- `deveListarPorCliente` — aprovado.
- `deveBuscar` — aprovado.
- `deveListar` — aprovado.
- `veiculoNaoEncontradoAoAtualizar_retorna404` — aprovado.
- `veiculoNaoEncontrado_retorna404` — aprovado.

</details>

## DisabledEmailNotificacaoAdapterTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/adapters/out/notification/DisabledEmailNotificacaoAdapterTest.java) — **1 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `deveIgnorarEnvioQuandoEmailEstaDesativado` — aprovado.

</details>

## SmtpEmailNotificacaoAdapterTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/adapters/out/notification/SmtpEmailNotificacaoAdapterTest.java) — **1 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `deveEnviarEmailUsandoJavaMailSender` — aprovado.

</details>

## MockPagamentoGatewayTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/adapters/out/payment/MockPagamentoGatewayTest.java) — **3 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `deveRecusarQuandoTaxaForZero` — aprovado.
- `deveAprovarQuandoTaxaForUm` — aprovado.
- `deveGerarTransactionIdUnicoPorChamada` — aprovado.

</details>

## BusinessDashboardMigrationTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/adapters/out/persistence/BusinessDashboardMigrationTest.java) — **1 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `migraBancoExistentePreservandoDatasECompletandoSomenteMassaOriginal` — aprovado.

</details>

## PersistenceMapperCoverageTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/adapters/out/persistence/mapper/PersistenceMapperCoverageTest.java) — **2 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `mapearEntidadesJpaEDominioNosDoisSentidos` — aprovado.
- `ordemDeServicoMapperPreservaVinculoDoItemJpaComAOrdem` — aprovado.

</details>

## OrdemDeServicoPersistenceTransactionTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/adapters/out/persistence/OrdemDeServicoPersistenceTransactionTest.java) — **1 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `deveMapearItensSemTransacaoNoChamadorComoNoAgendador` — aprovado.

</details>

## PersistenceAdapterCoverageTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/adapters/out/persistence/PersistenceAdapterCoverageTest.java) — **1 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `adaptersDelegamParaRepositoriosEMapeiamResultados` — aprovado.

</details>

## JwtTokenProviderAdapterTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/adapters/out/security/JwtTokenProviderAdapterTest.java) — **8 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `deveValidarTokenExternoDeCliente` — aprovado.
- `tokenNuloRetornaFalse` — aprovado.
- `tokenInvalidoRetornaFalse` — aprovado.
- `deveExtrairRole` — aprovado.
- `deveExtrairUsername` — aprovado.
- `deveRejeitarTokenExternoComAudienceInvalida` — aprovado.
- `chavesCurtas_devemSerPaddedPara256bits` — aprovado.
- `deveGerarEValidarToken` — aprovado.

</details>

## ApplicationExceptionTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/application/exception/ApplicationExceptionTest.java) — **1 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `devePreservarMensagemDasExcecoesDeAplicacao` — aprovado.

</details>

## ClienteUseCaseTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/application/usecase/ClienteUseCaseTest.java) — **15 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `naoDeveExcluirClienteComVeiculos` — aprovado.
- `deveLancarExcecaoQuandoNaoEncontrar` — aprovado.
- `naoDeveCriarClienteDuplicado` — aprovado.
- `naoDeveAtualizarClienteInexistente` — aprovado.
- `naoDeveBuscarPorDocumentoInexistente` — aprovado.
- `deveExcluirCliente` — aprovado.
- `deveBuscarPorId` — aprovado.
- `deveCriarClienteComSucesso` — aprovado.
- `deveListarTodos` — aprovado.
- `naoDeveExcluirClienteInexistente` — aprovado.
- `deveBuscarPorDocumento` — aprovado.
- `deveCriarClienteSemCep` — aprovado.
- `deveCriarClienteComCepInvalido` — aprovado.
- `deveAtualizarCliente` — aprovado.
- `naoDeveExcluirClienteComOrdensDeServico` — aprovado.

</details>

## CriarOrdemServicoCompletaUseCaseTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/application/usecase/CriarOrdemServicoCompletaUseCaseTest.java) — **3 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `deveRejeitarVeiculoVinculadoAOutroCliente` — aprovado.
- `deveCriarOSCompletaComClienteEVeiculoNovos` — aprovado.
- `deveReaproveitarClienteEVeiculoExistentes` — aprovado.

</details>

## NotificarStatusOrdemServicoUseCaseTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/application/usecase/NotificarStatusOrdemServicoUseCaseTest.java) — **12 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `deveMapearMensagemAmigavelPorStatus(String, String)[1]` — aprovado.
- `deveMapearMensagemAmigavelPorStatus(String, String)[2]` — aprovado.
- `deveMapearMensagemAmigavelPorStatus(String, String)[3]` — aprovado.
- `deveMapearMensagemAmigavelPorStatus(String, String)[4]` — aprovado.
- `deveMapearMensagemAmigavelPorStatus(String, String)[5]` — aprovado.
- `deveMapearMensagemAmigavelPorStatus(String, String)[6]` — aprovado.
- `deveMapearMensagemAmigavelPorStatus(String, String)[7]` — aprovado.
- `deveMapearMensagemAmigavelPorStatus(String, String)[8]` — aprovado.
- `deveEnviarEmailInformativoComStatusAtualELinkDeConsulta` — aprovado.
- `naoDeveEnviarEmailQuandoClientePossuiEmailEmBranco` — aprovado.
- `naoDeveEnviarEmailQuandoClienteNaoPossuiEmailCadastrado` — aprovado.
- `deveUsarSaudacaoGenericaQuandoNomeNaoInformado` — aprovado.

</details>

## OrcamentoDecisaoClienteUseCaseTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/application/usecase/OrcamentoDecisaoClienteUseCaseTest.java) — **6 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `deveRetornarLinksMesmoQuandoEnvioDeEmailFalhar` — aprovado.
- `deveAprovarPorTokenValido` — aprovado.
- `deveBloquearTokenInexistente` — aprovado.
- `deveBloquearTokenExpirado` — aprovado.
- `deveRecusarPorTokenValido` — aprovado.
- `deveEnviarNotificacaoGerandoTokenHashELinks` — aprovado.

</details>

## OrdemDeServicoUseCaseTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/application/usecase/OrdemDeServicoUseCaseTest.java) — **19 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `deveCriarOSComItens` — aprovado.
- `medeApenasTempoDoStatusAnteriorENaoIdadeDaOs` — aprovado.
- `deveGerarOrcamento` — aprovado.
- `deveBuscarEListar` — aprovado.
- `deveCalcularMetricasSemEntrega` — aprovado.
- `deveTraduzirTransicaoInvalidaAoAprovarOrcamentoParaNegocioException` — aprovado.
- `deveFinalizarERegistrarPagamento` — aprovado.
- `deveIniciarDiagnostico` — aprovado.
- `deveFormatarDuracaoComHorasEMinutos` — aprovado.
- `deveAprovarOrcamentoComBaixaEstoque` — aprovado.
- `naoAvancaDiagnosticoSemMecanicoValido` — aprovado.
- `deveRetornarZeroParaTempoMedioVazio` — aprovado.
- `naoDeveCriarOSSemCliente` — aprovado.
- `naoDeveGerarOrcamentoEmStatusInvalido` — aprovado.
- `criaExecucaoAusenteComMecanicoAntesDeAvancarDiagnostico` — aprovado.
- `deveLancarErroQuandoGatewayRecusaPagamento` — aprovado.
- `naoDeveGerarOrcamentoSemItens` — aprovado.
- `deveCalcularMetricasETempoMedio` — aprovado.
- `deveCriarOS` — aprovado.

</details>

## PagamentoUseCaseTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/application/usecase/PagamentoUseCaseTest.java) — **6 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `aprovarPagamentoPendente` — aprovado.
- `rejeitaPagamentoInexistente` — aprovado.
- `recusarPagamentoPendente` — aprovado.
- `dominioImpedeReprocessarPagamento` — aprovado.
- `processarPagamentoRecusadoNoGateway` — aprovado.
- `processarPagamentoAprovadoNoGateway` — aprovado.

</details>

## PecaUseCaseTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/application/usecase/PecaUseCaseTest.java) — **12 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `listarTodas` — aprovado.
- `listarEstoqueBaixo` — aprovado.
- `reporEstoque` — aprovado.
- `criarPecaSemEstoqueMinimo` — aprovado.
- `buscar` — aprovado.
- `excluir` — aprovado.
- `verificarDisponibilidade` — aprovado.
- `buscarNaoExiste` — aprovado.
- `criarPeca` — aprovado.
- `atualizarComNovaQuantidade` — aprovado.
- `baixarEstoque` — aprovado.
- `atualizarSemQuantidade` — aprovado.

</details>

## ServicoUseCaseTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/application/usecase/ServicoUseCaseTest.java) — **6 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `deveAtualizar` — aprovado.
- `deveBuscarPorId` — aprovado.
- `deveExcluir` — aprovado.
- `deveCriar` — aprovado.
- `deveListar` — aprovado.
- `buscarInexistente_lanca` — aprovado.

</details>

## UseCaseCoverageTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/application/usecase/UseCaseCoverageTest.java) — **1 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `useCasesComPortasMockadasExecutamFluxosPrincipais` — aprovado.

</details>

## UseCaseEdgeCoverageTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/application/usecase/UseCaseEdgeCoverageTest.java) — **7 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `processarPagamentoCobreAprovacaoRecusaEInexistente` — aprovado.
- `servicoUseCasesCobremAtualizacaoExclusaoEInexistentes` — aprovado.
- `useCasesSimplesCobremCaminhosNaoEncontrados` — aprovado.
- `registrarDiagnosticoCobreSucessoEExecucaoInexistente` — aprovado.
- `execucaoEntregaEncerramentoEOrcamentoDiretosCobremSucessoEInexistentes` — aprovado.
- `pecaUseCasesCobremAtualizacaoEstoqueDisponibilidadeEInexistentes` — aprovado.
- `autenticarLoginCobreCredenciaisInvalidasESucesso` — aprovado.

</details>

## UseCaseMapperCoverageTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/application/usecase/UseCaseMapperCoverageTest.java) — **1 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `mappersConvertemDominioParaResults` — aprovado.

</details>

## VeiculoUseCaseTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/application/usecase/VeiculoUseCaseTest.java) — **10 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `listarTodos` — aprovado.
- `buscarInexistente` — aprovado.
- `naoDeveCriarVeiculoComPlacaDuplicada` — aprovado.
- `naoDeveExcluirVeiculoComOrdemDeServicoVinculada` — aprovado.
- `excluir` — aprovado.
- `criarSemCliente_deveFalhar` — aprovado.
- `atualizar` — aprovado.
- `buscarPorId` — aprovado.
- `listarPorCliente` — aprovado.
- `criarVeiculo` — aprovado.

</details>

## AdapterAndDomainCoverageTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/coverage/AdapterAndDomainCoverageTest.java) — **9 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `usuarioValidaCamposObrigatoriosERole` — aprovado.
- `secureTokenGeraTokenEHashDeterministico` — aprovado.
- `emailLogAdapterAceitaMensagem` — aprovado.
- `pagamentoValidaCriacaoETransicoesInvalidas` — aprovado.
- `passwordHasherDelegaParaEncoder` — aprovado.
- `execucaoValidaEstadosObrigatorios` — aprovado.
- `decisaoClienteValidaTransicoesEExpiracao` — aprovado.
- `viaCepRetornaEnderecoETrataEntradasInvalidas` — aprovado.
- `orcamentoDecisaoPersistenceAdapterMapeiaOperacoes` — aprovado.

</details>

## StructuralCoverageTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/coverage/StructuralCoverageTest.java) — **1 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `recordsEntitiesAndConfigurationBeansRemainInstantiable` — aprovado.

</details>

## DiagnosticoTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/domain/model/DiagnosticoTest.java) — **7 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `naoIniciarDuasVezes` — aprovado.
- `deveIniciar` — aprovado.
- `concluir` — aprovado.
- `naoConcluirSemIniciar` — aprovado.
- `naoIdentificarSemIniciar` — aprovado.
- `deveComecarPendente` — aprovado.
- `identificarProblema` — aprovado.

</details>

## EncerramentoTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/domain/model/EncerramentoTest.java) — **3 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `deveCriarComStatusPendente` — aprovado.
- `naoDeveEncerrarDuasVezes` — aprovado.
- `deveEncerrar` — aprovado.

</details>

## EntregaTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/domain/model/EntregaTest.java) — **10 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `naoDeveEntregarSemLiberar` — aprovado.
- `deveRegistrarEmPatio` — aprovado.
- `deveCriarComStatusAguardandoLiberacao` — aprovado.
- `naoDeveLiberarSeJaLiberado` — aprovado.
- `naoDeveRegistrarEmPatioSemLiberar` — aprovado.
- `deveEntregarVeiculo` — aprovado.
- `fluxoCompleto` — aprovado.
- `deveRetirarDoPatio` — aprovado.
- `naoDeveRetirarDoPatioSemEstarNoPatio` — aprovado.
- `deveLiberarVeiculo` — aprovado.

</details>

## ExecucaoTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/domain/model/ExecucaoTest.java) — **9 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `fluxoCompletoComDiagnostico` — aprovado.
- `naoDiagnosticaSeJaEmAndamento` — aprovado.
- `naoIniciarServicoPorqueJaFinalizado` — aprovado.
- `deveCriarComStatusAguardando` — aprovado.
- `naoFinalizaSemIniciar` — aprovado.
- `tempoExecucaoComDataFimPreenchida` — aprovado.
- `podeIniciarServicoDiretoDeAguardando` — aprovado.
- `tempoExecucaoPositivoAposInicio` — aprovado.
- `tempoExecucaoZeroSemInicio` — aprovado.

</details>

## OrcamentoTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/domain/model/OrcamentoTest.java) — **12 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `naoDeveRejeitarSemEnviar` — aprovado.
- `naoDeveEnviarDuasVezes` — aprovado.
- `deveGerarOrcamentoComStatusPendente` — aprovado.
- `naoDeveAprovarSemEnviar` — aprovado.
- `deveRetornarNaoExpiradoComValidadeNula` — aprovado.
- `naoDeveGerarComValorNulo` — aprovado.
- `naoDeveGerarComValorZero` — aprovado.
- `naoDeveGerarComValorNegativo` — aprovado.
- `fluxoEnviarERejeitar` — aprovado.
- `estaExpiradoDeveRetornarFalseComDataFutura` — aprovado.
- `fluxoEnviarEAprovar` — aprovado.
- `naoDeveAprovarQuandoExpirado` — aprovado.

</details>

## OrdemDeServicoTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/domain/model/OrdemDeServicoTest.java) — **9 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `deveAdicionarItemECalcularTotal` — aprovado.
- `devePercorrerFluxoCompleto` — aprovado.
- `naoDevePermitirTransicaoInvalida` — aprovado.
- `naoDeveCriarSemVeiculo` — aprovado.
- `deveCriarOSComStatusRecebida` — aprovado.
- `naoDeveCriarSemCliente` — aprovado.
- `devePermitirVoltarParaAprovacaoQuandoNovoProblema` — aprovado.
- `deveCancelarOSRecebida` — aprovado.
- `naoDeveCancelarOSFinalizada` — aprovado.

</details>

## PagamentoTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/domain/model/PagamentoTest.java) — **7 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `deveRecusarComDadosDoGateway` — aprovado.
- `deveCriarComStatusPendente` — aprovado.
- `deveAprovarPagamento` — aprovado.
- `naoDeveRecusarJaAprovado` — aprovado.
- `naoDeveAprovarJaAprovado` — aprovado.
- `deveAprovarComDadosDoGateway` — aprovado.
- `deveRecusarPagamento` — aprovado.

</details>

## PecaTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/domain/model/PecaTest.java) — **9 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `deveBaixarEstoque` — aprovado.
- `deveAtualizarDados` — aprovado.
- `naoDeveReporQuantidadeNegativa` — aprovado.
- `deveVerificarDisponibilidade` — aprovado.
- `naoDeveBaixarMaisQueDisponivel` — aprovado.
- `deveIdentificarEstoqueNormal` — aprovado.
- `naoDeveBaixarQuantidadeNegativa` — aprovado.
- `deveIdentificarEstoqueBaixo` — aprovado.
- `deveReporEstoque` — aprovado.

</details>

## ServicoTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/domain/model/ServicoTest.java) — **2 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `deveCriarComConstrutor` — aprovado.
- `deveAtualizar` — aprovado.

</details>

## CpfCnpjTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/domain/valueobject/CpfCnpjTest.java) — **18 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `deveAceitarCpfSemFormatacao` — aprovado.
- `deveCriarCpfValido` — aprovado.
- `deveRejeitarCnpjInvalido` — aprovado.
- `deveCriarCnpjComPrimeiroDigitoZeroPorResto` — aprovado.
- `deveCriarCnpjValido` — aprovado.
- `deveFormatarCpf` — aprovado.
- `deveCriarCpfComSegundoDigitoVerificadorZero` — aprovado.
- `deveRejeitarCpfComDigitosErrados` — aprovado.
- `deveRejeitarCnpjComTodosDigitosIguais` — aprovado.
- `deveRejeitarCpfInvalido(String)[1]` — aprovado.
- `deveRejeitarCpfInvalido(String)[2]` — aprovado.
- `deveRejeitarCpfInvalido(String)[3]` — aprovado.
- `deveRejeitarCpfInvalido(String)[4]` — aprovado.
- `deveRejeitarCpfInvalido(String)[5]` — aprovado.
- `doisCpfsIguaisDevemSerEquals` — aprovado.
- `deveFormatarCnpj` — aprovado.
- `deveCriarCnpjComSegundoDigitoZeroPorResto` — aprovado.
- `deveCriarCpfComPrimeiroDigitoVerificadorZero` — aprovado.

</details>

## PeriodoExecucaoTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/domain/valueobject/PeriodoExecucaoTest.java) — **8 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `deveCriarComInicio` — aprovado.
- `deveCalcularDuracaoComFim` — aprovado.
- `periodosIguaisDevemSerEquals` — aprovado.
- `deveFinalizarComDataFim` — aprovado.
- `naoDeveCriarComInicioNulo` — aprovado.
- `naoDeveFinalizarComFimNulo` — aprovado.
- `deveCalcularDuracaoSemFimUsandoAgora` — aprovado.
- `naoDeveFinalizarComFimAnteriorAoInicio` — aprovado.

</details>

## PlacaTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/domain/valueobject/PlacaTest.java) — **8 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `deveConverterParaUppercase` — aprovado.
- `deveFormatar` — aprovado.
- `deveAceitarPlacaAntigaComoMercosul` — aprovado.
- `deveAceitarPlacaMercosul` — aprovado.
- `deveRejeitarPlacaInvalida(String)[1]` — aprovado.
- `deveRejeitarPlacaInvalida(String)[2]` — aprovado.
- `deveRejeitarPlacaInvalida(String)[3]` — aprovado.
- `deveRejeitarPlacaInvalida(String)[4]` — aprovado.

</details>

## QuantidadeTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/domain/valueobject/QuantidadeTest.java) — **12 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `naoDeveSubtrairMaisQueDisponivel` — aprovado.
- `deveCriarComValorPositivo` — aprovado.
- `deveCriarComValorZero` — aprovado.
- `naoDeveSubtrairValorZeroOuNegativo` — aprovado.
- `deveConverterParaString` — aprovado.
- `quantidadesIguaisDevemSerEquals` — aprovado.
- `deveAdicionar` — aprovado.
- `quantidadesDiferentesNaoDevemSerEquals` — aprovado.
- `naoDeveAdicionarValorZeroOuNegativo` — aprovado.
- `deveVerificarDisponibilidade` — aprovado.
- `naoDeveCriarComValorNegativo` — aprovado.
- `deveSubtrair` — aprovado.

</details>

## ViaCepClientTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/infrastructure/client/ViaCepClientTest.java) — **6 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `deveRetornarVazioQuandoApiLancaExcecao` — aprovado.
- `deveLimparCaracteresNaoNumericosDoCep` — aprovado.
- `deveRetornarVazioParaCepInvalido` — aprovado.
- `deveRetornarVazioParaCepComTamanhoErrado` — aprovado.
- `deveRetornarVazioQuandoApiRetornaNulo` — aprovado.
- `deveRetornarEnderecoParaCepValido` — aprovado.

</details>

## DashboardHistoricoPostgresTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/infrastructure/demo/DashboardHistoricoPostgresTest.java) — **1 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `persisteMassaHistoricaNoSchemaRealSemDuplicarOuAlterarMassaExistente` — aprovado.

</details>

## DashboardHistoricoTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/infrastructure/demo/DashboardHistoricoTest.java) — **6 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `mecanicoNaoPodeGerarMassa` — aprovado.
- `rotaEMassaFicamAusentesQuandoRecursoEstaDesabilitado` — aprovado.
- `snapshotPublicaOsIntervalosPersistidosDaMassaHistorica` — aprovado.
- `exigeAutenticacao` — aprovado.
- `gestorPodeGerarMassa` — aprovado.
- `geraSeteDiasDistintosComCicloCompletoDeUmaSemanaSemDuplicar` — aprovado.

</details>

## BusinessSnapshotPayloadTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/infrastructure/observability/BusinessSnapshotPayloadTest.java) — **2 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `publicaEntregaRealNoFusoDoNegocioEDatasDaCriacao` — aprovado.
- `finalizadaHojeContinuaContadaAposEntregaESemEntregaNaoExibeData` — aprovado.

</details>

## CorrelationIdFilterTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/infrastructure/observability/CorrelationIdFilterTest.java) — **4 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `deveGerarCorrelationIdQuandoHeaderNaoVierInformado` — aprovado.
- `devePreservarCorrelationIdRecebidoNoHeader` — aprovado.
- `deveUsarRequestIdQuandoCorrelationIdNaoVierInformado` — aprovado.
- `deveIgnorarCorrelationIdInvalidoEGerarNovoValor` — aprovado.

</details>

## NewRelicLinkingJsonProviderTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/infrastructure/observability/NewRelicLinkingJsonProviderTest.java) — **2 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `deveSerializarMetadadosComoCamposJsonSemAlterarMensagem` — aprovado.
- `deveProduzirJsonValidoSemAgenteNewRelic` — aprovado.

</details>

## OrdemServicoMicrometerMetricsTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/infrastructure/observability/OrdemServicoMicrometerMetricsTest.java) — **1 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `registraEventosDeNegocioDaOrdemDeServico` — aprovado.

</details>

## OrdemServicoStatusSnapshotPublisherTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/infrastructure/observability/OrdemServicoStatusSnapshotPublisherTest.java) — **2 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `publicaSnapshotDeStatusEOrdensOperacionais` — aprovado.
- `ignoraFalhaAoPublicarSnapshotParaNaoQuebrarAgendamento` — aprovado.

</details>

## CustomUserDetailsServiceTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/infrastructure/security/CustomUserDetailsServiceTest.java) — **2 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `deveCarregarUsuario` — aprovado.
- `deveLancarSeNaoEncontrar` — aprovado.

</details>

## JwtAuthenticationFilterTest

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/infrastructure/security/JwtAuthenticationFilterTest.java) — **7 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `deveProsseguirComHeaderSemBearer` — aprovado.
- `deveAutenticarClienteExternoComClienteId` — aprovado.
- `deveProsseguirComUsernameNulo` — aprovado.
- `naoDeveAutenticarComTokenInvalido` — aprovado.
- `deveProsseguirSemHeaderAuthorization` — aprovado.
- `deveAutenticarComTokenValido` — aprovado.
- `deveMontarAuthorityCorretaParaCadaPerfil` — aprovado.

</details>

## OficinaMecanicaDGCARApplicationTests

[Código da suíte](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/OficinaMecanicaDGCARApplicationTests.java) — **1 casos**, zero falhas, erros ou testes ignorados.

<details>
<summary>Casos executados</summary>

- `contextLoads` — aprovado.

</details>
