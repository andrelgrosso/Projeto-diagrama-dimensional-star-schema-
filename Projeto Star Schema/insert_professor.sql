-- =====================================================
-- INSERÇÃO DE DADOS DE EXEMPLO
-- =====================================================
use professor;

-- Status de oferta
INSERT INTO dim_status_oferta (descricao_status) VALUES
    ('Concluída'),
    ('Em andamento'),
    ('Cancelada'),
    ('Planejada');

-- Professores
INSERT INTO dim_professor (nome_professor, email_professor, titulacao, data_admissao, ativo) VALUES
    ('Prof. Dr. João Silva',    'joao.silva@universidade.edu',    'Doutor',  '2015-03-01', TRUE),
    ('Prof. Dra. Maria Santos', 'maria.santos@universidade.edu',  'Doutora', '2016-08-15', TRUE),
    ('Prof. Carlos Oliveira',   'carlos.oliveira@universidade.edu','Mestre', '2018-02-20', TRUE),
    ('Prof. Ana Costa',         'ana.costa@universidade.edu',     'Doutora', '2017-05-10', TRUE),
    ('Prof. Pedro Ferreira',    'pedro.ferreira@universidade.edu','Mestre',  '2019-07-01', TRUE);

-- Disciplinas (departamento desnormalizado)
INSERT INTO dim_disciplina
    (nome_disciplina, codigo_disciplina, carga_horaria, nivel, nome_departamento, sigla_departamento, campus_departamento, tem_prerequisito, qtd_prerequisitos, ativo)
VALUES
    ('Programação em Python',    'INT101', 60, 'Graduação', 'Departamento de Informática', 'INT', 'Campus Centro', FALSE, 0, TRUE),
    ('Banco de Dados',           'INT102', 60, 'Graduação', 'Departamento de Informática', 'INT', 'Campus Centro', TRUE,  1, TRUE),
    ('Estrutura de Dados',       'INT103', 60, 'Graduação', 'Departamento de Informática', 'INT', 'Campus Centro', TRUE,  1, TRUE),
    ('Cálculo I',                'MAT101', 90, 'Graduação', 'Departamento de Matemática',  'MAT', 'Campus Norte',  FALSE, 0, TRUE),
    ('Cálculo II',               'MAT102', 90, 'Graduação', 'Departamento de Matemática',  'MAT', 'Campus Norte',  TRUE,  1, TRUE),
    ('Resistência dos Materiais','ENG101', 75, 'Graduação', 'Departamento de Engenharia',  'ENG', 'Campus Sul',    TRUE,  1, TRUE),
    ('Gestão de Projetos',       'ADM101', 60, 'Graduação', 'Departamento de Administração','ADM','Campus Centro', FALSE, 0, TRUE),
    ('Administração Financeira', 'ADM102', 60, 'Graduação', 'Departamento de Administração','ADM','Campus Centro', FALSE, 0, TRUE);

-- Cursos (departamento desnormalizado)
INSERT INTO dim_curso
    (nome_curso, codigo_curso, duracao_semestres, tipo_curso, nome_departamento, sigla_departamento, campus_departamento, ativo)
VALUES
    ('Bacharelado em Ciência da Computação', 'BCC001', 8,  'Bacharelado',  'Departamento de Informática',   'INT', 'Campus Centro', TRUE),
    ('Bacharelado em Engenharia Civil',      'BEC001', 10, 'Bacharelado',  'Departamento de Engenharia',    'ENG', 'Campus Sul',    TRUE),
    ('Bacharelado em Administração',         'BAD001', 8,  'Bacharelado',  'Departamento de Administração', 'ADM', 'Campus Centro', TRUE),
    ('Licenciatura em Matemática',           'LIC001', 8,  'Licenciatura', 'Departamento de Matemática',    'MAT', 'Campus Norte',  TRUE);

-- Datas
INSERT INTO dim_data
    (data_completa, dia, mes, ano, trimestre, semestre, semestre_ano, nome_mes, nome_dia_semana, eh_feriado, tipo_periodo_academico)
VALUES
    ('2024-01-15', 15,  1, 2024, 1, 1, '2024.1', 'Janeiro',  'Segunda', FALSE, 'Período letivo'),
    ('2024-02-20', 20,  2, 2024, 1, 1, '2024.1', 'Fevereiro','Terça',   FALSE, 'Período letivo'),
    ('2024-03-15', 15,  3, 2024, 1, 1, '2024.1', 'Março',    'Sexta',   FALSE, 'Período letivo'),
    ('2024-04-21', 21,  4, 2024, 2, 1, '2024.1', 'Abril',    'Domingo', TRUE,  'Feriado'),
    ('2024-05-10', 10,  5, 2024, 2, 1, '2024.1', 'Maio',     'Sexta',   FALSE, 'Período letivo'),
    ('2024-06-15', 15,  6, 2024, 2, 1, '2024.1', 'Junho',    'Sábado',  FALSE, 'Recesso'),
    ('2024-07-20', 20,  7, 2024, 3, 2, '2024.2', 'Julho',    'Sábado',  FALSE, 'Férias'),
    ('2024-08-15', 15,  8, 2024, 3, 2, '2024.2', 'Agosto',   'Quinta',  FALSE, 'Período letivo'),
    ('2024-09-10', 10,  9, 2024, 3, 2, '2024.2', 'Setembro', 'Terça',   FALSE, 'Período letivo'),
    ('2024-10-12', 12, 10, 2024, 4, 2, '2024.2', 'Outubro',  'Sábado',  FALSE, 'Período letivo'),
    ('2024-11-20', 20, 11, 2024, 4, 2, '2024.2', 'Novembro', 'Quarta',  FALSE, 'Período letivo'),
    ('2024-12-15', 15, 12, 2024, 4, 2, '2024.2', 'Dezembro', 'Domingo', FALSE, 'Recesso');

-- Fatos
-- id_status_oferta: 1=Concluída, 2=Em andamento
INSERT INTO fato_professor_disciplina
    (id_professor, id_disciplina, id_curso, id_data_oferta, id_status_oferta,
     quantidade_alunos_matriculados, carga_horaria_total)
VALUES
    -- Semestre 2024.1
    (1, 1, 1, 1,  1, 45, 60.00),   -- João / Python / BCC
    (1, 2, 1, 2,  1, 38, 60.00),   -- João / BD / BCC
    (2, 4, 4, 3,  1, 52, 90.00),   -- Maria / Cálculo I / Lic. Mat.
    (3, 6, 2, 4,  1, 35, 75.00),   -- Carlos / Res. Mat. / Eng. Civil
    (4, 7, 3, 5,  1, 42, 60.00),   -- Ana / Gestão Proj. / Adm.
    -- Semestre 2024.2
    (1, 3, 1, 8,  2, 40, 60.00),   -- João / Est. Dados / BCC
    (2, 5, 4, 9,  2, 48, 90.00),   -- Maria / Cálculo II / Lic. Mat.
    (3, 6, 2, 10, 2, 38, 75.00),   -- Carlos / Res. Mat. / Eng. Civil
    (4, 8, 3, 11, 2, 45, 60.00),   -- Ana / Adm. Fin. / Adm.
    (5, 1, 1, 8,  2, 50, 60.00);   -- Pedro / Python / BCC