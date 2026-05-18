import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../screens/pedidos/pedidos_page.dart';
import '../screens/relatorios/relatorios_page.dart';

void main() {
  runApp(const BeteSalgadosApp());
}

class BeteSalgadosApp extends StatelessWidget {
  const BeteSalgadosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bete Salgados',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
          primary: AppColors.primaryBlue,
        ),
      ),
      home: const HomePage(
        userName: 'Bete Salgados',
        totalRevenue: 600.00,
      ),
    );
  }
}

class AppColors {
  static const Color primaryBlue = Color(0xFF89C9F8);
  static const Color lightBlue = Color(0xFFE3F4FC);
  static const Color scaffoldBackground = Color(0xFFF7F7F7);
  static const Color drawerBackground = Color(0xFFD9D9D9);
  static const Color cardGrey = Color(0xFFD9D9D9);
  static const Color darkText = Color(0xFF444444);
  static const Color mutedText = Color(0xFF777777);
  static const Color actionBlue = Color(0xFF2F80ED);
  static const Color chartAccent = Color(0xFFFF6B5A);
  static const Color chartSoft = Color(0xFFF7C7C0);
  static const Color white = Color(0xFFFFFFFF);
}

class HomePage extends StatefulWidget {
  final String userName;
  final double totalRevenue;

  const HomePage({
    super.key,
    required this.userName,
    required this.totalRevenue,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _shortcutController = PageController(
    viewportFraction: 0.88,
  );

  Timer? _autoScrollTimer;

  int _currentShortcutPage = 0;
  int _selectedBottomIndex = 0;

  late final List<ShortcutAction> _shortcutActions = [
    ShortcutAction(
      title: 'Relatórios',
      description: 'Acompanhe vendas e desempenho',
      icon: Icons.insert_chart_outlined,
      onTap: () {
        // TODO: Navegar para Relatórios
      },
    ),
    ShortcutAction(
      title: 'Metas',
      description: 'Veja o progresso das metas',
      icon: Icons.emoji_events_outlined,
      onTap: () {
        // TODO: Navegar para Metas
      },
    ),
    ShortcutAction(
      title: 'Pedidos',
      description: 'Gerencie pedidos recentes',
      icon: Icons.receipt_long_outlined,
      onTap: () {
        // TODO: Navegar para Pedidos
      },
    ),
    ShortcutAction(
      title: 'Estoque',
      description: 'Controle produtos e insumos',
      icon: Icons.inventory_2_outlined,
      onTap: () {
        // TODO: Navegar para Estoque
      },
    ),
  ];

  @override
  void initState() {
    super.initState();

    _autoScrollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) {
        if (!mounted || !_shortcutController.hasClients) return;

        final int nextPage =
            (_currentShortcutPage + 1) % _shortcutActions.length;

        _shortcutController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _shortcutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(
                Icons.menu,
                color: AppColors.darkText,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Text(
          'Olá, ${widget.userName}',
          style: const TextStyle(
            color: AppColors.darkText,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFE8D8FF),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.person_outline,
                  size: 20,
                  color: AppColors.darkText,
                ),
                onPressed: () {
                  // TODO: Navegar para Perfil do Usuário
                },
              ),
            ),
          ),
        ],
      ),
      drawer: AppDrawer(userName: widget.userName),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            RevenueCard(totalRevenue: widget.totalRevenue),
            const SizedBox(height: 18),
            ShortcutCarousel(
              controller: _shortcutController,
              shortcuts: _shortcutActions,
              currentPage: _currentShortcutPage,
              onPageChanged: (index) {
                setState(() {
                  _currentShortcutPage = index;
                });
              },
            ),
            const SizedBox(height: 18),
            GraphHighlightButton(
              onPressed: () {
                // TODO: Navegar para Gráficos
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _selectedBottomIndex,
        onTap: (index) {
          setState(() {
            _selectedBottomIndex = index;
          });

          switch (index) {
            case 0:
              // TODO: Navegar para Home
              break;
            case 1:
              // TODO: Navegar para Estoque
              break;
            case 2:
              // TODO: Navegar para Relatórios
              break;
          }
        },
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  final String userName;

  const AppDrawer({
    super.key,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 270,
      backgroundColor: AppColors.drawerBackground,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              height: 54,
              width: double.infinity,
              color: AppColors.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              child: const Icon(
                Icons.menu,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 36),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                children: [
                  DrawerMenuTile(
                    icon: Icons.chat_bubble_outline,
                    title: 'Relátorios',
                    onTap: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RelatoriosPage(),
                                        ),
                                    );
                                  },
                                ),
                  DrawerMenuTile(
                    icon: Icons.chat_bubble_outline,
                    title: 'Pedidos',
                    onTap: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PedidosPage(),
                                        ),
                                    );
                                  },
                                ),
                  DrawerMenuTile(
                    icon: Icons.emoji_events_outlined,
                    title: 'Metas',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navegar para Metas
                    },
                  ),
                  DrawerMenuTile(
                    icon: Icons.shopping_basket_outlined,
                    title: 'Lista de Compras',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navegar para Lista de Compras
                    },
                  ),
                  DrawerMenuTile(
                    icon: Icons.camera_alt_outlined,
                    title: 'Instagram',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navegar para Instagram
                    },
                  ),
                  DrawerMenuTile(
                    icon: Icons.info_outline,
                    title: 'Sobre',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navegar para Sobre
                    },
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 18),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFA8A8A8),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Text(
                'Atualizado versão 1.0',
                style: TextStyle(
                  color: AppColors.darkText,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
              child: DrawerMenuTile(
                icon: Icons.settings_outlined,
                title: 'Configurações',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navegar para Configurações
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DrawerMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const DrawerMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        leading: Icon(
          icon,
          size: 19,
          color: AppColors.darkText,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.darkText,
            fontSize: 13,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

class RevenueCard extends StatelessWidget {
  final double totalRevenue;

  const RevenueCard({
    super.key,
    required this.totalRevenue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'FATURADO',
            style: TextStyle(
              color: AppColors.mutedText,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyHelper.formatBRL(totalRevenue),
            style: const TextStyle(
              color: AppColors.darkText,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 1,
            color: AppColors.darkText.withOpacity(0.45),
          ),
        ],
      ),
    );
  }
}

class ShortcutCarousel extends StatelessWidget {
  final PageController controller;
  final List<ShortcutAction> shortcuts;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  const ShortcutCarousel({
    super.key,
    required this.controller,
    required this.shortcuts,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: ScrollConfiguration(
            behavior: const MaterialScrollBehavior().copyWith(
              dragDevices: const {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
              },
            ),
            child: PageView.builder(
              controller: controller,
              itemCount: shortcuts.length,
              physics: const PageScrollPhysics(),
              onPageChanged: onPageChanged,
              itemBuilder: (context, index) {
                final shortcut = shortcuts[index];

                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ShortcutBannerCard(shortcut: shortcut),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            shortcuts.length,
            (index) {
              final bool isActive = currentPage == index;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 16 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.darkText
                      : AppColors.darkText.withOpacity(0.30),
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ShortcutBannerCard extends StatelessWidget {
  final ShortcutAction shortcut;

  const ShortcutBannerCard({
    super.key,
    required this.shortcut,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardGrey,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: shortcut.onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.85),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  shortcut.icon,
                  color: AppColors.darkText,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shortcut.title,
                      style: const TextStyle(
                        color: AppColors.darkText,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      shortcut.description,
                      style: const TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.darkText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GraphHighlightButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GraphHighlightButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.lightBlue,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Container(
          height: 150,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.primaryBlue.withOpacity(0.45),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 86,
                height: 86,
                child: CustomPaint(
                  painter: DonutChartPainter(),
                ),
              ),
              const SizedBox(width: 20),
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gráficos',
                      style: TextStyle(
                        color: AppColors.darkText,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Visualize custos, faturamento e relatórios do negócio.',
                      style: TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.actionBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: AppColors.white,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = size.width / 2;

    final Rect rect = Rect.fromCircle(
      center: center,
      radius: radius,
    );

    final Paint basePaint = Paint()
      ..color = AppColors.chartSoft
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    final Paint accentPaint = Paint()
      ..color = AppColors.chartAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      0.2,
      5.0,
      false,
      basePaint,
    );

    canvas.drawArc(
      rect,
      2.0,
      1.4,
      false,
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.primaryBlue,
      selectedItemColor: AppColors.darkText,
      unselectedItemColor: AppColors.darkText,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      elevation: 0,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: ActiveBottomIcon(icon: Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_outlined),
          activeIcon: ActiveBottomIcon(icon: Icons.grid_view_outlined),
          label: 'Estoque',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.show_chart_outlined),
          activeIcon: ActiveBottomIcon(icon: Icons.show_chart_outlined),
          label: 'Relatórios',
        ),
      ],
    );
  }
}

class ActiveBottomIcon extends StatelessWidget {
  final IconData icon;

  const ActiveBottomIcon({
    super.key,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      margin: const EdgeInsets.only(bottom: 2),
      decoration: const BoxDecoration(
        color: AppColors.lightBlue,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: AppColors.darkText,
        size: 25,
      ),
    );
  }
}

class ShortcutAction {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  ShortcutAction({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });
}

class CurrencyHelper {
  static String formatBRL(double value) {
    final bool isNegative = value < 0;
    final String fixed = value.abs().toStringAsFixed(2);
    final List<String> parts = fixed.split('.');

    final String integerPart = parts[0];
    final String decimalPart = parts[1];

    final List<String> reversed = integerPart.split('').reversed.toList();
    final StringBuffer buffer = StringBuffer();

    for (int i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) {
        buffer.write('.');
      }

      buffer.write(reversed[i]);
    }

    final String formattedInteger =
        buffer.toString().split('').reversed.join();

    return 'R\$ ${isNegative ? '-' : ''}$formattedInteger,$decimalPart';
  }
}