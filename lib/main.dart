import 'package:flutter/material.dart';
import 'package:madhakottai_bull_tamer/providers/auth_provider.dart';
import 'package:madhakottai_bull_tamer/providers/bull_tamer_search_provider.dart';
import 'package:madhakottai_bull_tamer/router/app_routes.dart';
import 'package:provider/provider.dart';
import 'providers/registration_provider.dart';
import 'providers/splash_provider.dart';
import 'providers/theme_provider.dart';
import 'utils/theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SplashProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BullTamerSearchProvider()),
        ChangeNotifierProvider(create: (_) => RegistrationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          title: '',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
