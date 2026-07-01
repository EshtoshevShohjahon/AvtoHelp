import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

// ─── AppLocalizations wrapper ────────────────────────────────────────────
class AppLocalizations {
  final BuildContext _ctx;
  AppLocalizations(this._ctx);

  Locale get _locale => Localizations.localeOf(_ctx);
  bool get _isRu => _locale.languageCode == 'ru';
  bool get _isCyrl =>
      _locale.languageCode == 'uz' && _locale.scriptCode == 'Cyrl';
  bool get _isEn => _locale.languageCode == 'en';

  String _s(String uz, String ru, String uzCyrl, [String? en]) {
    if (_isEn) return en ?? uz;
    if (_isRu) return ru;
    if (_isCyrl) return uzCyrl;
    return uz;
  }

  String get appName => 'AvtoHelp';
  String get welcome =>
      _s('Xush kelibsiz!', 'Добро пожаловать!', 'Хуш келибсиз!', 'Welcome!');
  String get continueBtn =>
      _s('Davom etish', 'Продолжить', 'Давом этиш', 'Continue');
  String get sendCode =>
      _s('Kod yuborish', 'Отправить код', 'Код юбориш', 'Send Code');
  String get login =>
      _s('Kirish', 'Войти', 'Кириш', 'Log In');
  String get register =>
      _s("Ro'yxatdan o'tish", 'Регистрация', "Рўйхатдан ўтиш", 'Sign Up');
  String get notRegisteredError =>
      _s("Siz ro'yxatdan o'tmagansiz. Iltimos, \"Ro'yxatdan o'tish\" tugmasini bosing.",
         'Вы не зарегистрированы. Нажмите кнопку «Регистрация».',
         "Сиз рўйхатдан ўтмагансиз. «Рўйхатдан ўтиш» тугмасини босинг.",
         'You are not registered. Please tap "Sign Up".');
  String get enterCode =>
      _s('Kodni kiriting', 'Введите код', 'Кодни киритинг', 'Enter Code');
  String get phoneNumber =>
      _s('Telefon raqam', 'Номер телефона', 'Телефон рақам', 'Phone Number');
  String get phoneHint => '+998 XX XXX XX XX';
  String get codeSent =>
      _s('SMS-kod yuborildi', 'SMS-код отправлен', 'СМС-код юборилди', 'SMS code sent');
  String get codeResend =>
      _s('Qayta yuborish', 'Отправить повторно', 'Қайта юбориш', 'Resend');
  String get selectRole =>
      _s('Siz kimligingizni tanlang', 'Выберите вашу роль',
          'Сиз кимлигингизни танланг', 'Select your role');
  String get roleClient =>
      _s('Mijozman', 'Я клиент', 'Мижозман', 'I am a client');
  String get roleClientDesc =>
      _s('Xizmat va ehtiyot qism qidiraman',
          'Ищу услугу или запчасти',
          'Хизмат ва эҳтиёт қисм қидираман',
          'Looking for service or parts');
  String get roleProvider =>
      _s("Xizmat ko'rsatuvchiman", 'Я исполнитель',
          'Хизмат кўрсатувчиман', 'I am a provider');
  String get roleProviderDesc =>
      _s('Usta, kuryer, do\'kon yoki STO',
          'Мастер, курьер, магазин или СТО',
          'Уста, курьер, дўкон ёки СТО',
          'Mechanic, courier, shop or workshop');
  String get selectServiceType =>
      _s('Xizmat turini tanlang', 'Выберите тип услуги',
          'Хизмат турини танланг', 'Select service type');
  String get kycTitle =>
      _s('Hujjatlarni tasdiqlash', 'Подтверждение документов',
          'Ҳужжатларни тасдиқлаш', 'Document Verification');
  String get kycDesc =>
      _s("Profilingiz avtomatik tasdiqlanadi. Inson aralashuviz yo'q.",
          'Профиль подтверждается автоматически. Без участия оператора.',
          'Профилингиз автоматик тасдиқланади. Инсон аралашуви йўқ.',
          'Your profile is verified automatically. No human involvement.');
  String get kycDocPhoto =>
      _s('Pasport/guvohnoma suratini yuklang',
          'Загрузите фото паспорта/удостоверения',
          'Паспорт/гувоҳнома суратини юкланг',
          'Upload passport/ID photo');
  String get kycSelfie =>
      _s('Selfie oling (liveness tekshiruvi)',
          'Сделайте селфи (проверка liveness)',
          'Селфи олинг (liveness текшируви)',
          'Take a selfie (liveness check)');
  String get kycSubmit =>
      _s('Tasdiqlashga yuborish', 'Отправить на проверку',
          'Тасдиқлашга юбориш', 'Submit for Review');
  String get kycApproved =>
      _s('Profil tasdiqlandi!', 'Профиль подтверждён!',
          'Профил тасдиқланди!', 'Profile approved!');
  String get home => _s('Asosiy', 'Главная', 'Асосий', 'Home');
  String get orders => _s('Buyurtmalar', 'Заказы', 'Буюртмалар', 'Orders');
  String get map => _s('Xarita', 'Карта', 'Харита', 'Map');
  String get profile => _s('Profil', 'Профиль', 'Профил', 'Profile');
  String get greeting =>
      _s('Assalomu alaykum', 'Привет', 'Ассалому алайкум', 'Hello');
  String get searchHint =>
      _s("Xizmat yoki do'kon qidirish", 'Поиск услуги или магазина',
          'Хизмат ёки дўкон қидириш', 'Search service or store');
  String get recentOrder =>
      _s("So'nggi buyurtma", 'Последний заказ', 'Сўнгги буюртма', 'Recent order');
  String get serviceTechSupport =>
      _s('Texnik yordam', 'Тех. помощь', 'Техник ёрдам', 'Tech Support');
  String get serviceTechSupportDesc =>
      _s("Usta joyingizga kelib ta'mirlaydi",
          'Мастер приедет к вам',
          'Уста жойингизга келиб таъмирлайди',
          'Mechanic comes to your location');
  String get serviceTowTruck =>
      _s('Evakuator', 'Эвакуатор', 'Эвакуатор', 'Tow Truck');
  String get serviceTowTruckDesc =>
      _s('Avtomobilni kerakli manzilga tashiydi',
          'Доставит авто куда нужно',
          'Автомобилни керакли манзилга ташийди',
          'Tows your car to any destination');
  String get serviceFuel =>
      _s("Yoqilg'i quyish", 'Доставка топлива', 'Ёқилғи қуйиш', 'Fuel Delivery');
  String get serviceFuelDesc =>
      _s("Yoqilg'i joyingizga olib kelinadi",
          'Топливо привезут к вам',
          'Ёқилғи жойингизга олиб келинади',
          'Fuel delivered to your location');
  String get serviceCarWash =>
      _s('Avtomobil yuvish', 'Автомойка', 'Автомобил ювиш', 'Car Wash');
  String get serviceCarWashDesc =>
      _s('Mobil yoki eng yaqin moyka',
          'Мобильная или ближайшая мойка',
          'Мобил ёки энг яқин мойка',
          'Mobile or nearest car wash');
  String get serviceTruckSection =>
      _s('Yuk avtomobillari', 'Грузовые авто', 'Юк автомобиллари', 'Trucks');
  String get serviceTruckSectionDesc =>
      _s("Yuk mashinalar uchun alohida bo'lim",
          'Отдельный раздел для грузовиков',
          'Юк машиналари учун алоҳида бўлим',
          'Separate section for trucks');
  String get truckRepair =>
      _s("Yuk mashinani ta'mirlash", 'Ремонт грузовика', 'Юк машинани таъмирлаш', 'Truck Repair');
  String get truckRepairDesc =>
      _s("Yuk mashinalari ustasi — dvigatel, karobka, moy",
          'Мастер по грузовикам — двигатель, КПП, масло',
          'Юк машиналари устаси — двигател, коробка, мой',
          'Truck mechanic — engine, gearbox, oil');
  String get truckTow =>
      _s('Yuk evakuator', 'Эвакуатор грузовой', 'Юк эвакуатор', 'Truck Tow');
  String get truckTowDesc =>
      _s("Og'ir texnikani ko'chirish",
          'Перемещение тяжёлой техники',
          'Оғир техникани кўчириш',
          'Heavy vehicle towing');
  String get truckTire =>
      _s("Yuk shinasi (22.5\" va boshqalar)",
          'Грузовые шины (22.5\" и др.)',
          'Юк шинаси (22.5\" ва бошқалар)',
          'Truck tires (22.5\" etc.)');
  String get truckTireDesc =>
      _s("Katta razmerdagi shinalar, balansировka",
          'Шины большого размера, балансировка',
          'Катта размердаги шиналар, балансировка',
          'Large-size tires, balancing');
  String get truckFuel =>
      _s("Dizel yetkazib berish", 'Доставка дизеля', 'Дизел етказиб бериш', 'Diesel delivery');
  String get truckFuelDesc =>
      _s("Dizel va AdBlue yetkazib berish",
          'Доставка дизеля и AdBlue',
          'Дизел ва AdBlue етказиб бериш',
          'Diesel and AdBlue delivery');
  String get truckWorkshops =>
      _s('Yuk mashina ustaxonalari', 'Мастерские для грузовиков',
          'Юк машина устахоналари', 'Truck Workshops');
  String get truckSection =>
      _s("Yuk avtomobillari bo'limi", 'Раздел грузовых авто',
          'Юк автомобиллари бўлими', 'Truck Section');
  String get truckOilTypes =>
      _s("Moy turlari: 15W-40, 10W-40, 5W-30 (dizel)",
          'Типы масла: 15W-40, 10W-40, 5W-30 (дизель)',
          'Мой турлари: 15W-40, 10W-40, 5W-30 (дизел)',
          'Oil types: 15W-40, 10W-40, 5W-30 (diesel)');
  String get truckProblemTypes =>
      _s("Muammo turi (yuk mashina)",
          'Тип проблемы (грузовик)',
          'Муаммо тури (юк машина)',
          'Problem type (truck)');
  String get serviceParts =>
      _s('Ehtiyot qismlar', 'Запчасти', 'Эҳтиёт қисмлар', 'Auto Parts');
  String get servicePartsDesc =>
      _s("Yaqin do'konlar va narxlar",
          'Ближайшие магазины и цены',
          'Яқин дўконлар ва нархлар',
          'Nearby stores and prices');
  String get serviceWorkshop =>
      _s('Ustaxonalar', 'Автосервисы', 'Устахоналар', 'Workshops');
  String get serviceWorkshopDesc =>
      _s('Reyting va narxlar bo\'yicha',
          'По рейтингу и ценам',
          'Рейтинг ва нархлар бўйича',
          'By rating and prices');
  String get problemType =>
      _s('Muammo turi', 'Тип проблемы', 'Муаммо тури', 'Problem type');
  String get pickupLocation =>
      _s('Joylashuvingiz', 'Ваше местоположение', 'Жойлашувингиз', 'Your location');
  String get destinationLocation =>
      _s('Yetkazish manzili', 'Адрес доставки', 'Етказиш манзили', 'Destination');
  String get towTruckDestHint =>
      _s("Qayerga olib borishni xohlaysiz?",
          'Куда отвезти автомобиль?',
          'Қаерга олиб боришни хоҳлайсиз?',
          'Where to tow the car?');
  String get estimatedPrice =>
      _s('Taxminiy narx', 'Примерная цена', 'Тахминий нарх', 'Est. price');
  String get estimatedTime =>
      _s('Kutish vaqti', 'Ожидание', 'Кутиш вақти', 'Wait time');
  String get requestService =>
      _s('Xizmat chaqirish', 'Вызвать услугу', 'Хизмат чақириш', 'Request Service');
  String get searching =>
      _s('Qidirilmoqda...', 'Поиск...', 'Қидирилмоқда...', 'Searching...');
  String get searchingDesc =>
      _s("Eng yaqin xizmat ko'rsatuvchini topyapmiz",
          'Ищем ближайшего исполнителя',
          'Энг яқин хизмат кўрсатувчини топяпмиз',
          'Finding the nearest provider');
  String get providerFound =>
      _s("Xizmat ko'rsatuvchi topildi!",
          'Исполнитель найден!',
          'Хизмат кўрсатувчи топилди!',
          'Provider found!');
  String get providerEnRoute =>
      _s("Yo'lda", 'В пути', 'Йўлда', 'En route');
  String etaMinutes(int min) =>
      _s('$min daqiqa', '$min мин', '$min дақиқа', '$min min');
  String get call => _s("Qo'ng'iroq", 'Позвонить', 'Қўнғироқ', 'Call');
  String get chat => _s('Xabar', 'Написать', 'Хабар', 'Message');
  String get orderAccepted =>
      _s('Qabul qilindi', 'Принят', 'Қабул қилинди', 'Accepted');
  String get orderEnRoute => _s("Yo'lda", 'В пути', 'Йўлда', 'En route');
  String get orderInProgress =>
      _s('Ish jarayonida', 'В процессе', 'Иш жараёнида', 'In progress');
  String get orderCompleted =>
      _s('Yakunlandi', 'Завершён', 'Якунланди', 'Completed');
  String get orderCancelled =>
      _s('Bekor qilindi', 'Отменён', 'Бекор қилинди', 'Cancelled');
  String get cancelOrder =>
      _s('Bekor qilish', 'Отменить заказ', 'Бекор қилиш', 'Cancel Order');
  String get leaveReview =>
      _s('Sharh qoldirish', 'Оставить отзыв', 'Шарҳ қолдириш', 'Leave Review');
  String get reviewTitle =>
      _s('Xizmatni baholang', 'Оцените услугу', 'Хизматни баҳоланг', 'Rate the service');
  String get reviewHint =>
      _s('Izoh qoldiring (ixtiyoriy)',
          'Оставьте комментарий (необязательно)',
          'Изоҳ қолдиринг (ихтиёрий)',
          'Leave a comment (optional)');
  String get submitReview =>
      _s('Yuborish', 'Отправить', 'Юбориш', 'Submit');
  String get nearbyStores =>
      _s("Yaqin do'konlar", 'Ближайшие магазины', 'Яқин дўконлар', 'Nearby stores');
  String get nearbyWorkshops =>
      _s('Yaqin ustaxonalar', 'Ближайшие автосервисы',
          'Яқин устахоналар', 'Nearby workshops');
  String distance(double km) =>
      _s('${km.toStringAsFixed(1)} km',
          '${km.toStringAsFixed(1)} км',
          '${km.toStringAsFixed(1)} км',
          '${km.toStringAsFixed(1)} km');
  String get openNow => _s('Ochiq', 'Открыто', 'Очиқ', 'Open');
  String get closed => _s('Yopiq', 'Закрыто', 'Ёпиқ', 'Closed');
  String get paymentMethod =>
      _s("To'lov usuli", 'Способ оплаты', 'Тўлов усули', 'Payment method');
  String get paymentCash =>
      _s('Naqd pul', 'Наличные', 'Нақд пул', 'Cash');
  String get paymentCard => _s('Karta', 'Карта', 'Карта', 'Card');
  String get paymentWallet =>
      _s('Hamyon', 'Кошелёк', 'Ҳамён', 'Wallet');
  String get pay => _s("To'lash", 'Оплатить', 'Тўлаш', 'Pay');
  String get paymentSuccess =>
      _s("To'lov muvaffaqiyatli", 'Оплата прошла успешно',
          'Тўлов муваффақиятли', 'Payment successful');
  String get paymentFailed =>
      _s("To'lov muvaffaqiyatsiz", 'Ошибка оплаты',
          'Тўлов муваффақиятсиз', 'Payment failed');
  String get myVehicles =>
      _s('Avtomobillarim', 'Мои авто', 'Автомобилларим', 'My Vehicles');
  String get myVehiclesDesc =>
      _s('Texnik ko\'rik tarixi va moy eslatmasi',
          'История ТО и напоминание о масле',
          'Техник кўрик тарихи ва мой эслатмаси',
          'Service history and oil change reminder');
  String get services =>
      _s('XIZMATLAR', 'УСЛУГИ', 'ХИЗМАТЛАР', 'SERVICES');
  String get addVehicle =>
      _s("Avtomobil qo'shish", 'Добавить авто',
          'Автомобил қўшиш', 'Add Vehicle');
  String get brand => _s('Marka', 'Марка', 'Марка', 'Brand');
  String get model => _s('Model', 'Модель', 'Модел', 'Model');
  String get plateNumber =>
      _s('Davlat raqami', 'Гос. номер', 'Давлат рақами', 'Plate number');
  String get year => _s('Yil', 'Год', 'Йил', 'Year');
  String get color => _s('Rang', 'Цвет', 'Ранг', 'Color');
  String get techPassport =>
      _s('Texnik passport raqami', 'Номер техпаспорта',
          'Техник паспорт рақами', 'Tech passport number');
  String get techPassportHint => 'AAF1234567';
  String get fetchFromRegistry =>
      _s('Bazadan yuklab olish', 'Загрузить из базы',
          'Базадан юклаб олиш', 'Fetch from registry');
  String get vehicleFound =>
      _s("Avtomobil topildi", 'Автомобиль найден',
          'Автомобиль топилди', 'Vehicle found');
  String get vehicleNotFound =>
      _s("Bu texpassport bo'yicha avtomobil topilmadi",
          'Авто по этому техпаспорту не найдено',
          'Бу техпаспорт бўйича автомобиль топилмади',
          'No vehicle found for this tech passport');
  String get noVehicles =>
      _s("Hali avtomobil qo'shilmagan", 'Авто пока не добавлено',
          'Ҳали автомобиль қўшилмаган', 'No vehicles added yet');
  String get save => _s('Saqlash', 'Сохранить', 'Сақлаш', 'Save');
  String get saveProfile =>
      _s('Profilni saqlash', 'Сохранить профиль', 'Профилни сақлаш', 'Save Profile');
  String get delete => _s("O'chirish", 'Удалить', 'Ўчириш', 'Delete');
  String get language => _s('Til', 'Язык', 'Тил', 'Language');
  String get selectLanguage => _s('Tilni tanlang', 'Выберите язык', 'Тилни танланг', 'Select language');
  String get logout => _s('Chiqish', 'Выйти', 'Чиқиш', 'Log Out');
  String get switchToProvider => _s("Xizmat ko'rsatuvchiga o'tish", 'Стать поставщиком', "Хизмат кўрсатувчига ўтиш", 'Switch to Provider');
  String get switchToClient => _s("Foydalanuvchiga o'tish", 'Стать клиентом', "Фойдаланувчига ўтиш", 'Switch to Client');
  String get switchToClientDesc => _s("Provider panelingizdan chiqib, oddiy foydalanuvchi sifatida kirmoqchimisiz?", 'Хотите выйти из панели поставщика и войти как обычный пользователь?', "Provider panelingizdan chiqib, oddiy foydalanuvchi sifatida kirmoqchimisiz?", 'Do you want to switch to client mode?');
  String get selectSectorDesc => _s("Qaysi sohada xizmat ko'rsatasiz?", 'В какой сфере вы оказываете услуги?', "Qaysi sohada xizmat ko'rsatasiz?", 'Which sector do you work in?');
  String get online => _s('Onlayn', 'Онлайн', 'Онлайн', 'Online');
  String get offline => _s('Oflayn', 'Офлайн', 'Офлайн', 'Offline');
  String get myEarnings =>
      _s('Daromadlarim', 'Мои заработки', 'Даромадларим', 'My Earnings');
  String get todayEarnings =>
      _s('Bugungi daromad', 'Заработок сегодня', 'Бугунги даромад', "Today's earnings");
  String get totalOrders =>
      _s('Jami buyurtmalar', 'Всего заказов', 'Жами буюртмалар', 'Total orders');
  String get myRating =>
      _s('Mening reytingim', 'Мой рейтинг', 'Менинг рейтингим', 'My rating');
  String get newOrderAlert =>
      _s('Yangi buyurtma!', 'Новый заказ!', 'Янги буюртма!', 'New order!');
  String get accept => _s('Qabul qilish', 'Принять', 'Қабул қилиш', 'Accept');
  String get decline => _s('Rad etish', 'Отклонить', 'Рад этиш', 'Decline');
  String get arrived =>
      _s('Yetib keldim', 'Я прибыл', 'Етиб келдим', 'I arrived');
  String get startWork =>
      _s('Ishni boshlash', 'Начать работу', 'Ишни бошлаш', 'Start work');
  String get finishWork =>
      _s('Ishni yakunlash', 'Завершить работу', 'Ишни якунлаш', 'Finish work');
  String get noOrdersYet =>
      _s("Hali buyurtmalar yo'q", 'Заказов пока нет',
          'Ҳали буюртмалар йўқ', 'No orders yet');
  String get error => _s('Xatolik', 'Ошибка', 'Хатолик', 'Error');
  String get retry =>
      _s('Qayta urinish', 'Повторить', 'Қайта уриниш', 'Retry');
  String get locating =>
      _s('Aniqlanmoqda...', 'Определяем...', 'Аниқланмоқда...', 'Locating...');
  String get locationDenied =>
      _s('Ruxsat berilmagan', 'Доступ запрещён', 'Рухсат берилмаган', 'Permission denied');
  String get locationFailed =>
      _s("Aniqlab bo'lmadi", 'Не удалось определить', 'Аниқлаб бўлмади', 'Could not determine location');
  String get noInternet =>
      _s("Internet aloqasi yo'q", 'Нет подключения к интернету',
          'Интернет алоқаси йўқ', 'No internet connection');
  String get loading =>
      _s('Yuklanmoqda...', 'Загрузка...', 'Юкланмоқда...', 'Loading...');
  String get cancel => _s('Bekor qilish', 'Отмена', 'Бекор қилиш', 'Cancel');
  String get confirm => _s('Tasdiqlash', 'Подтвердить', 'Тасдиқлаш', 'Confirm');
  String get done => _s('Tayyor', 'Готово', 'Тайёр', 'Done');
  String get back => _s('Orqaga', 'Назад', 'Орқага', 'Back');
  String get soum => _s("so'm", 'сум', 'сўм', 'sum');
  String get routeToClient =>
      _s("Mijozga yo'nalish", 'Маршрут к клиенту', 'Мижозга йўналиш', 'Route to client');
  String get showRoute =>
      _s("Yo'nalishni ko'rsatish", 'Показать маршрут', 'Йўналишни кўрсатиш', 'Show route');
  String get locationPermissionDenied =>
      _s("Joylashuv ruxsati berilmagan. Sozlamalarda ruxsat bering.",
          'Доступ к местоположению запрещён. Разрешите в настройках.',
          'Жойлашув рухсати берилмаган. Созламаларда рухсат беринг.',
          'Location permission denied. Please enable it in settings.');
  String get routeFetchFailed =>
      _s("Yo'nalish yuklanmadi — faqat markerlar ko'rsatilmoqda",
          'Маршрут не загружен — показаны только маркеры',
          'Йўналиш юкланмади — фақат маркерлар кўрсатилмоқда',
          'Route not loaded — showing markers only');
  String distanceAndTime(double km, int min) =>
      _s('${km.toStringAsFixed(1)} km · $min daqiqa',
          '${km.toStringAsFixed(1)} km · $min мин',
          '${km.toStringAsFixed(1)} km · $min дақиқа',
          '${km.toStringAsFixed(1)} km · $min min');

  // ─── Onboarding ───────────────────────────────────────────
  String get enterYourName => _s('Ismingizni kiriting', 'Введите ваше имя', 'Исмингизни киритинг', 'Enter your name');
  String get nameShownInProfile => _s("Bu ma'lumot profilingizda ko'rsatiladi", 'Отображается в вашем профиле', 'Бу маълумот профилингизда кўрсатилади', 'This will be shown in your profile');
  String get namePlaceholder => _s('Ism Familiya', 'Имя Фамилия', 'Исм Фамилия', 'First Last name');
  String get selectYourRole => _s('Siz kimligingizni tanlang', 'Кто вы?', 'Сиз кимлигингизни танланг', 'Who are you?');
  String get roleChangeHint => _s("Keyinchalik profil sozlamalaridan o'zgartirishingiz mumkin", 'Можно изменить в настройках профиля', 'Кейинчалик профил созламаларидан ўзгартиришингиз мумкин', 'You can change this later in profile settings');
  String get addProfilePhoto => _s("Profil rasmini qo'ying", 'Добавьте фото профиля', "Profil rasmini qo'ying", 'Add profile photo');
  String get photoOptional => _s("Ixtiyoriy — o'tkazib yuborish mumkin", 'Необязательно — можно пропустить', 'Ихтиёрий — ўтказиб юбориш мумкин', 'Optional — you can skip this');
  String get chooseFromGallery => _s('Galereyadan tanlash', 'Выбрать из галереи', 'Галереядан танлаш', 'Choose from gallery');
  String get iAmClient => _s('Mijozman', 'Я клиент', 'Мижозман', 'I am a client');
  String get clientRoleDesc => _s('Avtomobil xizmati yoki ehtiyot qism qidiraman', 'Ищу автосервис или запчасти', 'Автомобил хизмати ёки эҳтиёт қисм қидираман', 'Looking for car service or parts');
  String get iAmProvider => _s("Xizmat ko'rsatuvchiman", 'Я исполнитель', 'Хизмат кўрсатувчиман', 'I am a provider');
  String get providerRoleDesc => _s("Usta, evakuator, kuryer yoki STO", 'Мастер, эвакуатор, курьер или СТО', 'Уста, эвакуатор, курьер ёки СТО', 'Mechanic, tow truck, courier or workshop');

  // ─── Provider panel ────────────────────────────────────────
  String get providerPanel => _s('Usta paneli', 'Панель мастера', 'Уста панели', 'Provider panel');
  String get searchClientVehicle => _s('Mijoz avtomobilini qidirish', 'Поиск авто клиента', 'Мижоз автомобилини қидириш', "Search client's vehicle");
  String get enterTechPassport => _s('Tex passport raqamini kiriting', 'Введите номер техпаспорта', 'Техпаспорт рақамини киритинг', 'Enter tech passport number');
  String get vehicleLookupHint => _s("Mijoz avtomobilining tex pasportini\nkiriting va tarixini ko'ring", 'Введите техпаспорт клиента\nи посмотрите историю ТО', 'Мижоз автомобилининг техпаспортини\nкиритинг ва тарихини кўринг', "Enter client's tech passport\nto view service history");
  String get serviceHistory => _s('Xizmat tarixi', 'История ТО', 'Хизмат тарихи', 'Service history');
  String get addServiceRecord => _s("Tex xizmat qo'shish", 'Добавить запись ТО', 'Теххизмат қўшиш', 'Add service record');
  String get noServiceHistory => _s("Hali xizmat tarixi yo'q", 'История ТО пуста', 'Ҳали хизмат тарихи йўқ', 'No service history yet');
  String recordsCount(int n) => _s('$n ta yozuv', '$n записей', '$n та ёзув', '$n records');
  String get serviceType => _s('Xizmat turi', 'Тип обслуживания', 'Хизмат тури', 'Service type');
  String get workshopName => _s('Ustaxona nomi', 'Название СТО', 'Устахона номи', 'Workshop name');
  String get mechanicName => _s('Usta ismi', 'Имя мастера', 'Уста исми', 'Mechanic name');
  String get cost => _s('Narxi', 'Стоимость', 'Нархи', 'Cost');
  String get notes => _s('Izoh', 'Примечание', 'Изоҳ', 'Notes');
  String get nextOilChangeKm => _s("Keyingi moy almashtirishgacha (km)", 'До следующей замены масла (км)', 'Кейинги мой алмаштиришгача (км)', 'Next oil change at (km)');

  // ─── Vehicle detail ────────────────────────────────────────
  String get updateOdometer => _s("Hozirgi km ni yangilash", 'Обновить одометр', 'Ҳозирги км ни янгилаш', 'Update odometer');
  String get currentOdometer => _s('Hozirgi yurgan masofasi', 'Текущий пробег', 'Ҳозирги юрган масофаси', 'Current mileage');
  String get addInspection => _s("Tex ko'rik qo'shish", 'Добавить ТО', "Техкўрик қўшиш", 'Add inspection');
  String get inspectionHistory => _s("Tex ko'rik tarixi", 'История ТО', "Техкўрик тарихи", 'Inspection history');
  String get noInspectionYet => _s("Hali tex ko'rik yozuvi yo'q", 'Записей ТО пока нет', "Ҳали техкўрик ёзуви йўқ", 'No inspection records yet');
  String get addWithPlusBtn => _s("+ tugmasini bosib qo'shing", 'Нажмите + чтобы добавить', '+ тугмасини босиб қўшинг', 'Tap + to add');
  String get newInspection => _s("Yangi tex ko'rik", 'Новое ТО', 'Янги техкўрик', 'New inspection');
  String get deleteConfirm => _s("Bu yozuvni o'chirishni xohlaysizmi?", 'Удалить эту запись?', 'Бу ёзувни ўчиришни хоҳлайсизми?', 'Delete this record?');
  String get no => _s("Yo'q", 'Нет', 'Йўқ', 'No');
  String get deleteBtn => _s("O'chirish", 'Удалить', 'Ўчириш', 'Delete');
  String get dateLabel => _s('Sana', 'Дата', 'Сана', 'Date');
  String get odometerKm => _s('Hozirgi km (odometr)', 'Пробег (одометр, км)', 'Ҳозирги км (одометр)', 'Current km (odometer)');
  String nextOilAt(int km) => _s('Keyingi moy: $km km da', 'След. замена масла: $km км', 'Кейинги мой: $km км да', 'Next oil change: $km km');
  String get minutes => _s('DAQIQA', 'МИН', 'ДАҚИҚА', 'MIN');
  String get noInternet2 => _s("Hali buyurtmalar yo'q", 'Заказов пока нет', 'Ҳали буюртмалар йўқ', 'No orders yet');

  // ─── Moy eslatmasi ─────────────────────────────────────────
  String get oilChangeRequired => _s('Moy almashtirish kerak!', 'Замена масла необходима!', 'Мой алмаштириш керак!', 'Oil change required!');
  String get oilChangeReminder => _s('Moy almashtirish eslatmasi', 'Напоминание о замене масла', 'Мой алмаштириш эслатмаси', 'Oil change reminder');
  String oilKmLeftUrgent(int km) => _s('Atigi $km km qoldi', 'Осталось всего $km км', 'Атиги $km км қолди', 'Only $km km left');
  String oilKmLeftNormal(int km) => _s('$km km qoldi', 'Осталось $km км', '$km км қолди', '$km km left');
  String oilAtKm(int km) => _s('($km km da almashtiring)', '(замените на $km км)', '($km км да алмаштиринг)', '(change at $km km)');
  String get canceledByClient => _s("Mijoz bekor qildi", 'Клиент отменил', 'Мижоз бекор қилди', 'Cancelled by client');
  String get vehicleNotFoundPassport => _s(
    "Avtomobil topilmadi. Tex passport to'g'ri kiritilganini tekshiring.",
    'Авто не найдено. Проверьте правильность техпаспорта.',
    'Автомобил топилмади. Техпаспорт тўғри киритилганини текширинг.',
    'Vehicle not found. Please verify the tech passport number.',
  );

  // ─── Provider buyurtmalar ──────────────────────────────────
  String get activeOrders => _s("Faol buyurtmalar", 'Активные заказы', 'Фаол буюртмалар', 'Active orders');
  String get noActiveOrders => _s("Hozircha buyurtma yo'q", 'Заказов пока нет', 'Ҳозирча буюртма йўқ', 'No orders yet');
  String get setOnlineToReceive => _s("Buyurtma olish uchun «Faol» holatiga o'ting", 'Перейдите в режим «Онлайн» для получения заказов', 'Буюртма олиш учун «Фаол» ҳолатига ўтинг', 'Go online to receive orders');
  String get orderFrom => _s("Buyurtma:", 'Заказ:', 'Буюртма:', 'Order:');
  String get todayStats => _s("Bugungi ko'rsatkichlar", 'Показатели сегодня', 'Бугунги кўрсаткичлар', "Today's stats");
  String get statusActive => _s('Faol', 'Онлайн', 'Фаол', 'Online');
  String get statusResting => _s('Dam olmoqda', 'Офлайн', 'Дам олмоқда', 'Offline');
  String get toggleOnline => _s("Faolga o'tish", 'Перейти онлайн', 'Фаолга ўтиш', 'Go online');
  String get toggleOffline => _s("Dam olishga o'tish", 'Перейти офлайн', 'Дам олишга ўтиш', 'Go offline');

  // ─── Xizmat turlari ────────────────────────────────────────
  String serviceTypeLabel(String t) {
    switch (t) {
      case 'oil_change':    return _s('Moy almashtirish', 'Замена масла', 'Мой алмаштириш', 'Oil change');
      case 'inspection':    return _s("Tex ko'rik", 'Техосмотр', 'Техкўрик', 'Inspection');
      case 'tire':          return _s('Shina', 'Шина', 'Шина', 'Tire');
      case 'brake':         return _s('Tormoz', 'Тормоз', 'Тормоз', 'Brakes');
      case 'engine':        return _s('Dvigatel', 'Двигатель', 'Двигател', 'Engine');
      case 'battery':       return _s('Akkumulyator', 'Аккумулятор', 'Аккумулятор', 'Battery');
      case 'transmission':  return _s('Karobka', 'КПП', 'Коробка', 'Transmission');
      case 'tech_support':  return _s('Texnik yordam', 'Тех. помощь', 'Техник ёрдам', 'Tech Support');
      case 'tow_truck':     return _s('Evakuator', 'Эвакуатор', 'Эвакуатор', 'Tow Truck');
      case 'fuel':          return _s("Yoqilg'i", 'Топливо', 'Ёқилғи', 'Fuel');
      case 'car_wash':      return _s('Avto yuvish', 'Автомойка', 'Авто ювиш', 'Car Wash');
      case 'truck_repair':  return _s("Yuk ta'mirlash", 'Ремонт грузовика', 'Юк таъмирлаш', 'Truck Repair');
      case 'truck_tow':     return _s('Yuk evakuator', 'Грузовой эвакуатор', 'Юк эвакуатор', 'Truck Tow');
      case 'truck_tire':    return _s('Yuk shinasi', 'Грузовые шины', 'Юк шинаси', 'Truck Tires');
      case 'truck_fuel':    return _s('Dizel yetkazish', 'Доставка дизеля', 'Дизел етказиш', 'Diesel Delivery');
      default:              return _s('Boshqa', 'Другое', 'Бошқа', 'Other');
    }
  }

  // ─── Marketplace ────────────────────────────────────────────
  String get marketplace =>
      _s('Bozor', 'Маркетплейс', 'Бозор', 'Marketplace');
  String get marketplaceSearch =>
      _s('Xizmat yoki mahsulot qidirish', 'Поиск услуги или товара',
          'Хизмат ёки маҳсулот қидириш', 'Search services or products');
  String get marketplaceServices =>
      _s('Xizmatlar', 'Услуги', 'Хизматлар', 'Services');
  String get marketplaceParts =>
      _s('Ehtiyot qismlar', 'Запчасти', 'Эҳтиёт қисмлар', 'Parts');
  String get marketplaceOil =>
      _s('Moylar', 'Масла', 'Мойлар', 'Oils');
  String get marketplaceTire =>
      _s('Shinalar', 'Шины', 'Шиналар', 'Tires');
  String get noListings =>
      _s("E'lonlar topilmadi", 'Объявлений нет', 'Эълонлар топилмади',
          'No listings found');
  String get myListings =>
      _s("Mening e'lonlarim", 'Мои объявления', 'Менинг эълонларим',
          'My listings');
  String get addListing =>
      _s("E'lon qo'shish", "Добавить объявление", "Эълон қўшиш", 'Add listing');
  String get setPriceHint =>
      _s("Yangi mahsulot joylang, narx belgilang",
          'Добавьте товар и укажите цену',
          'Янги маҳсулот жойланг, нарх белгиланг',
          'Add a product and set the price');
  String get editListing =>
      _s("E'lonni tahrirlash", 'Редактировать', 'Эълонни таҳрирлаш', 'Edit listing');
  String get listingTitle =>
      _s('Sarlavha', 'Заголовок', 'Сарлавҳа', 'Title');
  String get listingTitleHint =>
      _s("Masalan: Moy almashtirish — 15W-40 bilan",
          'Например: Замена масла — 15W-40',
          'Масалан: Мой алмаштириш — 15W-40 билан',
          'e.g. Oil change — 15W-40');
  String get listingType =>
      _s('Tur', 'Тип', 'Тур', 'Type');
  String get vehicleCategory =>
      _s('Avtomobil turi', 'Тип авто', 'Автомобил тури', 'Vehicle type');
  String get category =>
      _s('Kategoriya', 'Категория', 'Категория', 'Category');
  String get categoryHint =>
      _s("Masalan: Dvigatel, Elektr tizim...",
          'Например: Двигатель, Электрика...',
          'Масалан: Двигател, Электр тизим...',
          'e.g. Engine, Electrical...');
  String get price => _s('Narx', 'Цена', 'Нарх', 'Price');
  String get priceFixed => _s('Belgilangan', 'Фиксированная', 'Белгиланган', 'Fixed');
  String get priceFrom => _s('Dan boshlab', 'От', 'Дан бошлаб', 'From');
  String get fromPrice => _s('dan', 'от', 'дан', 'from');
  String get negotiable => _s('Kelishuv', 'Договорная', 'Келишув', 'Negotiable');
  String get description =>
      _s('Tavsif', 'Описание', 'Тавсиф', 'Description');
  String get descriptionHint =>
      _s("Xizmat yoki mahsulot haqida batafsil ma'lumot...",
          'Подробная информация о товаре или услуге...',
          'Хизмат ёки маҳсулот ҳақида батафсил маълумот...',
          'Detailed information about the service or product...');
  String get photos => _s('Rasmlar', 'Фото', 'Расмлар', 'Photos');
  String get publish => _s("Nashr qilish", 'Опубликовать', 'Нашр қилиш', 'Publish');
  String get saveChanges => _s("O'zgarishlarni saqlash", 'Сохранить изменения', 'Ўзгаришларни сақлаш', 'Save changes');
  String get seller => _s("Sotuvchi", 'Продавец', 'Сотувчи', 'Seller');
  String get contactSeller => _s('Sotuvchi bilan bog\'lanish', 'Связаться с продавцом', 'Сотувчи билан боғланиш', 'Contact seller');
  String get callNow => _s('Qo\'ng\'iroq qilish', 'Позвонить', 'Қўнғироқ қилиш', 'Call now');
  String get favorites => _s('Sevimlilar', 'Избранное', 'Севимлилар', 'Favorites');
  String get noFavorites => _s('Sevimlilar yo\'q', 'Нет избранного', 'Севимлилар йўқ', 'No favorites yet');
  String get notifications => _s('Bildirishnomalar', 'Уведомления', 'Билдиришномалар', 'Notifications');
  String get noNotifications => _s('Bildirishnomalar yo\'q', 'Нет уведомлений', 'Билдиришномалар йўқ', 'No notifications');
  String get reviews => _s('Sharhlar', 'Отзывы', 'Шарҳлар', 'Reviews');
  String get noReviews => _s('Hali sharhlar yo\'q', 'Пока нет отзывов', 'Ҳали шарҳлар йўқ', 'No reviews yet');
  String get rateProvider => _s('Baho berish', 'Оценить', 'Баҳо бериш', 'Rate');
  String get reviewThanks => _s('Sharh uchun rahmat!', 'Спасибо за отзыв!', 'Шарҳ учун раҳмат!', 'Thanks for your review!');
  String get send => _s('Yuborish', 'Отправить', 'Юбориш', 'Send');
  String get copyNumber => _s('Raqamni nusxalash', 'Скопировать номер', 'Рақамни нусхалаш', 'Copy number');
  String get phoneCopied => _s('Raqam nusxalandi', 'Номер скопирован', 'Рақам нусхаланди', 'Number copied');
  String get phoneUnavailable => _s('Telefon raqami mavjud emas', 'Номер телефона недоступен', 'Телефон рақами мавжуд эмас', 'Phone number unavailable');
  String get confirmDelete => _s("O'chirishni tasdiqlaysizmi?", 'Подтвердите удаление', 'Ўчиришни тасдиқлайсизми?', 'Confirm delete');
  String get other => _s('Boshqa', 'Другое', 'Бошқа', 'Other');
  String get servicesRendered =>
      _s("Ko'rsatilgan xizmatlar", 'Оказанные услуги', 'Кўрсатилган хизматлар',
          'Services rendered');
  String get servicesCount =>
      _s('Xizmatlar', 'Услуг', 'Хизматлар', 'Services');
  String get servicedVehicles =>
      _s('Avtomobillar', 'Автомобилей', 'Автомобиллар', 'Vehicles');
  String get recentServices =>
      _s("So'nggi xizmatlar", 'Последние услуги', 'Сўнгги хизматлар',
          'Recent services');
  String get viewStatistics =>
      _s("Statistikani ko'rish", 'Посмотреть статистику', 'Статистикани кўриш',
          'View statistics');
  String get providerStatistics =>
      _s('Usta statistikasi', 'Статистика мастера', 'Уста статистикаси',
          'Provider statistics');
  String get noStatistics =>
      _s("Hozircha statistika yo'q", 'Пока нет статистики', 'Ҳозирча статистика йўқ',
          'No statistics yet');
  String get completedOrders =>
      _s('Bajarilgan buyurtmalar', 'Выполненные заказы', 'Бажарилган буюртмалар',
          'Completed orders');
  String get getVerified =>
      _s('Tasdiqdan o\'tish', 'Пройти верификацию', 'Тасдиқдан ўтиш',
          'Get verified');
  String get verifiedBadge =>
      _s('Tasdiqlangan', 'Подтверждён', 'Тасдиқланган', 'Verified');
  String get notVerified =>
      _s('Tasdiqlanmagan', 'Не подтверждён', 'Тасдиқланмаган', 'Not verified');
  String get verificationDesc =>
      _s('Ishonchni oshirish uchun hujjatlaringizni yuboring',
          'Отправьте документы для повышения доверия',
          'Ишончни ошириш учун ҳужжатларингизни юборинг',
          'Submit your documents to build trust');
  String get documentNumber =>
      _s('Hujjat raqami (passport/ID)', 'Номер документа', 'Ҳужжат рақами',
          'Document number');
  String get uploadDocument =>
      _s('Hujjat fotosi', 'Фото документа', 'Ҳужжат фотоси', 'Document photo');
  String get uploadSelfie =>
      _s('Selfi', 'Селфи', 'Селфи', 'Selfie');
  String get submitVerification =>
      _s('Yuborish', 'Отправить', 'Юбориш', 'Submit');
  String get verificationRequired =>
      _s('Avval tasdiqdan o\'tishingiz kerak',
          'Сначала пройдите верификацию',
          'Аввал тасдиқдан ўтишингиз керак',
          'You must get verified first');
  String get verificationRequiredDesc =>
      _s('Bu sohada ishlash uchun tasdiqlanish majburiy',
          'Для работы в этой сфере верификация обязательна',
          'Бу соҳада ишлаш учун тасдиқланиш мажбурий',
          'Verification is required to work in this sector');
  String get verificationApproved =>
      _s('Tabriklaymiz! Siz tasdiqlandingiz', 'Поздравляем! Вы подтверждены',
          'Табриклаймиз! Сиз тасдиқландингиз', 'Congratulations! You are verified');
  String get verificationRejected =>
      _s('Tasdiqlanmadi. Iltimos, fotolarni tekshiring',
          'Не подтверждено. Проверьте фото',
          'Тасдиқланмади. Илтимос, фотоларни текширинг',
          'Not approved. Please check your photos');
  String get lightCar => _s('Yengil avto', 'Легковой', 'Енгил авто', 'Light car');
  String get all => _s('Barchasi', 'Все', 'Барчаси', 'All');
  String get fillRequired => _s("Sarlavha va narxni to'ldiring", 'Заполните заголовок и цену', 'Сарлавҳа ва нархни тўлдиринг', 'Fill in title and price');
  String get client => _s('Mijoz', 'Клиент', 'Мижоз', 'Client');
}

// ─── AppLogo ─────────────────────────────────────────────────
class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppColors.amberGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.amber.withValues(alpha: 0.45),
                blurRadius: 32,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.directions_car_rounded,
            color: Color(0xFF1A1100),
            size: 40,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'AvtoHelp',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.bone,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Avtomobil xizmatlari agregatori',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.steelLight,
          ),
        ),
      ],
    );
  }
}
