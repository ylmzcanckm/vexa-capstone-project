import 'package:flutter/material.dart';

/// Geçmiş ekranı — içerik sonra doldurulacak.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Geçmiş')),
      body: const Center(
        child: Text('Yakında'),
      ),
    );
  }
}
