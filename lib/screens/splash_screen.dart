import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/splash_provider.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final splashProvider = Provider.of<SplashProvider>(context);

    // Initialize splash screen state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      splashProvider.initializeSplash(context);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              'assets/images/logo.png', // Replace with your logo file path
              width: 200,
              height: 200,
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "புனித லூர்து மாதா ஜல்லிக்கட்டு பேரவை\nமாதகோட்டை, தஞ்சாவூர் மாவட்டம்",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
