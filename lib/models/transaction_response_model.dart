import 'transaction_model.dart';
import 'summary_model.dart';
import 'pagination_model.dart';

class TransactionResponseModel {
  final bool success;
  final String message;
  final List<TransactionModel> transactions;
  final PaginationModel pagination;
  final SummaryModel summary;
  final Map<String, double> categorySummary;

  TransactionResponseModel({
    required this.success,
    required this.message,
    required this.transactions,
    required this.pagination,
    required this.summary,
    required this.categorySummary,
  });

  factory TransactionResponseModel.fromJson(Map<String, dynamic> json,) {

    final List<dynamic> data = json['data'] ?? [];
    final Map<String, dynamic> categoryData = Map<String, dynamic>.from(json['category_summary'] ?? {},);
    final Map<String, double> categorySummary = {};

    categoryData.forEach((key, value) {
      categorySummary[key] = double.tryParse(value.toString()) ?? 0.0;
    });

    return TransactionResponseModel(
      success: json['success'] == true,

      message: json['message']?.toString() ?? '',

      transactions: data
          .map(
            (item) => TransactionModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),

      pagination: PaginationModel.fromJson(
        Map<String, dynamic>.from(
          json['pagination'] ?? {},
        ),
      ),

      summary: SummaryModel.fromJson(
        Map<String, dynamic>.from(
          json['summary'] ?? {},
        ),
      ),

      categorySummary: categorySummary,
    );
  }
}