const express = require('express');
const cors    = require('cors');
const db      = require('./db');

const app = express();
app.use(cors());
app.use(express.json());

// ── Helpers ───────────────────────────────────────────────────
function filtroData(periodo) {
  switch (periodo) {
    case 'hoje':   return 'DATE(criado_em) = CURDATE()';
    case 'semana': return 'criado_em >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)';
    case 'mes':    return 'criado_em >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)';
    default:       return '1=1';
  }
}

// ── Health check ──────────────────────────────────────────────
app.get('/health', (_, res) => res.json({ ok: true }));

// ── Métricas com filtro de período ────────────────────────────
app.get('/metricas', async (req, res) => {
  try {
    const periodo = req.query.periodo || 'todos';
    const filtro  = filtroData(periodo);

    const [[{ total_pedidos }]] = await db.query(
      `SELECT COUNT(*) AS total_pedidos FROM pedidos WHERE ${filtro}`
    );
    const [[{ faturado }]] = await db.query(
      `SELECT COALESCE(SUM(valor_total), 0) AS faturado FROM pedidos WHERE ${filtro}`
    );
    const [[{ lucro }]] = await db.query(`
      SELECT COALESCE(SUM(pi.quantidade * (pi.preco_unitario - p.preco_custo / p.quantidade)), 0) AS lucro
      FROM pedido_itens pi
      JOIN produtos p ON p.id = pi.produto_id
      JOIN pedidos ped ON ped.id = pi.pedido_id
      WHERE ${filtro.replace('criado_em', 'ped.criado_em').replace('DATE(criado_em)', 'DATE(ped.criado_em)')}
    `);
    const margem = faturado > 0 ? ((lucro / faturado) * 100).toFixed(1) : 0;

    res.json({ total_pedidos, faturado, lucro, margem });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ── Dados do gráfico de barras (últimos 7 dias) ───────────────
app.get('/relatorios/grafico', async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT
        DATE(p.criado_em) AS dia,
        COALESCE(SUM(p.valor_total), 0) AS faturamento,
        COALESCE(SUM(pi.quantidade * (pr.preco_custo / pr.quantidade)), 0) AS custo
      FROM pedidos p
      JOIN pedido_itens pi ON pi.pedido_id = p.id
      JOIN produtos pr ON pr.id = pi.produto_id
      WHERE p.criado_em >= DATE_SUB(CURDATE(), INTERVAL 6 DAY)
      GROUP BY DATE(p.criado_em)
      ORDER BY dia ASC
    `);

    // Preenche os 7 dias mesmo se não houver pedidos
    const resultado = [];
    for (let i = 6; i >= 0; i--) {
      const data = new Date();
      data.setDate(data.getDate() - i);
      const diaStr = data.toISOString().split('T')[0];
      const encontrado = rows.find(r => {
        const d = new Date(r.dia);
        return d.toISOString().split('T')[0] === diaStr;
      });
      const diasSemana = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
      resultado.push({
        dia: diasSemana[data.getDay()],
        faturamento: encontrado ? parseFloat(encontrado.faturamento) : 0,
        custo: encontrado ? parseFloat(encontrado.custo) : 0,
      });
    }

    res.json(resultado);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ── Pedidos ───────────────────────────────────────────────────
app.get('/pedidos', async (_, res) => {
  try {
    const [rows] = await db.query(`
      SELECT
        p.id, c.nome AS cliente, p.status, p.valor_total, p.criado_em,
        GROUP_CONCAT(CONCAT(pi.quantidade, 'x ', pr.nome) SEPARATOR ' • ') AS itens
      FROM pedidos p
      JOIN clientes c ON c.id = p.cliente_id
      JOIN pedido_itens pi ON pi.pedido_id = p.id
      JOIN produtos pr ON pr.id = pi.produto_id
      GROUP BY p.id
      ORDER BY p.criado_em DESC
    `);
    res.json(rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post('/pedidos', async (req, res) => {
  const { cliente_id, itens } = req.body;
  const conn = await db.getConnection();
  try {
    await conn.beginTransaction();
    const valor_total = itens.reduce(
      (s, i) => s + i.quantidade * i.preco_unitario, 0
    );
    const [{ insertId }] = await conn.query(
      'INSERT INTO pedidos (cliente_id, valor_total) VALUES (?, ?)',
      [cliente_id, valor_total]
    );
    for (const item of itens) {
      await conn.query(
        'INSERT INTO pedido_itens (pedido_id, produto_id, quantidade, preco_unitario) VALUES (?,?,?,?)',
        [insertId, item.produto_id, item.quantidade, item.preco_unitario]
      );
    }
    await conn.commit();
    res.status(201).json({ id: insertId });
  } catch (e) {
    await conn.rollback();
    res.status(500).json({ error: e.message });
  } finally {
    conn.release();
  }
});

app.patch('/pedidos/:id/status', async (req, res) => {
  try {
    await db.query('UPDATE pedidos SET status = ? WHERE id = ?', [
      req.body.status, req.params.id,
    ]);
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ── Produtos ──────────────────────────────────────────────────
app.get('/produtos', async (_, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM produtos ORDER BY criado_em DESC');
    res.json(rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post('/produtos', async (req, res) => {
  const { nome, unidade, preco_venda, preco_custo, quantidade, icone, categoria } = req.body;
  try {
    const [{ insertId }] = await db.query(
      'INSERT INTO produtos (nome, unidade, preco_venda, preco_custo, quantidade, icone, categoria) VALUES (?,?,?,?,?,?,?)',
      [nome, unidade, preco_venda, preco_custo, quantidade, icone, categoria]
    );
    res.status(201).json({ id: insertId });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ── Estoque ───────────────────────────────────────────────────
app.get('/estoque', async (_, res) => {
  try {
    const [rows] = await db.query(`
      SELECT e.id, p.nome, p.unidade, p.icone, p.categoria,
             e.quantidade_atual, e.quantidade_minima, e.atualizado_em
      FROM estoque e
      JOIN produtos p ON p.id = e.produto_id
      ORDER BY p.nome
    `);
    res.json(rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.patch('/estoque/:id', async (req, res) => {
  try {
    await db.query(
      'UPDATE estoque SET quantidade_atual = ? WHERE id = ?',
      [req.body.quantidade_atual, req.params.id]
    );
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post('/estoque', async (req, res) => {
  const { produto_id, quantidade_atual, quantidade_minima } = req.body;
  try {
    const [{ insertId }] = await db.query(
      'INSERT INTO estoque (produto_id, quantidade_atual, quantidade_minima) VALUES (?, ?, ?)',
      [produto_id, quantidade_atual, quantidade_minima ?? 10]
    );
    res.status(201).json({ id: insertId });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ── Clientes ──────────────────────────────────────────────────
app.get('/clientes', async (_, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM clientes ORDER BY nome');
    res.json(rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post('/clientes', async (req, res) => {
  try {
    const [{ insertId }] = await db.query(
      'INSERT INTO clientes (nome) VALUES (?)', [req.body.nome]
    );
    res.status(201).json({ id: insertId });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ── Auth ──────────────────────────────────────────────────────
app.post('/login', async (req, res) => {
  const { email, senha } = req.body;
  try {
    const [[usuario]] = await db.query(
      'SELECT * FROM usuarios WHERE email = ? AND senha = ?',
      [email, senha]
    );
    if (!usuario) {
      return res.status(401).json({ error: 'Email ou senha inválidos' });
    }
    res.json({
      id:         usuario.id,
      nome:       usuario.nome,
      email:      usuario.email,
      role:       usuario.role,
      cliente_id: usuario.cliente_id,
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ── Pedidos por cliente ───────────────────────────────────────
app.get('/pedidos/cliente/:clienteId', async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT
        p.id, c.nome AS cliente, p.status, p.valor_total, p.criado_em,
        GROUP_CONCAT(CONCAT(pi.quantidade, 'x ', pr.nome) SEPARATOR ' • ') AS itens
      FROM pedidos p
      JOIN clientes c ON c.id = p.cliente_id
      JOIN pedido_itens pi ON pi.pedido_id = p.id
      JOIN produtos pr ON pr.id = pi.produto_id
      WHERE p.cliente_id = ?
      GROUP BY p.id
      ORDER BY p.criado_em DESC
    `, [req.params.clienteId]);
    res.json(rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ── Cadastro ──────────────────────────────────────────────────
app.post('/cadastro', async (req, res) => {
  const { nome, email, senha } = req.body;
  const conn = await db.getConnection();
  try {
    await conn.beginTransaction();
    const [{ insertId: clienteId }] = await conn.query(
      'INSERT INTO clientes (nome) VALUES (?)', [nome]
    );
    const [{ insertId: usuarioId }] = await conn.query(
      'INSERT INTO usuarios (nome, email, senha, role, cliente_id) VALUES (?, ?, ?, "cliente", ?)',
      [nome, email, senha, clienteId]
    );
    await conn.commit();
    res.status(201).json({ id: usuarioId, nome, email, role: 'cliente', cliente_id: clienteId });
  } catch (e) {
    await conn.rollback();
    if (e.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({ error: 'Email já cadastrado' });
    }
    res.status(500).json({ error: e.message });
  } finally {
    conn.release();
  }
});

app.listen(3000, () => console.log('API rodando na porta 3000'));