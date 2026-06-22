import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/network/api_client.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/vehicles/vehicle_detail_screen.dart';
import '../../widgets/app_widgets.dart';

// ─── Provider bosh ekrani ────────────────────────────────────────────────────
class ProviderHomeScreen extends ConsumerStatefulWidget {
  const ProviderHomeScreen({super.key});
  @override
  ConsumerState<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends ConsumerState<ProviderHomeScreen> {
  final _passportCtrl = TextEditingController();
  bool _searching = false;
  String? _error;
  Map<String, dynamic>? _foundVehicle;
  List<dynamic> _records = [];
  Map<String, dynamic>? _oilAlert;

  @override
  void dispose() {
    _passportCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final tp = _passportCtrl.text.trim().toUpperCase();
    if (tp.isEmpty) return;
    setState(() { _searching = true; _error = null; _foundVehicle = null; });
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.get('/providers/vehicle-lookup',
          query: {'tech_passport': tp});
      setState(() {
        _foundVehicle = res.data['vehicle'];
        _records = res.data['records'] ?? [];
        _oilAlert = res.data['oil_alert'];
        _searching = false;
      });
    } catch (e) {
      setState(() {
        _searching = false;
        _error = e.toString().contains('404')
            ? 'Avtomobil topilmadi. Tex passport to\'g\'ri kiritilganini tekshiring.'
            : e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final l = AppLocalizations(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.providerPanel),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                user?.fullName?.split(' ').first ?? 'Usta',
                style: const TextStyle(color: AppColors.amber, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Qidirish paneli
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.charcoal,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.steelLine),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.search, color: AppColors.amber, size: 18),
                const SizedBox(width: 8),
                Text(l.searchClientVehicle,
                    style: const TextStyle(
                        color: AppColors.bone,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
              ]),
              const SizedBox(height: 4),
              Text(l.enterTechPassport,
                  style: const TextStyle(color: AppColors.steelLight, fontSize: 12)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _passportCtrl,
                    style: const TextStyle(
                        color: AppColors.bone,
                        fontFamily: 'monospace',
                        letterSpacing: 1.5),
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      hintText: 'AAF1234567',
                      prefixIcon: Icon(Icons.credit_card_outlined,
                          color: AppColors.amber),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _searching ? null : _search,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                  child: _searching
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.asphalt))
                      : const Icon(Icons.search, size: 20),
                ),
              ]),
            ]),
          ),

          // Xatolik
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.danger.withOpacity(0.4)),
              ),
              child: Row(children: [
                const Icon(Icons.error_outline,
                    color: AppColors.danger, size: 20),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(_error!,
                        style: const TextStyle(
                            color: AppColors.danger, fontSize: 13))),
              ]),
            ),
          ],

          // Topilgan avtomobil
          if (_foundVehicle != null) ...[
            const SizedBox(height: 16),
            _VehicleInfoCard(
              vehicle: _foundVehicle!,
              oilAlert: _oilAlert,
              records: _records,
              onAddRecord: () async {
                final added = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _ProviderAddRecordScreen(
                      vehicleId: _foundVehicle!['id'],
                      vehicleTitle:
                          '${_foundVehicle!['brand']} ${_foundVehicle!['model']}',
                    ),
                  ),
                );
                if (added == true) _search();
              },
            ),
          ],

          if (_foundVehicle == null && !_searching && _error == null) ...[
            const SizedBox(height: 48),
            const Center(
              child: Column(children: [
                Icon(Icons.car_repair, color: AppColors.steelLine, size: 64),
                SizedBox(height: 16),
                Text(l.vehicleLookupHint,
                    style: const TextStyle(
                        color: AppColors.steelLight, fontSize: 14),
                    textAlign: TextAlign.center),
              ]),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Topilgan avtomobil kartasi + tarix ──────────────────────────────────────
class _VehicleInfoCard extends StatelessWidget {
  final Map<String, dynamic> vehicle;
  final Map<String, dynamic>? oilAlert;
  final List<dynamic> records;
  final VoidCallback onAddRecord;

  const _VehicleInfoCard({
    required this.vehicle,
    required this.oilAlert,
    required this.records,
    required this.onAddRecord,
  });

  @override
  Widget build(BuildContext context) {
    final brand = vehicle['brand'] ?? '';
    final model = vehicle['model'] ?? '';
    final plate = vehicle['plate_number'] ?? '';
    final year = vehicle['year'];
    final currentKm = vehicle['current_odometer'] ?? 0;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Avtomobil sarlavhasi
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.teal.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.teal.withOpacity(0.4)),
        ),
        child: Row(children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.teal.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.directions_car_rounded,
                color: AppColors.teal, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$brand $model',
                  style: const TextStyle(
                      color: AppColors.bone,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              const SizedBox(height: 3),
              Text(
                [
                  plate,
                  if (year != null) '$year-yil',
                  '$currentKm km',
                ].join(' · '),
                style: const TextStyle(
                    color: AppColors.steelLight, fontSize: 12),
              ),
            ]),
          ),
          const Icon(Icons.check_circle, color: AppColors.teal, size: 22),
        ]),
      ),

      // Moy eslatmasi
      if (oilAlert != null) ...[
        const SizedBox(height: 10),
        _OilAlertBanner(alert: oilAlert!),
      ],

      const SizedBox(height: 16),

      // Xizmat qo'shish tugmasi
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onAddRecord,
          icon: const Icon(Icons.add_circle_outline, size: 18),
          label: Text(AppLocalizations(context).addServiceRecord),
        ),
      ),

      const SizedBox(height: 16),

      // Tarix
      Builder(builder: (ctx) {
        final l = AppLocalizations(ctx);
        return Row(children: [
          Text(l.serviceHistory,
              style: const TextStyle(
                  color: AppColors.bone,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(l.recordsCount(records.length),
              style: const TextStyle(
                  color: AppColors.steelLight, fontSize: 12)),
        ]);
      }),
      const SizedBox(height: 10),

      if (records.isEmpty)
        Builder(builder: (ctx) => Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.charcoal,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.steelLine),
          ),
          child: Center(
            child: Text(AppLocalizations(ctx).noServiceHistory,
                style: const TextStyle(color: AppColors.steelLight)),
          ),
        ))
      else
        ...records.map((r) => ServiceRecordModel.fromJson(r)).map(
              (r) => _HistoryTile(record: r),
            ),
    ]);
  }
}

// ─── Moy ogohlantirish banner ─────────────────────────────────────────────────
class _OilAlertBanner extends StatelessWidget {
  final Map<String, dynamic> alert;
  const _OilAlertBanner({required this.alert});

  @override
  Widget build(BuildContext context) {
    final isUrgent = alert['alert'] == true;
    final kmLeft = alert['km_left'] ?? 0;
    final color = isUrgent ? AppColors.danger : AppColors.amber;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(children: [
        Icon(isUrgent ? Icons.warning_amber_rounded : Icons.oil_barrel_outlined,
            color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            isUrgent
                ? '⚠️ MOY ALMASHTIRISH KERAK! $kmLeft km qoldi'
                : '🛢️ Keyingi moy: $kmLeft km qoldi',
            style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600),
          ),
        ),
      ]),
    );
  }
}

// ─── Tarix qatori ─────────────────────────────────────────────────────────────
class _HistoryTile extends StatelessWidget {
  final ServiceRecordModel record;
  const _HistoryTile({required this.record});

  static const _labels = {
    'oil_change': 'Moy almashtirish',
    'inspection': 'Tex ko\'rik',
    'tire': 'Shina',
    'brake': 'Tormoz',
    'engine': 'Dvigatel',
    'battery': 'Akkumulyator',
    'transmission': 'Karobka',
    'other': 'Boshqa',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.steelLine),
      ),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.steel,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.build_outlined,
              color: AppColors.amber, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_labels[record.serviceType] ?? 'Boshqa',
                style: const TextStyle(
                    color: AppColors.bone,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(
              [
                record.serviceDate,
                '${record.odometerKm} km',
                if (record.workshopName != null) record.workshopName!,
              ].join(' · '),
              style: const TextStyle(
                  color: AppColors.steelLight, fontSize: 11),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ─── Provider tomonidan xizmat qo'shish ──────────────────────────────────────
class _ProviderAddRecordScreen extends ConsumerStatefulWidget {
  final String vehicleId;
  final String vehicleTitle;
  const _ProviderAddRecordScreen(
      {required this.vehicleId, required this.vehicleTitle});

  @override
  ConsumerState<_ProviderAddRecordScreen> createState() =>
      _ProviderAddRecordScreenState();
}

class _ProviderAddRecordScreenState
    extends ConsumerState<_ProviderAddRecordScreen> {
  String _serviceType = 'inspection';
  final _dateCtrl = TextEditingController(
      text: DateTime.now().toIso8601String().split('T').first);
  final _odometerCtrl = TextEditingController();
  final _workshopCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _nextKmCtrl = TextEditingController();
  bool _loading = false;

  static const _typeKeys = [
    'oil_change', 'inspection', 'tire', 'brake',
    'engine', 'battery', 'transmission', 'other',
  ];

  @override
  void dispose() {
    _dateCtrl.dispose();
    _odometerCtrl.dispose();
    _workshopCtrl.dispose();
    _costCtrl.dispose();
    _notesCtrl.dispose();
    _nextKmCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.amber),
        ),
        child: child!,
      ),
    );
    if (d != null) {
      setState(() => _dateCtrl.text = d.toIso8601String().split('T').first);
    }
  }

  Future<void> _save() async {
    if (_odometerCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final api = ref.read(apiClientProvider);
      final user = ref.read(authProvider).user;
      await api.post(
        '/providers/vehicle-lookup/${widget.vehicleId}/service-records',
        data: {
          'service_type': _serviceType,
          'service_date': _dateCtrl.text.trim(),
          'odometer_km': int.tryParse(_odometerCtrl.text.trim()) ?? 0,
          if (_workshopCtrl.text.isNotEmpty)
            'workshop_name': _workshopCtrl.text.trim(),
          'mechanic_name': user?.fullName ?? '',
          if (_costCtrl.text.isNotEmpty)
            'cost': double.tryParse(_costCtrl.text.trim()),
          if (_notesCtrl.text.isNotEmpty) 'notes': _notesCtrl.text.trim(),
          if (_serviceType == 'oil_change' && _nextKmCtrl.text.isNotEmpty)
            'next_service_km': int.tryParse(_nextKmCtrl.text.trim()),
        },
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.danger));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vehicleTitle,
            style: const TextStyle(fontSize: 15)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(AppLocalizations(context).addServiceRecord,
                style: TextStyle(
                    color: AppColors.amber.withOpacity(0.8),
                    fontSize: 12)),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Xizmat turi
            Text(AppLocalizations(context).serviceType,
                style: const TextStyle(color: AppColors.steelLight, fontSize: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _typeKeys.map((key) {
                final sel = _serviceType == key;
                final label = AppLocalizations(context).serviceTypeLabel(key);
                return GestureDetector(
                  onTap: () => setState(() => _serviceType = key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel
                          ? AppColors.amber.withOpacity(0.15)
                          : AppColors.charcoal,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color:
                              sel ? AppColors.amber : AppColors.steelLine),
                    ),
                    child: Text(label,
                        style: TextStyle(
                            color: sel
                                ? AppColors.amber
                                : AppColors.boneDim,
                            fontSize: 13,
                            fontWeight: sel
                                ? FontWeight.w600
                                : FontWeight.normal)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Sana
            GestureDetector(
              onTap: _pickDate,
              child: TextField(
                controller: _dateCtrl,
                enabled: false,
                style: const TextStyle(color: AppColors.bone),
                decoration: InputDecoration(
                  labelText: AppLocalizations(context).dateLabel,
                  prefixIcon: const Icon(Icons.calendar_today_outlined,
                      color: AppColors.amber),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Km
            TextField(
              controller: _odometerCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.bone),
              decoration: InputDecoration(
                labelText: AppLocalizations(context).odometerKm,
                hintText: '45000',
                prefixIcon:
                    Icon(Icons.speed_outlined, color: AppColors.amber),
                suffixText: 'km',
              ),
            ),
            const SizedBox(height: 14),

            if (_serviceType == 'oil_change') ...[
              TextField(
                controller: _nextKmCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.bone),
                decoration: InputDecoration(
                  labelText: AppLocalizations(context).nextOilChangeKm,
                  hintText: '50000',
                  prefixIcon: Icon(Icons.update, color: AppColors.amber),
                  suffixText: 'km',
                ),
              ),
              const SizedBox(height: 14),
            ],

            TextField(
              controller: _workshopCtrl,
              style: const TextStyle(color: AppColors.bone),
              decoration: InputDecoration(
                labelText: AppLocalizations(context).workshopName,
                hintText: 'Toshkent STO',
                prefixIcon: Icon(Icons.store_outlined,
                    color: AppColors.steelLight),
              ),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _costCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.bone),
              decoration: InputDecoration(
                labelText: AppLocalizations(context).cost,
                hintText: '85000',
                prefixIcon: Icon(Icons.payments_outlined,
                    color: AppColors.steelLight),
                suffixText: 'so\'m',
              ),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _notesCtrl,
              style: const TextStyle(color: AppColors.bone),
              maxLines: 2,
              decoration: InputDecoration(
                labelText: AppLocalizations(context).notes,
                prefixIcon: Icon(Icons.notes, color: AppColors.steelLight),
              ),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    (_odometerCtrl.text.isNotEmpty && !_loading) ? _save : null,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.asphalt))
                    : Text(AppLocalizations(context).save),
              ),
            ),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }
}
