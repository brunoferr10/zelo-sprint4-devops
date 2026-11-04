# Provisionamento — somente em ambiente novo

O ambiente da entrega já está funcionando; atualização de documentação não exige executar esta sequência outra vez.

1. No computador gere chave SSH dedicada, se não existir. Guarde chave privada local e copie apenas .pub ao Cloud Shell. Obtenha IPv4 público do computador (curl -4 https://api.ipify.org).
2. No Cloud Shell Bash, clone o repositório master. az account show deve mostrar assinatura correta. Defina SSH_PUBLIC_KEY_FILE e SSH_SOURCE_CIDR=IP/32; LOCATION=eastus2 e VM_SIZE=Standard_D2s_v3. Execute bash scripts/01-criar-vm-linux.sh. Quota e capacidade podem mudar. Grupo já existente é reutilizado.
3. No Git Bash local, ssh -i ~/.ssh/zelo_sprint4 bruno@IP_DA_VM. Na VM, clone o projeto e execute bash scripts/02-preparar-ubuntu.sh. Confirme java -version e mvn -version com Java 21.
4. Na VM nova, bash scripts/07-preparar-mysql.sh. Digite senhas ocultas. O script para se container/volume existentes puderem ser afetados. Aguarde banco pronto com sudo docker logs --tail 30 zelo-mysql. Não mostre docker inspect (pode expor senhas).
5. Só no banco novo, sudo docker exec -it zelo-mysql mysql -u zelo_user -p zelo. Dentro do monitor SQL, cole o conteúdo de script_bd.sql. SHOW TABLES deve mostrar pets e cuidados. Na VM existente, NÃO repetir CREATE TABLE.
6. Na VM, az login --use-device-code; conclua login e seleção sem Ctrl+C. Execute bash scripts/03-criar-webapp.sh. Plano B1 tem custo.
7. Na VM autenticada, bash scripts/08-liberar-mysql-webapp.sh. A regra MySQL-WebApp libera 3306 somente para possibleOutboundIpAddresses. Confirme docker publica3306 e que não há outra regra ampla para banco.
8. Crie projeto privado Sprint 4 – Azure DevOps, Git, Scrum, descrição com professor e equipe. Professor Basic e acesso ao projeto. Conexão Azure Resource Manager MyAzureSubscription com workload identity federation, escopo rg-zelo-s4-webapp. Autorize pipeline específica.
9. Conecte GitHub master e YAML existente. Cadastre SPRING_DATASOURCE_URL, SPRING_DATASOURCE_USERNAME, SPRING_DATASOURCE_PASSWORD como secretas; valores no README. Em novo IP/nome, ajuste URL e variáveis YAML antes do deploy.
10. Execute primeira pipeline. Confira CI, oito testes, app/app.jar, CD e health. Prove novo disparo por mudança de código na master e título online. Faça CRUD no Web App e SELECT na VM.

Segredos não pertencem ao Git nem aos logs. H2 é apenas teste. Mantenha a VM ligada: ela hospeda o banco. Não apagar volume para reiniciar container. Após avaliação planeje backup e encerramento dos recursos com custo.
