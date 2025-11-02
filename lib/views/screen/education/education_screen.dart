import 'package:flutter/material.dart';
import 'education_detail_screen.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  List<Map<String, String>> get _educationItems => [
        {
          "title": "Kenali Arti Grade A–D pada Produk Kemasan",
          "subtitle":
              "Tahukah kamu kalau produk kemasan kini bisa dinilai tingkat kesehatannya? Sistem Nutri-Grade digunakan untuk...",
          "image": "assets/image_education1.jpg",
          "content": '''
Sistem Nutri-Grade digunakan untuk membantu kamu memahami tingkat kesehatan produk kemasan.

A → Paling sehat, rendah gula dan lemak jenuh
B → Cukup baik, aman dikonsumsi harian
C → Tinggi gula/garam/lemak, batasi konsumsinya
D → Sangat tinggi gula atau lemak, sebaiknya dihindari

Semakin rendah kandungan Gula, Garam, dan Lemak (GGL), semakin baik grade-nya!
          ''',
        },
        {
          "title": "Pahami Batas Gula, Garam, dan Lemak Harianmu",
          "subtitle":
              "Tiga komponen utama yang sering membuat makanan jadi tidak sehat adalah gula, garam, dan lemak...",
          "image": "assets/image_education2.jpg",
          "content": '''
Kementerian Kesehatan RI menyarankan konsumsi harian maksimal:
• Gula: 50 g (≈ 4 sdt)
• Garam: 2000 mg natrium (≈ 1 sdt)
• Lemak: 67 g total

Jika satu produk saja sudah mengandung setengah dari batas ini, berarti kamu perlu mengurangi konsumsi dari sumber lain hari itu.

Jadikan kebiasaan membaca label sebagai langkah kecil menuju hidup sehat.
          ''',
        },
        {
          "title": "Cara Membaca Label Gizi dengan Mudah",
          "subtitle":
              "Banyak orang hanya melihat kalori, padahal ada informasi penting lain...",
          "image": "assets/image_education3.jpg",
          "content": '''
Banyak orang hanya melihat jumlah kalori, padahal ada informasi penting lain yang menentukan kesehatan produk.

Saat membaca label, perhatikan:
1. Takaran saji — pastikan kamu menyesuaikan dengan jumlah yang dikonsumsi.
2. Gula, lemak jenuh, dan natrium — nilai tinggi menandakan risiko lebih besar.
3. Persentase AKG (%AKG) — menunjukkan kontribusi nutrisi terhadap kebutuhan harian.

Semakin rendah %AKG untuk GGL, semakin baik produk tersebut.
          ''',
        },
        {
          "title": "Tidak Semua Produk Grade C atau D Buruk",
          "subtitle":
              "Produk snack atau dessert masih boleh dikonsumsi, asal tahu batas dan frekuensinya...",
          "image": "assets/image_education4.jpg",
          "content": '''
Produk dengan grade C atau D bukan berarti harus dilarang total.
Misalnya, cokelat atau es krim bisa tetap dinikmati dalam porsi kecil dan tidak setiap hari.

Gunakan grade sebagai panduan, bukan larangan.
Seimbang antara makanan sehat dan treat sesekali tetap bisa menjaga gaya hidup sehat tanpa stres. 🍫💚
          ''',
        },
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Education",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        itemCount: _educationItems.length,
        itemBuilder: (context, index) {
          final item = _educationItems[index];
          return _EducationCard(
            title: item["title"] ?? "",
            subtitle: item["subtitle"] ?? "",
            imagePath: item["image"] ?? "",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EducationDetailScreen(
                    title: item["title"] ?? "",
                    imagePath: item["image"] ?? "",
                    content: item["content"] ?? "",
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

class _EducationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final VoidCallback onTap;

  const _EducationCard({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      margin: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Colors.black54,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    imagePath,
                    width: 78,
                    height: 78,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 78,
                      height: 78,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported),
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
