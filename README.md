# Zelo — Sprint 4 — DevOps Tools & Cloud Computing

API para tutores e clínicas acompanharem pets e cuidados preventivos (vacinas, consultas, exames e medicamentos). Oferece CRUD de Pets e Cuidados com relacionamento 1:N, validação e Swagger.

## Integrantes

| Nome completo | RM | Turma |
|---|---|---|
| Hebert Lopes do Santos | 563192 | 2TDSR |
| Nicolas Monteiro Ramiro | 562380 | 2TDSR |
| Marcus Vinícius Vila Nova da Silva | 558771 | 2TDSR |
| Bruno Ferreira | 563489 | 2TDSR |
| Gabriel Robertoni Padilha | 566293 | 2TDSR |

## Stack e arquitetura

Java 21, Spring Boot 3.4.5, Maven, Spring Data JPA, Bean Validation, Swagger, MySQL 8.4, Docker, GitHub, Azure DevOps Pipelines, ACR, ACI, Azure Files e Key Vault. JUnit/MockMvc e H2 são usados somente nos testes do CI. A aplicação entregue usa MySQL em ACI na nuvem.

![Arquitetura e fluxo CI/CD](docs/arquitetura-azure.svg)

O desenvolvedor altera o código e envia para master no GitHub (1). Azure Pipelines compila e executa testes (2), publica o JAR como artefato app (3). O CD baixa esse JAR (4), constrói a imagem no ACR com tag BuildId (5) e atualiza o ACI da aplicação (6). O usuário acessa a página/Swagger (7); a API persiste no MySQL em outro ACI (8), com volume Azure Files. Key Vault guarda credenciais da infraestrutura; variáveis secretas do Azure DevOps fornecem usuário e senha ao CD.

## Comece aqui

1. Extraia este ZIP e suba o conteúdo da pasta zelo-sprint4 no GitHub, na branch **master**.
2. Siga [o passo a passo Azure](docs/CONFIGURAR-AZURE.md).
3. Execute a primeira pipeline, confira testes, artefato e deploy.
4. Grave conforme [roteiro do vídeo](docs/roteiro-video.md).
5. Preencha os links reais no [modelo da entrega](docs/ENTREGA.md) e gere o PDF final.

O pacote prepara os arquivos; criação dos recursos, permissões e execução real na sua assinatura ainda são necessárias. Nenhum recurso foi criado na Azure durante a preparação deste ZIP.

## Subir no GitHub (repositório novo e vazio)

```bash
git init
git add .
git commit -m "feat: Zelo Sprint 4 com CI/CD Azure DevOps"
git branch -M master
git remote add origin https://github.com/SEU-USUARIO/SEU-REPOSITORIO.git
git push -u origin master
```

Se o repositório já tem histórico, copie os arquivos para o clone existente e use add, commit e push; não reinicialize nem force o push. Ajuste a URL acima. A pipeline deve apontar para esse mesmo repositório, sem cópias divergentes.

## Testes automáticos

```bash
mvn -B clean verify -DfailIfNoTests=true
```

Requer JDK 21 e Maven. Há três testes: fluxo CRUD completo de Pets e Cuidados com persistência H2, rejeição de entrada inválida (400) e recurso inexistente (404). H2 está em escopo test e perfil test. O CI publica relatórios JUnit e só publica o JAR se os testes passarem. A demonstração oficial de persistência deve usar SELECT no MySQL Azure.

## Estrutura

- azure-pipelines.yml: CI e CD automáticos.
- scripts/01-criar-recursos.sh, 02-build-push.sh, 03-deploy-banco.sh: preparação única de infraestrutura e banco.
- scripts/04-deploy-cicd.sh: execução pelo CD a cada artefato aprovado.
- docker/app/Dockerfile.cicd: imagem construída a partir do JAR publicado.
- script_bd.sql: schema e dados iniciais do MySQL.
- docs/: arquitetura, configuração, consultas SQL e roteiro.
- postman/: coleção REST.
- docker-compose.yml e Dockerfile original: apoio opcional ao desenvolvimento local.

## 9. CRUD completo

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

## 10. Evidência direta no banco por SELECT

Recupere o IP do banco e abra o cliente MySQL dentro do ACI:

```bash
az container exec --resource-group rg-zelo-s4-rm563489 \
  --name rm563489-zelos4-db --exec-command "/bin/bash"

mysql -uzelo_user -p zelo
```

Digite a senha quando solicitada. Use as consultas de `docs/consultas-evidencia.sql`. No vídeo, a ordem obrigatória para **cada tabela** é:

1. POST na API e SELECT do registro inserido;
2. PUT na API e SELECT do registro alterado;
3. GET na API e SELECT de consulta;
4. DELETE na API e SELECT retornando zero linhas.

Apague primeiro `cuidados` e depois `pets`, pois a chave estrangeira protege a integridade do histórico.


## Checklist real da entrega

- [ ] Projeto privado com nome e descrição exigidos e processo Scrum ou Agile.
- [ ] Professor convidado com Basic e Project Administrators conforme print.
- [ ] CI disparando por push na master; testes verdes e artefato disponível.
- [ ] CD automático consumindo o artefato e ACI atualizado com tag BuildId.
- [ ] Credenciais protegidas, sem valores no Git ou vídeo.
- [ ] Vídeo com alteração visível no código, pipeline e CRUD + SELECTs no MySQL.
- [ ] PDF apenas com integrantes/turmas e os três links reais.

Não apague os recursos antes da avaliação. O script 06-excluir-recursos.sh remove o grupo de recursos inteiro da Sprint 4 e seus dados: execute apenas quando não precisar mais do ambiente.
