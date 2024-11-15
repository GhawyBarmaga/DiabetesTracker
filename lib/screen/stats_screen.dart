import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'stat-cards.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  List<Map<String, dynamic>> readinlist = [];
  final box = Hive.box('Diabetes');

  void getReadings() {
    readinlist.clear();
    final data = box.keys.map((key) {
      final value = box.get(key);
      return {
        'id': key,
        'glucoseLevel': value['glucoseLevel'],
        'readingType': value['readingType'],
        'notes': value['notes'],
        'timestamp': value['timestamp'],
      };
    }).toList();
    setState(() {
      readinlist = data;
    });

    log(readinlist.toString());
  }

  @override
  void initState() {
    getReadings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final avgGlucose =
        readinlist.map((r) => r['glucoseLevel']).reduce((a, b) => a + b) /
            readinlist.length;
    final lastWeekReadings = readinlist
        .where((r) => r['timestamp']
            .isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .toList();
    return Scaffold(
        appBar: AppBar(
          title: const Text('Statistics'),
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatCard(
                    title: 'Average Glucose Level',
                    value: '${avgGlucose.toStringAsFixed(1)} mg/dL',
                  ),
                  const SizedBox(height: 16),
                  StatCard(
                    title: 'Readings This Week',
                    value: lastWeekReadings.length.toString(),
                  ),
                  const SizedBox(height: 16),
                  StatCard(
                    title: 'Total Readings',
                    value: readinlist.length.toString(),
                  ),
                ],
              ),
            )
          ]),

          // body: ValueListenableBuilder(
          //   valueListenable: Hive.box<GlucoseReading>('glucose_readings').listenable(),
          //   builder: (context, Box<GlucoseReading> box, _) {
          //     if (box.isEmpty) {
          //       return const Center(
          //         child: Text('No readings available'),
          //       );
          //     }

          //     final readings = box.values.toList();
          //     final avgGlucose = readings.map((r) => r.glucoseLevel).reduce((a, b) => a + b) / readings.length;
          //     final lastWeekReadings = readings
          //         .where((r) => r.timestamp.isAfter(DateTime.now().subtract(const Duration(days: 7))))
          //         .toList();

          //     return Padding(
          //       padding: const EdgeInsets.all(16.0),
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           _StatCard(
          //             title: 'Average Glucose Level',
          //             value: '${avgGlucose.toStringAsFixed(1)} mg/dL',
          //           ),
          //           const SizedBox(height: 16),
          //           _StatCard(
          //             title: 'Readings This Week',
          //             value: lastWeekReadings.length.toString(),
          //           ),
          //           const SizedBox(height: 16),
          //           _StatCard(
          //             title: 'Total Readings',
          //             value: readings.length.toString(),
          //           ),
          //         ],
          //       ),
          //     );
          //   },
          // ),
        ));
  }
}
