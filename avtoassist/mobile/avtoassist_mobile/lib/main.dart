import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'widgets/app_widgets.dart';
import 'core/storage/secure_storage.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/phone_screen.dart';
import 'features/auth/otp_screen.dart';
import 'features/auth/onboarding_screen.dart';
import 'features/provider/provider_home_screen.dart'
    show ProviderHomeScreen, ProviderOrdersScreen;
import 'features/provider/provider_profile_screen.dart';
import 'features/provider/provider_verification_screen.dart';
import 'features/home/home_screen.dart';
import 'features/vehicles/vehicles_screen.dart';
import 'features/orders/new_order_screen.dart';
import 'features/orders/tracking_screen.dart';
import 'features/catalog/catalog_screens.dart';
import 'features/catalog/workshops_map_screen.dart';
import 'features/truck/truck_section_screen.dart';
import 'features/marketplace/marketplace_screen.dart';
import 'features/marketplace/listing_detail_screen.dart';
import 'features/marketplace/add_listing_screen.dart';
import 'features/marketplace/provider_listings_screen.dart';
import 'features/notifications/notifications_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };
  try {
    await AppPrefs.init();
  } catch (_) {
    // SharedPreferences xatosida ham ilova ishga tushsin
  }
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const ProviderScope(child: AvtoHelpApp()));
}

// ─── Router ───────────────────────────────────────────────
final _router = GoRouter(
  initialLocation: '/auth/phone',
  redirect: (context, state) async {
    final token = await SecureStorage.read('access_token');
    final refresh = await SecureStorage.read('refresh_token');
    final hasSession = token != null || refresh != null;
    final loc = state.matchedLocation;
    // OTP va onboarding ekranlari authenticated foydalanuvchilar uchun ham ruxsat
    if (loc == '/auth/onboarding' || loc == '/auth/otp') {
      return hasSession ? null : '/auth/phone';
    }
    final onLoginFlow = loc.startsWith('/auth');
    if (!hasSession && !onLoginFlow) return '/auth/phone';

    // Rolga qarab to'g'ri "uy" ekranini aniqlaymiz
    final role = await SecureStorage.read('user_role') ?? 'client';
    final home = role == 'provider' ? '/provider/home' : '/home';

    if (hasSession && onLoginFlow) return home;

    // Shell mosligini ta'minlaymiz: client provider shellida yoki aksincha qolib
    // ketmasligi uchun. (Rol almashtirilganda ham ekran avtomatik to'g'rilanadi.)
    const clientShell = {'/home', '/my-orders', '/profile'};
    const providerShell = {'/provider/home', '/provider/orders', '/provider/profile'};
    if (role == 'provider' && clientShell.contains(loc)) return '/provider/home';
    if (role == 'client' && providerShell.contains(loc)) return '/home';

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
        final extra = state.extra;
        final phone = extra is Map ? (extra['phone'] as String? ?? '') : (extra as String? ?? '');
        final register = extra is Map ? (extra['register'] as bool? ?? false) : false;
        return OtpScreen(phone: phone, register: register);
      },
    ),
    GoRoute(
      path: '/auth/onboarding',
      builder: (_, __) => const OnboardingScreen(),
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
      builder: (_, __) => const WorkshopsMapScreen(),
    ),
    GoRoute(
      path: '/truck',
      builder: (_, __) => const TruckSectionScreen(),
    ),
    GoRoute(
      path: '/marketplace',
      builder: (_, __) => const MarketplaceScreen(),
    ),
    GoRoute(
      path: '/marketplace/add',
      builder: (_, __) => const AddListingScreen(),
    ),
    GoRoute(
      path: '/marketplace/my',
      builder: (_, __) => const ProviderListingsScreen(),
    ),
    GoRoute(
      path: '/marketplace/favorites',
      builder: (_, __) => const FavoritesScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (_, __) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/provider/verify',
      builder: (_, __) => const ProviderVerificationScreen(),
    ),
    GoRoute(
      path: '/provider/:id/stats',
      builder: (_, state) => ProviderProfileScreen(
        providerId: state.pathParameters['id']!,
        name: state.extra as String?,
      ),
    ),
    GoRoute(
      path: '/marketplace/edit/:id',
      builder: (_, state) {
        final data = state.extra as Map<String, dynamic>?;
        return AddListingScreen(existing: data);
      },
    ),
    GoRoute(
      path: '/marketplace/:id',
      builder: (_, state) {
        final id = state.pathParameters['id']!;
        final data = state.extra as Map<String, dynamic>?;
        return ListingDetailScreen(listingId: id, initialData: data);
      },
    ),
    ShellRoute(
      builder: (context, state, child) => _ProviderShell(child: child),
      routes: [
        GoRoute(
          path: '/provider/home',
          builder: (_, __) => const ProviderHomeScreen(),
        ),
        GoRoute(
          path: '/provider/orders',
          builder: (_, __) => const ProviderOrdersScreen(),
        ),
        GoRoute(
          path: '/provider/profile',
          builder: (_, __) => const _ProfileScreen(),
        ),
      ],
    ),
  ],
);

// ─── App ─────────────────────────────────────────────────
class AvtoHelpApp extends ConsumerWidget {
  const AvtoHelpApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedLang = ref.watch(localeProvider);
    final locale = _parseLocale(savedLang);

    // Auth holati o'zgarganda router avtomatik yo'naltiradi
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.unauthenticated &&
          previous?.status == AuthStatus.authenticated) {
        _router.go('/auth/phone');
      }
    });

    return MaterialApp.router(
      title: 'AvtoHelp',
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

    final l = AppLocalizations(context);
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
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home_rounded),
            label: l.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long_outlined),
            activeIcon: const Icon(Icons.receipt_long),
            label: l.orders,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline_rounded),
            activeIcon: const Icon(Icons.person_rounded),
            label: l.profile,
          ),
        ],
      ),
    );
  }
}

// ─── Provider shell ──────────────────────────────────────────────────────────
class _ProviderShell extends ConsumerWidget {
  final Widget child;
  const _ProviderShell({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = switch (location) {
      '/provider/home'    => 0,
      '/provider/orders'  => 1,
      '/provider/profile' => 2,
      _                   => 0,
    };
    final l = AppLocalizations(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) {
          switch (i) {
            case 0: context.go('/provider/home');
            case 1: context.go('/provider/orders');
            case 2: context.go('/provider/profile');
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home_rounded),
            label: l.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long_outlined),
            activeIcon: const Icon(Icons.receipt_long),
            label: l.orders,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline_rounded),
            activeIcon: const Icon(Icons.person_rounded),
            label: l.profile,
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
    final l = AppLocalizations(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.orders)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long_outlined,
                color: AppColors.steelLight, size: 56),
            const SizedBox(height: 12),
            Text(l.noOrdersYet,
                style: const TextStyle(color: AppColors.steelLight)),
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
    final l = AppLocalizations(context);
    final isProvider = user?.role == 'provider';
    return Scaffold(
      appBar: AppBar(title: Text(l.profile)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(child: _ProfileAvatar(user: user, onEdit: () => context.go('/auth/onboarding'))),
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isProvider
                    ? AppColors.amber.withOpacity(0.15)
                    : AppColors.steel,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                isProvider ? l.iAmProvider : l.iAmClient,
                style: TextStyle(
                    color: isProvider ? AppColors.amber : AppColors.steelLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
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
            title: l.myVehicles,
            onTap: () => context.push('/vehicles'),
          ),
          // Rol almashtirish
          _ProfileTile(
            icon: isProvider ? Icons.person_outline : Icons.handyman_outlined,
            title: isProvider ? l.switchToClient : l.switchToProvider,
            onTap: () => _showRoleSwitchDialog(context, ref, isProvider),
          ),
          _ProfileTile(
            icon: Icons.language_outlined,
            title: l.language,
            onTap: () => _showLanguagePicker(context, ref),
          ),
          _ProfileTile(
            icon: Icons.logout,
            title: l.logout,
            color: AppColors.danger,
            onTap: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }
}

void _showRoleSwitchDialog(BuildContext context, WidgetRef ref, bool isProvider) {
  final l = AppLocalizations(context);
  if (isProvider) {
    // Provider → Client: oddiy dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.charcoal,
        title: Text(l.switchToClient,
            style: const TextStyle(color: AppColors.bone)),
        content: Text(l.switchToClientDesc,
            style: const TextStyle(color: AppColors.steelLight)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel,
                style: const TextStyle(color: AppColors.steelLight)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).updateProfile(role: 'client');
              if (context.mounted) context.go('/home');
            },
            child: Text(l.switchToClient),
          ),
        ],
      ),
    );
  } else {
    // Client → Provider: sektor tanlash sheet
    _showProviderSectorSheet(context, ref);
  }
}

void _showProviderSectorSheet(BuildContext context, WidgetRef ref) {
  final l = AppLocalizations(context);
  String? selectedSector;

  const sectors = [
    ('workshop',     Icons.handyman_outlined,          'Ustaxona / Mexanik'),
    ('parts_store',  Icons.settings_outlined,          "Ehtiyot qismlar do'koni"),
    ('tire_shop',    Icons.trip_origin_outlined,        'Shina va disk'),
    ('oil_store',    Icons.opacity_outlined,            'Moy va suyuqliklar'),
    ('car_wash',     Icons.local_car_wash_outlined,     'Avtoyuv'),
    ('tow_truck',    Icons.rv_hookup_outlined,          'Evakuator'),
    ('tech_support', Icons.build_circle_outlined,       'Texnik yordam'),
  ];

  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.charcoal,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.steelLine,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(l.switchToProvider,
                  style: const TextStyle(
                      color: AppColors.bone,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(l.selectSectorDesc,
                  style: const TextStyle(
                      color: AppColors.steelLight, fontSize: 13)),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: sectors.map((s) {
                  final (key, icon, label) = s;
                  final sel = selectedSector == key;
                  return GestureDetector(
                    onTap: () => setState(() => selectedSector = key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColors.amber.withOpacity(0.12)
                            : AppColors.steel,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: sel ? AppColors.amber : AppColors.steelLine,
                          width: sel ? 1.5 : 1,
                        ),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(icon, size: 16,
                            color: sel ? AppColors.amber : AppColors.steelLight),
                        const SizedBox(width: 6),
                        Text(label,
                            style: TextStyle(
                                fontSize: 13,
                                color: sel ? AppColors.amber : AppColors.bone,
                                fontWeight: sel ? FontWeight.w600 : FontWeight.normal)),
                      ]),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedSector == null
                      ? null
                      : () async {
                          Navigator.pop(ctx);
                          await ref.read(authProvider.notifier).updateProfile(
                              role: 'provider', sector: selectedSector);
                          if (context.mounted) context.go('/provider/home');
                        },
                  child: Text(l.switchToProvider),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
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
    builder: (ctx) {
      final l = AppLocalizations(ctx);
      return SafeArea(
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(l.selectLanguage,
                style: const TextStyle(
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
    );
    },
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
    final isDanger = color == AppColors.danger;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.steelLine),
        ),
        child: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: (isDanger ? AppColors.danger : AppColors.amber).withOpacity(0.14),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: isDanger ? AppColors.danger : AppColors.amber, size: 19),
          ),
          const SizedBox(width: 12),
          Text(title,
              style: TextStyle(
                  color: c, fontSize: 14.5, fontWeight: FontWeight.w600)),
          const Spacer(),
          Icon(Icons.chevron_right,
              color: AppColors.steelLight, size: 18),
        ]),
      ),
    );
  }
}

// ─── Profil avatar ────────────────────────────────────────────────────────────
class _ProfileAvatar extends StatelessWidget {
  final dynamic user;
  final VoidCallback onEdit;
  const _ProfileAvatar({required this.user, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    ImageProvider? img;
    final url = user?.avatarUrl as String?;
    if (url != null && url.startsWith('data:')) {
      try {
        img = MemoryImage(base64Decode(url.split(',').last));
      } catch (_) {}
    }
    final initials = () {
      final n = user?.fullName as String?;
      if (n != null && n.isNotEmpty) return n[0].toUpperCase();
      final p = user?.phone as String?;
      if (p != null && p.length >= 2) return p.substring(p.length - 2);
      return '?';
    }();
    return Stack(alignment: Alignment.bottomRight, children: [
      Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          gradient: AppColors.amberGradient,
          shape: BoxShape.circle,
          boxShadow: AppColors.glow(AppColors.amber),
        ),
        child: CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.charcoal,
          backgroundImage: img,
          child: img == null
              ? Text(initials,
                  style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.bone))
              : null,
        ),
      ),
      GestureDetector(
        onTap: onEdit,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
              color: AppColors.amber,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.asphalt, width: 2)),
          child: const Icon(Icons.edit, color: Color(0xFF1A1100), size: 14),
        ),
      ),
    ]);
  }
}

