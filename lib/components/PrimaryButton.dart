import 'package:flutter/material.dart';
import 'package:aisyiyah_smartlife/theme/AppColors.dart';

class PrimaryButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  final Color warna;
  final String text;
  final Curve animasi;


  const PrimaryButton({
    super.key,
    required this.isLoading,
    required this.onTap,
    required this.warna,
    required this.text,
    required this.animasi,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: animasi,
        width: isLoading ? 90 : screenWidth,
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isLoading ? Colors.grey.shade300 : warna,
          borderRadius: BorderRadius.circular(isLoading ? 100.0 : 8.0),
        ),

        child: isLoading ? CircularProgressIndicator(
            color: warna,
            strokeWidth: 3
        )
            : Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
