import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vehicle_provider.dart';
import 'add_vehicle_screen.dart';
import 'vehicle_detail_screen.dart';

class VehicleScreen extends StatefulWidget {
  const VehicleScreen({Key? key}) : super(key: key);

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token != null) {
      final vehicleProvider = Provider.of<VehicleProvider>(context, listen: false);
      await vehicleProvider.fetchVehicles(token);
      await vehicleProvider.fetchReminders(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mening avtomobillarim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddVehicleScreen()),
              ).then((_) => _loadData());
            },
          ),
        ],
      ),
      body: Consumer<VehicleProvider>(
        builder: (context, vehicleProvider, _) {
          if (vehicleProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reminders Section
                  if (vehicleProvider.reminders.isNotEmpty) ...[
                    Text(
                      'Eslatmalar',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    ...vehicleProvider.reminders.map((reminder) {
                      return Card(
                        color: reminder.shouldNotify ? Colors.orange.shade50 : null,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            Icons.warning,
                            color: reminder.shouldNotify ? Colors.orange : Colors.grey,
                          ),
                          title: Text('${reminder.brand} ${reminder.model}'),
                          subtitle: Text(reminder.displayText),
                          trailing: reminder.shouldNotify
                              ? const Icon(Icons.priority_high, color: Colors.orange)
                              : null,
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 24),
                  ],

                  // Vehicles Section
                  Text(
                    'Avtomobillar',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),

                  if (vehicleProvider.vehicles.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          Icon(Icons.directions_car, size: 80, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          const Text('Hali avtomobil qo\'shilmagan'),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const AddVehicleScreen()),
                              ).then((_) => _loadData());
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Avtomobil qo\'shish'),
                          ),
                        ],
                      ),
                    )
                  else
                    ...vehicleProvider.vehicles.map((vehicle) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const Icon(Icons.directions_car, size: 40),
                          title: Text(vehicle.displayName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Davr raqami: ${vehicle.plateNumber}'),
                              Text('Kilometr: ${vehicle.currentMileage} km'),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => VehicleDetailScreen(vehicle: vehicle),
                              ),
                            ).then((_) => _loadData());
                          },
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
