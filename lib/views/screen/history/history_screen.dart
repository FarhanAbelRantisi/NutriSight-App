import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/history/history_list_view_model.dart';
import 'history_detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Widget _buildGradeImage(String grade) {
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
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: const Center(child: Text("N/A")),
      );
    }

    return Image.asset(
      asset,
      height: 56,
      width: 56,
      fit: BoxFit.contain,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("Kamu belum login."),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => HistoryListViewModel(userId: user.uid),
      child: _HistoryScreenBody(buildGradeImage: _buildGradeImage),
    );
  }
}

class _HistoryScreenBody extends StatelessWidget {
  final Widget Function(String grade) buildGradeImage;

  const _HistoryScreenBody({
    super.key,
    required this.buildGradeImage,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HistoryListViewModel>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Scan History",
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
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: vm.historyStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "There is no scan history yet.",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final String categoryName =
                  (data['categoryName'] ?? 'Tidak diketahui').toString();
              final String grade = (data['grade'] ?? 'N/A').toString();
              final Timestamp? createdAt = data['createdAt'];
              final String? imageLocalPath =
                  (data['imageLocalPath'] ?? '').toString().isEmpty
                      ? null
                      : data['imageLocalPath'].toString();

              String subtitle = "—";
              if (createdAt != null) {
                final dt = createdAt.toDate();
                subtitle =
                    "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} "
                    "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
              }

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HistoryDetailScreen(
                        userId: vm.userId,
                        docId: doc.id,
                        data: data,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          height: 64,
                          width: 64,
                          child: imageLocalPath != null &&
                                  File(imageLocalPath).existsSync()
                              ? Image.file(
                                  File(imageLocalPath),
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.image_not_supported,
                                      color: Colors.grey),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              categoryName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "Grade: $grade",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      buildGradeImage(grade),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
