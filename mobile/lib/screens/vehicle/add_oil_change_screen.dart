import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/vehicle_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vehicle_provider.dart';

class AddOilChangeScreen extends StatefulWidget {
  final VehicleModel vehicle;

  const AddOilChangeScreen({Key? key, required this.vehicle}) : super(key: key);

  @override
  State<AddOilChangeScreen> createState() => _AddOilChangeScreenState();
}

class _AddOilChangeScreenState extends State<AddOilChangeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oilTypeController = TextEditingController();
  final _mileageController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void dispose() {
    _oilTypeController.dispose();
    _mileageController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token == null) return;

      final success = await Provider.of<VehicleProvider>(context, listen: false).addOilChange(
        token: token,
        vehicleId: widget.vehicle.id,
        oilType: _oilTypeController.text.trim(),
        mileage: int.parse(_mileageController.text),
        price: _priceController.text.isNotEmpty ? double.parse(_priceController.text) : null,
        location: _locationController.text.trim(),
      );

      if (success && mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Moy almashtirish qo\'shish')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _oilTypeController,
                decoration: const InputDecoration(labelText: 'Moy turi (Shell Helix Ultra 5W-40)'),
                validator: (v) => v?.isEmpty ?? true ? 'Moy turini kiriting' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mileageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Kilometr (70000)'),
                validator: (v) => v?.isEmpty ?? true ? 'Kilometrni kiriting' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Narxi (so\'m, ixtiyoriy)'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Joy (ixtiyoriy)'),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                ),
                child: const Text('Saqlash'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
