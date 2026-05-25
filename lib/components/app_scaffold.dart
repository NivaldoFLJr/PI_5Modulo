import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/login/login_page.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final int currentIndex;
  final bool showMenu;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.currentIndex,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.showMenu = true,
  });

  void _onMenuSelected(BuildContext context, String value) {
    switch (value) {
      case 'perfil':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil em breve')),
        );
        break;
      case 'configuracoes':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configurações em breve')),
        );
        break;
      case 'sair':
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: showMenu
            ? [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) => _onMenuSelected(context, value),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'perfil',
                      child: Row(
                        children: const [
                          Icon(Icons.person_outline, size: 20),
                          SizedBox(width: 12),
                          Text('Perfil'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'configuracoes',
                      child: Row(
                        children: const [
                          Icon(Icons.settings_outlined, size: 20),
                          SizedBox(width: 12),
                          Text('Configurações'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'sair',
                      child: Row(
                        children: const [
                          Icon(Icons.logout, size: 20, color: Colors.red),
                          SizedBox(width: 12),
                          Text('Sair', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ]
            : null,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}