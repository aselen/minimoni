class FeedingModel {
  final String id;
  final String babyId;
  final String type; // 'breast', 'formula', 'solid'
  final int? amount; // ml for formula/solid, null for breast
  final Duration? duration; // for breast feeding
  final DateTime timestamp;
  final String? note;
  final String? side; // 'left', 'right', 'both' for breast feeding

  FeedingModel({
    required this.id,
    required this.babyId,
    required this.type,
    this.amount,
    this.duration,
    required this.timestamp,
    this.note,
    this.side,
  });

  // Generate unique ID
  static String generateId() {
    return 'feeding_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Get feeding type display name
  String get typeDisplayName {
    switch (type) {
      case 'breast':
        return 'Anne Sutu';
      case 'formula':
        return 'Biberon';
      case 'solid':
        return 'Kati Besin';
      default:
        return type;
    }
  }

  // Get display amount/duration
  String get displayAmount {
    switch (type) {
      case 'breast':
        if (duration != null) {
          return '${duration!.inMinutes} dakika';
        }
        return 'Belirtilmedi';
      case 'formula':
      case 'solid':
        if (amount != null) {
          return '${amount}ml';
        }
        return 'Belirtilmedi';
      default:
        return 'Belirtilmedi';
    }
  }

  // Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dakika once';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat once';
    } else {
      return '${difference.inDays} gun once';
    }
  }

  // Get display note
  String get displayNote {
    if (note != null && note!.isNotEmpty) {
      return note!;
    }

    switch (type) {
      case 'breast':
        if (side != null) {
          switch (side) {
            case 'left':
              return 'Sol gogus';
            case 'right':
              return 'Sag gogus';
            case 'both':
              return 'Her iki gogus';
            default:
              return 'Anne sutu';
          }
        }
        return 'Anne sutu';
      case 'formula':
        return 'Biberon';
      case 'solid':
        return 'Kati besin';
      default:
        return typeDisplayName;
    }
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'babyId': babyId,
      'type': type,
      'amount': amount,
      'duration': duration?.inMinutes,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
      'side': side,
    };
  }

  // Create from JSON
  factory FeedingModel.fromJson(Map<String, dynamic> json) {
    return FeedingModel(
      id: json['id'] ?? generateId(),
      babyId: json['babyId'] ?? '',
      type: json['type'] ?? 'breast',
      amount: json['amount'],
      duration:
          json['duration'] != null ? Duration(minutes: json['duration']) : null,
      timestamp:
          json['timestamp'] != null
              ? DateTime.parse(json['timestamp'])
              : DateTime.now(),
      note: json['note'],
      side: json['side'],
    );
  }

  // Create copy with updated fields
  FeedingModel copyWith({
    String? id,
    String? babyId,
    String? type,
    int? amount,
    Duration? duration,
    DateTime? timestamp,
    String? note,
    String? side,
  }) {
    return FeedingModel(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      duration: duration ?? this.duration,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
      side: side ?? this.side,
    );
  }

  @override
  String toString() {
    return 'FeedingModel(id: $id, type: $type, amount: $amount, duration: $duration, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeedingModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
