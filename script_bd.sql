-- Execute uma vez no seu schema Oracle FIAP, antes do primeiro deploy.
-- Usa nomes propios do Zelo. Nao apaga tabelas existentes.
-- Se objetos ja existirem, confira estrutura e dados antes de executar novamente.
CREATE SEQUENCE zelo_pet_seq START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE zelo_cuidado_seq START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE TABLE pets (
 id NUMBER(19,0) NOT NULL PRIMARY KEY,
 nome VARCHAR2(100 CHAR) NOT NULL,
 especie VARCHAR2(30 CHAR) NOT NULL,
 raca VARCHAR2(80 CHAR),
 data_nascimento DATE NOT NULL,
 nome_tutor VARCHAR2(120 CHAR) NOT NULL
);
CREATE TABLE cuidados (
 id NUMBER(19,0) NOT NULL PRIMARY KEY,
 pet_id NUMBER(19,0) NOT NULL,
 tipo VARCHAR2(40 CHAR) NOT NULL,
 descricao VARCHAR2(255 CHAR) NOT NULL,
 data_prevista DATE NOT NULL,
 status VARCHAR2(20 CHAR) NOT NULL,
 CONSTRAINT fk_cuidado_pet FOREIGN KEY (pet_id) REFERENCES pets(id),
 CONSTRAINT ck_cuidado_status CHECK (status IN ('PENDENTE','CONCLUIDO','ATRASADO','CANCELADO'))
);
CREATE INDEX ix_cuidados_pet_data ON cuidados(pet_id,data_prevista);
INSERT INTO pets VALUES(zelo_pet_seq.NEXTVAL,'Thor','Cao','Golden Retriever',DATE '2021-03-15','Mariana Costa');
INSERT INTO pets VALUES(zelo_pet_seq.NEXTVAL,'Luna','Gato','Sem raca definida',DATE '2022-08-10','Rafael Lima');
INSERT INTO cuidados SELECT zelo_cuidado_seq.NEXTVAL,id,'VACINA','Reforco anual',DATE '2026-12-01','PENDENTE' FROM pets WHERE nome='Thor';
INSERT INTO cuidados SELECT zelo_cuidado_seq.NEXTVAL,id,'CONSULTA','Retorno preventivo',DATE '2026-12-02','PENDENTE' FROM pets WHERE nome='Luna';
COMMIT;
