import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lecture.dart';
import '../services/lecture_service.dart';

class AddLectureScreen extends StatefulWidget {
  final Lecture? lecture; // للتعديل

  AddLectureScreen({this.lecture});

  @override
  _AddLectureScreenState createState() => _AddLectureScreenState();
}

class _AddLectureScreenState extends State<AddLectureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _doctorController = TextEditingController();
  final _locationController = TextEditingController();
  
  String _selectedType = 'نظري';
  int _selectedDay = 1;
  TimeOfDay _selectedTime = TimeOfDay.now();
  
  final List<String> _types = ['نظري', 'عملي'];
  final List<String> _days = [
    'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 
    'الخميس', 'الجمعة', 'السبت'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.lecture != null) {
      _nameController.text = widget.lecture!.name;
      _doctorController.text = widget.lecture!.doctorName ?? '';
      _locationController.text = widget.lecture!.location;
      _selectedType = widget.lecture!.type;
      _selectedDay = widget.lecture!.dayOfWeek;
      _selectedTime = _parseTimeString(widget.lecture!.startTime);
    }
  }

  TimeOfDay _parseTimeString(String timeString) {
    try {
      final parts = timeString.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (e) {
      return TimeOfDay.now();
    }
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.lecture != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'تعديل المحاضرة' : 'إضافة محاضرة جديدة'),
        actions: [
          if (isEditing)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _deleteLecture,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // اسم المحاضرة
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'اسم المحاضرة *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال اسم المحاضرة';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // نوع المحاضرة
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: 'نوع المحاضرة *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _types.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            SizedBox(height: 16),

            // اسم الدكتور
            TextFormField(
              controller: _doctorController,
              decoration: InputDecoration(
                labelText: 'اسم الدكتور (اختياري)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 16),

            // اليوم
            DropdownButtonFormField<int>(
              value: _selectedDay,
              decoration: InputDecoration(
                labelText: 'اليوم *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              items: List.generate(_days.length, (index) {
                return DropdownMenuItem(
                  value: index + 1,
                  child: Text(_days[index]),
                );
              }),
              onChanged: (value) {
                setState(() {
                  _selectedDay = value!;
                });
              },
            ),
            SizedBox(height: 16),

            // الوقت
            InkWell(
              onTap: _selectTime,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'وقت البداية *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time),
                ),
                child: Text(_formatTime(_selectedTime)),
              ),
            ),
            SizedBox(height: 16),

            // المكان
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'مكان الحضور *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال مكان الحضور';
                }
                return null;
              },
            ),
            SizedBox(height: 32),

            // أزرار الحفظ والإلغاء
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveLecture,
                    child: Text(isEditing ? 'تحديث' : 'حفظ'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('إلغاء'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveLecture() async {
    if (_formKey.currentState!.validate()) {
      final lectureService = Provider.of<LectureService>(context, listen: false);
      
      final lecture = Lecture(
        id: widget.lecture?.id,
        name: _nameController.text.trim(),
        type: _selectedType,
        doctorName: _doctorController.text.trim().isEmpty 
            ? null 
            : _doctorController.text.trim(),
        startTime: _formatTime(_selectedTime),
        location: _locationController.text.trim(),
        dayOfWeek: _selectedDay,
        createdAt: widget.lecture?.createdAt ?? DateTime.now(),
      );

      bool success;
      if (widget.lecture != null) {
        success = await lectureService.updateLecture(lecture);
      } else {
        success = await lectureService.addLecture(lecture);
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.lecture != null 
                ? 'تم تحديث المحاضرة بنجاح' 
                : 'تم إضافة المحاضرة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ، يرجى المحاولة مرة أخرى'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteLecture() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف هذه المحاضرة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('حذف'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.lecture != null) {
      final lectureService = Provider.of<LectureService>(context, listen: false);
      final success = await lectureService.deleteLecture(widget.lecture!.id!);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حذف المحاضرة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ في الحذف'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doctorController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}

