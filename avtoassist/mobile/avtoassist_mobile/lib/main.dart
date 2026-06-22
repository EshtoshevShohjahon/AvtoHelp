import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'core/storage/secure_storage.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/phone_screen.dart';
import 'features/auth/otp_screen.dart';
import 'features/auth/kyc_screen.dart';
import 'features/home/home_screen.dart';
import 'features/orders/new_order_screen.dart';
import 'features/orders/tracking_screen.dart';
import 'features/catalog/catalog_screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppPrefs.init();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const ProviderScope(child: AvtoAssistApp()));
}

final _router = GoRouter(
  initialLocation: '/auth/phone',
  redirect: (context, state) async {
    final token = await SecureStorage.read('access_token');
    final onAuth = state.matchedLocation.startsWith('/auth') ||
        state.matchedLocation.startsWith('/kyc');
    if (token == null && !onAuth) return '/auth/phone';
    return null;
  },
  routes: [
    GoRoute(
      path: '/auth/phone',
      builder: (_, __) => const PhoneScreen(),
    ),
    GoRoute(
      path: '/auth/otp',
      builder: (_, state) {
        final phone = state.extra as String? ?? '';
        return OtpScreen(phone: phone);
      },
    ),
    GoRoute(
      path: '/kyc',
      builder: (_, state) {
        final serviceType = state.extra as String? ?? 'tech_support';
        return KycScreen(serviceType: serviceType);
      },
    ),
    ShellRoute(
      builder: (context, state, child) => _MainShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (_, __) => const HomeScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (_, __) => const _ProfileScreen(),
        ),
        GoRoute(
          path: '/my-orders',
          builder: (_, __) => const _OrdersListScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/order/new',
      builder: (_, state) {
        final serviceType = state.extra as String? ?? 'tech_support';
        return NewOrderScreen(serviceType: serviceType);
      },
    ),
    GoRoute(
      path: '/order/tracking/:id',
      builder: (_, state) {
        final id = state.pathParameters['id']!;
        return TrackingScreen(orderId: id);
      },
    ),
    GoRoute(
      path: '/catalog/parts',
      builder: (_, __) => const PartsScreen(),
    ),
    GoRoute(
      path: '/catalog/workshops',
      builder: (_, __) => const WorkshopsScreen(),
    ),
    GoRoute(
      path: '/provider/home',
      builder: (_, __) => const _ProviderHomeScreen(),
    ),
  ],
);

class AvtoAssistApp extends ConsumerWidget {
  const AvtoAssistApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedLang = AppPrefs.appLang;
    final locale = _parseLocale(savedLang);

    return MaterialApp.router(
      title: 'AvtoAssist',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      locale: locale,
      supportedLocales: const [
        Locale('uz'),
        Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Cyrl'),
        Locale('ru'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: _router,
    );
  }

  Locale _parseLocale(String lang) {
    switch (lang) {
      case 'ru': return const Locale('ru');
      case 'en': return const Locale('en');
      case 'uz-cyrl': return const Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Cyrl');
      default: return const Locale('uz');
    }
  }
}

class _MainShell extends ConsumerWidget {
  final Widget child;
  const _MainShell({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = switch (location) {
      '/home'      => 0,
      '/my-orders' => 1,
      '/profile'   => 2,
      _            => 0,
    };

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) {
          switch (i) {
            case 0: context.go('/home');
            case 1: context.go('/my-orders');
            case 2: context.go('/profile');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Asosiy',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Buyurtmalar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _OrdersListScreen extends StatelessWidget {
  const _OrdersListScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buyurtmalar')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, color: AppColors.steelLight, size: 56),
            SizedBox(height: 12),
            Text("Hali buyurtmalar yo'q",
                style: TextStyle(color: AppColors.steelLight)),
          ],
        ),
      ),
    );
  }
}

class _ProfileScreen extends ConsumerWidget {
  const _ProfileScreen();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 38,
              backgroundColor: AppColors.steel,
              child: Text(
                (user?.fullName?.isNotEmpty == true
                    ? user!.fullName![0]
                    : user?.phone?.substring((user.phone.length - 2)) ?? '?').toUpperCase(),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.bone),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(child: Text(user?.fullName ?? user?.phone ?? '',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.bone))),
          const SizedBox(height: 28),
          _ProfileTile(icon: Icons.directions_car_outlined, title: 'Avtomobillarim', onTap: () {}),
          _ProfileTile(icon: Icons.language_outlined, title: 'Til sozlamalari', onTap: () {}),
          _ProfileTile(icon: Icons.logout, title: 'Chiqish', color: AppColors.danger,
              onTap: () => ref.read(authProvider.notifier).logout()),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? color;
  final VoidCallback onTap;
  const _ProfileTile({required this.icon, required this.title, this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.bone;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.charcoal,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.steelLine),
        ),
        child: Row(children: [
          Icon(icon, color: c, size: 20),
          const SizedBox(width: 12),
          Text(title, style: TextStyle(color: c, fontSize: 14)),
          const Spacer(),
          Icon(Icons.chevron_right, color: AppColors.steelLight, size: 18),
        ]),
      ),
    );
  }
}

class _ProviderHomeScreen extends ConsumerWidget {
  const _ProviderHomeScreen();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    return Scaffold(
      appBar: AppBar(title: const Text('Provider Panel')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.handyman_outlined, color: AppColors.amber, size: 56),
            const SizedBox(height: 16),
            Text('Xush kelibsiz, \${user?.fullName?.split(\' \').first ?? \'Usta\'}!',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.bone)),
            const SizedBox(height: 8),
            const Text('Yangi buyurtmalarni kuting...',
                style: TextStyle(color: AppColors.steelLight)),
          ],
        ),
      ),
    );
  }
}
