-- MySQL 8.4: DDL do ambiente validado. Execute apenas em banco vazio.
-- Nao executar novamente na VM atual: pets e cuidados ja existem.
-- Nao apaga nem substitui dados. IDs usam AUTO_INCREMENT.
CREATE TABLE pets (
 id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
 nome VARCHAR(100) NOT NULL,
 especie VARCHAR(30) NOT NULL,
 raca VARCHAR(80),
 data_nascimento DATE NOT NULL,
 nome_tutor VARCHAR(120) NOT NULL
);
CREATE TABLE cuidados (
 id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
 pet_id BIGINT NOT NULL,
 tipo VARCHAR(40) NOT NULL,
 descricao VARCHAR(255) NOT NULL,
 data_prevista DATE NOT NULL,
 status VARCHAR(20) NOT NULL,
 CONSTRAINT fk_cuidado_pet FOREIGN KEY (pet_id) REFERENCES pets(id),
 CONSTRAINT ck_cuidado_status CHECK (status IN ('PENDENTE','CONCLUIDO','ATRASADO','CANCELADO'))
);
CREATE INDEX ix_cuidados_pet_data ON cuidados(pet_id,data_prevista);
