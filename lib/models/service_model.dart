class ServiceModel {
  final int    id;
  final String name;
  final String? description;
  final double price;
  final int    duration;
  final String? image;
  final bool   isActive;

  ServiceModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.duration,
    this.image,
    required this.isActive,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id:          json['id'],
      name:        json['name'] ?? '',
      description: json['description'],
      price:       double.parse(json['price']?.toString() ?? '0'),
      duration:    json['duration'] ?? 0,
      image:       json['image'],
      isActive:    json['is_active'] ?? true,
    );
  }

  // Format harga ke Rupiah: 35000 → Rp 35.000
  String get priceFormatted {
    final formatted = price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }
}
