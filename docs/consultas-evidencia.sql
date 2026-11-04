-- Execute no cliente MySQL conectado ao banco zelo.
SELECT DATABASE(), CURRENT_USER();
-- Substitua pelos IDs retornados pela API. SELECT apos POST, GET, PUT e DELETE.
SET @pet_id = 2;
SET @cuidado_id = 1;
SELECT id, nome, especie, raca, data_nascimento, nome_tutor FROM pets WHERE id = @pet_id;
SELECT id, pet_id, tipo, descricao, data_prevista, status FROM cuidados WHERE id = @cuidado_id;
SELECT c.id, p.nome, c.tipo, c.descricao, c.data_prevista, c.status
FROM cuidados c JOIN pets p ON p.id=c.pet_id ORDER BY c.data_prevista,c.id;
-- Resumo UTC, mesmas regras da API. COALESCE garante zeros no banco vazio.
SELECT COUNT(*) AS total,
 COALESCE(SUM(status='PENDENTE' AND data_prevista >= UTC_DATE()),0) AS pendentes,
 COALESCE(SUM(status='ATRASADO' OR (status='PENDENTE' AND data_prevista < UTC_DATE())),0) AS atrasados,
 COALESCE(SUM(status='CONCLUIDO'),0) AS concluidos,
 COALESCE(SUM(status='CANCELADO'),0) AS cancelados
FROM cuidados;
-- Aplique os mesmos filtros pet/status/periodo ao comparar resumo filtrado.
