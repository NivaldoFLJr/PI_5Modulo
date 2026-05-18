import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      child: const HomePage(),
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _navIndex = 2;

  final List<Pedido> pedidos = [
    Pedido(
      cliente: 'Maria Clara',
      itens: '50 Coxinhas • 20 Kibes',
      valor: 'R\$ 180,00',
      status: 'Em preparo',
    ),
    Pedido(
      cliente: 'João Pedro',
      itens: '100 Salgados variados',
      valor: 'R\$ 320,00',
      status: 'Finalizado',
    ),
    Pedido(
      cliente: 'Fernanda',
      itens: '30 Enroladinhos',
      valor: 'R\$ 90,00',
      status: 'Entregue',
    ),
  ];

  void _openLeftCard(Widget card) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => Scaffold(
          backgroundColor: Colors.transparent,
          body: GestureDetector(
            onTap: () => Navigator.pop(context),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Expanded(child: card),
                Expanded(child: Container()),
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
          backgroundColor: Colors.transparent,
          body: GestureDetector(
            onTap: () => Navigator.pop(context),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Expanded(child: Container()),
                Expanded(child: card),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos'),
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
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 110),
            children: [
              const HeroBanner(),

              const SizedBox(height: 20),

              const Text(
                'Pedidos Recentes',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),

              const SizedBox(height: 18),

              ...pedidos.map(
                (pedido) => PedidoCard(pedido: pedido),
              ),
            ],
          ),

          Positioned(
            right: 20,
            bottom: 20,
            child: FloatingActionButton(
              backgroundColor: AppTheme.primaryDeep,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddPedidoPage(),
                  ),
                );
              },
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (i) {
          setState(() {
            _navIndex = i;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Estoque',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Pedidos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Relatórios',
          ),
        ],
      ),
    );
  }
}

class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
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
              'PEDIDOS',
              '24',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _metric(
              'FATURADO',
              'R\$ 590',
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

class Pedido {
  final String cliente;
  final String itens;
  final String valor;
  final String status;

  Pedido({
    required this.cliente,
    required this.itens,
    required this.valor,
    required this.status,
  });
}

class PedidoCard extends StatelessWidget {
  final Pedido pedido;

  const PedidoCard({
    super.key,
    required this.pedido,
  });

  Color getStatusColor() {
    switch (pedido.status) {
      case 'Finalizado':
        return AppTheme.green;

      case 'Entregue':
        return AppTheme.primaryDeep;

      default:
        return AppTheme.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.cardBorder,
        ),
      ),
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
                  Text(
                    pedido.cliente,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    pedido.itens,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: getStatusColor().withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      pedido.status,
                      style: TextStyle(
                        color: getStatusColor(),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Text(
              pedido.valor,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddPedidoPage extends StatefulWidget {
  const AddPedidoPage({super.key});

  @override
  State<AddPedidoPage> createState() => _AddPedidoPageState();
}

class _AddPedidoPageState extends State<AddPedidoPage> {
  final List<Map<String, dynamic>> produtos = [
    {
      'nome': 'Coxinha',
      'quantidade': 0,
    },
    {
      'nome': 'Kibe',
      'quantidade': 0,
    },
    {
      'nome': 'Enroladinho',
      'quantidade': 0,
    },
    {
      'nome': 'Bolinha de queijo',
      'quantidade': 0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Pedido'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Escolha os itens',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),

          const SizedBox(height: 22),

          ...produtos.map(
            (produto) {
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppTheme.cardBorder,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      produto['nome'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),

                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (produto['quantidade'] > 0) {
                                produto['quantidade']--;
                              }
                            });
                          },
                          icon: const Icon(Icons.remove_circle_outline),
                        ),

                        Text(
                          produto['quantidade'].toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        IconButton(
                          onPressed: () {
                            setState(() {
                              produto['quantidade']++;
                            });
                          },
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 26),

          SizedBox(
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryDeep,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Salvar Pedido',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ConfigScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            ListTile(
              leading: Icon(Icons.bar_chart),
              title: Text('Relatórios'),
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text('Pedidos'),
            ),
            ListTile(
              leading: Icon(Icons.flag),
              title: Text('Metas'),
            ),
          ],
        ),
      ),
    );
  }
}

class PerfilScreen extends StatelessWidget {
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

              const Text(
                'Painel do usuário',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}