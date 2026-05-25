import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  final int currentIndex;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.currentIndex,
    this.bottomNavigationBar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),

      body: body,

      floatingActionButton: floatingActionButton,

      bottomNavigationBar: bottomNavigationBar,
    );
  }
}