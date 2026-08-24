class TransactionModel {
  final int? id;
  final String description;
  final double amount;
  final String type;
  final String category;
  final DateTime transactionDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TransactionModel({
    this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.category,
    required this.transactionDate,
    this.createdAt,
    this.updatedAt,
  });
// fromJson() converts API resp JSON into  Dart object.
//String → key
//dynamic → value
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      //Get description. Convert it to String if it exists. If it doesn't exist, use an empty string.
      description: json['description']?.toString() ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0', ) ?? 0.0,
      type: json['type']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Other',
      transactionDate: DateTime.parse(json['transaction_date']?.toString() ?? json['date'].toString(),),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString(),) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString(),) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'type': type,
      'category': category,
      'date':
          transactionDate.toIso8601String().split('T').first,
    };
  }
}