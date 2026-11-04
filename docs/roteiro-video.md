# Roteiro de vídeo — Sprint 4 DevOps

Grave em720p ou mais, com áudio claro, explicação falada e sem legendas. Prepare IDE (por exemplo VS Code Remote SSH), terminal SSH, GitHub, Azure DevOps, Portal Azure, Web App/Swagger e MySQL antes de gravar. Nunca exibir senhas, tokens, chave privada ou docker inspect.

## 1. Apresentação e arquitetura
Apresente Zelo, pets/cuidados, stack e equipe. Abra README e diagrama: usuário HTTPS → Web App Java 21 → MySQL 8.4 na VM Ubuntu com volume persistente. Mostre os números do fluxo CI/CD. Explique a evolução funcional de filtros/resumo/painel em relação à Sprint3.

## 2. Azure DevOps
Mostre projeto privado, descrição com integrantes, Git/Scrum, professor Basic na organização e membro do projeto. Abra azure-pipelines.yml: trigger master, Java 21, Maven clean verify, testes JUnit, preparação e publicação app.jar; dependência do CD, download do mesmo artefato, configuração datasource por variáveis protegidas, deploy Web App e health. Mostre só os cadeados das variáveis.

## 3. Alteração real de código e disparo
Mostre primeiro o título atual online. Na IDE, edite src/main/resources/static/index.html: por exemplo troque apenas o texto do h1 de Deploy automático para CI/CD demonstrado. Salve. Na VM use git --no-pager diff -- src/main/resources/static/index.html, git add, git commit e git push origin master. Não usar apenas alteração de README e não clicar Run. Abra a nova execução e mostre Individual CI e master.

## 4. Narração durante CI/CD
Abra cada etapa em andamento e explique sua finalidade. CI compila, testa e gera JAR; falha bloqueia CD. Abra Tests e resultados, artefato app e app.jar. CD baixa artefato aprovado, configura segredos, publica aplicação e verifica saúde. Mostre logs sem revelar segredos. Se houver espera longa, mantenha demonstração compreensível sem esconder as etapas importantes.

## 5. Azure e aplicação atualizada
No Portal, abra zelo-s4-rm563489, plano Linux e recursos. Mostre VM em execução e Docker/MySQL com volume. Volte ao Web App HTTPS e Ctrl+F5: título novo precisa aparecer. Não usar localhost como aplicação da entrega.

## 6. CRUD completo e SELECT depois de cada operação
No Swagger online crie pet com POST e anote ID. No terminal MySQL execute SELECT do mesmo ID. Faça GET e SELECT; PUT alterando nome/tutor e SELECT mostrando mudança; DELETE e SELECT sem registro. Consulte docs/consultas-evidencia.sql. Use IDs realmente retornados.

Para mostrar também cuidados/painel: mantenha pet criado, cadastre cuidado ligado a ele, mostre SELECT e painel com total. Demonstre filtros e resumo; atualize status/descrição e SELECT; exclua cuidado e SELECT; só depois exclua pet. Não executar DELETE SQL para simular CRUD: operações devem vir pela aplicação/REST.

## 7. Fechamento
Confira CI/CD verde, testes/artefato e links. Publique no YouTube com acesso ao professor, confira qualidade 720p e áudio e copie link no README e docs/ENTREGA.md. PDF só nomes/RMs/turma e links GitHub/YouTube/Azure DevOps. Mantenha VM/banco/Web App e acesso do professor disponíveis até avaliação.
