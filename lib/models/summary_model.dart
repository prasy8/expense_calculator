class SummaryModel {
  final double income;
  final double expense;
  final double balance;

  SummaryModel({
    required this.income,
    required this.expense,
    required this.balance,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      income: double.tryParse(
            json['income']?.toString() ?? '0',
          ) ??
          0.0,

      expense: double.tryParse(
            json['expense']?.toString() ?? '0',
          ) ??
          0.0,

      balance: double.tryParse(
            json['balance']?.toString() ?? '0',
          ) ??
          0.0,
    );
  }

  factory SummaryModel.empty() {
    return SummaryModel(
      income: 0,
      expense: 0,
      balance: 0,
    );
  }
}