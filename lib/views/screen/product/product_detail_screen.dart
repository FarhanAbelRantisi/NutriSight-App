import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

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
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade200,
        ),
        child: const Center(child: Text("N/A")),
      );
    }

    return Image.asset(
      assetName,
      height: 70,
      width: 70,
      errorBuilder: (_, __, ___) => Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade200,
        ),
        child: Center(child: Text(grade)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String productName = product['productName'] ?? 'No Name';
    final String manufacturer = product['manufacturer'] ?? 'Unknown';
    final String imageUrl = product['imageUrl'] ?? '';
    final String categoryName = product['categoryName'] ?? 'Unknown Category';
    final String grade = (product['grade'] ?? 'N/A').toString();
    final String servingSizeInfo =
        product['servingSizeInfo'] ?? 'Takaran saji tidak tersedia';

    final Map<String, dynamic> nutrition =
        (product['nutrition_per_100g'] ?? {}) as Map<String, dynamic>;

    final sugar = nutrition['sugar_g'];
    final satFat = nutrition['saturatedFat_g'] ?? nutrition['saturated_fat_g'];
    final sodium = nutrition['sodium_mg'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Product Detail",
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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 240,
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.image_not_supported, size: 48),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.image_not_supported, size: 48),
                      ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          manufacturer,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.category_outlined, size: 16),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                categoryName,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildGradeLogo(grade),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6FAFF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.scale_outlined,
                        color: Color(0xFF1C69A8)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        servingSizeInfo,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Nutrition per 100g",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    _buildNutritionRow(
                      label: "Sugar",
                      value: sugar != null ? "$sugar g" : "-",
                    ),
                    _buildNutritionRow(
                      label: "Saturated Fat",
                      value: satFat != null ? "$satFat g" : "-",
                    ),
                    _buildNutritionRow(
                      label: "Sodium",
                      value: sodium != null ? "$sodium mg" : "-",
                      showDivider: false,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionRow({
    required String label,
    required String value,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          dense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          trailing: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: Colors.grey.shade200,
          ),
      ],
    );
  }
}
