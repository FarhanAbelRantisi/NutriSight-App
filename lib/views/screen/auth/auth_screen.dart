import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import '../home_screen.dart';

class AuthScreen extends StatelessWidget {
  AuthScreen({super.key});

  final Color primaryBlue = const Color(0xFF1C69A8);
  final Color darkText = const Color(0xFF1D1D1D);
  final Color greyText = const Color(0xFFBFBFBF);

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null && context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error signing in with Google: $e")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/healthfood.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.35),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.40),
                  const Text(
                    "Discover\nwhat's inside\nyour food.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Let NutriSight make you healthier",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: _buildAuthSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Create new account',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: darkText, fontSize: 14),
                children: [
                  const TextSpan(text: 'Already have account? '),
                  TextSpan(
                    text: 'Login here',
                    style: TextStyle(
                      color: primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(child: Divider(color: greyText)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('OR', style: TextStyle(color: greyText)),
              ),
              Expanded(child: Divider(color: greyText)),
            ],
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: 50,
            height: 50,
            child: OutlinedButton(
              onPressed: () => _signInWithGoogle(context),
              style: OutlinedButton.styleFrom(
                shape: const CircleBorder(),
                side: BorderSide(color: greyText),
                padding: const EdgeInsets.all(12),
              ),
              child: SvgPicture.asset(
                'assets/google_logo.svg',
                height: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}