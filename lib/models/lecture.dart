class Lecture {
  final int? id;
  final String name;
  final String type; // نظري أو عملي
  final String? doctorName;
  final String startTime;
  final String location;
  final int dayOfWeek; // 1 = الأحد, 2 = الاثنين, ... 7 = السبت
  final DateTime createdAt;

  Lecture({
    this.id,
    required this.name,
    required this.type,
    this.doctorName,
    required this.startTime,
    required this.location,
    required this.dayOfWeek,
    required this.createdAt,
  });

  // تحويل من Map إلى Lecture
  factory Lecture.fromMap(Map<String, dynamic> map) {
    return Lecture(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      doctorName: map['doctor_name'],
      startTime: map['start_time'],
      location: map['location'],
      dayOfWeek: map['day_of_week'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  // تحويل من Lecture إلى Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'doctor_name': doctorName,
      'start_time': startTime,
      'location': location,
      'day_of_week': dayOfWeek,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // نسخ المحاضرة مع تعديل بعض الخصائص
  Lecture copyWith({
    int? id,
    String? name,
    String? type,
    String? doctorName,
    String? startTime,
    String? location,
    int? dayOfWeek,
    DateTime? createdAt,
  }) {
    return Lecture(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      doctorName: doctorName ?? this.doctorName,
      startTime: startTime ?? this.startTime,
      location: location ?? this.location,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // الحصول على اسم اليوم بالعربية
  String get dayName {
    switch (dayOfWeek) {
      case 1:
        return 'الأحد';
      case 2:
        return 'الاثنين';
      case 3:
        return 'الثلاثاء';
      case 4:
        return 'الأربعاء';
      case 5:
        return 'الخميس';
      case 6:
        return 'الجمعة';
      case 7:
        return 'السبت';
      default:
        return 'غير محدد';
    }
  }

  @override
  String toString() {
    return 'Lecture{id: $id, name: $name, type: $type, doctorName: $doctorName, startTime: $startTime, location: $location, dayOfWeek: $dayOfWeek, dayName: $dayName}';
  }
}

