import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/app_constants.dart';
import '../models/transaction_model.dart';
import '../models/transaction_response_model.dart';

class TransactionApiService {
  final String endpoint = AppConstants.transactionsEndpoint;

  Future<TransactionResponseModel> getTransactions({
      int page = 1,
      int limit = 10,
      String search = '',
      String type = '',
      String month = '',
      String category = '',
    }) 
  async {
    final uri = Uri.parse(endpoint).replace(
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
        'search': search,
        'type': type,
        'month': month,
        'category': category,
      },
    );

    final response = await http.get(uri);
    //print(response.body);
    if (response.statusCode != 200) {
      throw Exception('Failed to load transactions',);
    }
    /*print('RAW API RESPONSE:');
    print(response.body);*/
    final Map<String, dynamic> json = jsonDecode(response.body);

    if (json['success'] != true) {
      throw Exception(json['message'] ?? 'Unable to load transactions',);
    }

    return TransactionResponseModel.fromJson(json);
  }

  //POST-added this method
  Future<int> addTransaction(
    TransactionModel transaction,
  ) 
  async {
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'description': transaction.description,
        'amount': transaction.amount,
        'type': transaction.type,
        'category': transaction.category,
        'date': transaction.transactionDate.toIso8601String().split('T').first,}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add transaction',);
    }

    final Map<String, dynamic> json = jsonDecode(response.body);

    if (json['success'] != true) {
      throw Exception(json['message'] ?? 'Unable to add transaction',);
    }

    return int.tryParse(json['id']?.toString() ?? '0',) ?? 0;
  }

  //PUT - added this method
  Future<void> updateTransaction(
    TransactionModel transaction,
  ) 
  async {
    final response = await http.put(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id': transaction.id,
        'description': transaction.description,
        'amount': transaction.amount,
        'type': transaction.type,
        'category': transaction.category,
        'date': transaction.transactionDate.toIso8601String().split('T').first,}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update transaction',);
    }

    final Map<String, dynamic> json = jsonDecode(response.body);

    if (json['success'] != true) {
      throw Exception(json['message'] ?? 'Unable to update transaction',);
    }
  }

  //Add DELETE function
  Future<void> deleteTransaction(
    int id,
  ) 
  async {
    final response = await http.delete(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id': id,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete transaction',);
    }

    final Map<String, dynamic> json = jsonDecode(response.body);

    if (json['success'] != true) {
      throw Exception(json['message'] ?? 'Unable to delete transaction',);
    }
  }

}