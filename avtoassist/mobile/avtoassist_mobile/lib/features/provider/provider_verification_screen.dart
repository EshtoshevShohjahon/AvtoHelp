import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../core/network/api_client.dart';
import '../../widgets/app_widgets.dart';

// Usta tasdiqdan (KYC) o'tadi: hujjat raqami + hujjat fotosi + selfi yuboradi.
class ProviderVerificationScreen extends ConsumerStatefulWidget {
  const ProviderVerificationScreen({super.key});
  @override
  ConsumerState<ProviderVerificationScreen> createState() =>
      _ProviderVerificationScreenState();
}

class _ProviderVerificationScreenState
    extends ConsumerState<ProviderVerificationScreen> {
  final _docCtrl = TextEditingController();
  String? _docPhoto;
  String? _selfie;
  bool _loading = false;

  @override
  void dispose() {
    _docCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick(bool isSelfie) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: isSelfie ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 55,
      maxWidth: 1024,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    final ext = file.name.split('.').last.toLowerCase();
    final mime = ext == 'png' ? 'image/png' : 'image/jpeg';
    final b64 = 'data:$mime;base64,${base64Encode(bytes)}';
    setState(() {
      if (isSelfie) {
        _selfie = b64;
      } else {
        _docPhoto = b64;
      }
    });
  }

  bool get _canSubmit =>
      _docCtrl.text.trim().isNotEmpty &&
      _docPhoto != null &&
      _selfie != null &&
      !_loading;

  Future<void> _submit() async {
    setState(() => _loading = true);
    final l = AppLocalizations(context);
    try {
      final res = await ref.read(apiClientProvider).post('/providers/register',
          data: {
            'document_number': _docCtrl.text.trim(),
            'document_photo_url': _docPhoto,
            'selfie_url': _selfie,
          });
      if (!mounted) return;
      final approved = res.data['kyc']?['approved'] == true;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            approved ? l.verificationApproved : l.verificationRejected),
        backgroundColor: approved ? AppColors.teal : AppColors.danger,
      ));
      if (approved) context.pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()), backgroundColor: AppColors.danger));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.getVerified),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
              ),
              child: Row(children: [
                const Icon(Icons.verified_user_outlined,
                    color: AppColors.teal, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(l.verificationDesc,
                      style: const TextStyle(
                          color: AppColors.steelLight, fontSize: 12)),
                ),
              ]),
            ),
            const SizedBox(height: 20),

            Text(l.documentNumber,
                style: const TextStyle(
                    color: AppColors.steelLight, fontSize: 12)),
            const SizedBox(height: 8),
            TextField(
              controller: _docCtrl,
              style: const TextStyle(color: AppColors.bone),
              textCapitalization: TextCapitalization.characters,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'AB1234567',
                prefixIcon: Icon(Icons.badge_outlined, color: AppColors.amber),
              ),
            ),
            const SizedBox(height: 20),

            _UploadTile(
              label: l.uploadDocument,
              icon: Icons.description_outlined,
              done: _docPhoto != null,
              onTap: () => _pick(false),
            ),
            const SizedBox(height: 12),
            _UploadTile(
              label: l.uploadSelfie,
              icon: Icons.camera_alt_outlined,
              done: _selfie != null,
              onTap: () => _pick(true),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canSubmit ? _submit : null,
                child: _loading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.asphalt))
                    : Text(l.submitVerification),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _UploadTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool done;
  final VoidCallback onTap;
  const _UploadTile({
    required this.label,
    required this.icon,
    required this.done,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.charcoal,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: done
                  ? AppColors.teal.withValues(alpha: 0.5)
                  : AppColors.steelLine),
        ),
        child: Row(children: [
          Icon(icon, color: done ? AppColors.teal : AppColors.amber, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.bone, fontSize: 14)),
          ),
          Icon(
            done ? Icons.check_circle : Icons.add_circle_outline,
            color: done ? AppColors.teal : AppColors.steelLight,
            size: 22,
          ),
        ]),
      ),
    );
  }
}
