import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/transaction_model.dart';

class CsvExport {

  static Future<void> exportTransactions(
    List<TransactionModel> transactions,
  ) async {

    final List<List<dynamic>> rows = [];

    // CSV Header
    rows.add([
      'ID',
      'Description',
      'Amount',
      'Type',
      'Category',
      'Transaction Date',
    ]);

    // CSV Data
    for (final transaction in transactions) {

      rows.add([
        transaction.id ?? '',
        transaction.description,
        transaction.amount,
        transaction.type,
        transaction.category,
        transaction.transactionDate
            .toIso8601String()
            .split('T')
            .first,
      ]);
    }

    // Convert rows to CSV
    final String csvData = csv.encode(rows);

    // Get application directory
    final directory =
        await getApplicationDocumentsDirectory();

    // Create filename
    final now = DateTime.now();

    final fileName =
        'expense_transactions_'
        '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}-'
        '${now.minute.toString().padLeft(2, '0')}.csv';

    final file = File(
      '${directory.path}/$fileName',
    );

    // Write CSV
    await file.writeAsString(csvData);

    // Share / Save
    await SharePlus.instance.share(
      ShareParams(
        text: 'Expense Transactions CSV',
        files: [
          XFile(file.path),
        ],
      ),
    );
  }
}