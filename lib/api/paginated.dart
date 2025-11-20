class Paginated<T> {
  final List<T> data;
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  Paginated({
    required this.data,
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  static Paginated<T> fromJson<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final list = (json['data'] as List).cast<dynamic>();
    final items = list.map((e) => fromJson((e as Map<String, dynamic>))).toList();
    final meta = (json['meta'] ?? {}) as Map<String, dynamic>;
    return Paginated<T>(
      data: items,
      currentPage: (meta['current_page'] ?? 1) as int,
      perPage: (meta['per_page'] ?? items.length) as int,
      total: (meta['total'] ?? items.length) as int,
      lastPage: (meta['last_page'] ?? 1) as int,
    );
    }
}