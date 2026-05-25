import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../components/app_scaffold.dart';
import '../../services/api_service.dart';
import '../../services/api_client.dart';

class CardapioPage extends StatefulWidget {
  final Usuario usuario;
  const CardapioPage({super.key, required this.usuario});

  @override
  State<CardapioPage> createState() => _CardapioPageState();
}

class _CardapioPageState extends State<CardapioPage> {
  List<ProdutoApi> _produtos = [];
  bool _loading = true;
  String? _erro;
  final Map<int, int> _quantidades = {};

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      setState(() { _loading = true; _erro = null; });
      final produtos = await ApiService.getProdutos();
      setState(() { _produtos = produtos; _loading = false; });
    } catch (e) {
      setState(() { _erro = 'Erro ao carregar cardápio'; _loading = false; });
    }
  }

  double get _total => _quantidades.entries.fold(0, (sum, e) {
        final produto = _produtos.firstWhere((p) => p.id == e.key);
        return sum + (produto.precoVenda / produto.quantidade) * e.value;
      });

  Future<void> _fazerPedido() async {
    final itensSelecionados =
        _quantidades.entries.where((e) => e.value > 0).toList();

    if (itensSelecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione ao menos um item')),
      );
      return;
    }

    try {
      final itens = itensSelecionados.map((e) {
        final produto = _produtos.firstWhere((p) => p.id == e.key);
        return {
          'produto_id': produto.id,
          'quantidade': e.value,
          'preco_unitario': produto.precoVenda / produto.quantidade,
        };
      }).toList();

      await ApiClient.post('/pedidos', {
        'cliente_id': widget.usuario.clienteId,
        'itens': itens,
      });

      setState(() => _quantidades.clear());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido realizado com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao realizar pedido')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppTheme.primary,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return AppScaffold(
      title: 'Cardápio',
      currentIndex: 1,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
              ? Center(child: Text(_erro!))
              : Stack(
                  children: [
                    ListView(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                      children: [
                        Text('O que deseja pedir?',
                            style: AppTheme.sectionTitleStyle),
                        const SizedBox(height: 18),
                        ..._produtos.map((produto) => Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(16),
                              decoration: AppTheme.cardDecoration,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(produto.nome,
                                            style: AppTheme.cardTitleStyle),
                                        Text(
                                          'R\$ ${(produto.precoVenda / produto.quantidade).toStringAsFixed(2).replaceAll('.', ',')} / un',
                                          style: AppTheme.cardSubtitleStyle,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () => setState(() {
                                          final q =
                                              _quantidades[produto.id] ?? 0;
                                          if (q > 0)
                                            _quantidades[produto.id] = q - 1;
                                        }),
                                        icon: const Icon(
                                            Icons.remove_circle_outline),
                                      ),
                                      Text(
                                        '${_quantidades[produto.id] ?? 0}',
                                        style: AppTheme.boldTextStyle,
                                      ),
                                      IconButton(
                                        onPressed: () => setState(() {
                                          _quantidades[produto.id] =
                                              (_quantidades[produto.id] ?? 0) +
                                                  1;
                                        }),
                                        icon: const Icon(
                                            Icons.add_circle_outline),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),

                    // ── Botão flutuante de pedido ───────────────
                    if (_total > 0)
                      Positioned(
                        bottom: 20,
                        left: 16,
                        right: 16,
                        child: ElevatedButton(
                          onPressed: _fazerPedido,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Fazer Pedido',
                                  style: AppTheme.buttonTextStyle),
                              Text(
                                'R\$ ${_total.toStringAsFixed(2).replaceAll('.', ',')}',
                                style: AppTheme.buttonTextStyle,
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