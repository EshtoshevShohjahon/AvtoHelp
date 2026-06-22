import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import 'auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phone;
  final bool register;
  const OtpScreen({super.key, required this.phone, this.register = false});
  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  String _code = '';

  Future<void> _verify() async {
    final ok = await ref.read(authProvider.notifier).verifyOtp(
          phone: widget.phone,
          code: _code,
        );
    if (!mounted) return;
    if (ok) {
      final user = ref.read(authProvider).user;
      final isNew = user?.fullName == null || user!.fullName!.trim().isEmpty;
      if (!widget.register && isNew) {
        // Yangi foydalanuvchi "Kirish" tugmasini bosgan — ruxsat yo'q
        await ref.read(authProvider.notifier).logout();
        if (!mounted) return;
        setState(() => _loginError = AppLocalizations(context).notRegisteredError);
        return;
      }
      context.go((widget.register || isNew) ? '/auth/onboarding' : '/home');
    }
  }

  String? _loginError;

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
              const SizedBox(height: 32),

              // OTP kiritish
              Center(
                child: Pinput(
                  length: 6,
                  defaultPinTheme: pinTheme,
                  focusedPinTheme: pinTheme.copyDecorationWith(
                    border: Border.all(color: AppColors.amber, width: 1.5),
                  ),
                  onCompleted: (v) => setState(() => _code = v),
                  onChanged: (v) => setState(() => _code = v),
                ),
              ),

              if (auth.error != null || _loginError != null) ...[
                const SizedBox(height: 16),
                Text(
                    _loginError ?? auth.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.danger)),
              ],

              const SizedBox(height: 32),
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
}
