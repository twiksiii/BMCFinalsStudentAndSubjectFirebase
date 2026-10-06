import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Registration',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const StudentRegistrationPage(),
    );
  }
}

class StudentRegistrationPage extends StatefulWidget {
  const StudentRegistrationPage({super.key});

  @override
  State<StudentRegistrationPage> createState() => _StudentRegistrationPageState();
}

class _StudentRegistrationPageState extends State<StudentRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _sectionController = TextEditingController();
  final _yearLevelController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _sectionController.dispose();
    _yearLevelController.dispose();
    super.dispose();
  }

  void _goToSchedulePage() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubjectSchedulePage(
            name: _nameController.text.trim(),
            section: _sectionController.text.trim(),
            yearLevel: _yearLevelController.text.trim(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Registration'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Student Information',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  ),
                  const SizedBox(height: 25),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) =>
                        value == null || value.trim().isEmpty ? 'Ilagay ang pangalan' : null,
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _sectionController,
                    decoration: const InputDecoration(
                      labelText: 'Section',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.class_),
                    ),
                    validator: (value) =>
                        value == null || value.trim().isEmpty ? 'Ilagay ang section' : null,
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _yearLevelController,
                    decoration: const InputDecoration(
                      labelText: 'Year Level',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.school),
                    ),
                    validator: (value) =>
                        value == null || value.trim().isEmpty ? 'Ilagay ang year level' : null,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _goToSchedulePage,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('NEXT', style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SubjectSchedulePage extends StatefulWidget {
  final String name;
  final String section;
  final String yearLevel;

  const SubjectSchedulePage({
    super.key,
    required this.name,
    required this.section,
    required this.yearLevel,
  });

  @override
  State<SubjectSchedulePage> createState() => _SubjectSchedulePageState();
}

class _SubjectSchedulePageState extends State<SubjectSchedulePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isSaving = false;

  final List<Map<String, TextEditingController>> _subjects = [
    {'name': TextEditingController(), 'schedule': TextEditingController()},
    {'name': TextEditingController(), 'schedule': TextEditingController()},
    {'name': TextEditingController(), 'schedule': TextEditingController()},
  ];

  @override
  void dispose() {
    for (final subj in _subjects) {
      subj['name']!.dispose();
      subj['schedule']!.dispose();
    }
    super.dispose();
  }

  Future<void> _saveToFirestore() async {
    setState(() => _isSaving = true);
    try {
      final List<Map<String, dynamic>> subjectList = _subjects
          .map((s) => {
                'subject': s['name']!.text.trim(),
                'schedule': s['schedule']!.text.trim(),
              })
          .toList();

      await _firestore.collection('students').add({
        'name': widget.name,
        'section': widget.section,
        'yearLevel': widget.yearLevel,
        'subjects': subjectList,
        'registeredAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(' Saved to Firestore!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(' Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subject Schedule'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student: ${widget.name}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text('Section: ${widget.section} | Year: ${widget.yearLevel}'),
                const SizedBox(height: 25),
                const Text(
                  'Subjects & Schedule',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
                const SizedBox(height: 20),
                ...List.generate(_subjects.length, (index) {
                  return Column(
                    children: [
                      TextFormField(
                        controller: _subjects[index]['name'],
                        decoration: InputDecoration(
                          labelText: 'Subject ${index + 1}',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _subjects[index]['schedule'],
                        decoration: InputDecoration(
                          labelText: 'Schedule ${index + 1}',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                  );
                }),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveToFirestore,
                    icon: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Icon(Icons.cloud_upload),
                    label: Text(_isSaving ? 'SAVING...' : 'SAVE TO FIRESTORE', style: const TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}