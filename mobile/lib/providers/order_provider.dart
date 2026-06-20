import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/order_model.dart';

class OrderProvider extends ChangeNotifier {
  List<OrderModel> _orders = [];
  OrderModel? _currentOrder;
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> get orders => _orders;
  OrderModel? get currentOrder => _currentOrder;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> createOrder({
    required String token,
    required String serviceType,
    required Map<String, double> pickupLocation,
    Map<String, double>? destinationLocation,
    String? description,
    Map<String, dynamic>? vehicleInfo,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final body = {
        'service_type': serviceType,
        'pickup_location': pickupLocation,
        'description': description,
      };

      if (destinationLocation != null) {
        body['destination_location'] = destinationLocation;
      }

      if (vehicleInfo != null) {
        body['vehicle_info'] = vehicleInfo;
      }

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.ordersEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201 && data['success']) {
        _currentOrder = OrderModel.fromJson(data['data']['order']);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = data['message'] ?? 'Buyurtma yaratishda xatolik';
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

  Future<void> fetchOrders(String token, {String? status}) async {
    _isLoading = true;
    notifyListeners();

    try {
      var uri = Uri.parse('${AppConstants.baseUrl}${AppConstants.ordersEndpoint}');
      
      if (status != null) {
        uri = uri.replace(queryParameters: {'status': status});
      }

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        _orders = (data['data'] as List)
            .map((order) => OrderModel.fromJson(order))
            .toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Buyurtmalarni yuklashda xatolik';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelOrder(String token, int orderId) async {
    try {
      final response = await http.patch(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.ordersEndpoint}/$orderId/cancel'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        await fetchOrders(token);
        return true;
      }

      return false;
    } catch (e) {
      _errorMessage = 'Buyurtmani bekor qilishda xatolik';
      notifyListeners();
      return false;
    }
  }

  Future<bool> rateOrder({
    required String token,
    required int orderId,
    required int rating,
    String? review,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.ordersEndpoint}/$orderId/rate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'rating': rating,
          'review': review,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        await fetchOrders(token);
        return true;
      }

      return false;
    } catch (e) {
      _errorMessage = 'Baholashda xatolik';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
