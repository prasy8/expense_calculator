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

      transactions    = result.transactions;
      summary         = result.summary;
      pagination      = result.pagination;
      categorySummary = result.categorySummary;
    } 
    catch (error) {
      errorMessage = error.toString();
    }

    isLoading = false;

    notifyListeners();
  }
}
/*
notifyListeners()- The data has changed. Widgets that are listening to me should rebuild.
You don't manually manipulate the UI like you did with JavaScript:
totalIncome.textContent = ...
Flutter rebuilds the relevant widgets.
*/