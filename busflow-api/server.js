const express = require('express');
const cors = require('cors');
const pool = require('./db');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// ==================== AUTENTICAÇÃO ====================

// Login Aluno
app.post('/api/login/aluno', async (req, res) => {
  try {
    const { email, cpf, senha } = req.body;
    if (!senha) return res.status(400).json({ erro: 'Senha é obrigatória' });

    let query = 'SELECT * FROM alunos WHERE senha = ?';
    let params = [senha];

    if (email) {
      query = 'SELECT * FROM alunos WHERE email = ? AND senha = ?';
      params = [email.toLowerCase().trim(), senha];
    } else if (cpf) {
      const cpfLimpo = cpf.replace(/\D/g, '');
      query = 'SELECT * FROM alunos WHERE cpf = ? AND senha = ?';
      params = [cpfLimpo, senha];
    }

    const [rows] = await pool.execute(query, params);
    if (rows.length === 0) {
      return res.status(401).json({ erro: 'Senha incorreta ou conta não encontrada' });
    }

    const aluno = rows[0];
    delete aluno.senha;
    res.json({ ok: true, tipo: 'aluno', dados: aluno });
  } catch (err) {
    console.error('Erro login aluno:', err);
    res.status(500).json({ erro: 'Erro interno do servidor' });
  }
});

// Login Motorista
app.post('/api/login/motorista', async (req, res) => {
  try {
    const { email, cpf, senha } = req.body;
    if (!senha) return res.status(400).json({ erro: 'Senha é obrigatória' });

    let query = 'SELECT * FROM motoristas WHERE senha = ?';
    let params = [senha];

    if (email) {
      query = 'SELECT * FROM motoristas WHERE email = ? AND senha = ?';
      params = [email.toLowerCase().trim(), senha];
    } else if (cpf) {
      const cpfLimpo = cpf.replace(/\D/g, '');
      query = 'SELECT * FROM motoristas WHERE cpf = ? AND senha = ?';
      params = [cpfLimpo, senha];
    }

    const [rows] = await pool.execute(query, params);
    if (rows.length === 0) {
      return res.status(401).json({ erro: 'Senha incorreta ou conta não encontrada' });
    }

    const motorista = rows[0];
    delete motorista.senha;
    res.json({ ok: true, tipo: 'motorista', dados: motorista });
  } catch (err) {
    console.error('Erro login motorista:', err);
    res.status(500).json({ erro: 'Erro interno do servidor' });
  }
});

// Login Admin
app.post('/api/login/admin', async (req, res) => {
  try {
    const { email, cpf, senha } = req.body;
    if (!senha) return res.status(400).json({ erro: 'Senha é obrigatória' });

    let query = 'SELECT * FROM admins WHERE senha = ?';
    let params = [senha];

    if (email) {
      query = 'SELECT * FROM admins WHERE email = ? AND senha = ?';
      params = [email.toLowerCase().trim(), senha];
    } else if (cpf) {
      const cpfLimpo = cpf.replace(/\D/g, '');
      query = 'SELECT * FROM admins WHERE cpf = ? AND senha = ?';
      params = [cpfLimpo, senha];
    }

    const [rows] = await pool.execute(query, params);
    if (rows.length === 0) {
      return res.status(401).json({ erro: 'Senha incorreta ou conta não encontrada' });
    }

    const admin = rows[0];
    delete admin.senha;
    res.json({ ok: true, tipo: 'admin', dados: admin });
  } catch (err) {
    console.error('Erro login admin:', err);
    res.status(500).json({ erro: 'Erro interno do servidor' });
  }
});

// ==================== CADASTRO ====================

// Cadastro Aluno
app.post('/api/alunos', async (req, res) => {
  try {
    const { nome, email, cpf, senha, ra, instituicao, telefone } = req.body;
    if (!nome || !email || !senha) {
      return res.status(400).json({ erro: 'Nome, email e senha são obrigatórios' });
    }

    const [existe] = await pool.execute(
      'SELECT id FROM alunos WHERE email = ? OR cpf = ?',
      [email.toLowerCase().trim(), (cpf || '').replace(/\D/g, '')]
    );
    if (existe.length > 0) {
      return res.status(409).json({ erro: 'Já existe uma conta com este email ou CPF' });
    }

    const [result] = await pool.execute(
      'INSERT INTO alunos (nome, email, cpf, senha, ra, instituicao, telefone) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [nome, email.toLowerCase().trim(), (cpf || '').replace(/\D/g, ''), senha, ra || null, instituicao || null, telefone || null]
    );

    res.json({ ok: true, id: result.insertId, mensagem: 'Aluno cadastrado com sucesso' });
  } catch (err) {
    console.error('Erro cadastro aluno:', err);
    res.status(500).json({ erro: 'Erro interno do servidor' });
  }
});

// Cadastro Motorista
app.post('/api/motoristas', async (req, res) => {
  try {
    const { nome, email, cpf, senha, cnh, empresa, telefone } = req.body;
    if (!nome || !email || !senha) {
      return res.status(400).json({ erro: 'Nome, email e senha são obrigatórios' });
    }

    const [existe] = await pool.execute(
      'SELECT id FROM motoristas WHERE email = ? OR cpf = ?',
      [email.toLowerCase().trim(), (cpf || '').replace(/\D/g, '')]
    );
    if (existe.length > 0) {
      return res.status(409).json({ erro: 'Já existe uma conta com este email ou CPF' });
    }

    const [result] = await pool.execute(
      'INSERT INTO motoristas (nome, email, cpf, senha, cnh, empresa, telefone) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [nome, email.toLowerCase().trim(), (cpf || '').replace(/\D/g, ''), senha, cnh || null, empresa || null, telefone || null]
    );

    res.json({ ok: true, id: result.insertId, mensagem: 'Motorista cadastrado com sucesso' });
  } catch (err) {
    console.error('Erro cadastro motorista:', err);
    res.status(500).json({ erro: 'Erro interno do servidor' });
  }
});

// Cadastro Admin
app.post('/api/admins', async (req, res) => {
  try {
    const { nome, email, cpf, senha, cargo, orgao, chave_adm } = req.body;
    if (!nome || !email || !senha) {
      return res.status(400).json({ erro: 'Nome, email e senha são obrigatórios' });
    }

    const [existe] = await pool.execute(
      'SELECT id FROM admins WHERE email = ? OR cpf = ?',
      [email.toLowerCase().trim(), (cpf || '').replace(/\D/g, '')]
    );
    if (existe.length > 0) {
      return res.status(409).json({ erro: 'Já existe uma conta com este email ou CPF' });
    }

    const [result] = await pool.execute(
      'INSERT INTO admins (nome, email, cpf, senha, cargo, orgao, chave_adm) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [nome, email.toLowerCase().trim(), (cpf || '').replace(/\D/g, ''), senha, cargo || null, orgao || null, chave_adm || null]
    );

    res.json({ ok: true, id: result.insertId, mensagem: 'Administrador cadastrado com sucesso' });
  } catch (err) {
    console.error('Erro cadastro admin:', err);
    res.status(500).json({ erro: 'Erro interno do servidor' });
  }
});

// ==================== LISTAGENS ====================

// Listar alunos
app.get('/api/alunos', async (req, res) => {
  try {
    const [rows] = await pool.execute('SELECT id, nome, email, cpf, ra, instituicao, telefone, status, criado_em FROM alunos');
    res.json({ ok: true, dados: rows });
  } catch (err) {
    console.error('Erro listar alunos:', err);
    res.status(500).json({ erro: 'Erro interno do servidor' });
  }
});

// Listar motoristas
app.get('/api/motoristas', async (req, res) => {
  try {
    const [rows] = await pool.execute('SELECT id, nome, email, cpf, cnh, categoria_cnh, empresa, veiculo, telefone, status, criado_em FROM motoristas');
    res.json({ ok: true, dados: rows });
  } catch (err) {
    console.error('Erro listar motoristas:', err);
    res.status(500).json({ erro: 'Erro interno do servidor' });
  }
});

// Listar admins
app.get('/api/admins', async (req, res) => {
  try {
    const [rows] = await pool.execute('SELECT id, nome, email, cpf, orgao, cargo, chave_adm, status, criado_em FROM admins');
    res.json({ ok: true, dados: rows });
  } catch (err) {
    console.error('Erro listar admins:', err);
    res.status(500).json({ erro: 'Erro interno do servidor' });
  }
});

// Listar veículos
app.get('/api/veiculos', async (req, res) => {
  try {
    const [rows] = await pool.execute(`
      SELECT v.*, m.nome as motorista_nome 
      FROM veiculos v 
      LEFT JOIN motoristas m ON v.motorista_id = m.id
    `);
    res.json({ ok: true, dados: rows });
  } catch (err) {
    console.error('Erro listar veículos:', err);
    res.status(500).json({ erro: 'Erro interno do servidor' });
  }
});

// Listar rotas
app.get('/api/rotas', async (req, res) => {
  try {
    const [rows] = await pool.execute('SELECT * FROM rotas');
    res.json({ ok: true, dados: rows });
  } catch (err) {
    console.error('Erro listar rotas:', err);
    res.status(500).json({ erro: 'Erro interno do servidor' });
  }
});

// Listar viagens
app.get('/api/viagens', async (req, res) => {
  try {
    const [rows] = await pool.execute(`
      SELECT v.*, m.nome as motorista_nome, r.nome as rota_nome
      FROM viagens v
      LEFT JOIN motoristas m ON v.motorista_id = m.id
      LEFT JOIN rotas r ON v.rota_id = r.id
    `);
    res.json({ ok: true, dados: rows });
  } catch (err) {
    console.error('Erro listar viagens:', err);
    res.status(500).json({ erro: 'Erro interno do servidor' });
  }
});

// Listar reservas
app.get('/api/reservas', async (req, res) => {
  try {
    const [rows] = await pool.execute(`
      SELECT r.*, a.nome as aluno_nome, v.placa as veiculo_placa
      FROM reservas r
      LEFT JOIN alunos a ON r.aluno_id = a.id
      LEFT JOIN viagens vi ON r.viagem_id = vi.id
      LEFT JOIN veiculos v ON vi.veiculo_id = v.id
    `);
    res.json({ ok: true, dados: rows });
  } catch (err) {
    console.error('Erro listar reservas:', err);
    res.status(500).json({ erro: 'Erro interno do servidor' });
  }
});

// Listar notificações
app.get('/api/notificacoes', async (req, res) => {
  try {
    const [rows] = await pool.execute('SELECT * FROM notificacoes ORDER BY criado_em DESC');
    res.json({ ok: true, dados: rows });
  } catch (err) {
    console.error('Erro listar notificações:', err);
    res.status(500).json({ erro: 'Erro interno do servidor' });
  }
});

// Listar alertas
app.get('/api/alertas', async (req, res) => {
  try {
    const [rows] = await pool.execute('SELECT * FROM alertas ORDER BY criado_em DESC');
    res.json({ ok: true, dados: rows });
  } catch (err) {
    console.error('Erro listar alertas:', err);
    res.status(500).json({ erro: 'Erro interno do servidor' });
  }
});

// Listar solicitações
app.get('/api/solicitacoes', async (req, res) => {
  try {
    const [rows] = await pool.execute(`
      SELECT s.*, a.nome as aluno_nome
      FROM solicitacoes s
      LEFT JOIN alunos a ON s.aluno_id = a.id
    `);
    res.json({ ok: true, dados: rows });
  } catch (err) {
    console.error('Erro listar solicitações:', err);
    res.status(500).json({ erro: 'Erro interno do servidor' });
  }
});

// ==================== STATUS ====================

app.get('/api/status', (req, res) => {
  res.json({ ok: true, mensagem: 'API BusFlow online', timestamp: new Date().toISOString() });
});

// ==================== INICIAR SERVIDOR ====================

app.listen(PORT, () => {
  console.log(`🚀 API BusFlow rodando em http://localhost:${PORT}`);
  console.log(`📋 Endpoints disponíveis:`);
  console.log(`   POST /api/login/aluno`);
  console.log(`   POST /api/login/motorista`);
  console.log(`   POST /api/login/admin`);
  console.log(`   POST /api/alunos`);
  console.log(`   POST /api/motoristas`);
  console.log(`   POST /api/admins`);
  console.log(`   GET  /api/alunos`);
  console.log(`   GET  /api/motoristas`);
  console.log(`   GET  /api/admins`);
  console.log(`   GET  /api/veiculos`);
  console.log(`   GET  /api/rotas`);
  console.log(`   GET  /api/viagens`);
  console.log(`   GET  /api/reservas`);
  console.log(`   GET  /api/notificacoes`);
  console.log(`   GET  /api/alertas`);
  console.log(`   GET  /api/solicitacoes`);
  console.log(`   GET  /api/status`);
});
