import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import 'auth_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0; // 0=ism, 1=rol, [2=sektor(provider)], 2/3=rasm
  final _nameCtrl = TextEditingController();
  String _role = 'client';
  String? _sector;
  String? _avatarBase64;

  int get _totalSteps => _role == 'provider' ? 4 : 3;

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 60, maxWidth: 400);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    final ext = file.name.split('.').last.toLowerCase();
    final mime = ext == 'png' ? 'image/png' : 'image/jpeg';
    setState(() {
      _avatarBase64 = 'data:$mime;base64,${base64Encode(bytes)}';
    });
  }

  Future<void> _finish() async {
    final ok = await ref.read(authProvider.notifier).updateProfile(
          fullName: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
          role: _role,
          avatarUrl: _avatarBase64,
          sector: _sector,
        );
    if (!mounted) return;
    if (ok) {
      context.go(_role == 'provider' ? '/provider/home' : '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final l = AppLocalizations(context);

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          // Progressbar
          LinearProgressIndicator(
            value: (_step + 1) / _totalSteps,
            backgroundColor: AppColors.steelLine,
            valueColor: const AlwaysStoppedAnimation(AppColors.amber),
            minHeight: 3,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildStep(),
              ),
            ),
          ),
          // Xato
          if (auth.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(auth.error!,
                  style: const TextStyle(color: AppColors.danger, fontSize: 13),
                  textAlign: TextAlign.center),
            ),
          // Tugmalar
          Padding(
            padding:
                const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Row(children: [
              if (_step > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _step--),
                    child: Text(l.back),
                  ),
                ),
              if (_step > 0) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _canNext(auth.isLoading)
                      ? () {
                          if (_step < _totalSteps - 1) {
                            setState(() => _step++);
                          } else {
                            _finish();
                          }
                        }
                      : null,
                  child: auth.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.asphalt))
                      : Text(_step < _totalSteps - 1 ? l.continueBtn : l.saveProfile),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildStep() {
    if (_step == 0) return _NameStep(ctrl: _nameCtrl, key: const ValueKey(0));
    if (_step == 1) return _RoleStep(role: _role, onChanged: (r) => setState(() { _role = r; _sector = null; }), key: const ValueKey(1));
    if (_step == 2 && _role == 'provider') return _SectorStep(sector: _sector, onChanged: (s) => setState(() => _sector = s), key: const ValueKey(2));
    return _AvatarStep(avatarBase64: _avatarBase64, onPick: _pickImage, key: ValueKey(_role == 'provider' ? 3 : 2));
  }

  bool _canNext(bool loading) {
    if (loading) return false;
    if (_step == 0) return _nameCtrl.text.trim().length >= 2;
    if (_step == 2 && _role == 'provider') return _sector != null;
    return true;
  }
}

// ─── Qadam 1: Ism ────────────────────────────────────────────────────────────
class _NameStep extends StatelessWidget {
  final TextEditingController ctrl;
  const _NameStep({required this.ctrl, super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l.enterYourName,
          style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.bone)),
      const SizedBox(height: 6),
      Text(l.nameShownInProfile,
          style: const TextStyle(color: AppColors.steelLight, fontSize: 14)),
      const SizedBox(height: 32),
      TextField(
        controller: ctrl,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        style: const TextStyle(color: AppColors.bone),
        decoration: InputDecoration(
          hintText: l.namePlaceholder,
          prefixIcon: const Icon(Icons.person_outline, color: AppColors.amber),
        ),
      ),
    ]);
  }
}

// ─── Qadam 2: Rol ────────────────────────────────────────────────────────────
class _RoleStep extends StatelessWidget {
  final String role;
  final void Function(String) onChanged;
  const _RoleStep({required this.role, required this.onChanged, super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l.selectYourRole,
          style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.bone)),
      const SizedBox(height: 6),
      Text(l.roleChangeHint,
          style: const TextStyle(color: AppColors.steelLight, fontSize: 14)),
      const SizedBox(height: 32),
      _RoleCard(
        selected: role == 'client',
        icon: Icons.directions_car_outlined,
        title: l.iAmClient,
        desc: l.clientRoleDesc,
        onTap: () => onChanged('client'),
      ),
      const SizedBox(height: 12),
      _RoleCard(
        selected: role == 'provider',
        icon: Icons.handyman_outlined,
        title: l.iAmProvider,
        desc: l.providerRoleDesc,
        onTap: () => onChanged('provider'),
      ),
    ]);
  }
}

class _RoleCard extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String title;
  final String desc;
  final VoidCallback onTap;
  const _RoleCard(
      {required this.selected,
      required this.icon,
      required this.title,
      required this.desc,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.amber.withOpacity(0.12) : AppColors.charcoal,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selected ? AppColors.amber : AppColors.steelLine,
              width: selected ? 1.5 : 1),
        ),
        child: Row(children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.amber.withOpacity(0.2)
                  : AppColors.steel,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon,
                color: selected ? AppColors.amber : AppColors.boneDim,
                size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: selected ? AppColors.amber : AppColors.bone,
                          fontSize: 15)),
                  const SizedBox(height: 3),
                  Text(desc,
                      style: const TextStyle(
                          color: AppColors.steelLight, fontSize: 12)),
                ]),
          ),
          if (selected)
            const Icon(Icons.check_circle, color: AppColors.amber, size: 20),
        ]),
      ),
    );
  }
}

// ─── Qadam 3 (provider): Sektor tanlash ──────────────────────────────────────
class _SectorStep extends StatelessWidget {
  final String? sector;
  final void Function(String) onChanged;
  const _SectorStep({required this.sector, required this.onChanged, super.key});

  static const _sectors = [
    ('workshop',    Icons.handyman_outlined,          'Ustaxona / Mexanik'),
    ('parts_store', Icons.settings_outlined,          'Ehtiyot qismlar do\'koni'),
    ('tire_shop',   Icons.trip_origin_outlined,       'Shina va disk'),
    ('oil_store',   Icons.opacity_outlined,           'Moy va suyuqliklar'),
    ('car_wash',    Icons.local_car_wash_outlined,    'Avtoyuv'),
    ('tow_truck',   Icons.rv_hookup_outlined,         'Evakuator'),
    ('tech_support',Icons.build_circle_outlined,      'Texnik yordam (yo\'lda)'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Qaysi sohadaSiz?',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.bone)),
      const SizedBox(height: 6),
      const Text('Mijozlar sizni tezroq topsin',
          style: TextStyle(color: AppColors.steelLight, fontSize: 14)),
      const SizedBox(height: 24),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _sectors.map((s) {
          final (key, icon, label) = s;
          final sel = sector == key;
          return GestureDetector(
            onTap: () => onChanged(key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: sel ? AppColors.amber.withOpacity(0.12) : AppColors.charcoal,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: sel ? AppColors.amber : AppColors.steelLine,
                    width: sel ? 1.5 : 1),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(icon, size: 18, color: sel ? AppColors.amber : AppColors.steelLight),
                const SizedBox(width: 8),
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
    ]);
  }
}

// ─── Qadam 3: Profil rasmi ───────────────────────────────────────────────────
class _AvatarStep extends StatelessWidget {
  final String? avatarBase64;
  final VoidCallback onPick;
  const _AvatarStep(
      {required this.avatarBase64, required this.onPick, super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context);
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          Text(l.addProfilePhoto,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.bone),
              textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(l.photoOptional,
              style: const TextStyle(color: AppColors.steelLight, fontSize: 14),
              textAlign: TextAlign.center),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: onPick,
            child: Stack(children: [
              CircleAvatar(
                radius: 64,
                backgroundColor: AppColors.steel,
                backgroundImage: avatarBase64 != null
                    ? MemoryImage(
                        base64Decode(avatarBase64!.split(',').last))
                    : null,
                child: avatarBase64 == null
                    ? const Icon(Icons.person_outline,
                        color: AppColors.boneDim, size: 48)
                    : null,
              ),
              Positioned(
                right: 4,
                bottom: 4,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt,
                      color: Color(0xFF1A1100), size: 16),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: onPick,
            child: Text(l.chooseFromGallery,
                style: const TextStyle(color: AppColors.amber)),
          ),
        ]);
  }
}
