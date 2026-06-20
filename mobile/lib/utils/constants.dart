class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://localhost:3000/api';
  
  // Endpoints
  static const String authEndpoint = '/auth';
  static const String ordersEndpoint = '/orders';
  static const String vehiclesEndpoint = '/vehicles';
  static const String providersEndpoint = '/providers';
  static const String servicesEndpoint = '/services';
  static const String notificationsEndpoint = '/notifications';
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';
  
  // Service Types
  static const List<Map<String, dynamic>> services = [
    {
      'id': 'technical_help',
      'name': 'Texnik yordam',
      'icon': '🔧',
      'description': 'Yo\'lda qolgan avtomobilga tezkor texnik yordam',
    },
    {
      'id': 'fuel_delivery',
      'name': 'Yoqilg\'i yetkazish',
      'icon': '⛽',
      'description': 'Benzin tugasa, sizga yetkazib beramiz',
    },
    {
      'id': 'car_wash',
      'name': 'Avtomobil yuvish',
      'icon': '🚿',
      'description': 'Sifatli avtomobil yuvish xizmati',
    },
    {
      'id': 'parts_catalog',
      'name': 'Ehtiyot qismlar',
      'icon': '🏪',
      'description': 'Yaqin atrofdagi ehtiyot qismlar do\'konlari',
    },
    {
      'id': 'workshops',
      'name': 'Ustaxonalar',
      'icon': '🏭',
      'description': 'Yaqin atrofdagi avtomobil ustaxonalari',
    },
    {
      'id': 'tow_truck',
      'name': 'Evakuator',
      'icon': '🚚',
      'description': 'Avtomobilni olib ketish xizmati',
    },
  ];
  
  // Order Statuses
  static const Map<String, String> orderStatuses = {
    'pending': 'Kutilmoqda',
    'accepted': 'Qabul qilindi',
    'in_progress': 'Jarayonda',
    'completed': 'Yakunlandi',
    'cancelled': 'Bekor qilindi',
  };
  
  // Default Values
  static const int defaultOilChangeInterval = 10000;
  static const int oilChangeWarningThreshold = 500;
}
