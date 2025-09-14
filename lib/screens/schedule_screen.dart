import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/lecture_service.dart';
import '../models/lecture.dart';
import 'add_lecture_screen.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final List<String> _days = [
    'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 
    'الخميس', 'الجمعة', 'السبت'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('جدول المحاضرات'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              Provider.of<LectureService>(context, listen: false).loadLectures();
            },
          ),
        ],
      ),
      body: Consumer<LectureService>(
        builder: (context, lectureService, child) {
          if (lectureService.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (lectureService.lectures.isEmpty) {
            return _buildEmptyState();
          }

          return _buildScheduleView(lectureService);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'لا توجد محاضرات مضافة',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'اضغط على زر + لإضافة محاضرة جديدة',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleView(LectureService lectureService) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _days.length,
      itemBuilder: (context, index) {
        final dayIndex = index + 1;
        final dayLectures = lectureService.getLecturesByDay(dayIndex);
        
        return _buildDayCard(dayIndex, _days[index], dayLectures);
      },
    );
  }

  Widget _buildDayCard(int dayIndex, String dayName, List<Lecture> lectures) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.blue[700]),
                SizedBox(width: 8),
                Text(
                  dayName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${lectures.length}',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (lectures.isEmpty)
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'لا توجد محاضرات في هذا اليوم',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ...lectures.map((lecture) => _buildLectureItem(lecture)).toList(),
        ],
      ),
    );
  }

  Widget _buildLectureItem(Lecture lecture) {
    return InkWell(
      onTap: () => _editLecture(lecture),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: lecture.type == 'نظري' ? Colors.blue : Colors.green,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lecture.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        lecture.startTime,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      SizedBox(width: 16),
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          lecture.location,
                          style: TextStyle(color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (lecture.doctorName != null) ...[
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.person, size: 16, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          lecture.doctorName!,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: lecture.type == 'نظري' 
                        ? Colors.blue[100] 
                        : Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    lecture.type,
                    style: TextStyle(
                      fontSize: 12,
                      color: lecture.type == 'نظري' 
                          ? Colors.blue[700] 
                          : Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Icon(Icons.edit, color: Colors.grey[400], size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _editLecture(Lecture lecture) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddLectureScreen(lecture: lecture),
      ),
    );
  }
}

