import 'package:flutter/foundation.dart';
import '../models/lecture.dart';
import 'database_service.dart';

class LectureService extends ChangeNotifier {
  List<Lecture> _lectures = [];
  List<Lecture> _filteredLectures = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Lecture> get lectures => _lectures;
  List<Lecture> get filteredLectures => _filteredLectures;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  // تحميل جميع المحاضرات
  Future<void> loadLectures() async {
    _isLoading = true;
    notifyListeners();

    try {
      _lectures = await DatabaseService.getAllLectures();
      _filteredLectures = List.from(_lectures);
    } catch (e) {
      print('خطأ في تحميل المحاضرات: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // إضافة محاضرة جديدة
  Future<bool> addLecture(Lecture lecture) async {
    try {
      final id = await DatabaseService.insertLecture(lecture);
      final newLecture = lecture.copyWith(id: id);
      _lectures.add(newLecture);
      _applyFilter();
      notifyListeners();
      return true;
    } catch (e) {
      print('خطأ في إضافة المحاضرة: $e');
      return false;
    }
  }

  // تحديث محاضرة
  Future<bool> updateLecture(Lecture lecture) async {
    try {
      await DatabaseService.updateLecture(lecture);
      final index = _lectures.indexWhere((l) => l.id == lecture.id);
      if (index != -1) {
        _lectures[index] = lecture;
        _applyFilter();
        notifyListeners();
      }
      return true;
    } catch (e) {
      print('خطأ في تحديث المحاضرة: $e');
      return false;
    }
  }

  // حذف محاضرة
  Future<bool> deleteLecture(int id) async {
    try {
      await DatabaseService.deleteLecture(id);
      _lectures.removeWhere((lecture) => lecture.id == id);
      _applyFilter();
      notifyListeners();
      return true;
    } catch (e) {
      print('خطأ في حذف المحاضرة: $e');
      return false;
    }
  }

  // البحث في المحاضرات
  void searchLectures(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  // تطبيق الفلتر
  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredLectures = List.from(_lectures);
    } else {
      _filteredLectures = _lectures.where((lecture) {
        return lecture.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               (lecture.doctorName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
               lecture.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               lecture.type.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  // الحصول على محاضرات يوم معين
  List<Lecture> getLecturesByDay(int dayOfWeek) {
    return _filteredLectures.where((lecture) => lecture.dayOfWeek == dayOfWeek).toList();
  }

  // الحصول على محاضرات اليوم
  List<Lecture> getTodayLectures() {
    final today = DateTime.now().weekday;
    // تحويل من نظام Dart (1=الاثنين) إلى نظامنا (1=الأحد)
    int ourDaySystem = today == 7 ? 1 : today + 1;
    return getLecturesByDay(ourDaySystem);
  }

  // الحصول على المحاضرة التالية
  Lecture? getNextLecture() {
    final now = DateTime.now();
    final todayLectures = getTodayLectures();
    
    for (final lecture in todayLectures) {
      final lectureTime = _parseTime(lecture.startTime);
      if (lectureTime != null && lectureTime.isAfter(now)) {
        return lecture;
      }
    }
    
    // إذا لم توجد محاضرة اليوم، ابحث في الأيام التالية
    for (int i = 1; i <= 7; i++) {
      final dayOfWeek = (now.weekday + i) % 7;
      final ourDay = dayOfWeek == 0 ? 1 : dayOfWeek + 1;
      final dayLectures = getLecturesByDay(ourDay);
      if (dayLectures.isNotEmpty) {
        return dayLectures.first;
      }
    }
    
    return null;
  }

  // تحليل الوقت من النص
  DateTime? _parseTime(String timeString) {
    try {
      final now = DateTime.now();
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return DateTime(now.year, now.month, now.day, hour, minute);
      }
    } catch (e) {
      print('خطأ في تحليل الوقت: $e');
    }
    return null;
  }

  // الحصول على إحصائيات
  Map<String, int> getStatistics() {
    final stats = <String, int>{};
    stats['total'] = _lectures.length;
    stats['theoretical'] = _lectures.where((l) => l.type == 'نظري').length;
    stats['practical'] = _lectures.where((l) => l.type == 'عملي').length;
    
    for (int i = 1; i <= 7; i++) {
      final dayLectures = getLecturesByDay(i);
      stats['day_$i'] = dayLectures.length;
    }
    
    return stats;
  }

  // مسح جميع المحاضرات
  Future<bool> clearAllLectures() async {
    try {
      await DatabaseService.deleteAllLectures();
      _lectures.clear();
      _filteredLectures.clear();
      notifyListeners();
      return true;
    } catch (e) {
      print('خطأ في مسح المحاضرات: $e');
      return false;
    }
  }
}

