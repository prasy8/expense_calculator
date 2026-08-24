class PaginationModel {
  final int currentPage;
  final int perPage;
  final int totalRecords;
  final int totalPages;
  final int from;
  final int to;

  PaginationModel({
    required this.currentPage,
    required this.perPage,
    required this.totalRecords,
    required this.totalPages,
    required this.from,
    required this.to,
  });

  factory PaginationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PaginationModel(
      currentPage:
          int.tryParse(
                json['current_page']?.toString() ?? '1',
              ) ??
              1,

      perPage:
          int.tryParse(
                json['per_page']?.toString() ?? '10',
              ) ??
              10,

      totalRecords:
          int.tryParse(
                json['total_records']?.toString() ?? '0',
              ) ??
              0,

      totalPages:
          int.tryParse(
                json['total_pages']?.toString() ?? '0',
              ) ??
              0,

      from:
          int.tryParse(
                json['from']?.toString() ?? '0',
              ) ??
              0,

      to:
          int.tryParse(
                json['to']?.toString() ?? '0',
              ) ??
              0,
    );
  }

  factory PaginationModel.empty() {
    return PaginationModel(
      currentPage: 1,
      perPage: 10,
      totalRecords: 0,
      totalPages: 0,
      from: 0,
      to: 0,
    );
  }
}