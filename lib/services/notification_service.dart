import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/lecture.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // تهيئة خدمة الإشعارات
  static Future<void> initialize() async {
    if (_initialized) return;

    // تهيئة المناطق الزمنية
    tz.initializeTimeZones();

    // إعدادات Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // إعدادات iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // الإعدادات العامة
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(initializationSettings);
    _initialized = true;
  }

  // طلب الأذونات
  static Future<bool> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      final bool? granted = await androidImplementation.requestPermission();
      return granted ?? false;
    }

    final DarwinFlutterLocalNotificationsPlugin? iosImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            DarwinFlutterLocalNotificationsPlugin>();

    if (iosImplementation != null) {
      final bool? granted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  // إرسال إشعار فوري
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'jameti_channel',
      'جامعتي',
      channelDescription: 'إشعارات تطبيق جامعتي',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notifications.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // جدولة إشعار
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'jameti_scheduled',
      'جامعتي - مجدولة',
      channelDescription: 'إشعارات مجدولة لتطبيق جامعتي',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // جدولة إشعار يومي
  static Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'jameti_daily',
      'جامعتي - يومي',
      channelDescription: 'إشعارات يومية لتطبيق جامعتي',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  // جدولة إشعارات المحاضرات
  static Future<void> scheduleLectureNotifications(List<Lecture> lectures) async {
    // إلغاء جميع الإشعارات المجدولة
    await cancelAllNotifications();

    for (final lecture in lectures) {
      await _scheduleLectureNotification(lecture);
    }
  }

  // جدولة إشعار محاضرة واحدة
  static Future<void> _scheduleLectureNotification(Lecture lecture) async {
    try {
      final lectureTime = _parseTime(lecture.startTime);
      if (lectureTime == null) return;

      // إشعار قبل نصف ساعة
      final notificationTime = lectureTime.subtract(Duration(minutes: 30));
      final now = DateTime.now();

      // حساب التاريخ التالي لهذا اليوم
      final nextDate = _getNextDateForDay(lecture.dayOfWeek);
      final scheduledDateTime = DateTime(
        nextDate.year,
        nextDate.month,
        nextDate.day,
        notificationTime.hour,
        notificationTime.minute,
      );

      if (scheduledDateTime.isAfter(now)) {
        await scheduleNotification(
          id: lecture.id ?? 0,
          title: 'تذكير بالمحاضرة',
          body: '${lecture.name} - ${lecture.startTime}\n'
                'الدكتور: ${lecture.doctorName ?? 'غير محدد'}\n'
                'المكان: ${lecture.location}\n'
                'النوع: ${lecture.type}',
          scheduledDate: scheduledDateTime,
        );
      }
    } catch (e) {
      print('خطأ في جدولة إشعار المحاضرة: $e');
    }
  }

  // إلغاء إشعار
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // إلغاء جميع الإشعارات
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // الحصول على التاريخ التالي ليوم معين
  static DateTime _getNextDateForDay(int dayOfWeek) {
    final now = DateTime.now();
    final currentDay = now.weekday == 7 ? 1 : now.weekday + 1; // تحويل إلى نظامنا
    
    int daysToAdd = dayOfWeek - currentDay;
    if (daysToAdd <= 0) {
      daysToAdd += 7; // الأسبوع القادم
    }
    
    return now.add(Duration(days: daysToAdd));
  }

  // تحليل الوقت
  static DateTime? _parseTime(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final now = DateTime.now();
        return DateTime(now.year, now.month, now.day, hour, minute);
      }
    } catch (e) {
      print('خطأ في تحليل الوقت: $e');
    }
    return null;
  }

  // الحصول على التوقيت التالي لوقت معين
  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
      0,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  // إرسال إشعار ملخص يومي
  static Future<void> sendDailySummary(List<Lecture> todayLectures) async {
    if (todayLectures.isEmpty) {
      await showNotification(
        id: 999,
        title: 'جامعتي - ملخص اليوم',
        body: 'لا توجد محاضرات اليوم. استمتع بيومك!',
      );
    } else {
      final lectureNames = todayLectures.map((l) => l.name).join('، ');
      await showNotification(
        id: 999,
        title: 'جامعتي - ملخص اليوم',
        body: 'لديك ${todayLectures.length} محاضرة اليوم:\n$lectureNames',
      );
    }
  }
}

