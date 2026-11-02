-- Conecte ao mesmo schema Oracle usado pelo Web App.
SELECT USER FROM dual;
SELECT * FROM pets ORDER BY id;
SELECT * FROM cuidados ORDER BY id;
-- Substitua os IDs de exemplo pelos retornados no POST.
-- Execute depois de POST, GET, PUT e DELETE; no DELETE o resultado deve ser vazio.
SELECT * FROM pets WHERE id = 3;
SELECT * FROM cuidados WHERE id = 3;
SELECT p.id,p.nome,c.id AS cuidado_id,c.tipo,c.status
FROM pets p JOIN cuidados c ON c.pet_id=p.id ORDER BY p.id,c.id;
-- Excluir primeiro cuidados e depois pets, sempre pela API.
