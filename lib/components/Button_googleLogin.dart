import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aisyiyah_smartlife/animation/TransitionAnim_forPage.dart';
import 'package:aisyiyah_smartlife/pages/Home.dart';

class Button_googleLogin extends StatefulWidget {
  final VoidCallback? onSuccess;
  final VoidCallback? onFail;

  const Button_googleLogin({
    super.key,
    this.onSuccess,
    this.onFail,
  });

  @override
  State<Button_googleLogin> createState() => _Button_googleLoginState();
}

class _Button_googleLoginState extends State<Button_googleLogin> {
  bool _isLoading = false;

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return; // pengguna batal login
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final email = googleUser.email;
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userQuery.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email belum terdaftar di sistem kami."),
            backgroundColor: Colors.redAccent,
          ),
        );
        await GoogleSignIn().signOut();
        widget.onFail?.call();
      } else {
        await FirebaseAuth.instance.signInWithCredential(credential);
        widget.onSuccess?.call();

        if (mounted) {
          Navigator.pushReplacement(
            context,
            SlideRightPageRoute(
              page: const HomeScreen(),
              animasi: Curves.bounceIn,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login gagal: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
      widget.onFail?.call();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
      ),
      icon: _isLoading
          ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      )
          : Image.asset('assets/icons/google.png', height: 24),
      label: Text(_isLoading ? "Memproses..." : "Masuk dengan Google"),
      onPressed: _isLoading ? null : _handleGoogleLogin,
    );
  }
}
