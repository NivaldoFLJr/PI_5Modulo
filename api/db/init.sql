CREATE TABLE IF NOT EXISTS clientes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS produtos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  unidade VARCHAR(20) NOT NULL,        -- ex: "100 un"
  preco_venda DECIMAL(10,2) NOT NULL,
  preco_custo DECIMAL(10,2) NOT NULL,
  quantidade INT NOT NULL DEFAULT 0,
  icone VARCHAR(50) DEFAULT 'basket',  -- nome do ícone
  categoria VARCHAR(50) DEFAULT 'salgado',
  criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS estoque (
  id INT AUTO_INCREMENT PRIMARY KEY,
  produto_id INT NOT NULL,
  quantidade_atual INT NOT NULL DEFAULT 0,
  quantidade_minima INT NOT NULL DEFAULT 10,
  atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (produto_id) REFERENCES produtos(id)
);

CREATE TABLE IF NOT EXISTS pedidos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  cliente_id INT NOT NULL,
  status ENUM('Em preparo', 'Finalizado', 'Entregue') DEFAULT 'Em preparo',
  valor_total DECIMAL(10,2) NOT NULL DEFAULT 0,
  criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

CREATE TABLE IF NOT EXISTS pedido_itens (
  id INT AUTO_INCREMENT PRIMARY KEY,
  pedido_id INT NOT NULL,
  produto_id INT NOT NULL,
  quantidade INT NOT NULL,
  preco_unitario DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (pedido_id) REFERENCES pedidos(id),
  FOREIGN KEY (produto_id) REFERENCES produtos(id)
);

-- Dados iniciais
INSERT INTO clientes (nome) VALUES ('Maria Clara'), ('João Pedro'), ('Fernanda');

INSERT INTO produtos (nome, unidade, preco_venda, preco_custo, quantidade, icone, categoria) VALUES
  ('Coxinha',         '100 un', 100.00, 55.00, 100, 'basket',   'salgado'),
  ('Mini Pizza',      '50 un',   85.00, 48.00,  50, 'pizza',    'salgado'),
  ('Kibe com Catupiry','50 un',  75.00, 42.00,  50, 'set_meal', 'salgado'),
  ('Enroladinho',     '30 un',   90.00, 50.00,  30, 'basket',   'salgado');

INSERT INTO estoque (produto_id, quantidade_atual, quantidade_minima) VALUES
  (1, 100, 20), (2, 50, 10), (3, 50, 10), (4, 30, 10);

INSERT INTO pedidos (cliente_id, status, valor_total) VALUES
  (1, 'Em preparo',  180.00),
  (2, 'Finalizado',  320.00),
  (3, 'Entregue',     90.00);

INSERT INTO pedido_itens (pedido_id, produto_id, quantidade, preco_unitario) VALUES
  (1, 1, 50, 1.00), (1, 3, 20, 1.50),
  (2, 1, 100, 1.00), (2, 4, 100, 1.50),
  (3, 4, 30, 1.00);

CREATE TABLE IF NOT EXISTS usuarios (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  senha VARCHAR(255) NOT NULL,
  role ENUM('admin', 'cliente') DEFAULT 'cliente',
  cliente_id INT,
  criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

-- Admin padrão (senha: admin123)
INSERT INTO usuarios (nome, email, senha, role) VALUES
  ('Administrador', 'admin@admin.com', 'admin123', 'admin');