
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';


Widget Card_header(BuildContext context, dynamic controller) {
  final screenWidth = MediaQuery.of(context).size.width;
  final double titleFontSize = screenWidth < 500 ? 22.0 : 28.0;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Halo, ${controller.getUserFirstName()}',
          style: GoogleFonts.poppins(fontSize: titleFontSize, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        IconButton(icon: const Icon(Icons.settings_outlined, color: Colors.black54),
          onPressed: () {
            Get.toNamed('/profile');
          },
        ),
      ],
    ),
  );
}