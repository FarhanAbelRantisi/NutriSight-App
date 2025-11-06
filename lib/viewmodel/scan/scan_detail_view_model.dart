import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import '../../data/scan_repository.dart';

class ScanDetailViewModel extends ChangeNotifier {
  final ScanRepository _scanRepository;

  ScanDetailViewModel({ScanRepository? scanRepository})
      : _scanRepository = scanRepository ?? ScanRepository();

  bool isInitializing = true;
  bool isScanning = false;
  String? permanentImagePath;
  String? selectedCategoryCode;

  final Map<String, String> categories = const {
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

  // dipanggil pertama kali dari Screen
  Future<void> initWithXFile(XFile imageFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = p.basename(imageFile.path);
      final newPath = p.join(appDir.path, fileName);

      final newImage = await File(imageFile.path).copy(newPath);
      permanentImagePath = newImage.path;
    } catch (e) {
      debugPrint("❌ Error copy file to app dir: $e");
      rethrow;
    } finally {
      isInitializing = false;
      notifyListeners();
    }
  }

  void setSelectedCategory(String? code) {
    selectedCategoryCode = code;
    notifyListeners();
  }

  Future<File> _convertToJpgIfNeeded(File inputFile) async {
    final ext = p.extension(inputFile.path).toLowerCase();

    if (ext == '.jpg' || ext == '.jpeg' || ext == '.png') {
      debugPrint("🟢 File sudah JPG/PNG, langsung kirim: ${inputFile.path}");
      return inputFile;
    }

    debugPrint("🟣 File bukan JPG ($ext), coba compress ke JPG...");

    // 1) flutter_image_compress
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
        debugPrint("✅ Berhasil convert ke JPG via flutter_image_compress: ${compressed.path}");
        return File(compressed.path);
      } else {
        debugPrint("⚠️ flutter_image_compress mengembalikan null");
      }
    } catch (e) {
      debugPrint("❌ Gagal convert pakai flutter_image_compress: $e");
    }

    // 2) fallback package:image
    try {
      debugPrint("🟡 Fallback ke package:image ...");
      final bytes = await inputFile.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded != null) {
        final jpgBytes = img.encodeJpg(decoded, quality: 90);
        final newPath = inputFile.path.replaceAll(RegExp(r'\.\w+$'), '.jpg');
        final newFile = File(newPath)..writeAsBytesSync(jpgBytes);
        debugPrint("✅ Fallback package:image berhasil: ${newFile.path}");
        return newFile;
      } else {
        debugPrint("❌ package:image tidak bisa decode file ini");
      }
    } catch (e) {
      debugPrint("❌ Gagal fallback package:image: $e");
    }

    debugPrint("⚠️ Semua metode konversi gagal. Kirim file asli: ${inputFile.path}");
    return inputFile;
  }

  Future<Map<String, dynamic>> scan() async {
    if (permanentImagePath == null) {
      throw Exception("Image belum siap");
    }
    if (selectedCategoryCode == null) {
      throw Exception("Kategori belum dipilih");
    }

    isScanning = true;
    notifyListeners();

    try {
      final originalFile = File(permanentImagePath!);
      final fileToSend = await _convertToJpgIfNeeded(originalFile);

      debugPrint("Mempersiapkan FormData & kirim ke repository...");
      final result = await _scanRepository.classifyImage(
        categoryCode: selectedCategoryCode!,
        file: fileToSend,
      );

      debugPrint("✅ Scan selesai, dapet data: $result");
      return result;
    } finally {
      isScanning = false;
      notifyListeners();
    }
  }
}
