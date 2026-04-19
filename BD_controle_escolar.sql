CREATE DATABASE IF NOT EXISTS ControleAcessoEscolar;
USE ControleAcessoEscolar;


CREATE TABLE BLOCO (
    id_bloco INT AUTO_INCREMENT PRIMARY KEY,
    nome_bloco VARCHAR(100) NOT NULL
);

CREATE TABLE PESSOA (
    id_pessoa INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf CHAR(11) UNIQUE NOT NULL,
    rua VARCHAR(150) NOT NULL,
    numero VARCHAR(10) NOT NULL,
    bairro VARCHAR(100) NOT NULL
);


CREATE TABLE CATRACA (
    id_catraca INT AUTO_INCREMENT PRIMARY KEY,
    localizacao VARCHAR(100) NOT NULL,
    id_bloco INT NOT NULL,
    CONSTRAINT fk_catraca_bloco FOREIGN KEY (id_bloco) REFERENCES BLOCO(id_bloco)
);

CREATE TABLE TELEFONE_PESSOA (
    id_telefone INT AUTO_INCREMENT PRIMARY KEY,
    id_pessoa INT NOT NULL,
    numero VARCHAR(20) NOT NULL,
    CONSTRAINT fk_telefone_pessoa FOREIGN KEY (id_pessoa) REFERENCES PESSOA(id_pessoa)
);

CREATE TABLE BIOMETRIA (
    id_biometria INT AUTO_INCREMENT PRIMARY KEY,
    id_pessoa INT NOT NULL,
    tipo_dedo VARCHAR(50) NOT NULL,
    CONSTRAINT fk_biometria_pessoa FOREIGN KEY (id_pessoa) REFERENCES PESSOA(id_pessoa)
);


CREATE TABLE FUNCIONARIO (
    id_pessoa INT PRIMARY KEY,
    cargo VARCHAR(100) NOT NULL,
    CONSTRAINT fk_funcionario_pessoa FOREIGN KEY (id_pessoa) REFERENCES PESSOA(id_pessoa)
);

CREATE TABLE ALUNO (
    id_pessoa INT PRIMARY KEY,
    matricula VARCHAR(20) UNIQUE NOT NULL,
    id_bloco INT NOT NULL,
    CONSTRAINT fk_aluno_pessoa FOREIGN KEY (id_pessoa) REFERENCES PESSOA(id_pessoa),
    CONSTRAINT fk_aluno_bloco FOREIGN KEY (id_bloco) REFERENCES BLOCO(id_bloco)
);

CREATE TABLE RESPONSAVEL (
    id_pessoa INT PRIMARY KEY,
    CONSTRAINT fk_responsavel_pessoa FOREIGN KEY (id_pessoa) REFERENCES PESSOA(id_pessoa)
);


CREATE TABLE RESPONSAVEL_ALUNO (
    id_vinculo INT AUTO_INCREMENT PRIMARY KEY,
    id_responsavel INT NOT NULL,
    id_aluno INT NOT NULL,
    grau_parentesco VARCHAR(50) NOT NULL,
    CONSTRAINT fk_vinculo_responsavel FOREIGN KEY (id_responsavel) REFERENCES RESPONSAVEL(id_pessoa),
    CONSTRAINT fk_vinculo_aluno FOREIGN KEY (id_aluno) REFERENCES ALUNO(id_pessoa)
);

CREATE TABLE ACESSO (
    id_registro INT AUTO_INCREMENT PRIMARY KEY,
    id_pessoa INT NOT NULL,
    id_catraca INT NOT NULL,
    data_hora DATETIME NOT NULL,
    movimento ENUM('Entrada', 'Saida') NOT NULL,
    liberado TINYINT(1) NOT NULL,
    CONSTRAINT fk_acesso_pessoa FOREIGN KEY (id_pessoa) REFERENCES PESSOA(id_pessoa),
    CONSTRAINT fk_acesso_catraca FOREIGN KEY (id_catraca) REFERENCES CATRACA(id_catraca)
);

CREATE TABLE OCORRENCIA_RETENCAO (
    id_ocorrencia INT AUTO_INCREMENT PRIMARY KEY,
    id_aluno INT NOT NULL,
    id_funcionario INT NOT NULL,
    id_catraca INT NOT NULL,
    motivo VARCHAR(255) NOT NULL,
    data_hora DATETIME NOT NULL,
    CONSTRAINT fk_ocorrencia_aluno FOREIGN KEY (id_aluno) REFERENCES ALUNO(id_pessoa),
    CONSTRAINT fk_ocorrencia_funcionario FOREIGN KEY (id_funcionario) REFERENCES FUNCIONARIO(id_pessoa),
    CONSTRAINT fk_ocorrencia_catraca FOREIGN KEY (id_catraca) REFERENCES CATRACA(id_catraca)
);

-- ==========================================
-- Inserindo Dados
-- ==========================================
INSERT INTO BLOCO (nome_bloco) VALUES ('Ensino Médio'), ('Fundamental II'), ('Administração');


INSERT INTO CATRACA (localizacao, id_bloco) VALUES 
('Portaria Principal - A', 1),
('Portaria Principal - B', 2),
('Portaria Secundária', 3);


INSERT INTO PESSOA (nome, cpf, rua, numero, bairro) VALUES 
('Caio Henrique', '12345678901', 'Rua das Flores', '100', 'Centro'),
('Douglas Leite', '98765432100', 'Av. Paulista', '500', 'Jardins'),
('Maria Marinho', '11122233344', 'Rua das Flores', '100', 'Centro');


INSERT INTO TELEFONE_PESSOA (id_pessoa, numero) VALUES (1, '(11) 99999-9999'), (3, '(11) 98888-8888');
INSERT INTO BIOMETRIA (id_pessoa, tipo_dedo) VALUES (1, 'Polegar Direito'), (2, 'Indicador Direito');


INSERT INTO ALUNO (id_pessoa, matricula, id_bloco) VALUES (1, '2026ADS001', 1);


INSERT INTO FUNCIONARIO (id_pessoa, cargo) VALUES (2, 'Inspetor Chefe');


INSERT INTO RESPONSAVEL (id_pessoa) VALUES (3);


INSERT INTO RESPONSAVEL_ALUNO (id_responsavel, id_aluno, grau_parentesco) VALUES (3, 1, 'Mãe');


INSERT INTO ACESSO (id_pessoa, id_catraca, data_hora, movimento, liberado) VALUES 
(1, 1, '2026-04-20 07:15:00', 'Entrada', 1), 
(3, 1, '2026-04-20 12:30:00', 'Entrada', 1);


INSERT INTO OCORRENCIA_RETENCAO (id_aluno, id_funcionario, id_catraca, motivo, data_hora) VALUES 
(1, 2, 2, 'Aluno tentou acessar bloco do Fundamental II sem permissão', '2026-04-20 10:00:00');

-- ==========================================
-- CONSULTAS (SELECT)
-- ==========================================

-- Consulta: Relatório completo de acessos do dia (Quem passou, onde e que horas)
SELECT 
    A.data_hora,
    P.nome AS 'Nome da Pessoa',
    A.movimento,
    C.localizacao AS 'Catraca',
    B.nome_bloco AS 'Bloco',
    CASE WHEN A.liberado = 1 THEN 'Sim' ELSE 'Não' END AS 'Liberado'
FROM ACESSO A
INNER JOIN PESSOA P ON A.id_pessoa = P.id_pessoa
INNER JOIN CATRACA C ON A.id_catraca = C.id_catraca
INNER JOIN BLOCO B ON C.id_bloco = B.id_bloco
ORDER BY A.data_hora DESC;

-- Consulta: Descobrir os responsáveis de um determinado aluno
SELECT 
    P_ALUNO.nome AS 'Aluno',
    A.matricula,
    P_RESP.nome AS 'Responsável',
    RA.grau_parentesco
FROM RESPONSAVEL_ALUNO RA
INNER JOIN ALUNO A ON RA.id_aluno = A.id_pessoa
INNER JOIN PESSOA P_ALUNO ON A.id_pessoa = P_ALUNO.id_pessoa
INNER JOIN RESPONSAVEL R ON RA.id_responsavel = R.id_pessoa
INNER JOIN PESSOA P_RESP ON R.id_pessoa = P_RESP.id_pessoa;

-- Consulta: Listar todas as ocorrências de retenção com o inspetor responsável
SELECT 
    O.data_hora,
    P_ALUNO.nome AS 'Aluno Retido',
    P_FUNC.nome AS 'Inspetor',
    O.motivo,
    C.localizacao AS 'Local'
FROM OCORRENCIA_RETENCAO O
INNER JOIN PESSOA P_ALUNO ON O.id_aluno = P_ALUNO.id_pessoa
INNER JOIN PESSOA P_FUNC ON O.id_funcionario = P_FUNC.id_pessoa
INNER JOIN CATRACA C ON O.id_catraca = C.id_catraca;


-- ==========================================
-- ATUALIZAÇÕES E DELEÇÕES (UPDATE / DELETE)
-- ==========================================

-- Aluno mudou de endereço e atualizou o cadastro no app:
UPDATE PESSOA 
SET rua = 'Avenida Nova Escola', numero = '123B', bairro = 'Jardim Novo'
WHERE cpf = '12345678901';

-- O inspetor foi promovido a Coordenador de Segurança
UPDATE FUNCIONARIO 
SET cargo = 'Coordenador de Segurança'
WHERE id_pessoa = (SELECT id_pessoa FROM PESSOA WHERE cpf = '98765432100');

-- Excluindo uma biometria antiga com erro de leitura
DELETE FROM BIOMETRIA 
WHERE id_biometria = 2;