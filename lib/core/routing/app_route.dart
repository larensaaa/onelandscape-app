import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onelandscape/features/auth/presentation/providers/auth_provider.dart';
import 'package:onelandscape/features/auth/presentation/screens/login_screen.dart';
import 'package:onelandscape/features/home/presentation/screens/home_screen.dart';
import 'package:onelandscape/features/map/presentation/screens/full_screen_map_screen.dart';
import 'package:onelandscape/features/shell_app/main_shell.dart';
import 'package:onelandscape/features/tematik/data/models/tematik_model.dart';
import 'package:onelandscape/features/tematik/presentation/screens/tematik_detail_page.dart';
// import 'package:onelandscape/features/tematik/presentation/screens/daftar_tematik_screen.dart';
import 'package:onelandscape/features/tematik/presentation/screens/tambah_edit_tematik_screen.dart';
import 'package:onelandscape/features/auth/presentation/screens/register_screen.dart';
import 'package:onelandscape/features/auth/presentation/screens/splash_screen.dart';
import 'package:onelandscape/features/user/presentation/screens/user_screen.dart';
import 'package:onelandscape/features/skpd/presentation/screens/skpd_screen.dart';

class AppRouter {
  final AuthProvider authProvider;
  late final GoRouter router;

  AppRouter(this.authProvider) {
    router = GoRouter(
      refreshListenable: authProvider,
      initialLocation: '/splash',

      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),

        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),

        GoRoute(
          path: '/map-full',
          builder: (context, state) => const FullScreenMapScreen(),
        ),
        GoRoute(
          path: '/tematik-detail',
          builder: (context, state) => const DaftarTematikScreen(),
        ),
        GoRoute(
          path: '/tematik-tambah-edit',
          builder: (context, state) {
            final item = state.extra as TematikItem?;
            return TambahEditTematikScreen(tematikItem: item);
          },
        ),

        ShellRoute(
          builder: (context, state, child) {
            return MainShell(child: child);
          },
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/skpd',
              builder: (context, state) => const SkpdScreen(),
            ),
            GoRoute(
              path: '/user',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],

      redirect: (BuildContext context, GoRouterState state) {
        final bool isLoggedIn = authProvider.isAuthenticated;
        final bool isCheckingAuth = authProvider.isCheckingAuth;
        final String location = state.matchedLocation;

        final bool isPublicRoute =
            (location == '/login' || location == '/register');

        if (isCheckingAuth) {
          return '/splash';
        }

        if (!isLoggedIn && !isPublicRoute) {
          return '/login';
        }

        if (isLoggedIn && (isPublicRoute || location == '/splash')) {
          return '/home';
        }

        return null;
      },
    );
  }
}
