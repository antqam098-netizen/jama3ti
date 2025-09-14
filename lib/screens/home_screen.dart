import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/lecture_service.dart';
import '../models/lecture.dart';
import 'add_lecture_screen.dart';
import 'schedule_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'about_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    ScheduleScreen(),
    SearchScreen(),
    SettingsScreen(),
    AboutScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // تحميل المحاضرات عند بدء التطبيق
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LectureService>(context, listen: false).loadLectures();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'الجدول',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'البحث',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'الإعدادات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'حول',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddLectureScreen()),
                );
              },
              backgroundColor: Colors.blue[700],
              child: Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

