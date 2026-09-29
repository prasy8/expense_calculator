import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/transaction_model.dart';

class CsvExport {

  static Future<void> exportTransactions(
    List<TransactionModel> transactions,
  ) async {

     // ==========================================
    // Calculate Summary
    // ==========================================

    double totalIncome = 0;
    double totalExpense = 0;

    for (final transaction in transactions) {

      if (transaction.type == 'income') {
        totalIncome += transaction.amount;
      } 
      else if (transaction.type == 'expense') 
      {
        totalExpense += transaction.amount;
      }
    }

    final double balance = totalIncome - totalExpense;


    // ==========================================
    // CSV Rows
    // ==========================================
    final List<List<dynamic>> rows = [];

    // ==========================================
    // Summary
    // ==========================================

    rows.add(['Summary','',]);
    rows.add(['Total Income',totalIncome.toStringAsFixed(2),]);
    rows.add(['Total Expense',totalExpense.toStringAsFixed(2),]);
    rows.add(['Balance',balance.toStringAsFixed(2),]);

    // Empty row between summary and transactions
    rows.add([]);

    // ==========================================
    // Transaction Header
    // ==========================================

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
        transaction.transactionDate.toIso8601String().split('T').first,
      ]);
    }

    // Convert rows to CSV
    final String csvData = csv.encode(rows);

    // Get application directory
    final directory = await getApplicationDocumentsDirectory();

    // Create filename
    final now = DateTime.now();

    final fileName =
        'expense_transactions_'
        '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}-'
        '${now.minute.toString().padLeft(2, '0')}.csv';

    final file = File('${directory.path}/$fileName',);

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