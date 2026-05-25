import 'package:flutter/material.dart';
import 'package:home_aplicativo/main.dart';
import 'package:intl/intl.dart';

import '../../theme/app_theme.dart';
import '../../components/app_scaffold.dart';
import '../../components/app_bottom_nav.dart';
import '../../services/api_service.dart';

import '../pedidos/pedidos_page.dart';

// ── Utilitário de formatação ──────────────────────────────────────────────────

String fmt(double value) {
  return NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  ).format(value);
}

// ── Mapeamento de ícone por nome ──────────────────────────────────────────────

IconData _iconePorNome(String nome) {
  switch (nome) {
    case 'pizza':
      return Icons.local_pizza_outlined;
    case 'set_meal':
      return Icons.set_meal_outlined;
    default:
      return Icons.shopping_basket_outlined;
  }
}

Color _iconBgPorCategoria(String categoria, int index) {
  final cores = [AppTheme.lightBlue, AppTheme.orangeLight, AppTheme.greenLight];
  return cores[index % cores.length];
}

Color _iconColorPorCategoria(String categoria, int index) {
  final cores = [AppTheme.primaryDeep, AppTheme.orange, AppTheme.green];
  return cores[index % cores.length];
}

// ── Página principal ──────────────────────────────────────────────────────────

class RelatoriosPage extends StatefulWidget {
  const RelatoriosPage({super.key});

  @override
  State<RelatoriosPage> createState() => _RelatoriosPageState();
}

class _RelatoriosPageState extends State<RelatoriosPage> {
  final int _navIndex = 3;

  List<ProdutoApi> _produtos = [];
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
        ApiService.getProdutos(),
        ApiService.getMetricas(),
      ]);

      setState(() {
        _produtos = results[0] as List<ProdutoApi>;
        _metricas = results[1] as Metricas;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _erro = 'Erro ao carregar relatórios';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Relatórios',
      currentIndex: _navIndex,

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
              // Página de estoque ainda não criada
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

      body: RefreshIndicator(
        onRefresh: _carregar,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _erro != null
                ? _ErroWidget(mensagem: _erro!, onRetry: _carregar)
                : _ExtratoScreen(
                    produtos: _produtos,
                    metricas: _metricas,
                  ),
      ),
    );
  }
}

// ── Tela de extrato ───────────────────────────────────────────────────────────

class _ExtratoScreen extends StatelessWidget {
  final List<ProdutoApi> produtos;
  final Metricas? metricas;

  const _ExtratoScreen({
    required this.produtos,
    required this.metricas,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _HeroBanner(metricas: metricas),
        ),

        if (produtos.isEmpty)
          const SliverFillRemaining(
            child: Center(
              child: Text(
                'Nenhum produto encontrado',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ProdutoCard(
                    produto: produtos[i],
                    index: i,
                  ),
                ),
                childCount: produtos.length,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Hero Banner ───────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final Metricas? metricas;

  const _HeroBanner({required this.metricas});

  @override
  Widget build(BuildContext context) {
    final margem = metricas != null
        ? '${metricas!.margem.toStringAsFixed(1)}%'
        : '--';
    final lucro = metricas != null ? fmt(metricas!.lucro) : '--';

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
          Expanded(child: _metric('MARGEM', margem)),
          const SizedBox(width: 12),
          Expanded(child: _metric('LUCRO', lucro)),
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

// ── Card de produto ───────────────────────────────────────────────────────────

class _ProdutoCard extends StatefulWidget {
  final ProdutoApi produto;
  final int index;

  const _ProdutoCard({
    required this.produto,
    required this.index,
  });

  @override
  State<_ProdutoCard> createState() => _ProdutoCardState();
}

class _ProdutoCardState extends State<_ProdutoCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.produto;
    final iconBg = _iconBgPorCategoria(p.categoria, widget.index);
    final iconColor = _iconColorPorCategoria(p.categoria, widget.index);
    final icone = _iconePorNome(p.icone);

    return GestureDetector(
      onTap: () => setState(() => expanded = !expanded),
      child: Container(
        decoration: AppTheme.cardDecoration,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Ícone
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icone, color: iconColor),
                  ),
                  const SizedBox(width: 12),

                  // Nome e descrição
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.nome, style: AppTheme.cardTitleStyle),
                        Text(
                          '${p.unidade} • ${_dataFormatada(p)}',
                          style: AppTheme.cardSubtitleStyle,
                        ),
                      ],
                    ),
                  ),

                  // Valores
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(fmt(p.precoVenda), style: AppTheme.cardValueStyle),
                      Text(
                        '+ ${fmt(p.lucro)}',
                        style: AppTheme.greenTextStyle,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Expandido
            if (expanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Column(
                  children: [
                    Container(
                      height: 1,
                      color: AppTheme.cardBorder,
                      margin: const EdgeInsets.only(bottom: 10),
                    ),
                    _row('Custo total', fmt(p.precoCusto)),
                    _row('Venda total', fmt(p.precoVenda)),
                    _row('Custo unitário', fmt(p.custoUnitario)),
                    _row('Margem', '${p.margemPct.toStringAsFixed(1)}%'),
                    _row('Quantidade', '${p.quantidade} un'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Formata a data a partir do campo criado_em se disponível
  String _dataFormatada(ProdutoApi p) {
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.now());
    } catch (_) {
      return '';
    }
  }

  Widget _row(String l, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l, style: AppTheme.defaultTextStyle),
          Text(v, style: AppTheme.boldTextStyle),
        ],
      ),
    );
  }
}

// ── Widget de erro ────────────────────────────────────────────────────────────

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