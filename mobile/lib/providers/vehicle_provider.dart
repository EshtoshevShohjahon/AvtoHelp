import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/vehicle_model.dart';
import '../models/oil_change_model.dart';
import '../models/reminder_model.dart';

class VehicleProvider extends ChangeNotifier {
  List<VehicleModel> _vehicles = [];
  List<OilChangeModel> _oilChanges = [];
  List<ReminderModel> _reminders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<VehicleModel> get vehicles => _vehicles;
  List<OilChangeModel> get oilChanges => _oilChanges;
  List<ReminderModel> get reminders => _reminders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchVehicles(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.vehiclesEndpoint}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        _vehicles = (data['data'] as List)
            .map((vehicle) => VehicleModel.fromJson(vehicle))
            .toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Avtomobillarni yuklashda xatolik';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addVehicle({
    required String token,
    required String brand,
    required String model,
    required int year,
    required String plateNumber,
    required int currentMileage,
    int? oilChangeInterval,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.vehiclesEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'brand': brand,
          'model': model,
          'year': year,
          'plate_number': plateNumber,
          'current_mileage': currentMileage,
          'oil_change_interval': oilChangeInterval ?? AppConstants.defaultOilChangeInterval,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201 && data['success']) {
        await fetchVehicles(token);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = data['message'] ?? 'Avtomobil qo\'shishda xatolik';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Tarmoq xatosi: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateVehicle({
    required String token,
    required int vehicleId,
    String? brand,
    String? model,
    int? year,
    String? plateNumber,
    int? currentMileage,
    int? oilChangeInterval,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (brand != null) body['brand'] = brand;
      if (model != null) body['model'] = model;
      if (year != null) body['year'] = year;
      if (plateNumber != null) body['plate_number'] = plateNumber;
      if (currentMileage != null) body['current_mileage'] = currentMileage;
      if (oilChangeInterval != null) body['oil_change_interval'] = oilChangeInterval;

      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.vehiclesEndpoint}/$vehicleId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        await fetchVehicles(token);
        return true;
      }

      return false;
    } catch (e) {
      _errorMessage = 'Yangilashda xatolik';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteVehicle(String token, int vehicleId) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.vehiclesEndpoint}/$vehicleId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        await fetchVehicles(token);
        return true;
      }

      return false;
    } catch (e) {
      _errorMessage = 'O\'chirishda xatolik';
      notifyListeners();
      return false;
    }
  }

  Future<bool> addOilChange({
    required String token,
    required int vehicleId,
    required String oilType,
    required int mileage,
    double? price,
    String? location,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.vehiclesEndpoint}/$vehicleId/oil-changes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'oil_type': oilType,
          'mileage': mileage,
          'price': price,
          'location': location,
          'notes': notes,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201 && data['success']) {
        await fetchVehicles(token);
        await fetchReminders(token);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = data['message'] ?? 'Moy almashtirish qo\'shishda xatolik';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Tarmoq xatosi: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchOilChangeHistory(String token, int vehicleId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.vehiclesEndpoint}/$vehicleId/oil-changes'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        _oilChanges = (data['data'] as List)
            .map((change) => OilChangeModel.fromJson(change))
            .toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Tarixni yuklashda xatolik';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchReminders(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.vehiclesEndpoint}/reminders/all'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        _reminders = (data['data'] as List)
            .map((reminder) => ReminderModel.fromJson(reminder))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Eslatmalarni yuklashda xatolik';
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
