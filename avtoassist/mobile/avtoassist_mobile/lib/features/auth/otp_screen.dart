import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../core/theme/app_theme.dart';
import '../../core/network/api_client.dart';
import '../../widgets/app_widgets.dart';
import 'auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});
  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  String _role = 'client';
  String _serviceType = 'tech_support';
  String _code = '';

  final _roles = [
    {'key': 'client',   'icon': Icons.person_outline},
    {'key': 'provider', 'icon': Icons.handyman_outlined},
  ];

  final _serviceTypes = [
    {'key': 'tech_support', 'icon': Icons.build_outlined},
    {'key': 'tow_truck',    'icon': Icons.local_shipping_outlined},
    {'key': 'fuel',         'icon': Icons.local_gas_station_outlined},
    {'key': 'car_wash',     'icon': Icons.water_drop_outlined},
  ];

  Future<void> _verify() async {
    final lang = 'uz';
    final ok = await ref.read(authProvider.notifier).verifyOtp(
          phone: widget.phone,
          code: _code,
          role: _role,
          lang: lang,
        );
    if (!mounted) return;
    if (ok) {
      if (_role == 'provider') {
        context.go('/kyc', extra: _serviceType);
      } else {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final l = AppLocalizations(context);

    final pinTheme = PinTheme(
      width: 52, height: 56,
      textStyle: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.bone),
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.steelLine),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(l.enterCode,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.bone)),
              const SizedBox(height: 4),
              Text(widget.phone,
                  style: const TextStyle(
                      color: AppColors.steelLight, fontSize: 14)),
              const SizedBox(height: 28),
              Center(
                child: Pinput(
                  length: 6,
                  defaultPinTheme: pinTheme,
                  focusedPinTheme: pinTheme.copyDecorationWith(
                    border: Border.all(color: AppColors.amber, width: 1.5),
                  ),
                  onCompleted: (v) => setState(() => _code = v),
                ),
              ),
              const SizedBox(height: 32),
              Text(l.selectRole,
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.steelLight,
                      letterSpacing: 0.5)),
              const SizedBox(height: 10),
              ..._roles.map((r) => _RoleCard(
                    selected: _role == r['key'],
                    icon: r['icon'] as IconData,
                    title: r['key'] == 'client' ? l.roleClient : l.roleProvider,
                    subtitle: r['key'] == 'client'
                        ? l.roleClientDesc
                        : l.roleProviderDesc,
                    onTap: () => setState(() => _role = r['key'] as String),
                  )),
              if (_role == 'provider') ...[  
                const SizedBox(height: 20),
                Text(l.selectServiceType,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.steelLight,
                        letterSpacing: 0.5)),
                const SizedBox(height: 10),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.8,
                  children: _serviceTypes
                      .map((s) => _ServiceTypeChip(
                            selected: _serviceType == s['key'],
                            icon: s['icon'] as IconData,
                            label: _serviceLabel(l, s['key'] as String),
                            onTap: () =>
                                setState(() => _serviceType = s['key'] as String),
                          ))
                      .toList(),
                ),
              ],
              if (auth.error != null) ...[  
                const SizedBox(height: 12),
                Text(auth.error!,
                    style: const TextStyle(color: AppColors.danger)),
              ],
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: (_code.length == 6 && !auth.isLoading) ? _verify : null,
                child: auth.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.asphalt))
                    : Text(l.continueBtn),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _serviceLabel(AppLocalizations l, String key) {
    switch (key) {
      case 'tech_support': return l.serviceTechSupport;
      case 'tow_truck':    return l.serviceTowTruck;
      case 'fuel':         return l.serviceFuel;
      case 'car_wash':     return l.serviceCarWash;
      default:             return key;
    }
  }
}

class _RoleCard extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _RoleCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.amber.withOpacity(0.08)
              : AppColors.charcoal,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.amber : AppColors.steelLine,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: selected ? AppColors.amber : AppColors.steel,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon,
                color: selected ? const Color(0xFF1A1100) : AppColors.boneDim,
                size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: selected ? AppColors.amber : AppColors.bone,
                      fontSize: 14)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(
                      color: AppColors.boneDim, fontSize: 12)),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _ServiceTypeChip extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ServiceTypeChip(
      {required this.selected,
      required this.icon,
      required this.label,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.amber.withOpacity(0.12)
              : AppColors.charcoal,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selected ? AppColors.amber : AppColors.steelLine),
        ),
        child: Row(children: [
          Icon(icon,
              size: 16,
              color: selected ? AppColors.amber : AppColors.steelLight),
          const SizedBox(width: 8),
          Flexible(
            child: Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: selected ? AppColors.amber : AppColors.boneDim),
                overflow: TextOverflow.ellipsis),
          ),
        ]),
      ),
    );
  }
}
