import 'package:equatable/equatable.dart';

/// Respuesta paginada estándar del backend.
/// Forma del JSON: `{ "data": [...], "total": N, "page": N, "lastPage": N }`.
class PaginatedResponse<T> extends Equatable {
  final List<T> data;
  final int total;
  final int page;
  final int lastPage;

  const PaginatedResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.lastPage,
  });

  bool get hasMore => page < lastPage;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final rawList = (json['data'] as List<dynamic>?) ?? const [];
    return PaginatedResponse<T>(
      data: rawList
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(growable: false),
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      lastPage: (json['lastPage'] as num?)?.toInt() ?? 1,
    );
  }

  PaginatedResponse<T> copyWithMerge(PaginatedResponse<T> next) =>
      PaginatedResponse<T>(
        data: [...data, ...next.data],
        total: next.total,
        page: next.page,
        lastPage: next.lastPage,
      );

  @override
  List<Object?> get props => [data, total, page, lastPage];
}
