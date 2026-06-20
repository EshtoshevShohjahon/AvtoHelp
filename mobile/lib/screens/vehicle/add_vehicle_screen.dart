import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vehicle_provider.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({Key? key}) : super(key: key);

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _plateController = TextEditingController();
  final _mileageController = TextEditingController();

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _plateController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token == null) return;

      final success = await Provider.of<VehicleProvider>(context, listen: false).addVehicle(
        token: token,
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        year: int.parse(_yearController.text),
        plateNumber: _plateController.text.trim(),
        currentMileage: int.parse(_mileageController.text),
      );

      if (success && mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Avtomobil qo\'shish')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: 'Brend (Chevrolet, Gentra)'),
                validator: (v) => v?.isEmpty ?? true ? 'Brendni kiriting' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(labelText: 'Model (Lacetti, Spark)'),
                validator: (v) => v?.isEmpty ?? true ? 'Modelni kiriting' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Yili (2020)'),
                validator: (v) => v?.isEmpty ?? true ? 'Yilini kiriting' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _plateController,
                decoration: const InputDecoration(labelText: 'Davr raqami (01A777AA)'),
                validator: (v) => v?.isEmpty ?? true ? 'Raqamni kiriting' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mileageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Hozirgi kilometr (50000)'),
                validator: (v) => v?.isEmpty ?? true ? 'Kilometrni kiriting' : null,
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
