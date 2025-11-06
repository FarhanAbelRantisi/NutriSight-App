import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/history/history_detail_view_model.dart';

class HistoryDetailScreen extends StatelessWidget {
  final String userId;
  final String docId;
  final Map<String, dynamic> data;

  const HistoryDetailScreen({
    super.key,
    required this.userId,
    required this.docId,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HistoryDetailViewModel>(
      create: (_) => HistoryDetailViewModel(
        userId: userId,
        docId: docId,
        rawData: data,
      ),
      child: const _HistoryDetailView(),
    );
  }
}

class _HistoryDetailView extends StatelessWidget {
  const _HistoryDetailView({super.key});

  Widget _buildGradeLogo(String grade) {
    String? asset;
    switch (grade) {
      case 'A':
        asset = 'assets/logo_gradeA.png';
        break;
      case 'B':
        asset = 'assets/logo_gradeB.png';
        break;
      case 'C':
        asset = 'assets/logo_gradeC.png';
        break;
      case 'D':
        asset = 'assets/logo_gradeD.png';
        break;
      default:
        asset = null;
    }

    if (asset == null) {
      return Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: const Center(child: Text("N/A")),
      );
    }

    return Image.asset(
      asset,
      height: 90,
      width: 90,
      fit: BoxFit.contain,
    );
  }

  Future<void> _confirmAndDelete(BuildContext context) async {
    final vm = context.read<HistoryDetailViewModel>();
    if (vm.isDeleting) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "Delete Scan Result?",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: const Text(
            "Are you sure want to delete scan result from history?",
          ),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1C69A8),
                side: const BorderSide(color: Color(0xFF1C69A8), width: 1.5),
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1C69A8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      await vm.deleteHistory();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hasil scan dihapus dari history ❌")),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menghapus: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HistoryDetailViewModel>();

    final categoryName = vm.categoryName;
    final grade = vm.grade;
    final imageLocalPath = vm.imageLocalPath;
    final nerResults = vm.nerResults;

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
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            onPressed: vm.isDeleting ? null : () => _confirmAndDelete(context),
            icon: vm.isDeleting
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(
                    Icons.bookmark,
                    color: Colors.redAccent,
                  ),
            tooltip: "Delete from History",
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 240,
                width: double.infinity,
                child: imageLocalPath != null && vm.imageExists
                    ? Image.file(
                        File(imageLocalPath),
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(Icons.image_not_supported,
                              color: Colors.grey, size: 48),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),

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
                        categoryName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
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
                const SizedBox(width: 16),
                _buildGradeLogo(grade),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 16),

            const Text(
              "Extraction Result Detail",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
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
                                  "Tidak ada data nutrisi",
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
    );
  }
}
