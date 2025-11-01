import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'result_scan_screen.dart';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class DetailScanScreen extends StatefulWidget {
  final XFile imageFile;
  const DetailScanScreen({super.key, required this.imageFile});

  @override
  State<DetailScanScreen> createState() => _DetailScanScreenState();
}

class _DetailScanScreenState extends State<DetailScanScreen> {
  final String _apiUrl = "https://nutrition-api-464605127931.asia-southeast2.run.app/classify-image-graded";
  final Dio _dio = Dio();

  final Map<String, String> _categories = {
    "01.0": "Produk susu & analognya",
    "02.0": "Lemak, minyak & emulsi",
    "03.0": "Es krim/sherbet",
    "04.0": "Buah & sayur olahan",
    "05.0": "Kembang gula & cokelat",
    "06.0": "Serealia & produk serealia",
    "07.0": "Produk bakeri",
    "08.0": "Daging olahan",
    "09.0": "Ikan olahan",
    "10.0": "Telur & produk telur",
    "11.0": "Gula, madu, sirup",
    "12.0": "Minuman non-alkohol",
    "13.0": "Makanan ringan",
    "14.0": "Bumbu, saus, penyedap",
    "15.0": "Pangan siap saji",
    "16.0": "Lainnya (tanpa grade)",
  };

  String? _selectedCategoryCode;
  bool _isLoading = false;

  late String _permanentImagePath;
  bool _isInitializing = true;

  final Color primaryBlue = const Color(0xFF1C69A8);

  @override
  void initState() {
    super.initState();
    _copyFileToAppDir();
  }

  Future<File> _convertToJpgIfNeeded(File inputFile) async {
    final ext = p.extension(inputFile.path).toLowerCase();

    if (ext == '.jpg' || ext == '.jpeg' || ext == '.png') {
      print("🟢 File sudah JPG/PNG, langsung kirim: ${inputFile.path}");
      return inputFile;
    }

    print("🟣 File bukan JPG ($ext), coba compress ke JPG...");
    try {
      final dir = await getApplicationDocumentsDirectory();
      final targetPath = p.join(
        dir.path,
        'scan_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final compressed = await FlutterImageCompress.compressAndGetFile(
        inputFile.path,
        targetPath,
        format: CompressFormat.jpeg,
        quality: 95,
      );

      if (compressed != null) {
        print("✅ Berhasil convert ke JPG via flutter_image_compress: ${compressed.path}");
        return File(compressed.path);
      } else {
        print("⚠️ flutter_image_compress mengembalikan null");
      }
    } catch (e) {
      print("❌ Gagal convert pakai flutter_image_compress: $e");
    }

    try {
      print("🟡 Fallback ke package:image ...");
      final bytes = await inputFile.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded != null) {
        final jpgBytes = img.encodeJpg(decoded, quality: 90);
        final newPath = inputFile.path.replaceAll(RegExp(r'\.\w+$'), '.jpg');
        final newFile = File(newPath)..writeAsBytesSync(jpgBytes);
        print("✅ Fallback package:image berhasil: ${newFile.path}");
        return newFile;
      } else {
        print("❌ package:image tidak bisa decode file ini");
      }
    } catch (e) {
      print("❌ Gagal fallback package:image: $e");
    }

    print("⚠️ Semua metode konversi gagal. Kirim file asli: ${inputFile.path}");
    return inputFile;
  }

  Future<void> _copyFileToAppDir() async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = p.basename(widget.imageFile.path);
      final String newPath = '${appDir.path}/$fileName';
      
      final File newImage = await File(widget.imageFile.path).copy(newPath);
      
      setState(() {
        _permanentImagePath = newImage.path;
        _isInitializing = false;
      });
    } catch (e) {
      print("Error menyalin file: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal memuat gambar. Silakan coba lagi.")),
      );
      Navigator.of(context).pop();
    }
  }

  void _handleScan() async {
    if (_selectedCategoryCode == null) return;

    setState(() { _isLoading = true; });

    print("=================================");
    print("Scan Dimulai...");
    print("API URL: $_apiUrl");
    print("Kategori Dipilih: $_selectedCategoryCode");
    print("Path File: $_permanentImagePath");

    try {
      print("Mempersiapkan FormData...");
      final File originalFile = File(_permanentImagePath);

      final File fileToSend = await _convertToJpgIfNeeded(originalFile);

      FormData formData = FormData.fromMap({
        'category_code': _selectedCategoryCode!,
        'file': await MultipartFile.fromFile(
          fileToSend.path,
          filename: p.basename(fileToSend.path),
        ),
      });
      print("FormData siap.");

      print("Mengirim request ke server...");
      var response = await _dio.post(
        _apiUrl,
        data: formData,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      print("Server merespons dengan StatusCode: ${response.statusCode}");
      print("Data Respons (mentah): ${response.data}");

      var responseData = response.data;

      String categoryName = _categories[_selectedCategoryCode!] ?? "Tidak Dikenali";

      if (!mounted) return;
      print("Navigasi ke ResultScanScreen...");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScanScreen(
            imageFile: XFile(_permanentImagePath),
            categoryName: categoryName,
            scanResult: responseData,
          ),
        ),
      );

    } on DioException catch (e) {
      print("--- ERROR (DioException) ---");
      if (e.response != null) {
        print("Error Status Code: ${e.response?.statusCode}");
        print("Error Data: ${e.response?.data}");
      } else {
        print("Error Tipe: ${e.type}");
        print("Error Message: ${e.message}");
      }
      print("----------------------------");

      if (!mounted) return;
      String errorMessage = "Terjadi kesalahan.";
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.sendTimeout || e.type == DioExceptionType.receiveTimeout) {
        errorMessage = "Koneksi ke server timeout. Server mungkin sibuk.";
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = "Tidak dapat terhubung. Periksa koneksi internet Anda.";
      } else if (e.response != null) {
        errorMessage = "Error dari Server: ${e.response?.statusCode}.";
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );

    } catch (e) {
      print("--- ERROR (Lainnya) ---");
      print(e.toString());
      print("-------------------------");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan tak terduga: $e")),
      );
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
      print("Scan Selesai (finally block).");
      print("=================================");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          "Detail Scan",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
      body: _isInitializing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Mempersiapkan gambar..."),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    "Periksa kembali foto dan pilih kategori produk:",
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        image: DecorationImage(
                          image: FileImage(File(_permanentImagePath)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  DropdownButtonFormField<String>(
                    value: _selectedCategoryCode,
                    hint: const Text("Pilih Kategori Produk"),
                    isExpanded: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: _categories.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategoryCode = newValue;
                      });
                    },
                  ),
                  
                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedCategoryCode == null || _isLoading
                          ? null
                          : _handleScan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : const Text(
                              'Scan',
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}