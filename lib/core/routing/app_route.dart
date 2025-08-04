import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/map/presentation/screens/full_screen_map_screen.dart';
import '../../features/shell_app/main_shell.dart';
import '../../features/skpd/presentation/screens/skpd_screen.dart';
import '../../features/tematik/presentation/screens/tematik_detail_page.dart';
import '../../features/user/presentation/screens/user_screen.dart';
import '../../features/tematik/presentation/screens/tambah_edit_tematik_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';

// Impor juga halaman daftar tematik jika belum ada


final GoRouter router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
     GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
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
      builder: (context, state) => const TambahEditTematikScreen(),
    ),
    // ShellRoute dengan halaman-halaman utama
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
          builder: (context, state) => const UserScreen(),
        ),
      ],
    ),
  ],
);