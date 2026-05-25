import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'components/app_bottom_nav.dart';
import 'components/app_scaffold.dart';
import 'services/api_service.dart';
import 'screens/pedidos/pedidos_page.dart';
import 'screens/estoque/estoque_page.dart';
import 'screens/relatorios/relatorios_page.dart';
import 'screens/login/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppTheme.primary,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const LoginPage(),
    );
  }
}

class AdminShell extends StatefulWidget {
  final Usuario usuario;
  const AdminShell({super.key, required this.usuario});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(usuario: widget.usuario),
      EstoquePage(usuario: widget.usuario),
      PedidosPage(usuario: widget.usuario),
      RelatoriosPage(usuario: widget.usuario),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final Usuario usuario;
  const HomePage({super.key, required this.usuario});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _shortcutController = PageController(viewportFraction: 0.88);
  Timer? _autoScrollTimer;
  int _currentShortcutPage = 0;

  Metricas? _metricas;
  bool _loadingMetricas = true;
  String? _erroMetricas;

  late final List<_ShortcutAction> _shortcutActions = [
    _ShortcutAction(
      title: 'Relatórios',
      description: 'Acompanhe vendas e desempenho',
      icon: Icons.insert_chart_outlined,
      onTap: () => _navigateTo(3),
    ),
    _ShortcutAction(
      title: 'Metas',
      description: 'Veja o progresso das metas',
      icon: Icons.emoji_events_outlined,
      onTap: () {},
    ),
    _ShortcutAction(
      title: 'Pedidos',
      description: 'Gerencie pedidos recentes',
      icon: Icons.receipt_long_outlined,
      onTap: () => _navigateTo(2),
    ),
    _ShortcutAction(
      title: 'Estoque',
      description: 'Controle produtos e insumos',
      icon: Icons.inventory_2_outlined,
      onTap: () => _navigateTo(1),
    ),
  ];

  void _navigateTo(int index) {
    final shell = context.findAncestorStateOfType<_AdminShellState>();
    shell?.setState(() => shell._index = index);
  }

  @override
  void initState() {
    super.initState();
    _carregarMetricas();
    _autoScrollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) {
        if (!mounted || !_shortcutController.hasClients) return;
        final int nextPage = (_currentShortcutPage + 1) % _shortcutActions.length;
        _shortcutController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  Future<void> _carregarMetricas() async {
    try {
      setState(() { _loadingMetricas = true; _erroMetricas = null; });
      final metricas = await ApiService.getMetricas();
      setState(() { _metricas = metricas; _loadingMetricas = false; });
    } catch (e) {
      setState(() { _erroMetricas = 'Erro ao carregar métricas'; _loadingMetricas = false; });
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _shortcutController.dispose();
    super.dispose();
  }

  String get _faturadoText {
    if (_loadingMetricas) return '...';
    if (_erroMetricas != null) return '--';
    return 'R\$ ${_metricas!.faturado.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Home',
      currentIndex: 0,
      // SEM bottomNavigationBar aqui — o AdminShell já cuida disso
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _carregarMetricas,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Container(
                height: 92,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('FATURADO', style: AppTheme.metricLabelStyle),
                    const SizedBox(height: 8),
                    _loadingMetricas
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(_faturadoText, style: AppTheme.metricValueStyle),
                    const SizedBox(height: 8),
                    Container(width: double.infinity, height: 1, color: Colors.white.withOpacity(0.35)),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              Column(
                children: [
                  SizedBox(
                    height: 140,
                    child: ScrollConfiguration(
                      behavior: const MaterialScrollBehavior().copyWith(
                        dragDevices: const {PointerDeviceKind.touch, PointerDeviceKind.mouse},
                      ),
                      child: PageView.builder(
                        controller: _shortcutController,
                        itemCount: _shortcutActions.length,
                        physics: const PageScrollPhysics(),
                        onPageChanged: (index) => setState(() => _currentShortcutPage = index),
                        itemBuilder: (context, index) {
                          final action = _shortcutActions[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: _ShortcutCard(
                              title: action.title,
                              description: action.description,
                              icon: action.icon,
                              onTap: action.onTap,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_shortcutActions.length, (index) {
                      final bool isActive = _currentShortcutPage == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: isActive ? 16 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppTheme.primaryDeep
                              : AppTheme.primaryDeep.withOpacity(0.30),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              GestureDetector(
                onTap: () => _navigateTo(3),
                child: Container(
                  height: 150,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primary.withOpacity(0.35)),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 86,
                        height: 86,
                        child: CustomPaint(painter: _DonutChartPainter()),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Gráficos', style: AppTheme.cardTitleStyle.copyWith(fontSize: 22)),
                            const SizedBox(height: 6),
                            if (_metricas != null) ...[
                              Text(
                                'Lucro: R\$ ${_metricas!.lucro.toStringAsFixed(2).replaceAll('.', ',')}',
                                style: AppTheme.greenTextStyle,
                              ),
                              Text(
                                'Margem: ${_metricas!.margem.toStringAsFixed(1)}%',
                                style: AppTheme.cardSubtitleStyle,
                              ),
                            ] else
                              Text(
                                'Visualize custos, faturamento e relatórios do negócio.',
                                style: AppTheme.cardSubtitleStyle,
                              ),
                          ],
                        ),
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(color: AppTheme.primaryDeep, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
                      ),
                    ],
                  ),
                ),
              ),

              if (_erroMetricas != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppTheme.red, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_erroMetricas!, style: const TextStyle(color: AppTheme.red))),
                      TextButton(onPressed: _carregarMetricas, child: const Text('Tentar novamente')),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ShortcutAction {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  _ShortcutAction({required this.title, required this.description, required this.icon, required this.onTap});
}

class _ShortcutCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _ShortcutCard({required this.title, required this.description, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(icon, color: AppTheme.primaryDeep, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTheme.cardTitleStyle),
                    const SizedBox(height: 6),
                    Text(description, style: AppTheme.cardSubtitleStyle),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.primaryDeep),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = size.width / 2;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    final Paint basePaint = Paint()
      ..color = AppTheme.primary.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    final Paint accentPaint = Paint()
      ..color = AppTheme.primaryDeep
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0.2, 5.0, false, basePaint);
    canvas.drawArc(rect, 2.0, 1.4, false, accentPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}