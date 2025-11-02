import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ScanResultScreen extends StatefulWidget {
  final XFile imageFile;
  final String categoryName;
  final Map<String, dynamic> scanResult;

  const ScanResultScreen({
    super.key,
    required this.imageFile,
    required this.categoryName,
    required this.scanResult,
  });

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  bool _isSaving = false;
  bool _isSaved = false;
  
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

  Future<void> _toggleBookmark() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("You are not logged in.")),
          );
        }
        return;
      }

      final collection = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('history');

      final grade = widget.scanResult['grade'] ?? 'N/A';
      final category = widget.categoryName;

      // cek apakah sudah ada
      final existing = await collection
          .where('categoryName', isEqualTo: category)
          .where('grade', isEqualTo: grade)
          .where('imageLocalPath', isEqualTo: widget.imageFile.path)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        // sudah ada → hapus
        await collection.doc(existing.docs.first.id).delete();
        if (mounted) {
          setState(() => _isSaved = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Scan Result are deleted from history ❌")),
          );
        }
      } else {
        await collection.add({
          'categoryName': category,
          'grade': grade,
          'scanResult': widget.scanResult,
          'imageLocalPath': widget.imageFile.path,
          'createdAt': FieldValue.serverTimestamp(),
        });
        if (mounted) {
          setState(() => _isSaved = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Scan result already save to history ✅")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("There is error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String grade = _extractGrade(widget.scanResult);
    final Map<String, dynamic> nerResults = _extractNer(widget.scanResult);

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
        title: const Text(
          "Scan Result",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            onPressed: _isSaving ? null : _toggleBookmark,
            icon: _isSaving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    _isSaved ? Icons.bookmark : Icons.bookmark_border_rounded,
                    color: _isSaved ? const Color(0xFF1C69A8) : Colors.black87,
                  ),
            tooltip: _isSaved ? "Delete from History" : "Save to History",
          ),
          const SizedBox(width: 4),
        ],
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
                  File(widget.imageFile.path),
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
                          "CATEGORY",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          widget.categoryName,
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
                "Extraction Result Detail",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
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
                      verticalInside:
                          BorderSide(color: Colors.grey.shade200, width: 1),
                    ),
                    children: tableRows.isEmpty
                        ? [
                            TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(
                                    "No nutritional data",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                const SizedBox.shrink(),
                              ],
                            )
                          ]
                        : tableRows,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
