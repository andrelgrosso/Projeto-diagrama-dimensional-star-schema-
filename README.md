# Projeto: Modelagem Dimensional - Star Schema (Foco em Professor)

## 📋 Descrição do Desafio

Este projeto tem como objetivo criar um **diagrama dimensional (Star Schema)** baseado em um diagrama relacional disponibilizado, com foco na análise dos dados dos **professores**.

## 🎯 Objetivo

Criar o esquema em estrela para análise dos dados dos professores, onde a tabela fato reflete diversos dados sobre:
- Professores
- Cursos ministrados
- Departamento ao qual faz parte
- Disciplinas lecionadas
- Períodos de oferta

> **Obs.:** Não é necessário refletir dados sobre os alunos!

## 📐 Estrutura do Modelo Dimensional

### Tabela Fato

**`fato_professor_disciplina`** - Contexto principal de análise

| Campo | Descrição |
|-------|-----------|
| `id_fato_professor_disciplina` | Chave primária |
| `id_professor` | FK para dim_professor |
| `id_disciplina` | FK para dim_disciplina |
| `id_curso` | FK para dim_curso |
| `id_data_oferta` | FK para dim_data |
| `id_status_oferta` | FK para dim_status_oferta |
| `quantidade_alunos_matriculados` | Métrica de alunos |
| `carga_horaria_total` | Métrica de horas |

**Granularidade:** Uma linha = uma oferta de disciplina por professor, curso e semestre.

### Tabelas Dimensão

#### 1. `dim_professor`
Dados cadastrais e funcionais dos professores.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `id_professor` | INT | Chave primária |
| `nome_professor` | VARCHAR(150) | Nome do professor |
| `email_professor` | VARCHAR(100) | E-mail institucional |
| `titulacao` | VARCHAR(50) | Titulação (Doutor, Mestre, etc.) |
| `data_admissao` | DATE | Data de ingresso na instituição |
| `ativo` | BOOLEAN | Status do professor |

#### 2. `dim_disciplina`
Informações sobre as disciplinas ministradas (departamento desnormalizado).

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `id_disciplina` | INT | Chave primária |
| `nome_disciplina` | VARCHAR(150) | Nome da disciplina |
| `codigo_disciplina` | VARCHAR(20) | Código único |
| `carga_horaria` | INT | Carga horária em horas |
| `nivel` | VARCHAR(20) | Nível (Graduação, Pós, etc.) |
| `nome_departamento` | VARCHAR(100) | Departamento (desnormalizado) |
| `sigla_departamento` | VARCHAR(10) | Sigla do departamento |
| `campus_departamento` | VARCHAR(100) | Campus do departamento |
| `tem_prerequisito` | BOOLEAN | Indica se possui pré-requisito |
| `qtd_prerequisitos` | INT | Quantidade de pré-requisitos |

#### 3. `dim_curso`
Dados dos cursos vinculados às ofertas (departamento desnormalizado).

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `id_curso` | INT | Chave primária |
| `nome_curso` | VARCHAR(150) | Nome do curso |
| `codigo_curso` | VARCHAR(20) | Código único |
| `duracao_semestres` | INT | Duração em semestres |
| `tipo_curso` | VARCHAR(50) | Tipo (Bacharelado, Licenciatura, etc.) |
| `nome_departamento` | VARCHAR(100) | Departamento (desnormalizado) |
| `sigla_departamento` | VARCHAR(10) | Sigla do departamento |
| `campus_departamento` | VARCHAR(100) | Campus do departamento |

#### 4. `dim_data`
Dimensão temporal para análise por períodos acadêmicos.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `id_data` | INT | Chave primária |
| `data_completa` | DATE | Data completa única |
| `dia` | INT | Dia do mês |
| `mes` | INT | Mês |
| `ano` | INT | Ano |
| `trimestre` | INT | Trimestre |
| `semestre` | INT | Semestre |
| `semestre_ano` | VARCHAR(10) | Formato "YYYY.S" (ex: 2024.1) |
| `nome_mes` | VARCHAR(15) | Nome do mês |
| `nome_dia_semana` | VARCHAR(15) | Dia da semana |
| `eh_feriado` | BOOLEAN | Indicador de feriado |
| `tipo_periodo_academico` | VARCHAR(30) | Período (letivo, recesso, férias) |

#### 5. `dim_status_oferta`
Status das ofertas de disciplinas.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `id_status_oferta` | INT | Chave primária |
| `descricao_status` | VARCHAR(50) | Descrição (Concluída, Em andamento, Cancelada, Planejada) |
| `ativo` | BOOLEAN | Status ativo |

## 🗂️ Arquivos do Projeto

| Arquivo | Descrição |
|---------|-----------|
| `star_schema_professor_alterado.sql` | Script completo com criação das tabelas e dados de exemplo |
| `insert_professor.sql` | Script apenas com inserção de dados |
| `diagram_professor.png` | Imagem do diagrama relacional original |
| `Diagram_professor_versaoAluno.mwb` | Arquivo MySQL Workbench do diagrama |
| `criação de um esquema dimensional – star schema.pdf` | Documento descritivo do desafio |

## 🚀 Como Utilizar

### 1. Criar o Banco de Dados

```sql
CREATE DATABASE professor;
USE professor;
```

### 2. Executar o Script de Criação

```bash
mysql -u usuario -p professor < "Projeto Star Schema/star_schema_professor_alterado.sql"
```

### 3. Validar a Criação das Tabelas

```sql
SELECT 'dim_professor' AS Tabela, COUNT(*) AS Total FROM dim_professor
UNION ALL
SELECT 'dim_disciplina', COUNT(*) FROM dim_disciplina
UNION ALL
SELECT 'dim_curso', COUNT(*) FROM dim_curso
UNION ALL
SELECT 'dim_data', COUNT(*) FROM dim_data
UNION ALL
SELECT 'dim_status_oferta', COUNT(*) FROM dim_status_oferta
UNION ALL
SELECT 'fato', COUNT(*) FROM fato_professor_disciplina;
```

## 📊 Exemplo de Query Analítica

Total de alunos por professor, departamento e semestre:

```sql
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
```

## ✨ Características do Modelo

- **Star Schema Puro:** Dimensões planas e auto-suficientes, sem relacionamentos entre dimensões (snowflake eliminado)
- **Desnormalização Controlada:** Dados do departamento replicados nas dimensões `dim_disciplina` e `dim_curso` para otimização de consultas
- **Dimensão de Data Completa:** Permite análises temporais flexíveis em diferentes granularidades (dia, mês, trimestre, semestre)
- **Dimensão de Status:** Tratamento adequado de atributos de baixa cardinalidade como dimensão separada
- **Métricas Claras:** Foco em quantidade de alunos e carga horária como medidas analisáveis

## 📝 Requisitos Atendidos

- [x] Tabela fato com contexto de professor
- [x] Tabelas dimensão relacionadas à fato
- [x] Dimensão de datas com múltiplas granularidades
- [x] Dados de oferta de disciplinas e cursos
- [x] Informações de departamento
- [x] Modelo focado em professor (sem dados de alunos na fato)

## 👨‍💻 Tecnologias

- MySQL / MariaDB
- MySQL Workbench (modelagem visual)

---

**Autor:** Projeto Acadêmico de Modelagem Dimensional  
**Data:** 2024
