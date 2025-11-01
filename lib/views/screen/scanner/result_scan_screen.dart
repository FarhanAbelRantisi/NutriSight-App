import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ResultScanScreen extends StatelessWidget {
  final XFile imageFile;
  final String categoryName;
  final Map<String, dynamic> scanResult;

  const ResultScanScreen({
    super.key,
    required this.imageFile,
    required this.categoryName,
    required this.scanResult,
  });

  String _extractGrade(Map<String, dynamic> data) {
    final candidates = [
      data['grade'],
      data['predicted_grade'],
      data['nutri_grade'],
      data['result'] is Map ? (data['result'] as Map)['grade'] : null,
    ];

    for (var c in candidates) {
      if (c == null) continue;
      final s = c.toString().trim();
      if (s.isNotEmpty && s.toUpperCase() != 'N/A') {
        return s.toUpperCase();
      }
    }
    return 'N/A';
  }

  Map<String, dynamic> _extractNer(Map<String, dynamic> data) {
    final possibleKeys = [
      'debug_ner_results',
      'extracted_fields',
      'ner',
      'parsed_fields',
      'fields',
    ];

    for (final key in possibleKeys) {
      final val = data[key];
      if (val is Map<String, dynamic> && val.isNotEmpty) {
        return val;
      }
    }

    final val = data['debug_ner_results'];
    if (val is List && val.isNotEmpty) {
      // ubah ke map sederhana
      final Map<String, dynamic> converted = {};
      for (final item in val) {
        if (item is Map && item['key'] != null) {
          converted[item['key'].toString()] = item['value'] ?? '';
        }
      }
      if (converted.isNotEmpty) return converted;
    }

    return {};
  }

  Widget _buildGradeLogo(String grade) {
    String? assetName;
    switch (grade) {
      case 'A':
        assetName = 'assets/logo_gradeA.png';
        break;
      case 'B':
        assetName = 'assets/logo_gradeB.png';
        break;
      case 'C':
        assetName = 'assets/logo_gradeC.png';
        break;
      case 'D':
        assetName = 'assets/logo_gradeD.png';
        break;
      default:
        assetName = null;
    }

    if (assetName == null) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[200],
        ),
        child: const Center(child: Text("N/A")),
      );
    }

    return Image.asset(
      assetName,
      height: 100,
      width: 100,
      errorBuilder: (_, __, ___) => Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[200],
        ),
        child: Center(child: Text(grade)),
      ),
    );
  }

  String _formatNerKey(String key) {
    if (key.isEmpty) return "N/A";
    return key
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final String grade = _extractGrade(scanResult);

    final Map<String, dynamic> nerResults = _extractNer(scanResult);

    final List<TableRow> tableRows = nerResults.entries.map((entry) {
      return TableRow(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              _formatNerKey(entry.key),
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              entry.value.toString(),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      );
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          "Scan Result",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(imageFile.path),
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "KATEGORI",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          categoryName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Grade: $grade",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  _buildGradeLogo(grade),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),

              const Text(
                "Detail Hasil Ekstraksi",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),

              if (tableRows.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Server tidak mengirim detail ekstraksi atau key-nya beda.\n\nData mentah:\n${scanResult.toString()}",
                    style: const TextStyle(fontSize: 13),
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(1.2),
                        1: FlexColumnWidth(1),
                      },
                      border: TableBorder(
                        verticalInside: BorderSide(color: Colors.grey.shade200, width: 1),
                      ),
                      children: tableRows,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
