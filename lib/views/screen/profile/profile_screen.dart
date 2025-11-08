import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutrisight/views/screen/auth/auth_screen.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/profile_view_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileViewModel>(
      create: (_) => ProfileViewModel(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView({super.key});

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  final _picker = ImagePicker();

  Future<void> _pickAndUploadImage(ProfileViewModel vm) async {
    final user = vm.currentUser ?? FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;

    final err = await vm.uploadProfileImage(picked);
    if (!mounted) return;

    if (err == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Foto profil diperbarui ✅")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal upload foto: $err")),
      );
    }
  }

  Future<void> _changeEmail(ProfileViewModel vm) async {
    final user = vm.currentUser ?? FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final newEmailController = TextEditingController(text: user.email ?? '');
    final passwordController = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            "Change Email",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newEmailController,
                decoration: const InputDecoration(labelText: "New email"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: "Current password"),
              ),
            ],
          ),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF1C69A8), width: 1.5),
                foregroundColor: const Color(0xFF1C69A8),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1C69A8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(
                "Save",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    final err = await vm.changeEmail(
      currentPassword: passwordController.text,
      newEmail: newEmailController.text,
    );

    if (!mounted) return;

    if (err == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Email has been sent for verification. Check your inbox ✅"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("failed to change email: $err")),
      );
    }
  }

  Future<void> _changePassword(ProfileViewModel vm) async {
    final user = vm.currentUser ?? FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            "Change Password",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPassController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: "Current password"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPassController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "New password"),
              ),
            ],
          ),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF1C69A8), width: 1.5),
                foregroundColor: const Color(0xFF1C69A8),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1C69A8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(
                "Save",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    final err = await vm.changePassword(
      currentPassword: currentPassController.text,
      newPassword: newPassController.text,
    );

    if (!mounted) return;

    if (err == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password already changed ✅")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("failed to change password: $err")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    final user = vm.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in yet")),
      );
    }

    final userStream = vm.userDocStream;

    if (userStream == null) {
      return const Scaffold(
        body: Center(child: Text("Unable to load profile.")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[50],
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.data();
          final photoUrl = data?['photoUrl'] as String?;
          final email = data?['email'] as String? ?? user.email;
          final name =
              data?['name'] as String? ?? (user.email?.split('@').first ?? "User");

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage:
                          photoUrl != null ? NetworkImage(photoUrl) : null,
                      child: photoUrl == null
                          ? Text(
                              name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: InkWell(
                        onTap: vm.isUploadingImage
                            ? null
                            : () => _pickAndUploadImage(vm),
                        child: Container(
                          height: 32,
                          width: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1C69A8),
                            shape: BoxShape.circle,
                          ),
                          child: vm.isUploadingImage
                              ? const Padding(
                                  padding: EdgeInsets.all(6.0),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email ?? "-",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),

                Container(
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
                  child: ListTile(
                    onTap: vm.isChangingEmail ? null : () => _changeEmail(vm),
                    leading: const Icon(Icons.email_outlined),
                    title: const Text("Change Email"),
                    subtitle: const Text("Change your account email"),
                    trailing: vm.isChangingEmail
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.chevron_right),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Container(
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
                  child: ListTile(
                    onTap:
                        vm.isChangingPassword ? null : () => _changePassword(vm),
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    leading: const Icon(Icons.lock_outline_rounded),
                    title: const Text("Change Password"),
                    subtitle: const Text("Change your account password"),
                    trailing: vm.isChangingPassword
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.chevron_right),
                  ),
                ),

                const SizedBox(height: 12),

                Container(
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
                  child: ListTile(
                    onTap: () async {
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (ctx) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Text(
                              "Logout",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            content: const Text("Are you sure you want to log out of this account?"),
                            actions: [
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF1C69A8),
                                  side: const BorderSide(color: Color(0xFF1C69A8), width: 1.5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1C69A8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text("Logout", style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          );
                        },
                      );

                      if (shouldLogout == true) {
                        await FirebaseAuth.instance.signOut();
                        if (!context.mounted) return;
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => AuthScreen()),
                          (route) => false,
                        );
                      }
                    },
                    leading: const Icon(Icons.logout, color: Colors.redAccent),
                    title: const Text("Logout"),
                    subtitle: const Text("Logout from NutriSight account"),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
