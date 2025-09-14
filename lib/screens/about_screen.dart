import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('حول التطبيق'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // شعار التطبيق
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.blue[700],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.school,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'جامعتي',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'الإصدار 1.0.0',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32),

          // وصف التطبيق
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'حول التطبيق',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'تطبيق جامعتي هو تطبيق مجاني لإدارة جدول المحاضرات الأسبوعي. '
                    'يساعدك على تنظيم محاضراتك والحصول على تذكيرات في الوقت المناسب. '
                    'التطبيق يعمل بدون إنترنت ويحفظ بياناتك محلياً على جهازك.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // الميزات
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الميزات',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildFeatureItem(Icons.schedule, 'جدول أسبوعي منظم'),
                  _buildFeatureItem(Icons.notifications, 'إشعارات ذكية'),
                  _buildFeatureItem(Icons.search, 'بحث سريع'),
                  _buildFeatureItem(Icons.offline_pin, 'يعمل بدون إنترنت'),
                  _buildFeatureItem(Icons.security, 'حفظ البيانات محلياً'),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // معلومات المطور
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تم تطوير هذا التطبيق بواسطة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.person, color: Colors.blue[700]),
                      SizedBox(width: 8),
                      Text(
                        'ABDULLAH ALASAAD',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.business, color: Colors.blue[700]),
                      SizedBox(width: 8),
                      Text(
                        'ARX-Tech',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // الروابط
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تواصل معنا',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildLinkItem(
                    Icons.facebook,
                    'تابعنا على الفيسبوك',
                    'https://www.facebook.com/profile.php?id=61579097697055',
                  ),
                  SizedBox(height: 8),
                  _buildLinkItem(
                    Icons.support_agent,
                    'تواصل مع فريق الدعم',
                    'https://t.me/mar01abdullah',
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 32),

          // حقوق النشر
          Center(
            child: Text(
              '© 2024 ARX-Tech. جميع الحقوق محفوظة.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue[700]),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkItem(IconData icon, String text, String url) {
    return InkWell(
      onTap: () => _copyToClipboard(url),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[700]),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  url,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[600],
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.copy, size: 16, color: Colors.grey[600]),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    // يمكن إضافة SnackBar هنا لإظهار رسالة نسخ
  }
}

