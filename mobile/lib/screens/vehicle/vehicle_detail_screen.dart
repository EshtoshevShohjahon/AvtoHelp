import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/vehicle_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vehicle_provider.dart';
import 'add_oil_change_screen.dart';

class VehicleDetailScreen extends StatefulWidget {
  final VehicleModel vehicle;

  const VehicleDetailScreen({Key? key, required this.vehicle}) : super(key: key);

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadOilChanges();
  }

  Future<void> _loadOilChanges() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token != null) {
      await Provider.of<VehicleProvider>(context, listen: false)
          .fetchOilChangeHistory(token, widget.vehicle.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vehicle.displayName),
      ),
      body: Consumer<VehicleProvider>(
        builder: (context, vehicleProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Davr raqami: ${widget.vehicle.plateNumber}'),
                        Text('Kilometr: ${widget.vehicle.currentMileage} km'),
                        Text('Moy almashtirish intervali: ${widget.vehicle.oilChangeInterval} km'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Moy almashtirish tarixi', style: Theme.of(context).textTheme.titleLarge),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AddOilChangeScreen(vehicle: widget.vehicle),
                          ),
                        ).then((_) => _loadOilChanges());
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Qo\'shish'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (vehicleProvider.oilChanges.isEmpty)
                  const Center(child: Text('Hali ma\'lumot yo\'q'))
                else
                  ...vehicleProvider.oilChanges.map((change) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.oil_barrel),
                        title: Text(change.oilType),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Kilometr: ${change.mileage} km'),
                            Text(DateFormat('dd MMM yyyy').format(change.changeDate)),
                          ],
                        ),
                        trailing: change.price != null ? Text('${change.price} so\'m') : null,
                      ),
                    );
                  }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}
