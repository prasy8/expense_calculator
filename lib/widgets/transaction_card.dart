import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionCard({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final bool isIncome =
        transaction.type == 'income';

    return Card(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      elevation: 0,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),

        leading: CircleAvatar(
          backgroundColor:
              isIncome
                  ? Colors.green.withOpacity(0.12)
                  : Colors.red.withOpacity(0.12),

          child: Icon(
            isIncome
                ? Icons.arrow_downward
                : Icons.arrow_upward,

            color: isIncome
                ? Colors.green
                : Colors.red,
          ),
        ),

        title: Text(
          transaction.description,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),

        subtitle: Text(
          '${transaction.category} • '
          '${DateFormat('dd MMM yyyy').format(transaction.transactionDate)}',
        ),

        trailing: Text(
          '${isIncome ? '+' : '-'} ₹${transaction.amount.toStringAsFixed(2)}',

          style: TextStyle(
            color:
                isIncome
                    ? Colors.green
                    : Colors.red,

            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}