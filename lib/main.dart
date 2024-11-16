import 'dart:developer';

import 'package:daibetes/screen/onboarding_1.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import 'screen/stats_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('Diabetes');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        textTheme: TextTheme(bodyMedium: GoogleFonts.openSans()),
        useMaterial3: true,
      ),
      home: const Onboarding1(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final glucoseController = TextEditingController();
  final notesController = TextEditingController();
  String selectedType = 'Fasting';
  List<Map<String, dynamic>> readings = [];
  final reading = Hive.box('Diabetes');

  //=============get Readings=====================//
  void getReadings() {
    readings.clear();
    final data = reading.keys.map((key) {
      final value = reading.get(key);
      return {
        'id': key,
        'glucoseLevel': value['glucoseLevel'],
        'readingType': value['readingType'],
        'notes': value['notes'],
        'timestamp': value['timestamp'],
      };
    }).toList();
    setState(() {
      readings = data;
    });
    log(readings.toString());
  }

  //==================   Delete Notes==========================
  Future<dynamic> deleteReading(int index) async {
    await reading.deleteAt(index);
    getReadings();
  }
  //=======================================================

  @override
  void initState() {
    super.initState();
    getReadings();
  }

  @override
  void dispose() {
    glucoseController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('1C274C'),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: HexColor('1C274C'),
        title: const Text(
          'Diabetes Tracker',
          style: TextStyle(
              fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              icon: const Icon(
                Icons.analytics,
                color: Colors.green,
                size: 30,
              ),
              onPressed: () => Get.to(() => const StatsPage())),
        ],
      ),
      body: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.max, children: [
        const SizedBox(
          height: 20,
        ),
        ListView.separated(
          shrinkWrap: true,
          itemCount: readings.length,
          itemBuilder: (context, index) {
            final reading = readings[index];
            return ListTile(
              tileColor: HexColor('0e1326'),
              title: Text(
                '${reading['glucoseLevel'] ?? ''} mg/dL - ${reading['readingType'] ?? ''}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: reading['glucoseLevel'] > 180
                        ? Colors.red
                        : Colors.amber),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      DateFormat('MMM dd, yyyy - HH:mm')
                          .format(reading['timestamp'] ?? DateTime.now()),
                      style: const TextStyle(color: Colors.grey)),
                  if (reading['notes'].isNotEmpty ?? false)
                    Text('Notes: ${reading['notes']}',
                        style: const TextStyle(color: Colors.white)),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () => deleteReading(reading['id']),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
        ),
      ])),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () => _showAddReadingDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

//======================================Show Dialog========================================
  void _showAddReadingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Reading'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: glucoseController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Glucose Level (mg/dL)',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                items: ['Fasting', 'Pre-meal', 'Post-meal']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => selectedType = value!),
                decoration: const InputDecoration(
                  labelText: 'Reading Type',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          TextButton(
            onPressed: () {
              final glucose = double.tryParse(glucoseController.text);
              if (glucose != null) {
                final reading = {
                  'glucoseLevel': glucose,
                  'readingType': selectedType,
                  'notes': notesController.text,
                  'timestamp': DateTime.now(),
                };
                Hive.box('Diabetes').add(reading);
                Navigator.pop(context);
                glucoseController.clear();
                notesController.clear();
                getReadings();
              }
            },
            child: const Text('Save',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ],
      ),
    );
  }
  //============================================================================================
}


