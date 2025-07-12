class BabyModel {
  final String id;
  final String name;
  final String gender;
  final DateTime birthDate;
  final String? parentName;
  final bool isActive;

  BabyModel({
    required this.id,
    required this.name,
    required this.gender,
    required this.birthDate,
    this.parentName,
    this.isActive = false,
  });

  // JSON serileştirme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'birthDate': birthDate.toIso8601String(),
      'parentName': parentName,
      'isActive': isActive,
    };
  }

  // JSON'dan oluşturma
  factory BabyModel.fromJson(Map<String, dynamic> json) {
    return BabyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      gender: json['gender'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      parentName: json['parentName'] as String?,
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  // ID generator
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Yaş hesaplama
  int get ageInMonths {
    final now = DateTime.now();
    int months = (now.year - birthDate.year) * 12;
    months += now.month - birthDate.month;
    if (now.day < birthDate.day) months--;
    return months;
  }

  // Yaş string formatı
  String get ageString {
    final months = ageInMonths;
    if (months < 12) {
      return '$months aylık';
    } else {
      final years = months ~/ 12;
      final remainingMonths = months % 12;
      if (remainingMonths == 0) {
        return '$years yaşında';
      } else {
        return '$years yaş $remainingMonths aylık';
      }
    }
  }

  // Cinsiyet emojisi
  String get genderEmoji {
    switch (gender.toLowerCase()) {
      case 'erkek':
      case 'male':
        return '👦';
      case 'kız':
      case 'female':
        return '👧';
      default:
        return '👶';
    }
  }

  // Copy with method
  BabyModel copyWith({
    String? id,
    String? name,
    String? gender,
    DateTime? birthDate,
    String? parentName,
    bool? isActive,
  }) {
    return BabyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      parentName: parentName ?? this.parentName,
      isActive: isActive ?? this.isActive,
    );
  }
}
