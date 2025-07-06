
import 'package:go_router/go_router.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/map/presentation/screens/full_screen_map_screen.dart'; // Impor baru
import 'features/shell_app/main_shell.dart';
import 'features/skpd/presentation/screens/skpd_screen.dart';
import 'features/tematik/presentation/screens/tematik_detail_page.dart'; // Impor baru
import 'features/user/presentation/screens/user_screen.dart';
import 'features/tematik_crud/presentation/screens/tematik_data_page.dart';

final GoRouter router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    // Rute baru untuk peta layar penuh
    GoRoute(
      path: '/map-full',
      builder: (context, state) => const FullScreenMapScreen(),
    ),
    // Rute baru untuk detail tematik, menggunakan parameter
    GoRoute(
      path: '/tematik-detail/:title', // ':title' adalah parameter
      builder: (context, state) {
        final title = state.pathParameters['title']!;
        return TematikDetailPage(title: title);
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
          path: '/data-tematik',
          builder: (context, state) => const TematikDataPage(),
        ),
        GoRoute(
          path: '/user',
          builder: (context, state) => const UserScreen(),
        ),
      ],
    ),
  ],
);