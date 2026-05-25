import 'api_client.dart';

// ── Modelos ───────────────────────────────────────────────────

class Metricas {
  final int totalPedidos;
  final double faturado;
  final double lucro;
  final double margem;

  Metricas({
    required this.totalPedidos,
    required this.faturado,
    required this.lucro,
    required this.margem,
  });

  factory Metricas.fromJson(Map<String, dynamic> j) => Metricas(
        totalPedidos: j['total_pedidos'],
        faturado:     (j['faturado'] as num).toDouble(),
        lucro:        (j['lucro'] as num).toDouble(),
        margem:       double.parse(j['margem'].toString()),
      );
}

class PedidoApi {
  final int id;
  final String cliente;
  final String itens;
  final String status;
  final double valorTotal;

  PedidoApi({
    required this.id,
    required this.cliente,
    required this.itens,
    required this.status,
    required this.valorTotal,
  });

  factory PedidoApi.fromJson(Map<String, dynamic> j) => PedidoApi(
        id:         j['id'],
        cliente:    j['cliente'],
        itens:      j['itens'] ?? '',
        status:     j['status'],
        valorTotal: (j['valor_total'] as num).toDouble(),
      );
}

class ProdutoApi {
  final int id;
  final String nome;
  final String unidade;
  final double precoVenda;
  final double precoCusto;
  final int quantidade;
  final String icone;
  final String categoria;

  ProdutoApi({
    required this.id,
    required this.nome,
    required this.unidade,
    required this.precoVenda,
    required this.precoCusto,
    required this.quantidade,
    required this.icone,
    required this.categoria,
  });

  double get lucro      => precoVenda - precoCusto;
  double get margemPct  => (lucro / precoVenda) * 100;
  double get custoUnitario => precoCusto / quantidade;

  factory ProdutoApi.fromJson(Map<String, dynamic> j) => ProdutoApi(
        id:          j['id'],
        nome:        j['nome'],
        unidade:     j['unidade'],
        precoVenda:  (j['preco_venda'] as num).toDouble(),
        precoCusto:  (j['preco_custo'] as num).toDouble(),
        quantidade:  j['quantidade'],
        icone:       j['icone'] ?? 'basket',
        categoria:   j['categoria'] ?? 'salgado',
      );
}

class EstoqueItem {
  final int id;
  final String nome;
  final String unidade;
  final int quantidadeAtual;
  final int quantidadeMinima;

  EstoqueItem({
    required this.id,
    required this.nome,
    required this.unidade,
    required this.quantidadeAtual,
    required this.quantidadeMinima,
  });

  bool get estaBaixo => quantidadeAtual <= quantidadeMinima;

  factory EstoqueItem.fromJson(Map<String, dynamic> j) => EstoqueItem(
        id:               j['id'],
        nome:             j['nome'],
        unidade:          j['unidade'],
        quantidadeAtual:  j['quantidade_atual'],
        quantidadeMinima: j['quantidade_minima'],
      );
}

class ClienteApi {
  final int id;
  final String nome;

  ClienteApi({required this.id, required this.nome});

  factory ClienteApi.fromJson(Map<String, dynamic> j) =>
      ClienteApi(id: j['id'], nome: j['nome']);
}

// ── Serviços ──────────────────────────────────────────────────

class ApiService {
  static Future<Metricas> getMetricas() async {
    final data = await ApiClient.get('/metricas');
    return Metricas.fromJson(data);
  }

  static Future<List<PedidoApi>> getPedidos() async {
    final data = await ApiClient.get('/pedidos') as List;
    return data.map((e) => PedidoApi.fromJson(e)).toList();
  }

  static Future<void> atualizarStatusPedido(int id, String status) async {
    await ApiClient.patch('/pedidos/$id/status', {'status': status});
  }

  static Future<List<ProdutoApi>> getProdutos() async {
    final data = await ApiClient.get('/produtos') as List;
    return data.map((e) => ProdutoApi.fromJson(e)).toList();
  }

  static Future<List<EstoqueItem>> getEstoque() async {
    final data = await ApiClient.get('/estoque') as List;
    return data.map((e) => EstoqueItem.fromJson(e)).toList();
  }

  static Future<List<ClienteApi>> getClientes() async {
    final data = await ApiClient.get('/clientes') as List;
    return data.map((e) => ClienteApi.fromJson(e)).toList();
  }

  static Future<void> criarCliente(String nome) async {
    await ApiClient.post('/clientes', {'nome': nome});
  }
}