import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//theme
import 'package:aisyiyah_smartlife/theme/AppColors.dart';

Widget Button_menuIcon(String title, IconData icon, VoidCallback onTap, double itemWidth) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: itemWidth,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF388E3C), size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    ),
  );
}