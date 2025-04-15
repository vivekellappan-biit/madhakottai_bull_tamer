import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:madhakottai_bull_tamer/providers/bull_tamer_company_search_provider.dart';
import 'package:madhakottai_bull_tamer/providers/splash_provider.dart';
import 'package:madhakottai_bull_tamer/router/router.dart';
import 'package:provider/provider.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.microtask(() async {
      final provider =
          Provider.of<BullTamerCompanyProfileProvider>(context, listen: false);
      await provider.searchCompanyProfile(context);

      if (context.mounted && provider.errorMessage.isEmpty) {
        final bullTamer = provider.searchResults.first;
        // Save logo details to SharedPreferences
        Provider.of<SplashProvider>(context, listen: false).setLogoString(
          bullTamer.logo,
          bullTamer.name,
          bullTamer.street,
          bullTamer.street2,
        );
        print('Vivek E${bullTamer.name}');
        context.go(Routes.home);
      } else if (provider.errorMessage.isNotEmpty &&
          !provider.errorMessage.contains("Session expired")) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage)),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo.png',
                width: 250,
                height: 250,
                fit: BoxFit.fitHeight,
              ),
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "ஜல்லிக்கட்டு காளையை அடக்குபவர் பதிவு படிவம்",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
