import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
  runApp(const ElectricityDashboardApp());
}

class ElectricityDashboardApp extends StatelessWidget {
  const ElectricityDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Electricity Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF4F4F4),
        fontFamily: 'Arial',
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  final List<dynamic> _data = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      final response = await http.get(Uri.parse('https://app-dev-backend.onrender.com/data'));
      if (response.statusCode == 200) {
        final List<dynamic> newData = json.decode(response.body);
        setState(() {
          _data.clear(); // clear old data before adding new
          _data.addAll(newData);
        });
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Widget _buildDataTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all<Color>(const Color(0xFF007BFF)),
          headingTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          columns: const [
            DataColumn(label: Center(child: Text('ID'))),
            DataColumn(label: Center(child: Text('Timestamp'))), // NEW
            DataColumn(label: Center(child: Text('Current (A)'))),
            DataColumn(label: Center(child: Text('Voltage (V)'))),
            DataColumn(label: Center(child: Text('Power (W)'))),
            DataColumn(label: Center(child: Text('KWh'))),
          ],
          rows: List.generate(
            _data.length,
            (index) {
              final entry = _data[index];
              final isEven = index % 2 == 0;
              final timestamp = entry['timestamp'] != null
                  ? DateFormat('dd MMM yyyy – hh:mm a')
                      .format(DateTime.parse(entry['timestamp']))
                  : 'N/A';

              return DataRow(
                color: WidgetStateProperty.all<Color>(
                  isEven ? const Color(0xFFF9F9F9) : const Color(0xFFE9E9E9),
                ),
                cells: [
                  DataCell(Center(child: Text('${entry['id']}'))),
                  DataCell(Center(child: Text(timestamp))), // NEW
                  DataCell(Center(child: Text('${entry['current']}'))),
                  DataCell(Center(child: Text('${entry['voltage']}'))),
                  DataCell(Center(child: Text('${entry['power']}'))),
                  DataCell(Center(child: Text('${entry['kwh']}'))),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-Time Electricity Consumption'),
        centerTitle: true,
        backgroundColor: const Color(0xFF007BFF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _data.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Real-Time Electricity Consumption Data',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(child: _buildDataTable()),
                ],
              ),
      ),
    );
  }
}
