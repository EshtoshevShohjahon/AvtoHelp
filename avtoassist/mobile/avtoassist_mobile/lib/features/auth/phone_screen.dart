import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import 'auth_provider.dart';

class PhoneScreen extends ConsumerStatefulWidget {
  const PhoneScreen({super.key});
  @override
  ConsumerState<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends ConsumerState<PhoneScreen> {
  final _controller = TextEditingController();
  String _digits = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final phone = '+998${_controller.text.replaceAll(RegExp(r'\D'), '')}';
    final debugCode = await ref.read(authProvider.notifier).sendOtp(phone);
    if (!mounted) return;
    if (debugCode != null) {
      // Debug rejimida: kodni snackbar'da ko'rsatamiz
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Debug OTP: $debugCode'),
          backgroundColor: AppColors.teal,
        ),
      );
    }
    final err = ref.read(authProvider).error;
    if (err == null) {
      context.go('/auth/otp', extra: phone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final l = AppLocalizations(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppLogo(),
              const SizedBox(height: 48),
              Text(l.phoneNumber,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.steelLight,
                      letterSpacing: 0.5)),
              const SizedBox(height: 8),
              Row(children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.charcoal,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.steelLine),
                  ),
                  child: const Text('+998',
                      style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 15,
                          color: AppColors.boneDim)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 15,
                        color: AppColors.bone),
                    maxLength: 9,
                    onChanged: (v) => setState(() =>
                        _digits = v.replaceAll(RegExp(r'\D'), '')),
                    decoration: const InputDecoration(
                      hintText: 'XX XXX XX XX',
                      counterText: '',
                    ),
                  ),
                ),
              ]),
              if (auth.error != null) ...[
                const SizedBox(height: 12),
                Text(auth.error!,
                    style: const TextStyle(color: AppColors.danger)),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: (auth.isLoading || _digits.length < 9) ? null : _send,
                child: auth.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.asphalt))
                    : Text(l.sendCode),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
