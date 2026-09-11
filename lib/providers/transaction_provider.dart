import 'package:flutter/foundation.dart';

import '../models/transaction_model.dart';
import '../models/summary_model.dart';
import '../models/pagination_model.dart';
import '../services/transaction_api_service.dart';

class TransactionProvider extends ChangeNotifier {

  final TransactionApiService _apiService = TransactionApiService();

  List<TransactionModel> transactions = [];
  SummaryModel summary = SummaryModel.empty();
  PaginationModel pagination = PaginationModel.empty();
  Map<String, double> categorySummary = {};

  bool isLoading = false;

  String? errorMessage;

  Future<void> loadTransactions({
    int page = 1,
    int limit = 10,
    String search = '',
    String type = '',
    String month = '',
    String category = '',
  }) async {
    isLoading = true;
    errorMessage = null;

    notifyListeners();

    try {
      final result = await _apiService.getTransactions(
        page: page,
        limit: limit,
        search: search,
        type: type,
        month: month,
        category: category,
      );

      print('API FILTER TYPE: [$type]');
      print('RESULT TRANSACTIONS: ${result.transactions.length}');

      for (final transaction in result.transactions) {
        print(
          'Transaction: ${transaction.description} | '
          'Type: ${transaction.type} | '
          'Amount: ${transaction.amount}',
        );
      }

      transactions    = result.transactions;
      summary         = result.summary;
      pagination      = result.pagination;
      categorySummary = result.categorySummary;
    } 
    catch (error) {
      print('API ERROR: $error');
      errorMessage = error.toString();
    }

    isLoading = false;

    notifyListeners();
  }

  Future<bool> addTransaction({
    required String description,
    required double amount,
    required String type,
    required String category,
    required String date,
    }) 
    async {
      try 
      {
        errorMessage = null;

          final transaction = TransactionModel(
                                                id: 0,
                                                description: description,
                                                amount: amount,
                                                type: type,
                                                category: category,
                                                transactionDate: DateTime.parse(date),
                                              );

        await _apiService.addTransaction(transaction);

        await loadTransactions(
          page: 1,
          limit: 5,
        );

        return true;
      

      } 
      catch (e) 
      {
        errorMessage =  e.toString();
        notifyListeners();
        return false;

      }
    }

    Future<bool> updateTransaction({
      required int id,
      required String description,
      required double amount,
      required String type,
      required String category,
      required String date,
    }) async {
      try {
          errorMessage = null;
    
          final transaction = TransactionModel(
                                                id: id,
                                                description: description,
                                                amount: amount,
                                                type: type,
                                                category: category,
                                                transactionDate: DateTime.parse(date),
                                              );

          await _apiService.updateTransaction(transaction);


          await loadTransactions(page: 1,limit: 5,);
          return true;
      } 
      catch (e) {
        errorMessage = e.toString();
        notifyListeners();
        return false;
      }
    }

}
/*
notifyListeners()- The data has changed. Widgets that are listening to me should rebuild.
You don't manually manipulate the UI like you did with JavaScript:
totalIncome.textContent = ...
Flutter rebuilds the relevant widgets.
*/