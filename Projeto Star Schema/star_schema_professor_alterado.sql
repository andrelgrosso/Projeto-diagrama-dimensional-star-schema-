-- =====================================================
-- STAR SCHEMA - FOCO EM PROFESSOR (VERSÃO CORRIGIDA)
-- =====================================================
-- Correções aplicadas:
--   1. dim_prerequisito removida (não é dimensão analítica)
--   2. dim_departamento desnormalizada em dim_disciplina e dim_curso
--      (elimina snowflake — dimensões não se referenciam entre si)
--   3. id_departamento removido da fato (caminho redundante)
--   4. semestre_oferta removido da fato (redundante com dim_data)
--   5. status_oferta tratado como dimensão de baixa cardinalidade
--      (dim_status_oferta), mantendo o valor descritivo fora da fato
-- =====================================================


-- =====================================================
-- 1. DIMENSÃO: dim_professor
-- =====================================================
CREATE TABLE dim_professor (
    id_professor        INT          PRIMARY KEY AUTO_INCREMENT,
    nome_professor      VARCHAR(150) NOT NULL,
    email_professor     VARCHAR(100),
    titulacao           VARCHAR(50),
    data_admissao       DATE,
    ativo               BOOLEAN      DEFAULT TRUE,
    data_criacao        TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE INDEX idx_professor_nome  ON dim_professor (nome_professor);
CREATE INDEX idx_professor_ativo ON dim_professor (ativo);


-- =====================================================
-- 2. DIMENSÃO: dim_disciplina
-- =====================================================
-- Departamento desnormalizado aqui (sem FK para dim_departamento).
-- Star schema puro: dimensões são planas e auto-suficientes.
-- =====================================================
CREATE TABLE dim_disciplina (
    id_disciplina           INT          PRIMARY KEY AUTO_INCREMENT,
    nome_disciplina         VARCHAR(150) NOT NULL,
    codigo_disciplina       VARCHAR(20)  UNIQUE NOT NULL,
    carga_horaria           INT,
    nivel                   VARCHAR(20),
    descricao               TEXT,
    -- Departamento desnormalizado
    nome_departamento       VARCHAR(100) NOT NULL,
    sigla_departamento      VARCHAR(10),
    campus_departamento     VARCHAR(100),
    -- Pré-requisito como atributo descritivo (sem tabela separada)
    tem_prerequisito        BOOLEAN      DEFAULT FALSE,
    qtd_prerequisitos       INT          DEFAULT 0,
    ativo                   BOOLEAN      DEFAULT TRUE,
    data_criacao            TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao        TIMESTAMP    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE INDEX idx_disciplina_nome         ON dim_disciplina (nome_disciplina);
CREATE INDEX idx_disciplina_codigo       ON dim_disciplina (codigo_disciplina);
CREATE INDEX idx_disciplina_departamento ON dim_disciplina (nome_departamento);
CREATE INDEX idx_disciplina_nivel        ON dim_disciplina (nivel);
CREATE INDEX idx_disciplina_campus       ON dim_disciplina (campus_departamento);


-- =====================================================
-- 3. DIMENSÃO: dim_curso
-- =====================================================
-- Departamento desnormalizado aqui também, pelo mesmo motivo.
-- =====================================================
CREATE TABLE dim_curso (
    id_curso                INT          PRIMARY KEY AUTO_INCREMENT,
    nome_curso              VARCHAR(150) NOT NULL,
    codigo_curso            VARCHAR(20)  UNIQUE NOT NULL,
    duracao_semestres       INT,
    tipo_curso              VARCHAR(50),
    -- Departamento desnormalizado
    nome_departamento       VARCHAR(100) NOT NULL,
    sigla_departamento      VARCHAR(10),
    campus_departamento     VARCHAR(100),
    ativo                   BOOLEAN      DEFAULT TRUE,
    data_criacao            TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao        TIMESTAMP    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE INDEX idx_curso_nome         ON dim_curso (nome_curso);
CREATE INDEX idx_curso_codigo       ON dim_curso (codigo_curso);
CREATE INDEX idx_curso_tipo         ON dim_curso (tipo_curso);
CREATE INDEX idx_curso_departamento ON dim_curso (nome_departamento);
CREATE INDEX idx_curso_campus       ON dim_curso (campus_departamento);


-- =====================================================
-- 4. DIMENSÃO: dim_data
-- =====================================================
CREATE TABLE dim_data (
    id_data                  INT          PRIMARY KEY AUTO_INCREMENT,
    data_completa            DATE         NOT NULL UNIQUE,
    dia                      INT          NOT NULL,
    mes                      INT          NOT NULL,
    ano                      INT          NOT NULL,
    trimestre                INT,
    semestre                 INT,
    semestre_ano             VARCHAR(10),
    nome_mes                 VARCHAR(15),
    nome_dia_semana          VARCHAR(15),
    eh_feriado               BOOLEAN      DEFAULT FALSE,
    tipo_periodo_academico   VARCHAR(30),
    data_criacao             TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_data_completa     ON dim_data (data_completa);
CREATE INDEX idx_data_semestre_ano ON dim_data (semestre_ano);
CREATE INDEX idx_data_ano          ON dim_data (ano);
CREATE INDEX idx_data_mes          ON dim_data (mes);


-- =====================================================
-- 5. DIMENSÃO: dim_status_oferta
-- =====================================================
-- Substituiu o VARCHAR status_oferta direto na fato.
-- Cardinalidade baixa (~5 valores), mas a dimensão permite
-- adicionar atributos futuros (ex.: exige_rematricula, cor_dashboard).
-- =====================================================
CREATE TABLE dim_status_oferta (
    id_status_oferta    INT          PRIMARY KEY AUTO_INCREMENT,
    descricao_status    VARCHAR(50)  NOT NULL UNIQUE,
    ativo               BOOLEAN      DEFAULT TRUE,
    data_criacao        TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_status_descricao ON dim_status_oferta (descricao_status);


-- =====================================================
-- 6. TABELA FATO: fato_professor_disciplina
-- =====================================================
-- Chaves removidas: id_departamento (redundante via disciplina/curso),
--                   semestre_oferta (redundante via dim_data.semestre_ano).
-- Chave adicionada: id_status_oferta (FK para nova dimensão).
-- Granularidade: uma linha = uma oferta de disciplina por professor,
--                curso e semestre.
-- =====================================================
CREATE TABLE fato_professor_disciplina (
    id_fato_professor_disciplina    INT             PRIMARY KEY AUTO_INCREMENT,
    -- Chaves estrangeiras para dimensões
    id_professor                    INT             NOT NULL,
    id_disciplina                   INT             NOT NULL,
    id_curso                        INT             NOT NULL,
    id_data_oferta                  INT             NOT NULL,
    id_status_oferta                INT             NOT NULL,
    -- Métricas
    quantidade_alunos_matriculados  INT             DEFAULT 0,
    carga_horaria_total             DECIMAL(5, 2),
    -- Auditoria
    data_criacao                    TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao                TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    -- Integridade referencial
    FOREIGN KEY (id_professor)    REFERENCES dim_professor    (id_professor),
    FOREIGN KEY (id_disciplina)   REFERENCES dim_disciplina   (id_disciplina),
    FOREIGN KEY (id_curso)        REFERENCES dim_curso        (id_curso),
    FOREIGN KEY (id_data_oferta)  REFERENCES dim_data         (id_data),
    FOREIGN KEY (id_status_oferta) REFERENCES dim_status_oferta (id_status_oferta)
);

CREATE INDEX idx_fato_professor           ON fato_professor_disciplina (id_professor);
CREATE INDEX idx_fato_disciplina          ON fato_professor_disciplina (id_disciplina);
CREATE INDEX idx_fato_curso               ON fato_professor_disciplina (id_curso);
CREATE INDEX idx_fato_data                ON fato_professor_disciplina (id_data_oferta);
CREATE INDEX idx_fato_status              ON fato_professor_disciplina (id_status_oferta);
CREATE INDEX idx_fato_professor_disciplina ON fato_professor_disciplina (id_professor, id_disciplina);


-- =====================================================
-- INSERÇÃO DE DADOS DE EXEMPLO
-- =====================================================

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


-- =====================================================
-- QUERIES DE VALIDAÇÃO
-- =====================================================

SELECT 'dim_professor'     AS Tabela, COUNT(*) AS Total FROM dim_professor
UNION ALL
SELECT 'dim_disciplina',   COUNT(*) FROM dim_disciplina
UNION ALL
SELECT 'dim_curso',        COUNT(*) FROM dim_curso
UNION ALL
SELECT 'dim_data',         COUNT(*) FROM dim_data
UNION ALL
SELECT 'dim_status_oferta',COUNT(*) FROM dim_status_oferta
UNION ALL
SELECT 'fato',             COUNT(*) FROM fato_professor_disciplina;

-- =====================================================
-- EXEMPLO DE QUERY ANALÍTICA
-- Total de alunos por professor, departamento e semestre
-- =====================================================
SELECT
    p.nome_professor,
    d.nome_departamento,
    dt.semestre_ano,
    COUNT(*)                              AS qtd_turmas,
    SUM(f.quantidade_alunos_matriculados) AS total_alunos,
    SUM(f.carga_horaria_total)            AS total_horas
FROM fato_professor_disciplina f
JOIN dim_professor   p  ON f.id_professor  = p.id_professor
JOIN dim_disciplina  d  ON f.id_disciplina = d.id_disciplina
JOIN dim_data        dt ON f.id_data_oferta = dt.id_data
GROUP BY
    p.nome_professor,
    d.nome_departamento,
    dt.semestre_ano
ORDER BY
    dt.semestre_ano,
    total_alunos DESC;
