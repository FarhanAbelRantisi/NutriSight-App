import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Untuk File
// --- 1. IMPORT HALAMAN BARU ---
import 'scan_detail_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  bool _isCameraInitialized = false;
  FlashMode _flashMode = FlashMode.off;
  int _selectedCameraIndex = 0; // 0 = back camera, 1 = front camera
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera(0); // Mulai dengan kamera belakang
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  // Handle app lifecycle changes (e.g., app minimized)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera(_selectedCameraIndex);
    }
  }

  Future<void> _initializeCamera(int cameraIndex) async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        print("No cameras found");
        return;
      }

      // Pastikan index kamera valid
      _selectedCameraIndex = cameraIndex % _cameras.length;

      final CameraController newController = CameraController(
        _cameras[_selectedCameraIndex], // Perbaikan: seharusnya _selectedCameraIndex
        ResolutionPreset.high,
        enableAudio: false,
      );

      // Buang controller lama jika ada
      await _controller?.dispose();

      // Inisialisasi controller baru
      await newController.initialize();
      
      // Set flash mode awal
      await newController.setFlashMode(_flashMode);

      if (mounted) {
        setState(() {
          _controller = newController;
          _isCameraInitialized = true;
        });
      }
    } on CameraException catch (e) {
      print("Error initializing camera: $e");
      _isCameraInitialized = false;
      if (mounted) setState(() {});
    }
  }

  void _toggleFlash() {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() {
      _flashMode = _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
    });
    _controller!.setFlashMode(_flashMode);
  }

  void _flipCamera() {
    if (_cameras.isEmpty) return;
    final int newIndex = (_selectedCameraIndex + 1) % _cameras.length;
    _initializeCamera(newIndex);
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final XFile imageFile = await _controller!.takePicture();
      
      print("Picture saved to ${imageFile.path}");

      // --- 2. PERUBAHAN NAVIGASI ---
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          // Buka halaman detail, kirim file gambarnya
          builder: (context) => ScanDetailScreen(imageFile: imageFile),
        ),
      );
      // --- AKHIR PERUBAHAN ---

    } on CameraException catch (e) {
      print("Error taking picture: $e");
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? imageFile = await _picker.pickImage(source: ImageSource.gallery);
      if (imageFile == null) return;

      print("Image picked from gallery: ${imageFile.path}");

      // --- 3. PERUBAHAN NAVIGASI ---
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          // Buka halaman detail, kirim file gambarnya
          builder: (context) => ScanDetailScreen(imageFile: imageFile),
        ),
      );
      // --- AKHIR PERUBAHAN ---
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Layer 1: Camera Preview
          Positioned.fill(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: CameraPreview(_controller!),
            ),
          ),
          
          // Layer 2: UI Controls
          _buildControlsOverlay(context),
        ],
      ),
    );
  }

  Widget _buildControlsOverlay(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // --- Top Controls (Flash, Title, Back) ---
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withOpacity(0.5), Colors.transparent],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              // Padding atas dan bawah
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
              // --- PERUBAHAN DI SINI ---
              // Child sekarang adalah Column, bukan Row
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Row 1: Tombol Kembali, Judul, Tombol Flash
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 1. Back Button
                      SizedBox(
                        width: 48, // Lebar konsisten untuk spasi
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24),
                          onPressed: () {
                            // Kembali ke halaman sebelumnya
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      
                      // 2. Title (Hanya Judul)
                      const Expanded(
                        child: Text(
                          "Scan",
                          textAlign: TextAlign.center, // Pusatkan judul
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // 3. Flash Button
                      SizedBox(
                        width: 48, // Lebar konsisten untuk spasi
                        child: IconButton(
                          icon: Icon(
                            _flashMode == FlashMode.off ? Icons.flash_off : Icons.flash_on,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: _toggleFlash,
                        ),
                      ),
                    ],
                  ),
                  
                  // Row 2: Teks Subjudul (di baris terpisah)
                  const SizedBox(height: 8), // Jarak antara judul dan subjudul
                  Text(
                    "Scan tabel informasi nilai gizi \n pada produk kemasan.",
                    textAlign: TextAlign.center, // Centered
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              // --- AKHIR PERUBAHAN ---
            ),
          ),
        ),

        // --- Bottom Controls (Gallery, Shutter, Flip) ---
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withOpacity(0.5), Colors.transparent],
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Gallery Button
                  IconButton(
                    icon: const Icon(Icons.photo_library, color: Colors.white, size: 32),
                    onPressed: _pickImageFromGallery,
                  ),
                  
                  // Shutter Button
                  _buildShutterButton(),

                  // Flip Camera Button (Menggantikan tombol Cancel)
                  IconButton(
                    icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 32),
                    onPressed: _flipCamera,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShutterButton() {
    return GestureDetector(
      onTap: _takePicture,
      child: Container(
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: Center(
          child: Container(
            height: 58,
            width: 58,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

