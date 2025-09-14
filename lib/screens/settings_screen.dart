import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  TimeOfDay _dailySummaryTime = TimeOfDay(hour: 6, minute: 0);
  bool _lectureReminders = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    // يمكن تحميل الإعدادات من SharedPreferences هنا
    setState(() {
      _notificationsEnabled = true;
      _dailySummaryTime = TimeOfDay(hour: 6, minute: 0);
      _lectureReminders = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إعدادات الإشعارات'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // تفعيل الإشعارات
          Card(
            child: SwitchListTile(
              title: Text('تفعيل الإشعارات'),
              subtitle: Text('السماح للتطبيق بإرسال الإشعارات'),
              value: _notificationsEnabled,
              onChanged: (value) async {
                if (value) {
                  final granted = await NotificationService.requestPermissions();
                  if (granted) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  } else {
                    _showPermissionDialog();
                  }
                } else {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  await NotificationService.cancelAllNotifications();
                }
              },
              secondary: Icon(Icons.notifications),
            ),
          ),
          SizedBox(height: 16),

          // الملخص اليومي
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text('الملخص اليومي'),
                  subtitle: Text('إشعار يومي بعدد المحاضرات'),
                  value: _notificationsEnabled,
                  onChanged: _notificationsEnabled
                      ? (value) {
                          setState(() {
                            // يمكن إضافة منطق منفصل للملخص اليومي
                          });
                        }
                      : null,
                  secondary: Icon(Icons.today),
                ),
                if (_notificationsEnabled)
                  ListTile(
                    title: Text('وقت الملخص اليومي'),
                    subtitle: Text(_formatTime(_dailySummaryTime)),
                    trailing: Icon(Icons.access_time),
                    onTap: _selectDailySummaryTime,
                  ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // تذكيرات المحاضرات
          Card(
            child: SwitchListTile(
              title: Text('تذكيرات المحاضرات'),
              subtitle: Text('إشعار قبل كل محاضرة بـ 30 دقيقة'),
              value: _lectureReminders && _notificationsEnabled,
              onChanged: _notificationsEnabled
                  ? (value) {
                      setState(() {
                        _lectureReminders = value;
                      });
                    }
                  : null,
              secondary: Icon(Icons.alarm),
            ),
          ),
          SizedBox(height: 16),

          // اختبار الإشعارات
          Card(
            child: ListTile(
              title: Text('اختبار الإشعارات'),
              subtitle: Text('إرسال إشعار تجريبي'),
              leading: Icon(Icons.science),
              trailing: Icon(Icons.send),
              onTap: _notificationsEnabled ? _sendTestNotification : null,
            ),
          ),
          SizedBox(height: 32),

          // معلومات إضافية
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[700]),
                      SizedBox(width: 8),
                      Text(
                        'معلومات مهمة',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• الإشعارات تعمل حتى مع إغلاق التطبيق\n'
                    '• يتم جدولة الإشعارات تلقائياً عند إضافة محاضرة\n'
                    '• يمكن تخصيص أوقات التذكير لكل محاضرة',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDailySummaryTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _dailySummaryTime,
    );
    if (picked != null && picked != _dailySummaryTime) {
      setState(() {
        _dailySummaryTime = picked;
      });
      
      // جدولة الملخص اليومي الجديد
      await NotificationService.scheduleDailyNotification(
        id: 999,
        title: 'جامعتي - ملخص اليوم',
        body: 'تحقق من محاضراتك اليوم',
        hour: _dailySummaryTime.hour,
        minute: _dailySummaryTime.minute,
      );
    }
  }

  Future<void> _sendTestNotification() async {
    await NotificationService.showNotification(
      id: 0,
      title: 'إشعار تجريبي',
      body: 'هذا إشعار تجريبي من تطبيق جامعتي',
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إرسال الإشعار التجريبي'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('أذونات الإشعارات'),
        content: Text(
          'يحتاج التطبيق إلى إذن الإشعارات لتذكيرك بمحاضراتك. '
          'يرجى تفعيل الإشعارات من إعدادات النظام.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('موافق'),
          ),
        ],
      ),
    );
  }
}

