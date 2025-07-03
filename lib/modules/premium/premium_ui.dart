import 'package:flutter/material.dart';
import 'premium_manager.dart';

class PremiumUI extends StatelessWidget {
  const PremiumUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Premium Features')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await PremiumManager().purchasePremium();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Premium purchase initiated')),
            );
          },
          child: const Text('Upgrade to Premium'),
        ),
      ),
    );
  }
}
