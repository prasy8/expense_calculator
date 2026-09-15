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

  // Categories available for the Category filter
  final List<String> categoryOptions;

  TransactionResponseModel({
    required this.success,
    required this.message,
    required this.transactions,
    required this.pagination,
    required this.summary,
    required this.categorySummary,
    required this.categoryOptions,
  });

  factory TransactionResponseModel.fromJson(Map<String, dynamic> json,) {
    /*print('>>> FROM JSON CALLED <<<');
    print('>>> JSON KEYS: ${json.keys}');
    print('>>> CATEGORY OPTIONS RAW: ${json['category_options']}');
    */
    final List<dynamic> data = json['data'] ?? [];
    final Map<String, dynamic> categoryData = Map<String, dynamic>.from(json['category_summary'] ?? {},);
    final Map<String, double> categorySummary = {};

    categoryData.forEach((key, value) {
      categorySummary[key] = double.tryParse(value.toString()) ?? 0.0;
    });
    // ========================================
    // Category Options
    // Used by Category Dropdown
    // ========================================
    final List<dynamic> categoryDataOptions = json['category_options'] is List ? List<dynamic>.from(json['category_options']) : [];

    final List<String> categoryOptions = categoryDataOptions.map((item) => item.toString()).where((item) => item.isNotEmpty).toList();
    /*
    // DEBUG
    print('JSON CATEGORY OPTIONS: ${json['category_options']}');
    print('PARSED CATEGORY OPTIONS: $categoryOptions');*/
    /*final List<dynamic> categoryDataOptions = json['category_options'] ?? [];

    final List<String> categoryOptions = categoryDataOptions.map((item) => item.toString()).toList();
    */
    // ========================================
    // Return Model
    // ========================================

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
      categoryOptions: categoryOptions,
    );
  }
}