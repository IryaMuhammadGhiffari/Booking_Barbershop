/// Mengurai respons API: array langsung atau hasil paginate Laravel lama.
List<dynamic> apiDataAsList(dynamic raw) {
  if (raw is List) return raw;
  if (raw is Map && raw['data'] is List) return raw['data'] as List;
  return [];
}
