# Zelo — Sprint 4
## DevOps Tools & Cloud Computing — FIAP

**Turma:** 2TDSR · **Professor:** João Menk · **Branch de integração:** `master`

## 1. Integrantes

| Nome completo | RM | Turma |
|---|---|---|
| Hebert Lopes do Santos | 563192 | 2TDSR |
| Nicolas Monteiro Ramiro | 562380 | 2TDSR |
| Marcus Vinícius Vila Nova da Silva | 558771 | 2TDSR |
| Bruno Ferreira | 563489 | 2TDSR |
| Gabriel Robertoni Padilha | 566293 | 2TDSR |


## 2. Descrição da solução

O Zelo aproxima tutores e clínicas veterinárias por meio do acompanhamento preventivo de pets. A aplicação mantém o cadastro dos animais e seus cuidados, como vacinas, consultas, exames e medicamentos. Isso ajuda a centralizar o histórico, organizar retornos e reduzir o esquecimento de cuidados importantes.

A API disponibiliza inclusão, consulta, atualização e exclusão de **Pets** e **Cuidados**, com relacionamento de um pet para vários cuidados. A página inicial permite identificar a versão implantada; o Swagger permite executar as operações REST.

Esta Sprint acrescenta integração e implantação contínuas no **Azure DevOps**. Um push na `master` dispara build e testes, publica um JAR como artefato e, após sucesso, implanta a aplicação no **Azure Container Instances (ACI)**. O banco de entrega é **MySQL em ACI na Azure**, com volume persistente.

## 3. Links da entrega e estado de validação

| Item | Link / estado |
|---|---|
| Repositório GitHub | https://github.com/brunoferr10/zelo-sprint4-devops |
| Azure DevOps | **Pendente:** inserir URL real do projeto após criação |
| Vídeo YouTube | **Pendente:** inserir URL real acessível ao professor após gravação |
| Aplicação Azure | **Pendente:** inserir URL real retornada pelo deploy |
| CI/CD e testes na Azure | **Pendente de execução e comprovação** |

Os arquivos de implementação estão disponíveis neste repositório. Os itens pendentes só devem ser marcados como concluídos depois da validação real. A preparação deste pacote não executou o deploy na assinatura Azure do grupo. A tentativa local de Maven foi impedida por falha de resolução de rede para baixar dependências; portanto, não há resultado local de testes aprovado a declarar.

## 4. Stack de tecnologias

| Tecnologia | Uso |
|---|---|
| Java 21 / Spring Boot 3.4.5 | API e página inicial |
| Spring Web / Bean Validation | Endpoints REST e validação das entradas |
| Spring Data JPA / Hibernate | Persistência e relacionamento das entidades |
| MySQL 8.4 / Connector J | Banco de dados da aplicação em nuvem |
| Springdoc OpenAPI / Swagger UI | Documentação interativa e execução do CRUD |
| Actuator | Verificação de saúde da aplicação |
| Maven | Compilação, execução de testes e empacotamento JAR |
| JUnit / MockMvc / H2 | Testes automatizados do CI; H2 somente no perfil de teste |
| Git / GitHub | Histórico e repositório fonte conectado ao Azure Pipelines |
| Azure DevOps / Azure Pipelines | Orquestração de CI/CD e resultados dos testes |
| Pipeline Artifacts | Publicação e download do JAR aprovado pelo CI |
| Docker / Eclipse Temurin 21 JRE | Imagem de execução do JAR |
| ACR / ACR Tasks | Construção e armazenamento das imagens |
| ACI | Execução separada da API e do MySQL |
| Azure Files | Persistência dos arquivos do MySQL |
| Key Vault | Armazenamento de credenciais da infraestrutura |
| Azure CLI / Bash | Provisionamento e atualização dos recursos |

**Distinção dos ambientes:** H2 é uma dependência de escopo `test`, usada pelos testes automatizados. A aplicação implantada e as evidências do vídeo utilizam MySQL na Azure. Execução em localhost não constitui a entrega.

## 5. Arquitetura e fluxo CI/CD

![Arquitetura Azure e fluxo numerado de CI/CD](docs/arquitetura-azure.svg)

O desenho representa personas, recursos e conexões da solução. A arquitetura inclui o desenvolvedor, o usuário final/avaliador, GitHub, Azure DevOps, artefatos, ACR, ACI da API, ACI MySQL, Azure Files e Key Vault.

| Ordem | Origem → destino | O que acontece |
|---|---|---|
| 1 | Desenvolvedor → GitHub | Alteração em código e push na branch `master` |
| 2 | GitHub → Azure Pipelines CI | Trigger inicia configuração Java 21, build e testes |
| 3 | CI → Pipeline Artifacts | Publicação de `app/app.jar` após sucesso dos testes |
| 4 | Pipeline Artifacts → CD | Download do artefato da mesma execução aprovada |
| 5 | CD → ACR Tasks / ACR | Construção da imagem a partir desse JAR; tag igual a `Build.BuildId` |
| 6 | CD / ACR → ACI da API | Atualização automática do container e verificação de saúde |
| 7 | Usuário final / avaliador → API | Acesso à página inicial e ao Swagger pelo FQDN público |
| 8 | API → MySQL → Azure Files | CRUD via JDBC; arquivos do banco persistidos no volume |

As variáveis secretas do Azure DevOps chegam ao ACI por `--secure-environment-variables`. A conexão de serviço autoriza as operações Azure. Key Vault guarda credenciais definidas na preparação da infraestrutura; o CD atual obtém a credencial do ACR pela Azure CLI e recebe as credenciais MySQL pelas variáveis secretas da pipeline.

### Recursos previstos pelos scripts

| Recurso | Nome padrão | Responsabilidade |
|---|---|---|
| Grupo de recursos | `rg-zelo-s4-rm563489` | Agrupar recursos da Sprint 4 |
| ACR | `zelos4acr563489` | Imagens da API e banco |
| ACI aplicação | `rm563489-zelos4-app` | API na porta 8080, usuário Linux 10001 |
| ACI banco | `rm563489-zelos4-db` | MySQL na porta 3306 |
| Storage Account | `zelos4data563489` | Armazenamento do compartilhamento Azure Files |
| Compartilhamento | `zelo-mysql-data` | Montagem em `/var/lib/mysql` |
| Key Vault | `kv-zelos4-563489` | Segredos de infraestrutura |
| Região | `canadacentral` | Local padrão dos recursos |

Os nomes são configurações previstas, não comprovantes de recursos já criados. Estão em `scripts/00-configurar-ambiente.sh` e isolam a Sprint 4 da Sprint 3. Altere antes do provisionamento se a região não estiver permitida ou algum nome global estiver indisponível.

## 6. Estrutura do repositório

| Caminho | Conteúdo |
|---|---|
| `azure-pipelines.yml` | Estágios CI e CD |
| `pom.xml` | Versões, dependências e empacotamento Maven |
| `src/main/java/` | Controllers, modelos, DTOs, repositórios e tratamento de erros |
| `src/main/resources/application.properties` | Configuração da API e datasource por ambiente |
| `src/main/resources/static/index.html` | Página a alterar no vídeo para comprovar o deploy |
| `src/test/java/br/com/fiap/zelo/CrudIntegrationTest.java` | Testes automatizados |
| `src/test/resources/application-test.properties` | Banco isolado para testes |
| `scripts/00-configurar-ambiente.sh` | Nomes e região dos recursos |
| `scripts/01-criar-recursos.sh` | Provisionamento de ACR, Storage, Files e Key Vault |
| `scripts/02-build-push.sh` | Build remoto da imagem inicial do banco no ACR |
| `scripts/03-deploy-banco.sh` | Implantação inicial do MySQL com volume |
| `scripts/04-deploy-cicd.sh` | Build da imagem da API a partir do artefato e deploy ACI |
| `scripts/06-excluir-recursos.sh` | Exclusão do grupo após a avaliação |
| `docker/app/Dockerfile.cicd` | Imagem de execução que recebe `app.jar` |
| `docker/db/Dockerfile` / `script_bd.sql` | Imagem MySQL e inicialização do schema |
| `postman/Zelo.postman_collection.json` | Coleção de chamadas REST |
| `docs/arquitetura-azure.svg` | Desenho de arquitetura |
| `docs/consultas-evidencia.sql` | Consultas para comprovação de persistência |
| `docs/CONFIGURAR-AZURE.md` | Guia complementar de configuração |
| `docs/roteiro-video.md` / `docs/ENTREGA.md` | Apoio ao vídeo e dados para o PDF |
| `docker-compose.yml` / `docker/app/Dockerfile` | Apoio opcional ao desenvolvimento local |

## 7. Pré-requisitos e clone

- Conta GitHub com permissão de escrita neste repositório.
- Organização Azure DevOps e permissão para criar projeto, pipeline e conexão de serviço.
- Assinatura Azure ativa, saldo/orçamento e permissão para provisionar recursos.
- Bash e Azure CLI para infraestrutura; Cloud Shell ou VM podem ser usados.
- JDK 21 e Maven para executar os testes na máquina de desenvolvimento.
- Navegador e Swagger/Postman; cliente MySQL está disponível dentro do ACI do banco.

Docker local não é necessário no caminho principal: as imagens são construídas no ACR Tasks. A VM é opcional como estação de trabalho; o destino obrigatório de deploy escolhido é o ACI.

```bash
git clone https://github.com/brunoferr10/zelo-sprint4-devops.git
cd zelo-sprint4-devops
git switch master
```

## 8. Provisionamento inicial na Azure

Execute na raiz do clone, em Bash, uma instrução por vez. Confira a assinatura antes de criar recursos.

```bash
az login
az account show --output table
# Somente se necessário:
# az account set --subscription "ID_DA_ASSINATURA"
```

Digite credenciais próprias no prompt. Os valores digitados para senhas não são exibidos. Não use o usuário reservado `root` como `MYSQL_USER`.

```bash
read -r -p 'Usuario MySQL: ' MYSQL_USER
read -r -s -p 'Senha MySQL: ' MYSQL_PASSWORD
echo
read -r -s -p 'Senha root MySQL: ' MYSQL_ROOT_PASSWORD
echo
export MYSQL_USER MYSQL_PASSWORD MYSQL_ROOT_PASSWORD

bash scripts/01-criar-recursos.sh
bash scripts/02-build-push.sh
bash scripts/03-deploy-banco.sh
```

O script 01 usa `az ad signed-in-user show` para dar acesso ao Key Vault ao usuário conectado; execute essa preparação com login interativo de usuário que tenha permissão de configurar a política do cofre. O CD usa sua própria conexão de serviço e não executa essa preparação.

Confira os logs e espere o MySQL ficar pronto antes do primeiro CD:

```bash
az container logs --resource-group rg-zelo-s4-rm563489 --name rm563489-zelos4-db
```

Aguarde a mensagem `ready for connections`. O `script_bd.sql` cria as tabelas e os registros iniciais quando `/var/lib/mysql` está vazio. Não remova o volume para atualizar a aplicação; ele guarda os dados. As senhas de inicialização devem corresponder às variáveis da pipeline. Alterar uma variável não troca automaticamente a senha de um banco já inicializado.

O banco do laboratório tem endpoint público, seguindo a arquitetura acadêmica em containers. Não use dados reais ou sensíveis. Para produção, a arquitetura precisa de rede privada e transporte criptografado; os scripts atuais não implementam essas proteções.

## 9. Criação do projeto Azure DevOps

| Campo | Configuração exigida |
|---|---|
| Project Name | `Sprint 4 – Azure DevOps` |
| Description | `Projeto para entrega da Sprint 4 do professor João Menk`, seguido de nomes, RMs e turmas da seção 1 |
| Visibility | `Private` |
| Version control | `Git` |
| Work item process | `Scrum` ou `Agile` |

O código usado pela pipeline fica neste GitHub. Criar o projeto com Git habilita Azure Repos, mas a pipeline deve ser conectada ao repositório GitHub efetivamente atualizado pelo grupo.

### Acesso do professor

1. Confirme o e-mail institucional correto nos materiais/FIAP antes do convite.
2. Em **Organization settings → Users → Add users**, adicione o professor com nível de acesso **Basic** e acesso ao projeto.
3. Em **Project settings → Permissions → Project Administrators**, inclua o professor, seguindo o print da entrega.
4. Confira o usuário, o nível Basic e a associação ao projeto. Mantenha o acesso até a correção.
5. Confira também a acessibilidade do vídeo. Falta de acesso do professor pode zerar a avaliação.

## 10. Conexão de serviço e variáveis protegidas

### Conexão Azure

1. Abra **Project settings → Service connections → New service connection**.
2. Escolha **Azure Resource Manager** e, quando disponível, **Workload identity federation**.
3. Selecione sua assinatura e o grupo `rg-zelo-s4-rm563489`.
4. Nomeie a conexão **`MyAzureSubscription`**, exatamente como no YAML.
5. Autorize a pipeline a usar a conexão.

A identidade deve poder atualizar ACI, executar ACR Tasks e consultar credenciais do ACR no grupo. O papel Contributor no grupo costuma cobrir essas operações de controle; políticas da assinatura podem exigir ajuste pelo administrador. Não use tokens ou senhas diretamente no YAML.

### Variáveis

| Nome | Onde configurar | Proteção / finalidade |
|---|---|---|
| `MYSQL_USER` | Variables da pipeline | Marcar secreta; mesmo usuário criado no banco |
| `MYSQL_PASSWORD` | Variables da pipeline | Marcar secreta; mesma senha criada no banco |
| `MYSQL_ROOT_PASSWORD` | Sessão Bash da preparação | Senha de inicialização root; não é exigida pelo CD |
| `azureServiceConnection` | YAML | Nome não sensível da conexão `MyAzureSubscription` |
| `IMAGE_TAG` | Injetada pelo YAML | `Build.BuildId`, sem preenchimento manual |
| `ARTIFACT_DIR` | Injetada pelo YAML | Caminho do artefato baixado |
| `SPRING_DATASOURCE_URL` | Script do CD | Gerada com FQDN do banco, sem senha embutida |
| `SPRING_DATASOURCE_USERNAME` | ACI, configuração segura | Recebe `MYSQL_USER` |
| `SPRING_DATASOURCE_PASSWORD` | ACI, configuração segura | Recebe `MYSQL_PASSWORD` |

Em **Pipelines → pipeline → Edit → Variables**, adicione `MYSQL_USER` e `MYSQL_PASSWORD` e marque **Keep this value secret** nos dois. As credenciais ACR são obtidas em variáveis de processo pela identidade da conexão de serviço; não estão versionadas. Evite `set -x`, impressão de variáveis e abertura de valores secretos durante a gravação.

## 11. Configuração e etapas da pipeline

1. Abra **Pipelines → New pipeline → GitHub**.
2. Autorize a integração e selecione `brunoferr10/zelo-sprint4-devops`.
3. Selecione **Existing Azure Pipelines YAML file**, branch **master**, arquivo **`/azure-pipelines.yml`**.
4. Configure as variáveis secretas da seção 10.
5. Use **Save and run** para validar a primeira execução e autorize a conexão quando solicitado.
6. Depois, faça alteração de código e push para comprovar o disparo automático. A execução inicial manual não substitui essa evidência.

### CI — integração contínua

| Etapa | Implementação | Evidência |
|---|---|---|
| Trigger | Push na branch `master` | Execução iniciada pelo commit enviado |
| Checkout | `checkout: self` | Commit/branch identificados na execução |
| Java | `JavaToolInstaller@0`, Java 21 | Task de configuração concluída |
| Build e testes | `Maven@4`, `clean verify`, `-DfailIfNoTests=true` | Log Maven e aba Tests |
| Relatórios | Publicação JUnit de `surefire-reports/TEST-*.xml` | Testes e resultados disponíveis |
| Preparação | Copia o JAR da aplicação para `app/app.jar` | Task de preparação concluída |
| Publicação | `PublishPipelineArtifact@1`, artefato `app` | Artefato acessível na execução |

Sem sucesso nos testes, o CI falha e não libera o estágio CD. O Maven gera `target/zelo-api-1.0.0.jar`; o artefato publicado contém `app.jar`.

### CD — implantação contínua

| Etapa | Implementação | Evidência |
|---|---|---|
| Dependência | `dependsOn: CI`, sucesso e branch `master` | Estágio iniciado após CI aprovado |
| Download | `DownloadPipelineArtifact@2`, execução atual, artefato `app` | Log de download do JAR |
| Conexão Azure | `AzureCLI@2` com conexão de serviço | Task autenticada sem credencial no código |
| Imagem | ACR Tasks usando `Dockerfile.cicd` e o JAR baixado | Imagem no ACR com tag BuildId |
| Deploy | `az container create` atualiza o ACI da aplicação | Imagem/tag atualizada no Portal Azure |
| Configuração | Datasource e credenciais seguras no container | Aplicação conecta ao MySQL |
| Saúde | Tentativas de acesso ao `/actuator/health` | Task aprovada quando a API responde |

CI e CD são estágios de uma mesma pipeline YAML. O CD roda automaticamente após a publicação bem-sucedida do artefato na execução atual; não é uma Release clássica separada. Não há aprovação manual configurada no YAML. Confira que nenhuma configuração externa esteja bloqueando a execução automática.

## 12. Testes automatizados

```bash
java -version
mvn -version
mvn -B clean verify -DfailIfNoTests=true
```

Use Java 21. A classe `CrudIntegrationTest` contém três cenários:

| Cenário | Verificação |
|---|---|
| CRUD completo com relacionamento | POST/GET/PUT/DELETE de pet e cuidado, alteração observável e 404 após exclusão |
| Entrada inválida | POST de pet sem campos obrigatórios retorna 400 |
| Recurso inexistente | Busca por pet inexistente retorna 404 |

Os testes sobem o contexto Spring e executam requisições com MockMvc, persistindo em H2 isolado. Não dependem do banco Azure. Eles validam o fluxo da aplicação, mas não comprovam conectividade nem compatibilidade de produção: faça também o CRUD no MySQL Azure. Mostre a aba **Tests** no vídeo; não basta haver arquivos de teste no repositório.

## 13. Conferência do deploy e URLs

```bash
az resource list --resource-group rg-zelo-s4-rm563489 --output table

az container show --resource-group rg-zelo-s4-rm563489 \
  --name rm563489-zelos4-app \
  --query '{imagem:containers[0].image,url:ipAddress.fqdn,estado:instanceView.state}' --output table

APP_FQDN=$(az container show --resource-group rg-zelo-s4-rm563489 \
  --name rm563489-zelos4-app --query ipAddress.fqdn --output tsv)

curl -fsS "http://${APP_FQDN}:8080/actuator/health"
```

| Acesso | Endereço |
|---|---|
| Página inicial | `http://FQDN_RETORNADO:8080/` |
| Swagger | `http://FQDN_RETORNADO:8080/swagger-ui/index.html` |
| Pets | `http://FQDN_RETORNADO:8080/api/pets` |
| Cuidados | `http://FQDN_RETORNADO:8080/api/cuidados` |
| Saúde | `http://FQDN_RETORNADO:8080/actuator/health` |

Use o FQDN realmente retornado pela Azure. No Portal mostre recursos da Sprint 4, imagem/tag do ACI, repositório de imagens no ACR e banco ativo. Se recriar o banco, confira DNS e conectividade da aplicação.

## 14. Endpoints e demonstração CRUD

| Método | Endpoint | Resultado esperado no fluxo válido |
|---|---|---|
| GET | `/api/pets` | 200, lista de pets |
| GET | `/api/pets/{id}` | 200; 404 se inexistente |
| POST | `/api/pets` | 201 com ID gerado |
| PUT | `/api/pets/{id}` | 200 com dados atualizados |
| DELETE | `/api/pets/{id}` | 204, sem corpo |
| GET | `/api/cuidados` | 200, lista de cuidados |
| GET | `/api/cuidados?petId={id}` | 200, cuidados do pet |
| GET | `/api/cuidados/{id}` | 200; 404 se inexistente |
| POST | `/api/cuidados` | 201 com ID gerado |
| PUT | `/api/cuidados/{id}` | 200 com dados atualizados |
| DELETE | `/api/cuidados/{id}` | 204, sem corpo |

Entradas que violam Bean Validation retornam 400. Para criar cuidado é necessário um pet existente. Exclua os cuidados antes do pet para respeitar a chave estrangeira.

Defina `APP_FQDN` conforme a seção 13. Nos exemplos abaixo, **substitua cada ID 3 pelo ID correto retornado no seu POST**; o ID do cuidado pode ser diferente do ID do pet. Na gravação execute os SELECTs da seção seguinte entre as operações.

### Pets

```bash
# CREATE
curl -X POST "http://${APP_FQDN}:8080/api/pets" \
  -H "Content-Type: application/json" \
  -d '{"nome":"Mel","especie":"Cao","raca":"Beagle","dataNascimento":"2023-04-12","nomeTutor":"Carla Souza"}'

# READ geral e individual (substitua 3 pelo ID retornado)
curl "http://${APP_FQDN}:8080/api/pets"
curl "http://${APP_FQDN}:8080/api/pets/3"

# UPDATE
curl -X PUT "http://${APP_FQDN}:8080/api/pets/3" \
  -H "Content-Type: application/json" \
  -d '{"nome":"Mel","especie":"Cao","raca":"Beagle","dataNascimento":"2023-04-12","nomeTutor":"Carla Souza Ferreira"}'

# DELETE: execute somente depois de apagar o cuidado relacionado
curl -i -X DELETE "http://${APP_FQDN}:8080/api/pets/3"
```

### Cuidados

```bash
# CREATE relacionado ao pet 3
curl -X POST "http://${APP_FQDN}:8080/api/cuidados" \
  -H "Content-Type: application/json" \
  -d '{"petId":3,"tipo":"EXAME","descricao":"Hemograma preventivo anual","dataPrevista":"2026-11-05","status":"PENDENTE"}'

# READ geral, individual e filtrado por pet
curl "http://${APP_FQDN}:8080/api/cuidados"
curl "http://${APP_FQDN}:8080/api/cuidados/3"
curl "http://${APP_FQDN}:8080/api/cuidados?petId=3"

# UPDATE
curl -X PUT "http://${APP_FQDN}:8080/api/cuidados/3" \
  -H "Content-Type: application/json" \
  -d '{"petId":3,"tipo":"EXAME","descricao":"Hemograma preventivo realizado","dataPrevista":"2026-11-05","status":"CONCLUIDO"}'

# DELETE primeiro, por causa da chave estrangeira
curl -i -X DELETE "http://${APP_FQDN}:8080/api/cuidados/3"
```

Use os IDs efetivamente retornados pelo POST, sem presumir que serão 3.


## 15. Evidências de persistência no MySQL

Abra um segundo terminal e acesse o banco real em nuvem:

```bash
az container exec --resource-group rg-zelo-s4-rm563489 \
  --name rm563489-zelos4-db --exec-command /bin/bash
```

Dentro do container, execute usando o mesmo usuário definido na preparação:

```bash
mysql -u SEU_USUARIO_MYSQL -p zelo
```

Digite a senha no prompt. No cliente MySQL, troque os números abaixo pelos IDs reais retornados pela API:

```sql
USE zelo;
SET @pet_id = 3;
SET @cuidado_id = 3;

-- Depois do POST do pet e durante a consulta GET:
SELECT id, nome, especie, raca, data_nascimento, nome_tutor
FROM pets WHERE id = @pet_id;

-- Depois do POST do cuidado e durante a consulta GET:
SELECT id, pet_id, tipo, descricao, data_prevista, status
FROM cuidados WHERE id = @cuidado_id;

-- Depois de cada PUT, execute o SELECT correspondente novamente.
-- A alteração de nome_tutor / descricao / status deve estar visível.

-- Consulta do relacionamento antes da exclusão:
SELECT p.id, p.nome, p.nome_tutor, c.id AS cuidado_id, c.tipo, c.status
FROM pets p JOIN cuidados c ON c.pet_id = p.id
WHERE p.id = @pet_id;

-- Depois de DELETE /api/cuidados/{id}: deve retornar zero linhas.
SELECT * FROM cuidados WHERE id = @cuidado_id;

-- Depois de DELETE /api/pets/{id}: deve retornar zero linhas.
SELECT * FROM pets WHERE id = @pet_id;
```

Sequência recomendada para comprovação: **POST → SELECT; GET → SELECT; PUT → SELECT atualizado; DELETE → SELECT sem registro**. Faça isso para as duas entidades. Inicialmente crie o pet e depois o cuidado; ao excluir, inverta a ordem. Mostre o comando e o resultado legíveis no vídeo. Resposta da API sozinha não substitui SELECT no banco.

Azure Files preserva os dados em `/var/lib/mysql`. Como verificação adicional de persistência, pode reiniciar o ACI do banco e consultar os registros novamente, aguardando o banco ficar pronto. Essa prova é complementar ao CRUD obrigatório.

## 16. Alteração de código para comprovar automação

1. Mostre a página atual acessada pelo FQDN Azure.
2. Na IDE abra `src/main/resources/static/index.html`.
3. Altere um título visível, por exemplo para `Zelo Sprint 4 - Deploy automatico validado`.
4. Salve e envie para `master`:

```bash
git switch master
git add src/main/resources/static/index.html
git commit -m "feat: atualizar titulo para demonstrar deploy automatico"
git push origin master
```

5. Mostre a execução iniciando automaticamente pelo commit.
6. Acompanhe e explique as tasks de CI e CD, resultados dos testes e artefato.
7. No Portal compare a imagem do ACI com o BuildId dessa execução.
8. Recarregue a URL Azure sem cache e mostre o novo título.

**Alteração somente no README não atende a essa demonstração.** Não clique em Run para simular disparo automático após o push.

## 17. Roteiro do vídeo

Grave em **720p ou superior**, com áudio claro, explicação por voz e sem legendas. Prepare as ferramentas antes da gravação e revise o arquivo gravado antes de publicar. Não há limite fixo de duração; priorize evidências claras.

| Sequência | Mostrar e explicar |
|---|---|
| 1 | Solução, integrantes, stack, IDE, GitHub, Azure DevOps, Portal e banco |
| 2 | Arquitetura com personas, recursos, conexões e ordem CI/CD |
| 3 | Projeto privado, configuração, nível Basic e acesso administrativo do professor |
| 4 | Pipeline e finalidade de cada job/task, trigger master e proteção de variáveis |
| 5 | Página antes da mudança, alteração no código, commit e push |
| 6 | Disparo automático e explicação das etapas durante a execução |
| 7 | Resultados dos testes e artefato publicado no Azure DevOps |
| 8 | CD e recursos atualizados no Portal, incluindo tag da imagem no ACI |
| 9 | Página Azure com alteração visível |
| 10 | CRUD completo de pets e cuidados com SELECTs após cada operação |
| 11 | Conferência dos links e acesso ao vídeo |

A operação CRUD pode usar Swagger ou Postman. O terminal MySQL deve mostrar a persistência. Evite exibir valores de segredos, tokens e dados pessoais de terceiros.

## 18. PDF obrigatório

O PDF final deve conter **somente**:

- Nome completo, RM e turma de cada integrante (seção 1).
- Link deste repositório GitHub.
- Link real do vídeo YouTube acessível ao professor.
- Link real do projeto Azure DevOps com acesso do professor.

O conteúdo técnico e o diagrama ficam neste README/repositório. O arquivo `docs/ENTREGA.md` serve como base; não entregue com links pendentes. Gere o PDF depois de criar o projeto Azure DevOps e publicar o vídeo.

## 19. Checklist de revisão antes de entregar

| Requisito | Onde comprovar | Estado |
|---|---|---|
| Nomes, RMs e turmas | Seção 1 e PDF final | Dados documentados; conferir grafia com a equipe |
| Descrição e stack | Seções 2 e 4 | Documentadas |
| Arquitetura e fluxo numerado | Seção 5 e SVG | Incluídos; revisar legibilidade no GitHub/vídeo |
| Banco permitido na nuvem | MySQL ACI e SELECTs | Pendente de execução |
| Projeto com nome/descrição/privacidade/processo | Azure DevOps | Pendente de configuração |
| Professor Basic e administrador | Azure DevOps Users/Permissions | Pendente de configuração |
| Repositório correto e branch master | GitHub e pipeline | Conferir conexão na Azure |
| Build e testes automáticos | Logs e aba Tests | Implementados; pendente de execução |
| Artefato publicado no Azure DevOps | Artefato app/app.jar | Configurado; pendente de execução |
| CD automático após artefato | Stage CD e ACI | Configurado; pendente de execução |
| Usuário, senha e tokens protegidos | Variables/conexões/ACI | Conferir configuração e logs |
| Mudança no código com efeito no app Azure | Vídeo antes/depois | Pendente de gravação |
| Recursos atualizados no Portal | Vídeo e imagem/tag ACI | Pendente de gravação |
| CRUD com SELECT para cada operação | Swagger/Postman + MySQL | Pendente de execução/gravação |
| Vídeo com qualidade e explicação falada | YouTube | Pendente |
| PDF contendo apenas dados e três links | PDF final | Pendente |

Atualize os estados após comprovar cada item. Um checklist preenchido não substitui evidências. CI/CD sem funcionar, entrega apenas em localhost ou professor sem acesso são falhas que podem zerar a avaliação conforme enunciado.

## 20. Diagnóstico de problemas

| Sintoma | Verificação / ação |
|---|---|
| Pipeline não inicia com push | Confirmar branch master, integração GitHub, YAML selecionado e trigger sem sobrescrita na interface |
| Pipeline aguardando agente | Conferir capacidade Microsoft-hosted; se necessário solicitar paralelismo ou configurar agente próprio e ajustar pool |
| Falha de compilação | Conferir Java 21, Maven e log da task |
| Testes falhando | Abrir aba Tests e relatório Surefire; corrigir o erro antes de prosseguir |
| Conexão de serviço não autorizada | Autorizar a pipeline e conferir assinatura, escopo e papel da identidade |
| ACR Tasks não constrói imagem | Conferir permissão, disponibilidade/quota e logs da task |
| Nome de recurso indisponível | Ajustar script 00 antes de provisionar e manter nomes consistentes |
| Deploy ACI falha | Conferir quota/região, permissão e configuração do container |
| Aplicação não fica saudável | Consultar logs da aplicação e banco, URL JDBC, credenciais e schema |
| Erro no schema | `ddl-auto=validate` exige tabelas existentes; confirmar inicialização e volume correto |
| Senha alterada mas banco rejeita | Conferir senha efetiva do banco já inicializado; variável de inicialização não redefine senha existente |
| Página não mostra mudança | Conferir commit, BuildId, imagem/tag no ACI, URL e cache do navegador |
| DELETE de pet falha por relacionamento | Excluir cuidados relacionados antes do pet |

```bash
az container logs -g rg-zelo-s4-rm563489 -n rm563489-zelos4-app
az container logs -g rg-zelo-s4-rm563489 -n rm563489-zelos4-db
az acr repository list -n zelos4acr563489 -o table
az acr repository show-tags -n zelos4acr563489 --repository 563489-zelo-app -o table
```

## 21. Custos e encerramento

ACR, ACI e armazenamento podem gerar cobrança. Verifique orçamento e mantenha os recursos disponíveis até a avaliação. Depois de confirmar que não são mais necessários, o comando abaixo remove **todo o grupo da Sprint 4**, inclusive armazenamento e dados:

```bash
bash scripts/06-excluir-recursos.sh
```

Não execute durante a preparação ou antes da correção.

## 22. Referências

- Enunciado da Sprint 4 e materiais de aula fornecidos pelo Prof. João Menk: Azure Repos, conceitos de Azure Pipelines e exercício Java.
- [Azure Pipelines — documentação oficial](https://learn.microsoft.com/azure/devops/pipelines/)
- [Task Maven@4](https://learn.microsoft.com/azure/devops/pipelines/tasks/reference/maven-v4)
- [Pipeline Artifacts](https://learn.microsoft.com/azure/devops/pipelines/artifacts/pipeline-artifacts)
- [Variáveis de ambiente seguras no ACI](https://learn.microsoft.com/azure/container-instances/container-instances-environment-variables)
- [Volume Azure Files no ACI](https://learn.microsoft.com/azure/container-instances/container-instances-volume-azure-files)
