import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../core/network/api_client.dart';
import '../../widgets/app_widgets.dart';
import 'auth_provider.dart';

class KycScreen extends ConsumerStatefulWidget {
  final String serviceType;
  const KycScreen({super.key, required this.serviceType});
  @override
  ConsumerState<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends ConsumerState<KycScreen> {
  final _docNumberCtrl = TextEditingController();
  final _fullNameCtrl  = TextEditingController();
  bool _hasDocPhoto = false;
  bool _hasSelfie   = false;
  bool _loading     = false;
  String? _result;
  bool _approved    = false;

  Future<void> _pickDoc() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.camera);
    if (img != null) setState(() => _hasDocPhoto = true);
  }

  Future<void> _pickSelfie() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(
        source: ImageSource.camera, preferredCameraDevice: CameraDevice.front);
    if (img != null) setState(() => _hasSelfie = true);
  }

  Future<void> _submit() async {
    if (_docNumberCtrl.text.isEmpty || _fullNameCtrl.text.isEmpty) return;
    setState(() { _loading = true; _result = null; });
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.post('/providers/register', data: {
        'service_type':       widget.serviceType,
        'document_number':    _docNumberCtrl.text.trim(),
        'full_name':          _fullNameCtrl.text.trim(),
        'has_document_photo': _hasDocPhoto,
        'has_selfie':         _hasSelfie,
      });
      setState(() {
        _loading  = false;
        _approved = true;
        _result   = res.data['message'];
      });
    } catch (e) {
      setState(() {
        _loading  = false;
        _approved = false;
        _result   = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _docNumberCtrl.dispose();
    _fullNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.kycTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.teal.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.teal.withOpacity(0.3)),
                ),
                child: Row(children: [
                  const Icon(Icons.verified_user_outlined, color: AppColors.teal),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(l.kycDesc,
                        style: const TextStyle(
                            color: AppColors.boneDim, fontSize: 13)),
                  ),
                ]),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _fullNameCtrl,
                style: const TextStyle(color: AppColors.bone),
                decoration: const InputDecoration(labelText: 'F.I.Sh'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _docNumberCtrl,
                style: const TextStyle(color: AppColors.bone),
                decoration: const InputDecoration(labelText: 'Pasport raqami (AB1234567)'),
              ),
              const SizedBox(height: 24),
              _UploadTile(
                icon: Icons.credit_card_outlined,
                label: l.kycDocPhoto,
                done: _hasDocPhoto,
                onTap: _pickDoc,
              ),
              const SizedBox(height: 12),
              _UploadTile(
                icon: Icons.face_outlined,
                label: l.kycSelfie,
                done: _hasSelfie,
                onTap: _pickSelfie,
              ),
              const SizedBox(height: 28),
              if (_result != null)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _approved
                        ? AppColors.teal.withOpacity(0.1)
                        : AppColors.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: _approved ? AppColors.teal : AppColors.danger),
                  ),
                  child: Column(children: [
                    Icon(_approved ? Icons.check_circle_outline : Icons.error_outline,
                        color: _approved ? AppColors.teal : AppColors.danger,
                        size: 40),
                    const SizedBox(height: 10),
                    Text(_result!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: _approved ? AppColors.teal : AppColors.danger)),
                    if (_approved) ...[  
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.go('/provider/home'),
                        child: Text(l.done),
                      ),
                    ],
                  ]),
                ),
              if (_result == null)
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.asphalt))
                      : Text(l.kycSubmit),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UploadTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool done;
  final VoidCallback onTap;
  const _UploadTile(
      {required this.icon,
      required this.label,
      required this.done,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: done
              ? AppColors.teal.withOpacity(0.08)
              : AppColors.charcoal,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: done ? AppColors.teal : AppColors.steelLine),
        ),
        child: Row(children: [
          Icon(icon, color: done ? AppColors.teal : AppColors.steelLight),
          const SizedBox(width: 12),
          Expanded(child: Text(label,
              style: TextStyle(
                  color: done ? AppColors.teal : AppColors.boneDim))),
          Icon(done ? Icons.check_circle : Icons.camera_alt_outlined,
              color: done ? AppColors.teal : AppColors.steelLight),
        ]),
      ),
    );
  }
}
