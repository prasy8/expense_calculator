import 'package:flutter/material.dart';

class TransactionsScreen
    extends StatelessWidget {

  const TransactionsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
                title: const Text('Transactions',),
                actions: [
                    IconButton(
                      tooltip: 'Export CSV', 
                      onPressed: () {print('Button pressed!');}, 
                      icon: const Icon(Icons.download))
                ],
              ),

      body: const Center(
        child: Text(
          'Transactions',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}