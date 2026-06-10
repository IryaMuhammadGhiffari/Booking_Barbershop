import 'service_model.dart';

class BarberModel {
  final int    id;
  final String name;
  final String? specialty;
  final String? bio;
  final String? photo;
  final int    experienceYears;
  final double rating;
  final bool   isActive;
  final List<ServiceModel>? services;

  BarberModel({
    required this.id,
    required this.name,
    this.specialty,
    this.bio,
    this.photo,
    required this.experienceYears,
    required this.rating,
    required this.isActive,
    this.services,
  });

  factory BarberModel.fromJson(Map<String, dynamic> json) {
    return BarberModel(
      id:              json['id'],
      name:            json['name'],
      specialty:       json['specialty'],
      bio:             json['bio'],
      photo:           json['photo'],
      experienceYears: json['experience_years'] ?? 0,
      rating:          double.parse(json['rating']?.toString() ?? '5.0'),
      isActive:        json['is_active'] ?? true,
      services:        (json['services'] as List<dynamic>?)
          ?.map((s) => ServiceModel.fromJson(s))
          .toList(),
    );
  }
}
