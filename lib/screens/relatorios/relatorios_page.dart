import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../components/app_scaffold.dart';
import '../../services/api_service.dart';

class RelatoriosPage extends StatefulWidget {
  final Usuario usuario;
  const RelatoriosPage({super.key, required this.usuario});

  @override
  State<RelatoriosPage> createState() => _RelatoriosPageState();
}

class _RelatoriosPageState extends State<RelatoriosPage> {
  String _periodo = 'todos';

  List<ProdutoApi> _produtos = [];
  Metricas? _metricas;
  List<GraficoDia> _grafico = [];
  bool _loading = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      setState(() { _loading = true; _erro = null; });
      final results = await Future.wait([
        ApiService.getProdutos(),
        ApiService.getMetricas(periodo: _periodo),
        ApiService.getGrafico(),
      ]);
      setState(() {
        _produtos = results[0] as List<ProdutoApi>;
        _metricas = results[1] as Metricas;
        _grafico  = results[2] as List<GraficoDia>;
        _loading  = false;
      });
    } catch (e) {
      setState(() { _erro = 'Erro ao carregar relatórios'; _loading = false; });
    }
  }

  Future<void> _trocarPeriodo(String periodo) async {
    setState(() { _periodo = periodo; _loading = true; _erro = null; });
    try {
      final metricas = await ApiService.getMetricas(periodo: periodo);
      setState(() { _metricas = metricas; _loading = false; });
    } catch (e) {
      setState(() { _erro = 'Erro ao carregar métricas'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Relatórios',
      currentIndex: 3,
      body: RefreshIndicator(
        onRefresh: _carregar,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _erro != null
                ? _ErroWidget(mensagem: _erro!, onRetry: _carregar)
                : _Conteudo(
                    metricas: _metricas,
                    produtos: _produtos,
                    grafico: _grafico,
                    periodo: _periodo,
                    onPeriodoChanged: _trocarPeriodo,
                  ),
      ),
    );
  }
}

// ── Conteúdo principal ────────────────────────────────────────

class _Conteudo extends StatelessWidget {
  final Metricas? metricas;
  final List<ProdutoApi> produtos;
  final List<GraficoDia> grafico;
  final String periodo;
  final ValueChanged<String> onPeriodoChanged;

  const _Conteudo({
    required this.metricas,
    required this.produtos,
    required this.grafico,
    required this.periodo,
    required this.onPeriodoChanged,
  });

  @override
  Widget build(BuildContext context) {
    final totalFaturamento = produtos.fold(0.0, (s, p) => s + p.precoVenda);
    final totalCusto       = produtos.fold(0.0, (s, p) => s + p.precoCusto);
    final totalVendas      = metricas?.totalPedidos ?? 0;
    final ticketMedio      = totalVendas > 0 ? totalFaturamento / totalVendas : 0.0;
    final roi              = totalCusto > 0 ? ((totalFaturamento - totalCusto) / totalCusto) * 100 : 0.0;

    return CustomScrollView(
      slivers: [
        // ── Hero banner ───────────────────────────────────────
        SliverToBoxAdapter(
          child: _HeroBanner(metricas: metricas),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([

              // ── Chips de período ──────────────────────────
              _PeriodChips(periodo: periodo, onChanged: onPeriodoChanged),
              const SizedBox(height: 16),

              // ── Cards de métricas ─────────────────────────
              const Text('Resumo financeiro', style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textMuted,
              )),
              const SizedBox(height: 10),
              _GridMetricas(metricas: metricas),
              const SizedBox(height: 14),

              // ── Gráfico de barras ─────────────────────────
              _CardGraficoBarras(grafico: grafico),
              const SizedBox(height: 14),

              // ── Margem por produto ────────────────────────
              _CardMargemProdutos(produtos: produtos),
              const SizedBox(height: 14),

              // ── Donut + Indicadores ───────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _CardDonut(produtos: produtos, total: totalFaturamento)),
                  const SizedBox(width: 10),
                  Expanded(child: _CardIndicadores(
                    ticketMedio: ticketMedio,
                    custoTotal: totalCusto,
                    roi: roi,
                  )),
                ],
              ),
              const SizedBox(height: 14),

              // ── Top produtos ──────────────────────────────
              _CardTopProdutos(produtos: produtos),
            ]),
          ),
        ),
      ],
    );
  }
}

// ── Hero Banner ───────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final Metricas? metricas;
  const _HeroBanner({required this.metricas});

  String _fmt(double v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    final margem  = metricas != null ? '${metricas!.margem.toStringAsFixed(1)}%' : '--';
    final lucro   = metricas != null ? _fmt(metricas!.lucro) : '--';

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

// ── Period Chips ──────────────────────────────────────────────

class _PeriodChips extends StatelessWidget {
  final String periodo;
  final ValueChanged<String> onChanged;
  const _PeriodChips({required this.periodo, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final opcoes = [
      {'chave': 'todos',  'label': 'Tudo'},
      {'chave': 'hoje',   'label': 'Hoje'},
      {'chave': 'semana', 'label': 'Semana'},
      {'chave': 'mes',    'label': 'Mês'},
    ];

    return Row(
      children: opcoes.map((o) {
        final ativo = periodo == o['chave'];
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onChanged(o['chave']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: ativo ? AppTheme.primaryDeep : Colors.white,
                border: Border.all(
                  color: ativo ? AppTheme.primaryDeep : AppTheme.cardBorder,
                  width: 1.5,
                ),
              ),
              child: Text(
                o['label']!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: ativo ? Colors.white : AppTheme.textMuted,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Grid de métricas ──────────────────────────────────────────

class _GridMetricas extends StatelessWidget {
  final Metricas? metricas;
  const _GridMetricas({required this.metricas});

  @override
  Widget build(BuildContext context) {
    String fmt(double v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

    final cards = [
      _MetricCardData(
        icone: Icons.attach_money,
        corFundo: AppTheme.lightBlue,
        corIcone: AppTheme.primaryDeep,
        label: 'Faturamento',
        valor: metricas != null ? fmt(metricas!.faturado) : '--',
      ),
      _MetricCardData(
        icone: Icons.trending_up,
        corFundo: AppTheme.greenLight,
        corIcone: AppTheme.green,
        label: 'Lucro líquido',
        valor: metricas != null ? fmt(metricas!.lucro) : '--',
      ),
      _MetricCardData(
        icone: Icons.percent,
        corFundo: AppTheme.orangeLight,
        corIcone: AppTheme.orange,
        label: 'Margem média',
        valor: metricas != null ? '${metricas!.margem.toStringAsFixed(1)}%' : '--',
      ),
      _MetricCardData(
        icone: Icons.shopping_bag_outlined,
        corFundo: const Color(0xFFF3F0FF),
        corIcone: const Color(0xFF7C5CBF),
        label: 'Pedidos',
        valor: metricas != null ? '${metricas!.totalPedidos}' : '--',
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: cards.map((c) => _MetricCard(data: c)).toList(),
    );
  }
}

class _MetricCardData {
  final IconData icone;
  final Color corFundo;
  final Color corIcone;
  final String label;
  final String valor;
  _MetricCardData({
    required this.icone,
    required this.corFundo,
    required this.corIcone,
    required this.label,
    required this.valor,
  });
}

class _MetricCard extends StatelessWidget {
  final _MetricCardData data;
  const _MetricCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: data.corFundo,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icone, color: data.corIcone, size: 18),
          ),
          const SizedBox(height: 6),
          Text(data.label, style: AppTheme.cardSubtitleStyle),
          Text(data.valor, style: AppTheme.boldTextStyle),
        ],
      ),
    );
  }
}

// ── Gráfico de barras ─────────────────────────────────────────

class _CardGraficoBarras extends StatelessWidget {
  final List<GraficoDia> grafico;
  const _CardGraficoBarras({required this.grafico});

  @override
  Widget build(BuildContext context) {
    if (grafico.isEmpty) return const SizedBox.shrink();

    final maxVal = grafico.fold(0.0, (m, d) => d.faturamento > m ? d.faturamento : m);
    final alturaMaxima = 120.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Faturamento x Custo', style: AppTheme.cardTitleStyle),
              Text('Últimos 7 dias', style: AppTheme.cardSubtitleStyle),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: grafico.map((d) {
                final altFat   = maxVal > 0 ? (d.faturamento / maxVal) * alturaMaxima : 0.0;
                final altCusto = maxVal > 0 ? (d.custo / maxVal) * alturaMaxima : 0.0;
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _Barra(altura: altFat,   cor: AppTheme.primary),
                          const SizedBox(width: 4),
                          _Barra(altura: altCusto, cor: AppTheme.orange),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(d.dia, style: AppTheme.cardSubtitleStyle.copyWith(fontSize: 10)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Legenda(cor: AppTheme.primary,    texto: 'Faturamento'),
              const SizedBox(width: 16),
              _Legenda(cor: AppTheme.orange,     texto: 'Custo'),
              const SizedBox(width: 16),
              _Legenda(cor: AppTheme.green,      texto: 'Lucro'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Barra extends StatelessWidget {
  final double altura;
  final Color cor;
  const _Barra({required this.altura, required this.cor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: altura.clamp(2.0, 200.0),
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _Legenda extends StatelessWidget {
  final Color cor;
  final String texto;
  const _Legenda({required this.cor, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 5),
        Text(texto, style: AppTheme.cardSubtitleStyle),
      ],
    );
  }
}

// ── Margem por produto ────────────────────────────────────────

class _CardMargemProdutos extends StatelessWidget {
  final List<ProdutoApi> produtos;
  const _CardMargemProdutos({required this.produtos});

  @override
  Widget build(BuildContext context) {
    final ordenados = [...produtos]..sort((a, b) => b.margemPct.compareTo(a.margemPct));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Margem por produto', style: AppTheme.cardTitleStyle),
              Text('%', style: AppTheme.cardSubtitleStyle),
            ],
          ),
          const SizedBox(height: 12),
          ...ordenados.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 110,
                  child: Text(
                    p.nome.length > 18 ? '${p.nome.substring(0, 16)}…' : p.nome,
                    style: AppTheme.cardTitleStyle.copyWith(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: (p.margemPct / 100).clamp(0.0, 1.0),
                      backgroundColor: AppTheme.lightBlue,
                      color: AppTheme.primaryDeep,
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 48,
                  child: Text(
                    '${p.margemPct.toStringAsFixed(1)}%',
                    textAlign: TextAlign.right,
                    style: AppTheme.greenTextStyle,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

// ── Donut Chart ───────────────────────────────────────────────

class _CardDonut extends StatelessWidget {
  final List<ProdutoApi> produtos;
  final double total;
  const _CardDonut({required this.produtos, required this.total});

  @override
  Widget build(BuildContext context) {
    final cores = [
      AppTheme.primary,
      AppTheme.orange,
      AppTheme.green,
      AppTheme.primaryDeep,
      const Color(0xFFB09BDD),
      const Color(0xFFBF8C3A),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Distribuição', style: AppTheme.cardTitleStyle),
          const SizedBox(height: 8),
          SizedBox(
            height: 130,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(120, 120),
                  painter: _DonutPainter(
                    valores: produtos.map((p) => p.precoVenda).toList(),
                    cores: cores,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'R\$${total.toInt()}',
                      style: AppTheme.cardTitleStyle.copyWith(fontSize: 18),
                    ),
                    Text('total', style: AppTheme.cardSubtitleStyle),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<double> valores;
  final List<Color> cores;
  _DonutPainter({required this.valores, required this.cores});

  @override
  void paint(Canvas canvas, Size size) {
    if (valores.isEmpty) return;
    final total = valores.reduce((a, b) => a + b);
    if (total == 0) return;
    double startAngle = -90;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.butt;

    for (int i = 0; i < valores.length; i++) {
      final sweepAngle = (valores[i] / total) * 360;
      paint.color = cores[i % cores.length];
      canvas.drawArc(
        Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: 50),
        startAngle * (3.14159 / 180),
        sweepAngle * (3.14159 / 180),
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ── Indicadores ───────────────────────────────────────────────

class _CardIndicadores extends StatelessWidget {
  final double ticketMedio;
  final double custoTotal;
  final double roi;
  const _CardIndicadores({
    required this.ticketMedio,
    required this.custoTotal,
    required this.roi,
  });

  @override
  Widget build(BuildContext context) {
    String fmt(double v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Indicadores', style: AppTheme.cardTitleStyle),
          const SizedBox(height: 12),
          _indicador('Ticket médio', fmt(ticketMedio)),
          const SizedBox(height: 10),
          _indicador('Custo total', fmt(custoTotal), cor: AppTheme.orange),
          const SizedBox(height: 10),
          _indicador('ROI', '${roi.toStringAsFixed(1)}%', cor: AppTheme.green),
        ],
      ),
    );
  }

  Widget _indicador(String label, String valor, {Color? cor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.cardSubtitleStyle.copyWith(fontSize: 10)),
        Text(
          valor,
          style: AppTheme.boldTextStyle.copyWith(
            fontSize: 16,
            color: cor ?? AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ── Top Produtos ──────────────────────────────────────────────

class _CardTopProdutos extends StatelessWidget {
  final List<ProdutoApi> produtos;
  const _CardTopProdutos({required this.produtos});

  @override
  Widget build(BuildContext context) {
    final ordenados = [...produtos]..sort((a, b) => b.lucro.compareTo(a.lucro));
    final cores = [
      AppTheme.lightBlue,
      AppTheme.orangeLight,
      AppTheme.greenLight,
      const Color(0xFFF3F0FF),
    ];
    final coresIcone = [
      AppTheme.primaryDeep,
      AppTheme.orange,
      AppTheme.green,
      const Color(0xFF7C5CBF),
    ];
    final icones = {
      'pizza':    Icons.local_pizza_outlined,
      'set_meal': Icons.set_meal_outlined,
      'basket':   Icons.shopping_basket_outlined,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Top produtos', style: AppTheme.cardTitleStyle),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.greenLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('por lucro', style: AppTheme.greenTextStyle.copyWith(fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(ordenados.length, (i) {
            final p = ordenados[i];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 9),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    child: Text('${i + 1}', style: AppTheme.cardSubtitleStyle.copyWith(fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: cores[i % cores.length],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icones[p.icone] ?? Icons.shopping_basket_outlined,
                      color: coresIcone[i % coresIcone.length],
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.nome, style: AppTheme.cardTitleStyle.copyWith(fontSize: 13)),
                        Text(p.unidade, style: AppTheme.cardSubtitleStyle),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'R\$ ${p.precoVenda.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: AppTheme.cardValueStyle.copyWith(fontSize: 13),
                      ),
                      Text(
                        '+R\$ ${p.lucro.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: AppTheme.greenTextStyle,
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Widget de erro ────────────────────────────────────────────

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
            ElevatedButton(onPressed: onRetry, child: const Text('Tentar novamente')),
          ],
        ),
      ),
    );
  }
}