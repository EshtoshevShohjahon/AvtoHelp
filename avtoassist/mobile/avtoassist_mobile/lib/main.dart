import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'core/storage/secure_storage.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/phone_screen.dart';
import 'features/auth/otp_screen.dart';
import 'features/home/home_screen.dart';
import 'features/vehicles/vehicles_screen.dart';
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

// ─── Router ───────────────────────────────────────────────
final _router = GoRouter(
  initialLocation: '/auth/phone',
  redirect: (context, state) async {
    // Sessiya saqlangan bo'lsa (access yoki refresh token) qayta login so'ramaymiz.
    final token = await SecureStorage.read('access_token');
    final refresh = await SecureStorage.read('refresh_token');
    final hasSession = token != null || refresh != null;
    final onAuth = state.matchedLocation.startsWith('/auth');
    if (!hasSession && !onAuth) return '/auth/phone';
    if (hasSession && onAuth) return '/home';
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
      path: '/vehicles',
      builder: (_, __) => const VehiclesScreen(),
    ),
    GoRoute(
      path: '/vehicles/add',
      builder: (_, __) => const AddVehicleScreen(),
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

// ─── App ─────────────────────────────────────────────────
class AvtoAssistApp extends ConsumerWidget {
  const AvtoAssistApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedLang = ref.watch(localeProvider);
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
      case 'ru':
        return const Locale('ru');
      case 'en':
        return const Locale('en');
      case 'uz-cyrl':
      case 'uz_Cyrl':
        return const Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Cyrl');
      default:
        return const Locale('uz');
    }
  }
}

// ─── Bottom nav shell ─────────────────────────────────────────────
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

// ─── Placeholder screens ─────────────────────────────────────────────
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
            Icon(Icons.receipt_long_outlined,
                color: AppColors.steelLight, size: 56),
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
                () {
                  final u = user;
                  if (u?.fullName != null && u!.fullName!.isNotEmpty) {
                    return u.fullName![0].toUpperCase();
                  }
                  final p = u?.phone;
                  if (p != null && p.length >= 2) {
                    return p.substring(p.length - 2);
                  }
                  return '?';
                }(),
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.bone),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              user?.fullName ?? user?.phone ?? '',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.bone),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              user?.phone ?? '',
              style: const TextStyle(color: AppColors.steelLight),
            ),
          ),
          const SizedBox(height: 28),
          _ProfileTile(
            icon: Icons.directions_car_outlined,
            title: 'Avtomobillarim',
            onTap: () => context.push('/vehicles'),
          ),
          _ProfileTile(
            icon: Icons.language_outlined,
            title: 'Til sozlamalari',
            onTap: () => _showLanguagePicker(context, ref),
          ),
          _ProfileTile(
            icon: Icons.logout,
            title: 'Chiqish',
            color: AppColors.danger,
            // Log Out qilingandagina tokenlar o'chiriladi va keyin Login so'raladi
            onTap: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/auth/phone');
            },
          ),
        ],
      ),
    );
  }
}

void _showLanguagePicker(BuildContext context, WidgetRef ref) {
  const langs = [
    ('uz', "O'zbekcha (lotin)"),
    ('uz-cyrl', 'Ўзбекча (кирилл)'),
    ('ru', 'Русский'),
    ('en', 'English'),
  ];
  final current = ref.read(localeProvider);
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.charcoal,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.steelLine,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Tilni tanlang',
                style: TextStyle(
                    color: AppColors.bone,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ),
          for (final (code, label) in langs)
            ListTile(
              title: Text(label, style: const TextStyle(color: AppColors.bone)),
              trailing: code == current
                  ? const Icon(Icons.check, color: AppColors.amber)
                  : null,
              onTap: () {
                ref.read(localeProvider.notifier).setLang(code);
                Navigator.pop(ctx);
              },
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? color;
  final VoidCallback onTap;
  const _ProfileTile(
      {required this.icon,
      required this.title,
      this.color,
      required this.onTap});

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
          Icon(Icons.chevron_right,
              color: AppColors.steelLight, size: 18),
        ]),
      ),
    );
  }
}

// ─── Provider home (stub) ───────────────────────────────────────────
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
            const Icon(Icons.handyman_outlined,
                color: AppColors.amber, size: 56),
            const SizedBox(height: 16),
            Text(
              'Xush kelibsiz, ${user?.fullName?.split(' ').first ?? 'Usta'}!',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.bone),
            ),
            const SizedBox(height: 8),
            const Text('Yangi buyurtmalarni kuting...',
                style: TextStyle(color: AppColors.steelLight)),
          ],
        ),
      ),
    );
  }
}
