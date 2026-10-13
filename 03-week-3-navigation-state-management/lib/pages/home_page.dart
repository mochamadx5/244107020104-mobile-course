import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) => ListTile(
          title: Text('Item ${index + 1}'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          // Navigasi deklaratif menuju route detail dengan parameter index
          onTap: () => context.go('/detail/${index + 1}'),
        ),
      ),
    );
  }
}
