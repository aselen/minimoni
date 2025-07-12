import 'package:hive/hive.dart';

part 'growth_model.g.dart';

@HiveType(typeId: 13)
class GrowthModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String babyId;

  @HiveField(2)
  double height; // cm cinsinden

  @HiveField(3)
  double weight; // kg cinsinden

  @HiveField(4)
  DateTime measurementDate;

  @HiveField(5)
  String? notes;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime updatedAt;

  GrowthModel({
    required this.id,
    required this.babyId,
    required this.height,
    required this.weight,
    required this.measurementDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GrowthModel.create({
    required String babyId,
    required double height,
    required double weight,
    required DateTime measurementDate,
    String? notes,
  }) {
    final now = DateTime.now();
    return GrowthModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      babyId: babyId,
      height: height,
      weight: weight,
      measurementDate: measurementDate,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  GrowthModel copyWith({
    String? id,
    String? babyId,
    double? height,
    double? weight,
    DateTime? measurementDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GrowthModel(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      measurementDate: measurementDate ?? this.measurementDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'babyId': babyId,
      'height': height,
      'weight': weight,
      'measurementDate': measurementDate.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory GrowthModel.fromJson(Map<String, dynamic> json) {
    return GrowthModel(
      id: json['id'],
      babyId: json['babyId'],
      height: json['height'].toDouble(),
      weight: json['weight'].toDouble(),
      measurementDate: DateTime.parse(json['measurementDate']),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  @override
  String toString() {
    return 'GrowthModel(id: $id, babyId: $babyId, height: ${height}cm, weight: ${weight}kg, date: $measurementDate)';
  }
}
