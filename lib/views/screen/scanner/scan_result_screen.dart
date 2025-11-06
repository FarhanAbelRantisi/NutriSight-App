import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/scan/scan_result_view_model.dart';

class ScanResultScreen extends StatelessWidget {
  final String imagePath;
  final String categoryName;
  final Map<String, dynamic> scanResult;

  const ScanResultScreen({
    super.key,
    required this.imagePath,
    required this.categoryName,
    required this.scanResult,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ScanResultViewModel>(
      create: (_) => ScanResultViewModel(
        imagePath: imagePath,
        categoryName: categoryName,
        scanResult: scanResult,
      ),
      child: const _ScanResultView(),
    );
  }
}

class _ScanResultView extends StatelessWidget {
  const _ScanResultView({super.key});

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

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ScanResultViewModel>();
    final grade = vm.grade;
    final nerResults = vm.nerResults;

    final tableRows = nerResults.entries.map((entry) {
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
              vm.formatNerKey(entry.key),
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
            onPressed: vm.isSaving
                ? null
                : () async {
                    try {
                      await vm.toggleBookmark();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            vm.isSaved
                                ? "Scan result saved to history ✅"
                                : "Scan result removed from history ❌",
                          ),
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  },
            icon: vm.isSaving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    vm.isSaved
                        ? Icons.bookmark
                        : Icons.bookmark_border_rounded,
                    color:
                        vm.isSaved ? const Color(0xFF1C69A8) : Colors.black87,
                  ),
            tooltip:
                vm.isSaved ? "Delete from History" : "Save to History",
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
                  File(vm.imagePath),
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
                          vm.categoryName,
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
