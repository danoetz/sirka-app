import 'dart:convert';

Pagination paginationFromJson(String str) => Pagination.fromJson(json.decode(str));

String paginationToJson(Pagination data) => json.encode(data.toJson());

class Pagination<T> {
  Pagination({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
    required this.data,
  });

  int currentPage;
  int perPage;
  int total;
  int lastPage;
  List<T> data;

  Pagination<T> copyWith({
    int? currentPage,
    int? perPage,
    int? total,
    int? lastPage,
    List<T>? data,
  }) =>
      Pagination(
        currentPage: currentPage ?? this.currentPage,
        perPage: perPage ?? this.perPage,
        total: total ?? this.total,
        lastPage: lastPage ?? this.lastPage,
        data: data ?? this.data,
      );

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        currentPage: json["currentPage"],
        perPage: json["perPage"],
        total: json["total"],
        lastPage: json["lastPage"],
        data: List<T>.from(json["data"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "currentPage": currentPage,
        "perPage": perPage,
        "total": total,
        "lastPage": lastPage,
        "data": List<T>.from(data.map((x) => x)),
      };
}
