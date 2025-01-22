import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:madhakottai_bull_tamer/router/router.dart';
import 'package:madhakottai_bull_tamer/screens/bulltamer_search_screen.dart';
import 'package:madhakottai_bull_tamer/screens/login_screen.dart';
import 'package:madhakottai_bull_tamer/screens/qr_scanner_screen.dart';
import 'package:madhakottai_bull_tamer/screens/registration_screen.dart';

import '../screens/splash_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: Routes.splash,
  routes: [
    GoRoute(
      path: Routes.splash,
      pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
        context: context,
        state: state,
        child: const SplashScreen(),
      ),
    ),
    GoRoute(
      path: Routes.login,
      pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
        context: context,
        state: state,
        child: const LoginScreen(),
      ),
    ),
    GoRoute(
      path: Routes.home,
      pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
        context: context,
        state: state,
        child: const RegistrationScreen(),
      ),
    ),
    GoRoute(
      path: Routes.search,
      pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
        context: context,
        state: state,
        child: const BullTamerSearchScreen(),
      ),
    ),
    GoRoute(
      path: Routes.qrScan,
      pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
        context: context,
        state: state,
        child: const QRScannerScreen(),
      ),
    ),
  ],
);

CustomTransitionPage<T> buildPageWithDefaultTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);
      return SlideTransition(position: offsetAnimation, child: child);
    },
  );
}
