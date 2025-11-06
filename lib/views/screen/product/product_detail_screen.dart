import 'package:flutter/material.dart';

class ProductDetailViewModel {
  final String productName;
  final String manufacturer;
  final String imageUrl;
  final String categoryName;
  final String grade;
  final String servingSizeInfo;

  final double? sugar;
  final double? saturatedFat;
  final double? sodium;

  ProductDetailViewModel.fromMap(Map<String, dynamic> product)
      : productName = product['productName'] ?? 'No Name',
        manufacturer = product['manufacturer'] ?? 'Unknown',
        imageUrl = product['imageUrl'] ?? '',
        categoryName = product['categoryName'] ?? 'Unknown Category',
        grade = (product['grade'] ?? 'N/A').toString(),
        servingSizeInfo =
            product['servingSizeInfo'] ?? 'Takaran saji tidak tersedia',
        sugar = (product['nutrition_per_100g']?['sugar_g'])?.toDouble(),
        saturatedFat = (product['nutrition_per_100g']?['saturatedFat_g'] ??
                product['nutrition_per_100g']?['saturated_fat_g'])
            ?.toDouble(),
        sodium = (product['nutrition_per_100g']?['sodium_mg'])?.toDouble();
}

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
    final vm = ProductDetailViewModel.fromMap(product);

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
                child: vm.imageUrl.isNotEmpty
                    ? Image.network(
                        vm.imageUrl,
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
                          vm.productName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          vm.manufacturer,
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
                                vm.categoryName,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildGradeLogo(vm.grade),
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
                        vm.servingSizeInfo,
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
                      value: vm.sugar != null ? "${vm.sugar} g" : "-",
                    ),
                    _buildNutritionRow(
                      label: "Saturated Fat",
                      value:
                          vm.saturatedFat != null ? "${vm.saturatedFat} g" : "-",
                    ),
                    _buildNutritionRow(
                      label: "Sodium",
                      value: vm.sodium != null ? "${vm.sodium} mg" : "-",
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
