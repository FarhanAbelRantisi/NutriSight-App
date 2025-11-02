import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutrisight/views/screen/product/product_detail_screen.dart';
import 'package:nutrisight/views/screen/profile/profile_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _allProducts = [];

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _filteredProducts = [];

  final TextEditingController _searchController = TextEditingController();

  String _selectedGrade = 'All';
  String _selectedCategory = 'All';
  List<String> _allCategories = ['All'];

  @override
  void initState() {
    super.initState();
    _fetch();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('products')
          .orderBy('productName_lowercase')
          .limit(60)
          .get();

      final Set<String> categories = {'All'};
      for (var doc in snap.docs) {
        final data = doc.data();
        final categoryName = (data['categoryName'] ?? '').toString();
        if (categoryName.isNotEmpty) {
          categories.add(categoryName);
        }
      }

      setState(() {
        _allProducts = snap.docs;
        _filteredProducts = snap.docs;
        _allCategories = categories.toList()..sort();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("🔥 error fetch: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<QueryDocumentSnapshot<Map<String, dynamic>>> result = List.from(_allProducts);

    if (_selectedGrade != 'All') {
      result = result.where((doc) {
        final grade = (doc.data()['grade'] ?? '').toString();
        return grade == _selectedGrade;
      }).toList();
    }

    if (_selectedCategory != 'All') {
      result = result.where((doc) {
        final cat = (doc.data()['categoryName'] ?? '').toString();
        return cat == _selectedCategory;
      }).toList();
    }

    final q = _searchController.text.toLowerCase();
    if (q.isNotEmpty) {
      result = result.where((doc) {
        final data = doc.data();
        final nameLower = (data['productName_lowercase'] ?? '').toString().toLowerCase();
        final barcodeLower = (data['barcode'] ?? '').toString().toLowerCase();

        return nameLower.contains(q) || barcodeLower.contains(q);
      }).toList();
    }

    setState(() {
      _filteredProducts = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        title: Image.asset(
          'assets/logo_nutrisight.png',
          height: 32,
        ),
        actions: [
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseAuth.instance.currentUser == null
                ? const Stream.empty()
                : FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
            builder: (context, snapshot) {
              String? photoUrl;
              String? name;
              if (snapshot.hasData && snapshot.data!.data() != null) {
                photoUrl = snapshot.data!.data()!['photoUrl'] as String?;
                name = snapshot.data!.data()!['name'] as String?;
              }

              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                  },
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage:
                        photoUrl != null ? NetworkImage(photoUrl) : null,
                    child: photoUrl == null
                        ? Text(
                            (name ?? 'U').substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          )
                        : null,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildSearchBar(),
          ),
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildFilters(),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildProductGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search by name or barcode',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['All', 'A', 'B', 'C', 'D'].map((g) {
              final selected = _selectedGrade == g;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text('Grade $g'),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      _selectedGrade = g;
                    });
                    _applyFilters();
                  },
                  selectedColor: Colors.blue.shade800,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Color(0xFF9D9D9D),
                  ),
                  showCheckmark: false,
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: selected ? Colors.transparent : Colors.grey.shade200,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _allCategories.map((cat) {
              final selected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(
                    cat,
                    style: const TextStyle(fontSize: 14),
                  ),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      _selectedCategory = cat;
                    });
                    _applyFilters();
                  },
                  selectedColor: Colors.green.shade700,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Color(0xFF9D9D9D),
                  ),
                  showCheckmark: false,
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: selected ? Colors.transparent : Colors.grey.shade200,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildProductGrid() {
    if (_filteredProducts.isEmpty) {
      return const Center(
        child: Text(
          'Produk tidak ditemukan',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 150),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 245,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        var data = _filteredProducts[index].data() as Map<String, dynamic>;
        return ProductGridCard(data: data);
      },
    );
  }
}

class ProductGridCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const ProductGridCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    String productName = data['productName'] ?? 'No Name';
    String manufacturer = data['manufacturer'] ?? 'No Brand';
    String imageUrl = data['imageUrl'] ?? '';
    String grade = data['grade'] ?? '';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: data),
          ),
        );
      },
      child: Card(
        elevation: 1,
        shadowColor: Colors.grey.shade50,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 150,
                  width: double.infinity,
                  color: const Color(0xFFFFFFFF),
                  padding: const EdgeInsets.all(8),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                                child: CircularProgressIndicator(strokeWidth: 2));
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image_not_supported,
                                color: Colors.grey);
                          },
                        )
                      : const Icon(Icons.image_not_supported,
                          color: Colors.grey, size: 50),
                ),
                Positioned(
                  top: 4,
                  right: 10,
                  child: _GradeBadge(grade: grade),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    manufacturer,
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradeBadge extends StatelessWidget {
  final String grade;
  const _GradeBadge({required this.grade});

  String? _assetForGrade(String grade) {
    switch (grade) {
      case 'A':
        return 'assets/logo_gradeA.png';
      case 'B':
        return 'assets/logo_gradeB.png';
      case 'C':
        return 'assets/logo_gradeC.png';
      case 'D':
        return 'assets/logo_gradeD.png';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final asset = _assetForGrade(grade);

    if (asset == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _gradeColor(grade),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          grade.isEmpty ? '-' : grade,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
    }

    return Image.asset(
      asset,
      height: 52,
      width: 52,
      errorBuilder: (_, __, ___) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _gradeColor(grade),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          grade.isEmpty ? '-' : grade,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Color _gradeColor(String grade) {
    switch (grade) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
