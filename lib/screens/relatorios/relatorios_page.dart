import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class RelatoriosPage extends StatelessWidget {
  const RelatoriosPage({super.key});

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
      child: const HomeScreen(),
    );
  }
}

class AppTheme {
  static const Color primary = Color(0xFF88CDFF);
  static const Color primaryDark = Color(0xFF5BB8FF);
  static const Color primaryDeep = Color(0xFF3A9EE8);

  static const Color background = Color(0xFFF0F8FF);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF1A2B3C);
  static const Color textMuted = Color(0xFF6B8CAE);

  static const Color cardBorder = Color(0xFFD0E9FF);

  static const Color green = Color(0xFF2ECC71);
  static const Color red = Color(0xFFE74C3C);
  static const Color orange = Color(0xFFE8974A);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        fontFamily: 'Nunito',
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.light(
          primary: primary,
          secondary: primaryDark,
          surface: surface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
      );
}

String fmt(double value) {
  return NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  ).format(value);
}

class Produto {
  final String nome;
  final String descricaoQtd;
  final IconData icone;
  final Color iconBg;
  final Color iconColor;
  final String data;
  final double precoVenda;
  final double precoCusto;
  final int quantidade;

  const Produto({
    required this.nome,
    required this.descricaoQtd,
    required this.icone,
    required this.iconBg,
    required this.iconColor,
    required this.data,
    required this.precoVenda,
    required this.precoCusto,
    this.quantidade = 1,
  });

  double get lucro => precoVenda - precoCusto;

  double get margemPct => (lucro / precoVenda) * 100;

  double get totalVendido => precoVenda;

  double get totalCusto => precoCusto;

  double get totalLucro => lucro;

  double get custoUnitario => precoCusto / quantidade;
}

class ProdutoRepository {
  static const List<Produto> produtos = [
    Produto(
      nome: 'Cento de Coxinha',
      descricaoQtd: '100 un',
      icone: Icons.shopping_basket_outlined,
      iconBg: Color(0xFFEEF6FF),
      iconColor: Color(0xFF3A9EE8),
      data: '14/05/2026',
      precoVenda: 100,
      precoCusto: 55,
      quantidade: 100,
    ),
    Produto(
      nome: 'Mini Pizza',
      descricaoQtd: '50 un',
      icone: Icons.local_pizza_outlined,
      iconBg: Color(0xFFFFF3EE),
      iconColor: Color(0xFFE8974A),
      data: '14/05/2026',
      precoVenda: 85,
      precoCusto: 48,
      quantidade: 50,
    ),
    Produto(
      nome: 'Kibe com Catupiry',
      descricaoQtd: '50 un',
      icone: Icons.set_meal_outlined,
      iconBg: Color(0xFFF4FEEE),
      iconColor: Color(0xFF3B6D11),
      data: '13/05/2026',
      precoVenda: 75,
      precoCusto: 42,
      quantidade: 50,
    ),
  ];

  static double get totalVendido =>
      produtos.fold(0, (s, p) => s + p.totalVendido);

  static double get totalLucro =>
      produtos.fold(0, (s, p) => s + p.totalLucro);

  static double get margemGeral =>
      totalVendido > 0 ? (totalLucro / totalVendido) * 100 : 0;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 3;

  void _openLeftCard(Widget card) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => Scaffold(
          backgroundColor: Colors.black.withOpacity(0.2),
          body: GestureDetector(
            onTap: () => Navigator.pop(context),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Expanded(child: card),
                const Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openRightCard(Widget card) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => Scaffold(
          backgroundColor: Colors.black.withOpacity(0.2),
          body: GestureDetector(
            onTap: () => Navigator.pop(context),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                const Expanded(child: SizedBox()),
                Expanded(child: card),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage() {
    switch (_navIndex) {
      case 0:
        return const Center(child: Text('Home em desenvolvimento'));
      case 1:
        return const Center(child: Text('Estoque em desenvolvimento'));
      case 2:
        return const Center(child: Text('Pedidos em desenvolvimento'));
      case 3:
        return const ExtratoScreen();
      default:
        return const ExtratoScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Relatórios'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _openLeftCard(ConfigScreen()),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => _openRightCard(PerfilScreen()),
          ),
        ],
      ),
      body: _buildPage(),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.primary,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 68,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBtn(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: _navIndex == 0,
                  onTap: () => setState(() => _navIndex = 0),
                ),
                _NavBtn(
                  icon: Icons.inventory_2_outlined,
                  label: 'Estoque',
                  isSelected: _navIndex == 1,
                  onTap: () => setState(() => _navIndex = 1),
                ),
                _NavBtn(
                  icon: Icons.shopping_cart_outlined,
                  label: 'Pedidos',
                  isSelected: _navIndex == 2,
                  onTap: () => setState(() => _navIndex = 2),
                ),
                _NavBtn(
                  icon: Icons.trending_up_rounded,
                  label: 'Relatórios',
                  isSelected: _navIndex == 3,
                  onTap: () => setState(() => _navIndex = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBtn({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: Colors.white,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExtratoScreen extends StatelessWidget {
  const ExtratoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final produtos = ProdutoRepository.produtos;

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: HeroBanner(),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ProdutoCard(produto: produtos[i]),
              ),
              childCount: produtos.length,
            ),
          ),
        ),
      ],
    );
  }
}

class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final lucro = ProdutoRepository.totalLucro;
    final margem = ProdutoRepository.margemGeral;

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
          Expanded(
            child: _metric(
              'MARGEM',
              '${margem.toStringAsFixed(1)}%',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _metric(
              'LUCRO',
              fmt(lucro),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class ProdutoCard extends StatefulWidget {
  final Produto produto;

  const ProdutoCard({
    super.key,
    required this.produto,
  });

  @override
  State<ProdutoCard> createState() => _ProdutoCardState();
}

class _ProdutoCardState extends State<ProdutoCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.produto;

    return GestureDetector(
      onTap: () {
        setState(() {
          expanded = !expanded;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppTheme.cardBorder,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: p.iconBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      p.icone,
                      color: p.iconColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.nome,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${p.descricaoQtd} • ${p.data}',
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        fmt(p.totalVendido),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '+ ${fmt(p.totalLucro)}',
                        style: const TextStyle(
                          color: AppTheme.green,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (expanded)
              Container(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Column(
                  children: [
                    _row('Custo', fmt(p.precoCusto)),
                    _row('Venda', fmt(p.precoVenda)),
                    _row('Unitário', fmt(p.custoUnitario)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(String l, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l),
          Text(
            v,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class ConfigScreen extends StatelessWidget {
  ConfigScreen({super.key});

  final List<Map<String, dynamic>> itens = [
    {
      'icon': Icons.bar_chart,
      'title': 'Relatórios',
    },
    {
      'icon': Icons.shopping_cart,
      'title': 'Pedidos',
    },
    {
      'icon': Icons.flag,
      'title': 'Metas',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: itens.length,
          itemBuilder: (context, index) {
            final item = itens[index];

            return ListTile(
              leading: Icon(item['icon']),
              title: Text(item['title']),
            );
          },
        ),
      ),
    );
  }
}

class PerfilScreen extends StatelessWidget {
  PerfilScreen({super.key});

  final double total = ProdutoRepository.totalVendido;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 40,
                child: Icon(Icons.store, size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                'Bete Salgados',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Total vendido: ${fmt(total)}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}