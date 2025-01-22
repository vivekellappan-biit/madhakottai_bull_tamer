import 'dart:convert';
import 'package:flutter/material.dart';

class Base64ImageDialog extends StatelessWidget {
  final String base64String;

  const Base64ImageDialog({
    super.key,
    required this.base64String,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image container with error handling
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildImage(),
              ),
            ),
            const SizedBox(height: 16),
            // Close button
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    try {
      return Image.memory(
        base64Decode(base64String),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Text(
              'Error loading image',
              style: TextStyle(color: Colors.red),
            ),
          );
        },
      );
    } catch (e) {
      return const Center(
        child: Text(
          'Invalid base64 string',
          style: TextStyle(color: Colors.red),
        ),
      );
    }
  }
}

// Example usage:
void showImageDialog(BuildContext context, String base64String) {
  showDialog(
    context: context,
    builder: (context) => Base64ImageDialog(base64String: base64String),
  );
}
