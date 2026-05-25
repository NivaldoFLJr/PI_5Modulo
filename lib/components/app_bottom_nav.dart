import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),

      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,

        type: BottomNavigationBarType.fixed,

        backgroundColor: Colors.white,

        selectedItemColor: AppTheme.primaryDeep,
        unselectedItemColor: AppTheme.textMuted,

        selectedFontSize: 12,
        unselectedFontSize: 12,

        elevation: 0,

        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
        ),

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
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
            icon: Icon(Icons.trending_up_rounded),
            label: 'Relatórios',
          ),
        ],
      ),
    );
  }
}