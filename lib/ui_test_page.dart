import 'package:flutter/material.dart';

class UiTestPage extends StatelessWidget {
  const UiTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teste de UI (Lista 1k)')),
      body: ListView.builder(
        itemCount: 1000,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Text('Item ${index + 1}'),
            subtitle: Text(
              'Descrição do item ${index + 1} para teste de scroll',
            ),
          );
        },
      ),
    );
  }
}
