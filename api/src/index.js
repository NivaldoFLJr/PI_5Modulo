const express = require('express');
const cors    = require('cors');
const db      = require('./db');

const app = express();
app.use(cors());
app.use(express.json());

// ── Health check ──────────────────────────────────────────────
app.get('/health', (_, res) => res.json({ ok: true }));

// ── Métricas (home) ───────────────────────────────────────────
app.get('/metricas', async (_, res) => {
  try {
    const [[{ total_pedidos }]] = await db.query(
      'SELECT COUNT(*) AS total_pedidos FROM pedidos'
    );
    const [[{ faturado }]] = await db.query(
      'SELECT COALESCE(SUM(valor_total), 0) AS faturado FROM pedidos'
    );
    const [[{ lucro }]] = await db.query(`
      SELECT COALESCE(SUM(pi.quantidade * (pi.preco_unitario - p.preco_custo / p.quantidade)), 0) AS lucro
      FROM pedido_itens pi
      JOIN produtos p ON p.id = pi.produto_id
    `);
    const margem = faturado > 0 ? ((lucro / faturado) * 100).toFixed(1) : 0;

    res.json({ total_pedidos, faturado, lucro, margem });
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
  // itens: [{ produto_id, quantidade, preco_unitario }]
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

// ── Produtos / Relatórios ─────────────────────────────────────
app.get('/produtos', async (_, res) => {
  try {
    const [rows] = await db.query(
      'SELECT * FROM produtos ORDER BY criado_em DESC'
    );
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

// ─────────────────────────────────────────────────────────────
app.listen(3000, () => console.log('API rodando na porta 3000'));