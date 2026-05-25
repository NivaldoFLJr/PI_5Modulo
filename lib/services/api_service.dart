import 'api_client.dart';

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
        faturado:     double.parse(j['faturado'].toString()),
        lucro:        double.parse(j['lucro'].toString()),
        margem:       double.parse(j['margem'].toString()),
      );
}

class GraficoDia {
  final String dia;
  final double faturamento;
  final double custo;

  GraficoDia({required this.dia, required this.faturamento, required this.custo});

  double get lucro => faturamento - custo;

  factory GraficoDia.fromJson(Map<String, dynamic> j) => GraficoDia(
        dia:         j['dia'],
        faturamento: double.parse(j['faturamento'].toString()),
        custo:       double.parse(j['custo'].toString()),
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
        valorTotal: double.parse(j['valor_total'].toString()),
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

  double get lucro         => precoVenda - precoCusto;
  double get margemPct     => (lucro / precoVenda) * 100;
  double get custoUnitario => precoCusto / quantidade;

  factory ProdutoApi.fromJson(Map<String, dynamic> j) => ProdutoApi(
        id:         j['id'],
        nome:       j['nome'],
        unidade:    j['unidade'],
        precoVenda: double.parse(j['preco_venda'].toString()),
        precoCusto: double.parse(j['preco_custo'].toString()),
        quantidade: j['quantidade'],
        icone:      j['icone'] ?? 'basket',
        categoria:  j['categoria'] ?? 'salgado',
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

class Usuario {
  final int id;
  final String nome;
  final String email;
  final String role;
  final int? clienteId;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.role,
    this.clienteId,
  });

  bool get isAdmin => role == 'admin';

  factory Usuario.fromJson(Map<String, dynamic> j) => Usuario(
        id:        j['id'],
        nome:      j['nome']  ?? 'Usuário',
        email:     j['email'] ?? '',
        role:      j['role']  ?? 'cliente',
        clienteId: j['cliente_id'],
      );
}

class ApiService {
  static Future<Metricas> getMetricas({String periodo = 'todos'}) async {
    final data = await ApiClient.get('/metricas?periodo=$periodo');
    return Metricas.fromJson(data);
  }

  static Future<List<GraficoDia>> getGrafico() async {
    final data = await ApiClient.get('/relatorios/grafico') as List;
    return data.map((e) => GraficoDia.fromJson(e)).toList();
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

  static Future<Usuario> login(String email, String senha) async {
    final data = await ApiClient.post('/login', {
      'email': email,
      'senha': senha,
    });
    return Usuario.fromJson(data);
  }

  static Future<List<PedidoApi>> getPedidosPorCliente(int clienteId) async {
    final data = await ApiClient.get('/pedidos/cliente/$clienteId') as List;
    return data.map((e) => PedidoApi.fromJson(e)).toList();
  }

  static Future<Usuario> cadastrar(String nome, String email, String senha) async {
    final data = await ApiClient.post('/cadastro', {
      'nome':  nome,
      'email': email,
      'senha': senha,
    });
    return Usuario.fromJson(data);
  }
}