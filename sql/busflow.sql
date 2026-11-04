-- BusFlow — schema MySQL 8.0 (usuários separados: alunos, motoristas, admins)
CREATE DATABASE IF NOT EXISTS busflow
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE busflow;

-- ============================================================
-- ALUNOS
-- ============================================================
CREATE TABLE IF NOT EXISTS alunos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(120) NOT NULL,
  email VARCHAR(160),
  cpf VARCHAR(20),
  telefone VARCHAR(20),
  senha VARCHAR(120) NOT NULL,
  ra VARCHAR(30),
  instituicao VARCHAR(160),
  turno VARCHAR(20),
  status ENUM('ativo','bloqueado','pendente') NOT NULL DEFAULT 'ativo',
  criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_aluno_email (email),
  KEY idx_aluno_status (status)
) ENGINE=InnoDB;

-- ============================================================
-- MOTORISTAS
-- ============================================================
CREATE TABLE IF NOT EXISTS motoristas (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(120) NOT NULL,
  email VARCHAR(160),
  cpf VARCHAR(20),
  telefone VARCHAR(20),
  senha VARCHAR(120) NOT NULL,
  cnh VARCHAR(20),
  categoria_cnh VARCHAR(10),
  empresa VARCHAR(160),
  veiculo VARCHAR(60),
  turno_operacao VARCHAR(40),
  status ENUM('ativo','bloqueado','pendente') NOT NULL DEFAULT 'ativo',
  criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_motorista_email (email),
  KEY idx_motorista_status (status)
) ENGINE=InnoDB;

-- ============================================================
-- ADMINS (gestores CCO / prefeitura)
-- ============================================================
CREATE TABLE IF NOT EXISTS admins (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(120) NOT NULL,
  email VARCHAR(160),
  cpf VARCHAR(20),
  senha VARCHAR(120) NOT NULL,
  orgao VARCHAR(160),
  cargo VARCHAR(120),
  chave_adm VARCHAR(60),
  status ENUM('ativo','bloqueado','pendente') NOT NULL DEFAULT 'ativo',
  criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_admin_email (email),
  KEY idx_admin_status (status)
) ENGINE=InnoDB;

-- ============================================================
-- FROTA E ROTAS
-- ============================================================
CREATE TABLE IF NOT EXISTS veiculos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  modelo VARCHAR(80) NOT NULL,
  placa VARCHAR(12) NOT NULL,
  status ENUM('Em Rota','Parado','Manutenção','Sem motorista') NOT NULL DEFAULT 'Parado',
  motorista_id INT,
  linha VARCHAR(60),
  lote VARCHAR(40),
  ocupacao INT NOT NULL DEFAULT 0,
  capacidade INT NOT NULL DEFAULT 44,
  acao_secundaria VARCHAR(80),
  UNIQUE KEY uq_veiculo_placa (placa),
  CONSTRAINT fk_veiculo_motorista FOREIGN KEY (motorista_id) REFERENCES motoristas(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS rotas (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(120) NOT NULL,
  linha VARCHAR(40) NOT NULL,
  origem VARCHAR(120),
  destino VARCHAR(120),
  status ENUM('Em Rota','Planejada','Encerrada') NOT NULL DEFAULT 'Planejada',
  horario VARCHAR(40),
  veiculo_id INT,
  CONSTRAINT fk_rota_veiculo FOREIGN KEY (veiculo_id) REFERENCES veiculos(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ============================================================
-- OPERAÇÃO
-- ============================================================
CREATE TABLE IF NOT EXISTS viagens (
  id INT AUTO_INCREMENT PRIMARY KEY,
  rota_id INT,
  veiculo_id INT,
  motorista_id INT,
  data DATE NOT NULL,
  partida VARCHAR(80),
  chegada VARCHAR(80),
  status ENUM('programada','em_curso','concluida','cancelada') NOT NULL DEFAULT 'programada',
  passageiros INT NOT NULL DEFAULT 0,
  CONSTRAINT fk_viagem_rota FOREIGN KEY (rota_id) REFERENCES rotas(id) ON DELETE SET NULL,
  CONSTRAINT fk_viagem_veiculo FOREIGN KEY (veiculo_id) REFERENCES veiculos(id) ON DELETE SET NULL,
  CONSTRAINT fk_viagem_motorista FOREIGN KEY (motorista_id) REFERENCES motoristas(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS reservas (
  id INT AUTO_INCREMENT PRIMARY KEY,
  aluno_id INT NOT NULL,
  viagem_id INT,
  data DATE NOT NULL,
  status ENUM('confirmada','cancelada','waitlist') NOT NULL DEFAULT 'confirmada',
  criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_reserva_aluno FOREIGN KEY (aluno_id) REFERENCES alunos(id) ON DELETE CASCADE,
  CONSTRAINT fk_reserva_viagem FOREIGN KEY (viagem_id) REFERENCES viagens(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS alertas (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tipo VARCHAR(40) NOT NULL,
  titulo VARCHAR(160) NOT NULL,
  descricao VARCHAR(300),
  status ENUM('pendente','resolvido') NOT NULL DEFAULT 'pendente',
  criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS solicitacoes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tipo VARCHAR(40) NOT NULL,
  nome VARCHAR(120) NOT NULL,
  email VARCHAR(160),
  documento VARCHAR(60),
  detalhe VARCHAR(300),
  status ENUM('pendente','aprovada','recusada') NOT NULL DEFAULT 'pendente',
  criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS notificacoes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  titulo VARCHAR(160) NOT NULL,
  mensagem VARCHAR(300),
  lida TINYINT(1) NOT NULL DEFAULT 0,
  aluno_id INT,
  motorista_id INT,
  admin_id INT,
  criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_notif_aluno FOREIGN KEY (aluno_id) REFERENCES alunos(id) ON DELETE CASCADE,
  CONSTRAINT fk_notif_motorista FOREIGN KEY (motorista_id) REFERENCES motoristas(id) ON DELETE CASCADE,
  CONSTRAINT fk_notif_admin FOREIGN KEY (admin_id) REFERENCES admins(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- SEED — alunos
-- ============================================================
INSERT INTO alunos (nome, email, cpf, telefone, senha, ra, instituicao, turno, status) VALUES
('Ana Beatriz Silva', 'ana@universidade.edu.br',  '16316170440', '(81) 99911-2233', 'Senha@Forte123', '2024100849', 'Universidade de Pernambuco (UPE)', 'Manhã',  'ativo'),
('João Pedro Santos', 'joao@universidade.edu.br', '12345678901', '(81) 98822-3344', 'Senha@Forte123', '2024100850', 'Universidade de Pernambuco (UPE)', 'Tarde',  'ativo'),
('Lucas Ferreira',    'lucas@universidade.edu.br','99887766554', '(81) 97733-4455', 'Senha@Forte123', '2024100912', 'Universidade de Pernambuco (UPE)', 'Noite',  'pendente');

-- ============================================================
-- SEED — motoristas
-- ============================================================
INSERT INTO motoristas (nome, email, cpf, telefone, senha, cnh, categoria_cnh, empresa, veiculo, turno_operacao, status) VALUES
('Carlos Mendes', 'carlos@onibus.com.br', '98765432100', '(81) 99611-2233', 'Senha@Forte123', '12345678901', 'B', 'Expresso Universitário • Linhas Municipais', 'BRA2E19', 'Manhã', 'ativo'),
('Marcos Souza',  'marcos@onibus.com.br', '11223344556', '(81) 99522-3344', 'Senha@Forte123', '11223344556', 'D', 'Consórcio Fênix • Transporte Urbano',          'QNP4A88', 'Tarde', 'ativo'),
('Ana Paula Reis','ana.reis@onibus.com.br','44555666777','(81) 99433-4455', 'Senha@Forte123', '44555666777', 'D', 'Expresso Universitário • Linhas Municipais',    'MGF3D12', 'Noite', 'ativo');

-- ============================================================
-- SEED — admins
-- ============================================================
INSERT INTO admins (nome, email, cpf, senha, orgao, cargo, chave_adm, status) VALUES
('Helena Vasconcelos', 'helena@depar.gov.br', '55666777888', 'Senha@Forte123',
 'Prefeitura Municipal de Vitória de Santo Antão • PE', 'Supervisor de Frota', 'ADM-DEMO-0001-2026', 'ativo'),
('Filipe Admin',       'gestor@gmail.com',    '16316170440', 'Senha@Forte123',
 'Prefeitura Municipal de Vitória de Santo Antão • PE', 'Administrador do Sistema CCO', 'ADM-DEMO-0001-2026', 'ativo');

-- ============================================================
-- SEED — veículos, rotas, viagens
-- ============================================================
INSERT INTO veiculos (modelo, placa, status, motorista_id, linha, lote, ocupacao, capacidade, acao_secundaria) VALUES
('Caio Apache',         'BRA2E19',  'Em Rota',       1, 'Linha 04', 'Lote A', 32, 44, 'Atribuir Rota'),
('Mercedes-Benz O500',  'QNP4A88',  'Em Rota',       2, 'Linha 02', 'Lote A', 42, 44, 'Atribuir Rota'),
('Marcopolo Volare',    'RIO1C23',  'Parado',        NULL, 'Linha 08', 'Lote B', 0, 34, 'Atribuir Rota'),
('Mercedes-Benz OF1721','SPX7H05',  'Manutenção',    NULL, 'Linha 06', 'Lote B', 0, 46, 'Atribuir Rota'),
('Volvo B270F',         'MGF3D12',  'Em Rota',       3, 'Linha 11', 'Lote C', 28, 44, 'Atribuir Rota'),
('Iveco Daily',         'PEK9B77',  'Sem motorista', NULL, 'Linha 03', 'Lote C', 0, 26, 'Atribuir Rota');

INSERT INTO rotas (nome, linha, origem, destino, status, horario, veiculo_id) VALUES
('Linha 04 • Campus Central',       '04', 'Terminal Central',    'Campus Central',    'Em Rota',   '06:30 - 22:10', 1),
('Linha 02 • Terminal Sul',         '02', 'Terminal Sul',        'Campus Norte',      'Em Rota',   '05:50 - 23:00', 2),
('Linha 08 • Vila Acadêmica',       '08', 'Vila Acadêmica',      'Campus Central',    'Planejada', '07:00 - 21:40', 3),
('Linha 06 • Zona Industrial',      '06', 'Centro',              'Zona Industrial',   'Planejada', '06:00 - 20:00', NULL),
('Linha 11 • Bairro Universitário', '11', 'Bairro Universitário','Campus Norte',      'Em Rota',   '06:45 - 22:30', 5);

INSERT INTO viagens (rota_id, veiculo_id, motorista_id, data, partida, chegada, status, passageiros) VALUES
(1, 1, 1, CURDATE(), '06:30', '07:10', 'em_curso', 32),
(2, 2, 2, CURDATE(), '05:50', '06:35', 'em_curso', 42),
(5, 5, 3, CURDATE(), '06:45', '07:25', 'em_curso', 28),
(3, 3, NULL, CURDATE(), '07:00', '07:45', 'programada', 0);

-- ============================================================
-- SEED — reservas, alertas, solicitações, notificações
-- ============================================================
INSERT INTO reservas (aluno_id, viagem_id, data, status) VALUES
(1, 1, CURDATE(), 'confirmada'),
(2, 3, CURDATE(), 'confirmada'),
(1, 2, CURDATE(), 'waitlist');

INSERT INTO alertas (tipo, titulo, descricao, status) VALUES
('lotacao',    'Lotação crítica na Linha 04',   'Veículo BRA2E19 acima de 90% às 08:12.', 'pendente'),
('atraso',     'Atraso de 12 min na Linha 02',  'QNP4A88 parado no Terminal Sul.',        'pendente'),
('manutencao', 'Revisão vencida — SPX7H05',     'Freios em manutenção há 6 dias.',        'pendente'),
('sistema',    'Sincronização GPS restabelecida','Todos os 24 nós voltaram a responder.', 'resolvido');

INSERT INTO solicitacoes (tipo, nome, email, documento, detalhe, status) VALUES
('matricula', 'Lucas Ferreira',  'lucas@universidade.edu.br',  '2024100912', 'Passe estudantil — turno noite', 'pendente'),
('matricula', 'Mariana Costa',   'mariana@universidade.edu.br','2024100913', 'Transferência de campus',        'pendente'),
('motorista', 'Paulo Henrique',  'paulo@onibus.com.br',        'CNH 99887766', 'Vaga de motorista — Lote C',   'pendente');

INSERT INTO notificacoes (titulo, mensagem, lida, aluno_id, motorista_id, admin_id) VALUES
('Embarque Confirmado',   'Ônibus em rota até você — Linha 04.', 0, 1, NULL, NULL),
('Linha 02 com 2 vagas',  'Últimos assentos disponíveis agora.', 0, 1, NULL, NULL),
('Reserva confirmada',    'Sua vaga da Linha 08 está garantida.', 1, 2, NULL, NULL),
('Turno iniciado',        'Boa viagem! Lembre-se de checar a lotação.', 0, NULL, 1, NULL),
('Alerta de lotação',     'Linha 04 acima de 90% — reforço solicitado.', 0, NULL, NULL, 1);
