import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_aplicativo/main.dart';
import '../../theme/app_theme.dart';
import '../../components/app_bottom_nav.dart';
import '../../components/app_scaffold.dart';
import '../../services/api_service.dart';
import '../relatorios/relatorios_page.dart';

class PedidosPage extends StatelessWidget {
  const PedidosPage({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppTheme.primary,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Theme(
      data: AppTheme.theme,
      child: const _PedidosHome(),
    );
  }
}

class _PedidosHome extends StatefulWidget {
  const _PedidosHome();

  @override
  State<_PedidosHome> createState() => _PedidosHomeState();
}

class _PedidosHomeState extends State<_PedidosHome> {
  final int _navIndex = 2;

  // ── Estado ────────────────────────────────────────────────────
  List<PedidoApi> _pedidos = [];
  Metricas? _metricas;
  bool _loading = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      setState(() {
        _loading = true;
        _erro = null;
      });

      final results = await Future.wait([
        ApiService.getPedidos(),
        ApiService.getMetricas(),
      ]);

      setState(() {
        _pedidos = results[0] as List<PedidoApi>;
        _metricas = results[1] as Metricas;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _erro = 'Erro ao carregar pedidos';
        _loading = false;
      });
    }
  }

  Future<void> _atualizarStatus(int id, String novoStatus) async {
    try {
      await ApiService.atualizarStatusPedido(id, novoStatus);
      await _carregar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar status')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Pedidos',
      currentIndex: 2,
      bottomNavigationBar: AppBottomNav(
        currentIndex: _navIndex,
        onTap: (index) {
          if (index == _navIndex) return;

          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MyApp()),
              );
              break;
            case 1:
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const PedidosPage()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const RelatoriosPage()),
              );
              break;
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryDeep,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPedidoPage()),
          );
          // Recarrega ao voltar da tela de adicionar
          _carregar();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Hero Banner ─────────────────────────────────────────
          _HeroBanner(
            metricas: _metricas,
            loading: _loading,
          ),

          // ── Lista ───────────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              onRefresh: _carregar,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _erro != null
                      ? _ErroWidget(
                          mensagem: _erro!,
                          onRetry: _carregar,
                        )
                      : _pedidos.isEmpty
                          ? const _EmptyWidget()
                          : ListView(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 20, 16, 110),
                              children: [
                                Text(
                                  'Pedidos Recentes',
                                  style: AppTheme.sectionTitleStyle,
                                ),
                                const SizedBox(height: 18),
                                ..._pedidos.map(
                                  (pedido) => PedidoCard(
                                    pedido: pedido,
                                    onStatusChanged: (novoStatus) =>
                                        _atualizarStatus(
                                            pedido.id, novoStatus),
                                  ),
                                ),
                              ],
                            ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero Banner ───────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final Metricas? metricas;
  final bool loading;

  const _HeroBanner({
    required this.metricas,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final totalPedidos =
        loading ? '...' : (metricas?.totalPedidos.toString() ?? '--');
    final faturado = loading
        ? '...'
        : metricas != null
            ? 'R\$ ${metricas!.faturado.toStringAsFixed(2).replaceAll('.', ',')}'
            : '--';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: const BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: _metric('PEDIDOS', totalPedidos)),
          const SizedBox(width: 12),
          Expanded(child: _metric('FATURADO', faturado)),
        ],
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.metricDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTheme.metricLabelStyle),
          const SizedBox(height: 8),
          Text(value, style: AppTheme.metricValueStyle),
        ],
      ),
    );
  }
}

// ── Card de pedido ────────────────────────────────────────────────────────────

class PedidoCard extends StatelessWidget {
  final PedidoApi pedido;
  final ValueChanged<String> onStatusChanged;

  const PedidoCard({
    super.key,
    required this.pedido,
    required this.onStatusChanged,
  });

  Color get _statusColor {
    switch (pedido.status) {
      case 'Finalizado':
        return AppTheme.green;
      case 'Entregue':
        return AppTheme.primaryDeep;
      default:
        return AppTheme.orange;
    }
  }

  void _showStatusMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alterar status', style: AppTheme.sectionTitleStyle),
            const SizedBox(height: 16),
            for (final status in ['Em preparo', 'Finalizado', 'Entregue'])
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: _colorForStatus(status).withOpacity(0.15),
                  child: Icon(
                    _iconForStatus(status),
                    color: _colorForStatus(status),
                    size: 20,
                  ),
                ),
                title: Text(status, style: AppTheme.cardTitleStyle),
                trailing: pedido.status == status
                    ? const Icon(Icons.check, color: AppTheme.primaryDeep)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  if (pedido.status != status) onStatusChanged(status);
                },
              ),
          ],
        ),
      ),
    );
  }

  Color _colorForStatus(String s) {
    switch (s) {
      case 'Finalizado':
        return AppTheme.green;
      case 'Entregue':
        return AppTheme.primaryDeep;
      default:
        return AppTheme.orange;
    }
  }

  IconData _iconForStatus(String s) {
    switch (s) {
      case 'Finalizado':
        return Icons.check_circle_outline;
      case 'Entregue':
        return Icons.local_shipping_outlined;
      default:
        return Icons.restaurant_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: AppTheme.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: AppTheme.primaryDeep,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pedido.cliente, style: AppTheme.cardTitleStyle),
                  const SizedBox(height: 4),
                  Text(pedido.itens, style: AppTheme.cardSubtitleStyle),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _showStatusMenu(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            pedido.status,
                            style: TextStyle(
                              color: _statusColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.expand_more,
                            size: 14,
                            color: _statusColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'R\$ ${pedido.valorTotal.toStringAsFixed(2).replaceAll('.', ',')}',
              style: AppTheme.cardValueStyle,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _ErroWidget extends StatelessWidget {
  final String mensagem;
  final VoidCallback onRetry;

  const _ErroWidget({required this.mensagem, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppTheme.red, size: 48),
            const SizedBox(height: 12),
            Text(mensagem, style: AppTheme.cardSubtitleStyle),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyWidget extends StatelessWidget {
  const _EmptyWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined,
                color: AppTheme.textMuted, size: 48),
            const SizedBox(height: 12),
            Text('Nenhum pedido encontrado',
                style: AppTheme.cardSubtitleStyle),
          ],
        ),
      ),
    );
  }
}

// ── Adicionar pedido ──────────────────────────────────────────────────────────

class AddPedidoPage extends StatefulWidget {
  const AddPedidoPage({super.key});

  @override
  State<AddPedidoPage> createState() => _AddPedidoPageState();
}

class _AddPedidoPageState extends State<AddPedidoPage> {
  List<ProdutoApi> _produtos = [];
  List<ClienteApi> _clientes = [];
  ClienteApi? _clienteSelecionado;
  bool _loading = true;
  bool _salvando = false;
  String? _erro;
  String _novoCliente = '';

  // quantidade selecionada por produto_id
  final Map<int, int> _quantidades = {};

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      setState(() => _loading = true);

      final results = await Future.wait([
        ApiService.getProdutos(),
        ApiService.getClientes(),
      ]);

      setState(() {
        _produtos = results[0] as List<ProdutoApi>;
        _clientes = results[1] as List<ClienteApi>;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _erro = 'Erro ao carregar dados';
        _loading = false;
      });
    }
  }

  Future<void> _salvar() async {
    if (_clienteSelecionado == null && _novoCliente.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione ou informe um cliente')),
      );
      return;
    }

    final itensSelecionados = _quantidades.entries
        .where((e) => e.value > 0)
        .toList();

    if (itensSelecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione ao menos um item')),
      );
      return;
    }

    setState(() => _salvando = true);

    try {
      int clienteId = _clienteSelecionado!.id;

      // Cria cliente novo se necessário
      if (_novoCliente.trim().isNotEmpty) {
        await ApiService.criarCliente(_novoCliente.trim());
        final clientes = await ApiService.getClientes();
        clienteId = clientes.last.id;
      }

      final itens = itensSelecionados.map((e) {
        final produto = _produtos.firstWhere((p) => p.id == e.key);
        return {
          'produto_id': produto.id,
          'quantidade': e.value,
          'preco_unitario':
              (produto.precoVenda / produto.quantidade),
        };
      }).toList();

      await ApiClient.post('/pedidos', {
        'cliente_id': clienteId,
        'itens': itens,
      });

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar pedido')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Novo Pedido',
      currentIndex: 2,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
              ? Center(child: Text(_erro!))
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // ── Cliente ───────────────────────────────────────
                    Text('Cliente', style: AppTheme.sectionTitleStyle),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: AppTheme.cardDecoration,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<ClienteApi>(
                          value: _clienteSelecionado,
                          hint: const Text('Selecione um cliente'),
                          isExpanded: true,
                          items: [
                            ..._clientes.map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(c.nome),
                              ),
                            ),
                          ],
                          onChanged: (c) =>
                              setState(() => _clienteSelecionado = c),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Ou digite um novo cliente...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      onChanged: (v) => _novoCliente = v,
                    ),

                    const SizedBox(height: 24),

                    // ── Itens ─────────────────────────────────────────
                    Text('Escolha os itens', style: AppTheme.sectionTitleStyle),
                    const SizedBox(height: 12),
                    ..._produtos.map(
                      (produto) => Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: AppTheme.cardDecoration,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(produto.nome,
                                      style: AppTheme.cardTitleStyle),
                                  Text(
                                    'R\$ ${produto.precoVenda.toStringAsFixed(2).replaceAll('.', ',')}',
                                    style: AppTheme.cardSubtitleStyle,
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      final q =
                                          _quantidades[produto.id] ?? 0;
                                      if (q > 0) {
                                        _quantidades[produto.id] = q - 1;
                                      }
                                    });
                                  },
                                  icon: const Icon(
                                      Icons.remove_circle_outline),
                                ),
                                Text(
                                  '${_quantidades[produto.id] ?? 0}',
                                  style: AppTheme.boldTextStyle,
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _quantidades[produto.id] =
                                          (_quantidades[produto.id] ?? 0) +
                                              1;
                                    });
                                  },
                                  icon: const Icon(
                                      Icons.add_circle_outline),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _salvando ? null : _salvar,
                        child: _salvando
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Text('Salvar Pedido',
                                style: AppTheme.buttonTextStyle),
                      ),
                    ),
                  ],
                ),
    );
  }
}