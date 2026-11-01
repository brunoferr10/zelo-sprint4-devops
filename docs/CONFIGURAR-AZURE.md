# Configuração da Sprint 4

## 1. Infraestrutura (uma vez)

Use Bash com Azure CLI (Cloud Shell ou VM). Execute na raiz do projeto. Não precisa instalar Docker: o build do banco usa ACR Tasks.

```bash
az login
az account show -o table
# Se necessário: az account set --subscription ID_DA_ASSINATURA
read -r -p 'Usuario MySQL: ' MYSQL_USER
read -r -s -p 'Senha MySQL: ' MYSQL_PASSWORD; echo
read -r -s -p 'Senha root MySQL: ' MYSQL_ROOT_PASSWORD; echo
export MYSQL_USER MYSQL_PASSWORD MYSQL_ROOT_PASSWORD
bash scripts/01-criar-recursos.sh
bash scripts/02-build-push.sh
bash scripts/03-deploy-banco.sh
```

Confira `az container logs -g rg-zelo-s4-rm563489 -n rm563489-zelos4-db` até aparecer ready for connections. A imagem inicializa script_bd.sql somente quando o volume está vazio. Não repita inicialização nem remova volumes para corrigir deploy da aplicação.

Os nomes isolam a Sprint 4 da Sprint 3. Nomes ACR, Storage, Key Vault e DNS precisam estar disponíveis globalmente. Se houver conflito, altere scripts/00-configurar-ambiente.sh antes de criar recursos. Região padrão canadacentral; mude se a assinatura exigir. Recursos geram cobrança; verifique orçamento e disponibilidade na sua assinatura.

O MySQL usa ACI público como no projeto anterior: ambiente acadêmico sem dados reais. O CD usa FQDN do banco. Se recriar o banco, confira DNS, senha e volume. Arquitetura de produção precisaria rede privada e TLS.

## 2. Projeto Azure DevOps

Crie com nome `Sprint 4 – Azure DevOps`, Visibility Private, Version control Git e processo Scrum ou Agile.
Descrição: `Projeto para entrega da Sprint 4 do professor João Menk`, seguida da tabela de integrantes do README com RM e 2TDSR.

Em Organization settings > Users, adicione o e-mail do professor confirmado no seu material/FIAP com nível Basic, incluindo o projeto. Em Project settings > Permissions > Project Administrators, adicione o professor conforme o print da entrega. Confira que consegue acessar Repos/Pipelines; mantenha o convite e a permissão até a avaliação.

## 3. Conexão Azure e variáveis

Project settings > Service connections > New service connection > Azure Resource Manager. Prefira Workload identity federation; selecione sua assinatura e escopo do grupo `rg-zelo-s4-rm563489`. Nome exato: `MyAzureSubscription`. Autorize somente a pipeline necessária. A identidade precisa criar/atualizar ACI, executar ACR Tasks e consultar credenciais do ACR nesse grupo (Contributor no grupo cobre as operações usuais; políticas da assinatura podem exigir ajuste pelo administrador).

Crie a pipeline em Pipelines > New pipeline > GitHub, autorize a conexão e selecione seu repositório. Use Existing Azure Pipelines YAML file, branch master, arquivo /azure-pipelines.yml.

Em Variables, crie **MYSQL_USER** e **MYSQL_PASSWORD**, ambos com opção secreta (cadeado). Use exatamente os mesmos valores da criação do banco. Não cole valores no YAML. Tokens GitHub/Azure devem ficar nas conexões de serviço, nunca no Git. Não use set -x nem mostre senhas na gravação.

Save and run para o primeiro teste. Autorize os recursos solicitados. Se não houver agente hospedado/parallelism disponível na organização, solicite capacidade Microsoft-hosted ou configure agente próprio com JDK 21, Maven, Azure CLI e acesso aos recursos; ajuste pool no YAML se usar agente próprio.

## 4. Validar CI/CD

O CI faz clean verify, publica testes JUnit e artefato app/app.jar. O CD depende do sucesso do CI, baixa o artefato da execução atual, constrói imagem no ACR com tag BuildId e atualiza ACI. Não há aprovação manual configurada no YAML. Confira que a interface não está sobrescrevendo o trigger.

```bash
az container show -g rg-zelo-s4-rm563489 -n rm563489-zelos4-app --query '{imagem:containers[0].image,url:ipAddress.fqdn,estado:instanceView.state}' -o table
```

Acesse http://FQDN_RETORNADO:8080 e /swagger-ui/index.html. No vídeo, altere o título em src/main/resources/static/index.html (ex.: Zelo Sprint 4 - Deploy automatico), faça commit e push na master. Mostre o início automático, testes, artefato, CD, nova tag no Portal e título atualizado no navegador (recarregue sem cache).

## 5. Banco e CRUD

```bash
az container exec -g rg-zelo-s4-rm563489 -n rm563489-zelos4-db --exec-command /bin/bash
mysql -u SEU_USUARIO -p zelo
```

Senha digitada no prompt, sem aparecer no vídeo. Para cada POST/GET/PUT/DELETE feito no Swagger/Postman, execute SELECT correspondente de docs/consultas-evidencia.sql. Apague cuidados antes de pets e mostre SELECT sem o registro após DELETE. Use os IDs retornados, não valores fixos. O CI com H2 não substitui essa prova no MySQL em nuvem.

## Verificação do pacote

Scripts conferidos com bash -n; pom.xml, SVG e coleção Postman validados quanto à sintaxe. A tentativa local de Maven foi bloqueada por falha de resolução de rede ao baixar o parent Spring Boot; não foi possível concluir os testes neste ambiente. A máquina de preparação possui Java 17; o projeto e a pipeline exigem Java 21. Valide clean verify no JDK 21 e a execução completa no Azure antes da gravação.

## 6. Diagnóstico

Falha Maven: abra logs e relatório Tests. Falha ACR build: confira permissão e disponibilidade ACR Tasks. Falha deploy: confira quota ACI, permissão, credenciais e logs do container. Health falhando: veja logs de banco/aplicação e variáveis; schema precisa existir (ddl-auto=validate). Não publique logs contendo segredos.

## Referências

Materiais Java/Azure Pipelines fornecidos pelo professor. Documentação oficial: https://learn.microsoft.com/azure/devops/pipelines/tasks/reference/maven-v4 e https://learn.microsoft.com/azure/container-instances/container-instances-environment-variables (secure values).
