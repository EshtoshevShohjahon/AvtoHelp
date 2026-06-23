import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/network/api_client.dart';
import '../../core/models/models.dart';
import '../../widgets/app_widgets.dart';
import 'vehicle_detail_screen.dart';

// ─── Avtomobillar ro'yxati ──────────────────────────────────
class VehiclesScreen extends ConsumerStatefulWidget {
  const VehiclesScreen({super.key});
  @override
  ConsumerState<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends ConsumerState<VehiclesScreen> {
  bool _loading = true;
  List<VehicleModel> _vehicles = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.get('/users/me/vehicles');
      final list = (res.data['vehicles'] as List)
          .map((e) => VehicleModel.fromJson(e))
          .toList();
      if (!mounted) return;
      setState(() { _vehicles = list; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _delete(VehicleModel v) async {
    try {
      final api = ref.read(apiClientProvider);
      await api.delete('/users/me/vehicles/${v.id}');
      _load();
    } catch (_) {}
  }

  Future<void> _openAdd() async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddVehicleScreen()),
    );
    if (added == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.myVehicles)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAdd,
        backgroundColor: AppColors.amber,
        icon: const Icon(Icons.add, color: Color(0xFF1A1100)),
        label: Text(l.addVehicle,
            style: const TextStyle(color: Color(0xFF1A1100))),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.amber))
          : _vehicles.isEmpty
              ? _EmptyState(message: l.noVehicles)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _vehicles.length,
                    itemBuilder: (_, i) => _VehicleCard(
                      vehicle: _vehicles[i],
                      onDelete: () => _delete(_vehicles[i]),
                    ),
                  ),
                ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final VehicleModel vehicle;
  final VoidCallback onDelete;
  const _VehicleCard({required this.vehicle, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VehicleDetailScreen(
            vehicleId: vehicle.id!,
            vehicleTitle: vehicle.title,
          ),
        ),
      ),
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.steelLine),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: AppColors.steel,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.directions_car_rounded,
              color: AppColors.amber, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(vehicle.title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.bone,
                    fontSize: 15)),
            const SizedBox(height: 3),
            Text(
              [
                vehicle.plateNumber,
                if (vehicle.year != null) '${vehicle.year}',
                if (vehicle.color != null) vehicle.color!,
              ].join(' • '),
              style: const TextStyle(color: AppColors.steelLight, fontSize: 12),
            ),
          ]),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.danger),
          onPressed: onDelete,
        ),
        const Icon(Icons.chevron_right, color: AppColors.steelLight, size: 18),
      ]),
    ),
    );
  }
}

// ─── Avtomobil qo'shish (texpassport orqali) ───────────────────────
class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key});
  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  final _techCtrl = TextEditingController();
  bool _looking = false;
  bool _saving = false;
  String? _error;
  VehicleModel? _found;

  @override
  void dispose() {
    _techCtrl.dispose();
    super.dispose();
  }

  // Texpassport raqami bo'yicha ma'lumotlar bazasidan avtomobil ma'lumotlarini yuklab oladi
  Future<void> _lookup() async {
    final tp = _techCtrl.text.trim();
    if (tp.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() { _looking = true; _error = null; _found = null; });
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.get('/users/me/vehicles/lookup',
          query: {'tech_passport': tp});
      if (!mounted) return;
      setState(() {
        _found = VehicleModel.fromJson(res.data['vehicle']);
        _looking = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _looking = false;
        _error = AppLocalizations(context).vehicleNotFound;
      });
    }
  }

  Future<void> _save() async {
    if (_found == null) return;
    setState(() { _saving = true; _error = null; });
    try {
      final api = ref.read(apiClientProvider);
      await api.post('/users/me/vehicles',
          data: {'tech_passport': _found!.techPassport});
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() { _saving = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.addVehicle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _techCtrl,
                style: const TextStyle(color: AppColors.bone),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
                  UpperCaseFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: l.techPassport,
                  hintText: l.techPassportHint,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _looking ? null : _lookup,
                icon: _looking
                    ? const SizedBox(
                        height: 16, width: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.amber))
                    : const Icon(Icons.cloud_download_outlined),
                label: Text(l.fetchFromRegistry),
              ),

              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!,
                    style: const TextStyle(color: AppColors.danger)),
              ],

              if (_found != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.teal.withOpacity(0.4)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Icon(Icons.check_circle_outline,
                          color: AppColors.teal, size: 20),
                      const SizedBox(width: 8),
                      Text(l.vehicleFound,
                          style: const TextStyle(
                              color: AppColors.teal,
                              fontWeight: FontWeight.w600)),
                    ]),
                    const SizedBox(height: 14),
                    _Field(label: l.brand, value: _found!.brand),
                    _Field(label: l.model, value: _found!.model),
                    _Field(label: l.plateNumber, value: _found!.plateNumber),
                    if (_found!.year != null)
                      _Field(label: l.year, value: '${_found!.year}'),
                    if (_found!.color != null)
                      _Field(label: l.color, value: _found!.color!),
                  ]),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.asphalt))
                      : Text(l.save),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;
  const _Field({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        SizedBox(
          width: 120,
          child: Text(label,
              style: const TextStyle(color: AppColors.steelLight, fontSize: 13)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  color: AppColors.bone, fontWeight: FontWeight.w500)),
        ),
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.directions_car_outlined,
              color: AppColors.steelLight, size: 56),
          const SizedBox(height: 12),
          Text(message,
              style: const TextStyle(color: AppColors.steelLight)),
        ],
      ),
    );
  }
}

class UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
