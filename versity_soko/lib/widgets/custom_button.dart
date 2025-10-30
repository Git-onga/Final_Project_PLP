import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isExpanded;
  final double? width;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isExpanded = true,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent, // transparent so gradient shows
        shadowColor: Colors.transparent,     // remove button shadow
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white, // white spinner for contrast
              ),
            )
          : Text(
              text,
              style: const TextStyle(
                color: Colors.white, // white text for contrast
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
    );

    final buttonWithGradient = Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF764BA2),
            Color(0xFF667EEA),// Vibrant blue
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: button,
    );

    return Center(
      child: SizedBox(
        width: isExpanded ? double.infinity : width ?? 250,
        child: buttonWithGradient,
      ),
    );
  }
}