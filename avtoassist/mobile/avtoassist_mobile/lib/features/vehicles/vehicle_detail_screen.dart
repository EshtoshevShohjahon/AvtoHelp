import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/network/api_client.dart';

// ─── Model ───────────────────────────────────────────────────────────────────
class ServiceRecordModel {
  final String id;
  final String serviceType;
  final String serviceDate;
  final int odometerKm;
  final String? workshopName;
  final String? mechanicName;
  final double? cost;
  final String? notes;
  final int? nextServiceKm;

  const ServiceRecordModel({
    required this.id,
    required this.serviceType,
    required this.serviceDate,
    required this.odometerKm,
    this.workshopName,
    this.mechanicName,
    this.cost,
    this.notes,
    this.nextServiceKm,
  });

  factory ServiceRecordModel.fromJson(Map<String, dynamic> j) =>
      ServiceRecordModel(
        id: j['id'],
        serviceType: j['service_type'] ?? 'other',
        serviceDate: j['service_date'] ?? '',
        odometerKm: j['odometer_km'] ?? 0,
        workshopName: j['workshop_name'],
        mechanicName: j['mechanic_name'],
        cost: j['cost'] != null ? (j['cost'] as num).toDouble() : null,
        notes: j['notes'],
        nextServiceKm: j['next_service_km'],
      );
}

class OilAlertModel {
  final int lastChangeKm;
  final int nextChangeKm;
  final int currentKm;
  final int kmLeft;
  final bool alert;

  const OilAlertModel({
    required this.lastChangeKm,
    required this.nextChangeKm,
    required this.currentKm,
    required this.kmLeft,
    required this.alert,
  });

  factory OilAlertModel.fromJson(Map<String, dynamic> j) => OilAlertModel(
        lastChangeKm: j['last_change_km'] ?? 0,
        nextChangeKm: j['next_change_km'] ?? 0,
        currentKm: j['current_km'] ?? 0,
        kmLeft: j['km_left'] ?? 0,
        alert: j['alert'] == true,
      );
}

// ─── Screen ──────────────────────────────────────────────────────────────────
class VehicleDetailScreen extends ConsumerStatefulWidget {
  final String vehicleId;
  final String vehicleTitle;
  const VehicleDetailScreen(
      {super.key, required this.vehicleId, required this.vehicleTitle});

  @override
  ConsumerState<VehicleDetailScreen> createState() =>
      _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends ConsumerState<VehicleDetailScreen> {
  List<ServiceRecordModel> _records = [];
  OilAlertModel? _oilAlert;
  Map<String, dynamic>? _vehicle;
  bool _loading = true;
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
      final res =
          await api.get('/users/me/vehicles/${widget.vehicleId}/service-records');
      final data = res.data;
      setState(() {
        _records = (data['records'] as List)
            .map((e) => ServiceRecordModel.fromJson(e))
            .toList();
        _vehicle = data['vehicle'];
        _oilAlert = data['oil_alert'] != null
            ? OilAlertModel.fromJson(data['oil_alert'])
            : null;
        _loading = false;
      });
    } catch (e) {
      setState(() { _loading = false; _error = e.toString(); });
    }
  }

  Future<void> _deleteRecord(String id) async {
    try {
      final api = ref.read(apiClientProvider);
      await api.delete(
          '/users/me/vehicles/${widget.vehicleId}/service-records/$id');
      _load();
    } catch (_) {}
  }

  Future<void> _updateOdometer() async {
    final ctrl = TextEditingController(
        text: _vehicle?['current_odometer']?.toString() ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.charcoal,
        title: const Text('Hozirgi km ni yangilash',
            style: TextStyle(color: AppColors.bone, fontSize: 16)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppColors.bone),
          decoration: const InputDecoration(
            hintText: 'Masalan: 45000',
            suffixText: 'km',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Bekor')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Saqlash',
                  style: TextStyle(color: AppColors.amber))),
        ],
      ),
    );
    if (ok != true) return;
    final km = int.tryParse(ctrl.text.trim());
    if (km == null) return;
    try {
      final api = ref.read(apiClientProvider);
      await api.patch(
          '/users/me/vehicles/${widget.vehicleId}/odometer',
          data: {'current_odometer': km});
      _load();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vehicleTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.speed_outlined, color: AppColors.amber),
            tooltip: 'Km yangilash',
            onPressed: _updateOdometer,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => AddServiceRecordScreen(
                  vehicleId: widget.vehicleId),
            ),
          );
          if (added == true) _load();
        },
        backgroundColor: AppColors.amber,
        foregroundColor: const Color(0xFF1A1100),
        icon: const Icon(Icons.add),
        label: const Text('Tex ko\'rik qo\'shish'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.amber))
          : _error != null
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.wifi_off, color: AppColors.steelLight, size: 48),
                    const SizedBox(height: 12),
                    Text(_error!,
                        style: const TextStyle(color: AppColors.steelLight),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _load, child: const Text('Qayta')),
                  ]))
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.amber,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Moy eslatmasi
                      if (_oilAlert != null) _OilAlertCard(alert: _oilAlert!),
                      if (_oilAlert != null) const SizedBox(height: 12),

                      // Hozirgi km
                      _OdometerCard(
                        currentKm: _vehicle?['current_odometer'] ?? 0,
                        onTap: _updateOdometer,
                      ),
                      const SizedBox(height: 16),

                      // Tex ko'rik tarixi
                      Row(children: [
                        const Text('Tex ko\'rik tarixi',
                            style: TextStyle(
                                color: AppColors.bone,
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Text('${_records.length} ta yozuv',
                            style: const TextStyle(
                                color: AppColors.steelLight, fontSize: 12)),
                      ]),
                      const SizedBox(height: 10),

                      if (_records.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.charcoal,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.steelLine),
                          ),
                          child: const Column(children: [
                            Icon(Icons.build_outlined,
                                color: AppColors.steelLight, size: 40),
                            SizedBox(height: 10),
                            Text('Hali tex ko\'rik yozuvi yo\'q',
                                style: TextStyle(color: AppColors.steelLight)),
                            SizedBox(height: 4),
                            Text('+ tugmasini bosib qo\'shing',
                                style: TextStyle(
                                    color: AppColors.steel, fontSize: 12)),
                          ]),
                        )
                      else
                        ...(_records.map((r) => _ServiceRecordCard(
                              record: r,
                              onDelete: () => _deleteRecord(r.id),
                            ))),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
    );
  }
}

// ─── Moy eslatmasi kartasi ───────────────────────────────────────────────────
class _OilAlertCard extends StatelessWidget {
  final OilAlertModel alert;
  const _OilAlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final isUrgent = alert.alert;
    final color = isUrgent ? AppColors.danger : AppColors.amber;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(children: [
        Icon(isUrgent ? Icons.warning_amber_rounded : Icons.oil_barrel_outlined,
            color: color, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              isUrgent
                  ? '⚠️ Moy almashtirish kerak!'
                  : 'Moy almashtirish eslatmasi',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              isUrgent
                  ? 'Atigi ${alert.kmLeft} km qoldi (${alert.nextChangeKm} km da)'
                  : '${alert.kmLeft} km qoldi — ${alert.nextChangeKm} km da almashtiring',
              style: const TextStyle(color: AppColors.boneDim, fontSize: 12),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (alert.currentKm - alert.lastChangeKm) /
                    (alert.nextChangeKm - alert.lastChangeKm).clamp(1, 999999),
                backgroundColor: AppColors.steelLine,
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${alert.lastChangeKm} km',
                    style: const TextStyle(
                        color: AppColors.steelLight, fontSize: 10)),
                Text('${alert.nextChangeKm} km',
                    style: const TextStyle(
                        color: AppColors.steelLight, fontSize: 10)),
              ],
            ),
          ]),
        ),
      ]),
    );
  }
}

// ─── Hozirgi km kartasi ──────────────────────────────────────────────────────
class _OdometerCard extends StatelessWidget {
  final int currentKm;
  final VoidCallback onTap;
  const _OdometerCard({required this.currentKm, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.charcoal,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.steelLine),
        ),
        child: Row(children: [
          const Icon(Icons.speed, color: AppColors.teal, size: 22),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Hozirgi yurgan masofasi',
                style: TextStyle(color: AppColors.steelLight, fontSize: 11)),
            Text(
              '${_fmt(currentKm)} km',
              style: const TextStyle(
                  color: AppColors.bone,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace'),
            ),
          ]),
          const Spacer(),
          const Icon(Icons.edit_outlined,
              color: AppColors.steelLight, size: 16),
        ]),
      ),
    );
  }

  String _fmt(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

// ─── Bir yozuv kartasi ───────────────────────────────────────────────────────
class _ServiceRecordCard extends StatelessWidget {
  final ServiceRecordModel record;
  final VoidCallback onDelete;
  const _ServiceRecordCard({required this.record, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.steelLine),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _typeColor(record.serviceType).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(_typeIcon(record.serviceType),
                  color: _typeColor(record.serviceType), size: 14),
              const SizedBox(width: 5),
              Text(_typeLabel(record.serviceType),
                  style: TextStyle(
                      color: _typeColor(record.serviceType),
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ]),
          ),
          const Spacer(),
          Text(record.serviceDate,
              style: const TextStyle(
                  color: AppColors.steelLight, fontSize: 12)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.charcoal,
                  content: const Text('Bu yozuvni o\'chirishni xohlaysizmi?',
                      style: TextStyle(color: AppColors.bone)),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Yo\'q')),
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('O\'chirish',
                            style: TextStyle(color: AppColors.danger))),
                  ],
                ),
              );
              if (ok == true) onDelete();
            },
            child: const Icon(Icons.delete_outline,
                color: AppColors.steelLight, size: 18),
          ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          const Icon(Icons.speed_outlined,
              color: AppColors.steelLight, size: 14),
          const SizedBox(width: 4),
          Text('${record.odometerKm} km',
              style: const TextStyle(
                  color: AppColors.bone,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace')),
          if (record.cost != null) ...[
            const SizedBox(width: 16),
            const Icon(Icons.payments_outlined,
                color: AppColors.steelLight, size: 14),
            const SizedBox(width: 4),
            Text('${record.cost!.toStringAsFixed(0)} so\'m',
                style: const TextStyle(color: AppColors.teal, fontSize: 13)),
          ],
        ]),
        if (record.workshopName != null || record.mechanicName != null) ...[
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.store_outlined,
                color: AppColors.steelLight, size: 13),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                [record.workshopName, record.mechanicName]
                    .where((e) => e != null && e.isNotEmpty)
                    .join(' · '),
                style: const TextStyle(
                    color: AppColors.boneDim, fontSize: 12),
              ),
            ),
          ]),
        ],
        if (record.nextServiceKm != null &&
            record.serviceType == 'oil_change') ...[
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.update, color: AppColors.amber, size: 13),
            const SizedBox(width: 4),
            Text('Keyingi moy: ${record.nextServiceKm} km da',
                style: const TextStyle(
                    color: AppColors.amber, fontSize: 12)),
          ]),
        ],
        if (record.notes != null && record.notes!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(record.notes!,
              style: const TextStyle(
                  color: AppColors.steelLight, fontSize: 12)),
        ],
      ]),
    );
  }

  Color _typeColor(String t) {
    return const {
      'oil_change': AppColors.amber,
      'inspection': AppColors.teal,
      'tire': Color(0xFF7C8CF8),
      'brake': AppColors.danger,
      'engine': Color(0xFFFF9500),
      'battery': Color(0xFF34C759),
      'transmission': Color(0xFFFF6B6B),
      'other': AppColors.steelLight,
    }[t] ?? AppColors.steelLight;
  }

  IconData _typeIcon(String t) {
    return const {
      'oil_change': Icons.oil_barrel_outlined,
      'inspection': Icons.fact_check_outlined,
      'tire': Icons.tire_repair,
      'brake': Icons.disc_full_outlined,
      'engine': Icons.engineering_outlined,
      'battery': Icons.battery_charging_full_outlined,
      'transmission': Icons.settings_outlined,
      'other': Icons.build_outlined,
    }[t] ?? Icons.build_outlined;
  }

  String _typeLabel(String t) {
    return const {
      'oil_change': 'Moy almashtirish',
      'inspection': 'Tex ko\'rik',
      'tire': 'Shina',
      'brake': 'Tormoz',
      'engine': 'Dvigatel',
      'battery': 'Akkumulyator',
      'transmission': 'Karobka',
      'other': 'Boshqa',
    }[t] ?? 'Boshqa';
  }
}

// ─── Yangi yozuv qo'shish ────────────────────────────────────────────────────
class AddServiceRecordScreen extends ConsumerStatefulWidget {
  final String vehicleId;
  const AddServiceRecordScreen({super.key, required this.vehicleId});

  @override
  ConsumerState<AddServiceRecordScreen> createState() =>
      _AddServiceRecordScreenState();
}

class _AddServiceRecordScreenState
    extends ConsumerState<AddServiceRecordScreen> {
  String _serviceType = 'oil_change';
  final _dateCtrl = TextEditingController(
      text: DateTime.now().toIso8601String().split('T').first);
  final _odometerCtrl = TextEditingController();
  final _workshopCtrl = TextEditingController();
  final _mechanicCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _nextKmCtrl = TextEditingController();
  bool _loading = false;

  static const _types = [
    ('oil_change', 'Moy almashtirish'),
    ('inspection', 'Tex ko\'rik'),
    ('tire', 'Shina'),
    ('brake', 'Tormoz'),
    ('engine', 'Dvigatel'),
    ('battery', 'Akkumulyator'),
    ('transmission', 'Karobka'),
    ('other', 'Boshqa'),
  ];

  @override
  void dispose() {
    _dateCtrl.dispose();
    _odometerCtrl.dispose();
    _workshopCtrl.dispose();
    _mechanicCtrl.dispose();
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
      setState(() {
        _dateCtrl.text = d.toIso8601String().split('T').first;
      });
    }
  }

  Future<void> _save() async {
    if (_odometerCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final api = ref.read(apiClientProvider);
      await api.post(
        '/users/me/vehicles/${widget.vehicleId}/service-records',
        data: {
          'service_type': _serviceType,
          'service_date': _dateCtrl.text.trim(),
          'odometer_km': int.tryParse(_odometerCtrl.text.trim()) ?? 0,
          if (_workshopCtrl.text.isNotEmpty) 'workshop_name': _workshopCtrl.text.trim(),
          if (_mechanicCtrl.text.isNotEmpty) 'mechanic_name': _mechanicCtrl.text.trim(),
          if (_costCtrl.text.isNotEmpty) 'cost': double.tryParse(_costCtrl.text.trim()),
          if (_notesCtrl.text.isNotEmpty) 'notes': _notesCtrl.text.trim(),
          if (_serviceType == 'oil_change' && _nextKmCtrl.text.isNotEmpty)
            'next_service_km': int.tryParse(_nextKmCtrl.text.trim()),
        },
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yangi tex ko\'rik')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Xizmat turi
            const Text('Xizmat turi',
                style: TextStyle(color: AppColors.steelLight, fontSize: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _types.map((t) {
                final selected = _serviceType == t.$1;
                return GestureDetector(
                  onTap: () => setState(() => _serviceType = t.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.amber.withOpacity(0.15)
                          : AppColors.charcoal,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: selected
                              ? AppColors.amber
                              : AppColors.steelLine),
                    ),
                    child: Text(t.$2,
                        style: TextStyle(
                            color: selected
                                ? AppColors.amber
                                : AppColors.boneDim,
                            fontSize: 13,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Sana
            const Text('Sana',
                style: TextStyle(color: AppColors.steelLight, fontSize: 12)),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _pickDate,
              child: TextField(
                controller: _dateCtrl,
                enabled: false,
                style: const TextStyle(color: AppColors.bone),
                decoration: const InputDecoration(
                  prefixIcon:
                      Icon(Icons.calendar_today_outlined, color: AppColors.amber),
                  suffixIcon:
                      Icon(Icons.chevron_right, color: AppColors.steelLight),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Km
            const Text('Hozirgi km (odometr)',
                style: TextStyle(color: AppColors.steelLight, fontSize: 12)),
            const SizedBox(height: 6),
            TextField(
              controller: _odometerCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.bone),
              decoration: const InputDecoration(
                hintText: '45000',
                prefixIcon: Icon(Icons.speed_outlined, color: AppColors.amber),
                suffixText: 'km',
              ),
            ),
            const SizedBox(height: 16),

            // Moy uchun keyingi km
            if (_serviceType == 'oil_change') ...[
              const Text('Keyingi moy almashtirishgacha (km)',
                  style: TextStyle(color: AppColors.steelLight, fontSize: 12)),
              const SizedBox(height: 6),
              TextField(
                controller: _nextKmCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.bone),
                decoration: const InputDecoration(
                  hintText: '50000 (masalan, har 5000 km da)',
                  prefixIcon:
                      Icon(Icons.update, color: AppColors.amber),
                  suffixText: 'km',
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Ustaxona
            const Text('Ustaxona nomi',
                style: TextStyle(color: AppColors.steelLight, fontSize: 12)),
            const SizedBox(height: 6),
            TextField(
              controller: _workshopCtrl,
              style: const TextStyle(color: AppColors.bone),
              decoration: const InputDecoration(
                hintText: 'Toshkent STO',
                prefixIcon: Icon(Icons.store_outlined, color: AppColors.steelLight),
              ),
            ),
            const SizedBox(height: 16),

            // Usta
            const Text('Usta ismi',
                style: TextStyle(color: AppColors.steelLight, fontSize: 12)),
            const SizedBox(height: 6),
            TextField(
              controller: _mechanicCtrl,
              style: const TextStyle(color: AppColors.bone),
              decoration: const InputDecoration(
                hintText: 'Sardor Abdullayev',
                prefixIcon:
                    Icon(Icons.person_outline, color: AppColors.steelLight),
              ),
            ),
            const SizedBox(height: 16),

            // Narx
            const Text('Xizmat narxi',
                style: TextStyle(color: AppColors.steelLight, fontSize: 12)),
            const SizedBox(height: 6),
            TextField(
              controller: _costCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.bone),
              decoration: const InputDecoration(
                hintText: '85000',
                prefixIcon:
                    Icon(Icons.payments_outlined, color: AppColors.steelLight),
                suffixText: 'so\'m',
              ),
            ),
            const SizedBox(height: 16),

            // Izoh
            const Text('Izoh (ixtiyoriy)',
                style: TextStyle(color: AppColors.steelLight, fontSize: 12)),
            const SizedBox(height: 6),
            TextField(
              controller: _notesCtrl,
              style: const TextStyle(color: AppColors.bone),
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Qo\'shimcha ma\'lumot...',
              ),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_odometerCtrl.text.isNotEmpty && !_loading)
                    ? _save
                    : null,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.asphalt))
                    : const Text('Saqlash'),
              ),
            ),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }
}
