import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class AppLocalizations {
  final BuildContext _ctx;
  AppLocalizations(this._ctx);

  Locale get _locale => Localizations.localeOf(_ctx);
  bool get _isRu => _locale.languageCode == 'ru';
  bool get _isCyrl =>
      _locale.languageCode == 'uz' && _locale.scriptCode == 'Cyrl';

  String _s(String uz, String ru, String uzCyrl) {
    if (_isRu) return ru;
    if (_isCyrl) return uzCyrl;
    return uz;
  }

  String get appName => 'AvtoAssist';
  String get welcome => _s('Xush kelibsiz!', 'Добро пожаловать!', 'Хуш келибсиз!');
  String get continueBtn => _s('Davom etish', 'Продолжить', 'Давом этиш');
  String get sendCode => _s('Kod yuborish', 'Отправить код', 'Код юбориш');
  String get enterCode => _s('Kodni kiriting', 'Введите код', 'Кодни киритинг');
  String get phoneNumber => _s('Telefon raqam', 'Номер телефона', 'Телефон рақам');
  String get phoneHint => '+998 XX XXX XX XX';
  String get codeSent => _s('SMS-kod yuborildi', 'SMS-код отправлен', 'СМС-код юборилди');
  String get codeResend => _s('Qayta yuborish', 'Отправить повторно', 'Қайта юбориш');
  String get selectRole => _s('Siz kimligingizni tanlang', 'Выберите вашу роль', 'Сиз кимлигингизни танланг');
  String get roleClient => _s('Mijozman', 'Я клиент', 'Мижозман');
  String get roleClientDesc => _s('Xizmat va ehtiyot qism qidiraman', 'Ищу услугу или запчасти', 'Хизмат ва эҳтиёт қисм қидираман');
  String get roleProvider => _s("Xizmat ko'rsatuvchiman", 'Я исполнитель', 'Хизмат кўрсатувчиман');
  String get roleProviderDesc => _s('Usta, kuryer, do\'kon yoki STO', 'Мастер, курьер, магазин или СТО', 'Уста, курьер, дўкон ёки СТО');
  String get selectServiceType => _s('Xizmat turini tanlang', 'Выберите тип услуги', 'Хизмат турини танланг');
  String get kycTitle => _s('Hujjatlarni tasdiqlash', 'Подтверждение документов', 'Ҳужжатларни тасдиқлаш');
  String get kycDesc => _s("Profilingiz avtomatik tasdiqlanadi. Inson aralashuviz yo'q.", 'Профиль подтверждается автоматически. Без участия оператора.', 'Профилингиз автоматик тасдиқланади. Инсон аралашуви йўқ.');
  String get kycDocPhoto => _s('Pasport/guvohnoma suratini yuklang', 'Загрузите фото паспорта/удостоверения', 'Паспорт/гувоҳнома суратини юкланг');
  String get kycSelfie => _s('Selfie oling (liveness tekshiruvi)', 'Сделайте селфи (проверка liveness)', 'Селфи олинг (liveness текшируви)');
  String get kycSubmit => _s('Tasdiqlashga yuborish', 'Отправить на проверку', 'Тасдиқлашга юбориш');
  String get kycApproved => _s('Profil tasdiqlandi!', 'Профиль подтверждён!', 'Профил тасдиқланди!');
  String get home => _s('Asosiy', 'Главная', 'Асосий');
  String get orders => _s('Buyurtmalar', 'Заказы', 'Буюртмалар');
  String get map => _s('Xarita', 'Карта', 'Харита');
  String get profile => _s('Profil', 'Профиль', 'Профил');
  String get greeting => _s('Assalomu alaykum', 'Привет', 'Ассалому алайкум');
  String get searchHint => _s("Xizmat yoki do'kon qidirish", 'Поиск услуги или магазина', 'Хизмат ёки дўкон қидириш');
  String get recentOrder => _s("So'nggi buyurtma", 'Последний заказ', 'Сўнгги буюртма');
  String get serviceTechSupport => _s('Texnik yordam', 'Тех. помощь', 'Техник ёрдам');
  String get serviceTechSupportDesc => _s("Usta joyingizga kelib ta'mirlaydi", 'Мастер приедет к вам', 'Уста жойингизга келиб таъмирлайди');
  String get serviceTowTruck => _s('Evakuator', 'Эвакуатор', 'Эвакуатор');
  String get serviceTowTruckDesc => _s('Avtomobilni kerakli manzilga tashiydi', 'Доставит авто куда нужно', 'Автомобилни керакли манзилга ташийди');
  String get serviceFuel => _s("Yoqilg'i quyish", 'Доставка топлива', 'Ёқилғи қуйиш');
  String get serviceFuelDesc => _s("Yoqilg'i joyingizga olib kelinadi", 'Топливо привезут к вам', 'Ёқилғи жойингизга олиб келинади');
  String get serviceCarWash => _s('Avtomobil yuvish', 'Автомойка', 'Автомобил ювиш');
  String get serviceCarWashDesc => _s('Mobil yoki eng yaqin moyka', 'Мобильная или ближайшая мойка', 'Мобил ёки энг яқин мойка');
  String get serviceParts => _s('Ehtiyot qismlar', 'Запчасти', 'Эҳтиёт қисмлар');
  String get servicePartsDesc => _s("Yaqin do'konlar va narxlar", 'Ближайшие магазины и цены', 'Яқин дўконлар ва нархлар');
  String get serviceWorkshop => _s('Ustaxonalar', 'Автосервисы', 'Устахоналар');
  String get serviceWorkshopDesc => _s('Reyting va narxlar bo\'yicha', 'По рейтингу и ценам', 'Рейтинг ва нархлар бўйича');
  String get problemType => _s('Muammo turi', 'Тип проблемы', 'Муаммо тури');
  String get pickupLocation => _s('Joylashuvingiz', 'Ваше местоположение', 'Жойлашувингиз');
  String get destinationLocation => _s('Yetkazish manzili', 'Адрес доставки', 'Етказиш манзили');
  String get towTruckDestHint => _s('Qayerga olib borishni xohlaysiz?', 'Куда отвезти автомобиль?', 'Қаерга олиб боришни хоҳлайсиз?');
  String get estimatedPrice => _s('Taxminiy narx', 'Примерная цена', 'Тахминий нарх');
  String get estimatedTime => _s('Kutish vaqti', 'Ожидание', 'Кутиш вақти');
  String get requestService => _s('Xizmat chaqirish', 'Вызвать услугу', 'Хизмат чақириш');
  String get searching => _s('Qidirilmoqda...', 'Поиск...', 'Қидирилмоқда...');
  String get searchingDesc => _s("Eng yaqin xizmat ko'rsatuvchini topyapmiz", 'Ищем ближайшего исполнителя', 'Энг яқин хизмат кўрсатувчини топяпмиз');
  String get providerFound => _s("Xizmat ko'rsatuvchi topildi!", 'Исполнитель найден!', 'Хизмат кўрсатувчи топилди!');
  String get providerEnRoute => _s("Yo'lda", 'В пути', 'Йўлда');
  String etaMinutes(int min) => _s('$min daqiqa', '$min мин', '$min дақиқа');
  String get call => _s("Qo'ng'iroq", 'Позвонить', 'Қўнғироқ');
  String get chat => _s('Xabar', 'Написать', 'Хабар');
  String get orderAccepted => _s('Qabul qilindi', 'Принят', 'Қабул қилинди');
  String get orderEnRoute => _s("Yo'lda", 'В пути', 'Йўлда');
  String get orderInProgress => _s('Ish jarayonida', 'В процессе', 'Иш жараёнида');
  String get orderCompleted => _s('Yakunlandi', 'Завершён', 'Якунланди');
  String get orderCancelled => _s('Bekor qilindi', 'Отменён', 'Бекор қилинди');
  String get cancelOrder => _s('Bekor qilish', 'Отменить заказ', 'Бекор қилиш');
  String get leaveReview => _s('Sharh qoldirish', 'Оставить отзыв', 'Шарҳ қолдириш');
  String get reviewTitle => _s('Xizmatni baholang', 'Оцените услугу', 'Хизматни баҳоланг');
  String get reviewHint => _s('Izoh qoldiring (ixtiyoriy)', 'Оставьте комментарий (необязательно)', 'Изоҳ қолдиринг (ихтиёрий)');
  String get submitReview => _s('Yuborish', 'Отправить', 'Юбориш');
  String get nearbyStores => _s("Yaqin do'konlar", 'Ближайшие магазины', 'Яқин дўконлар');
  String get nearbyWorkshops => _s('Yaqin ustaxonalar', 'Ближайшие автосервисы', 'Яқин устахоналар');
  String distance(double km) => _s('${km.toStringAsFixed(1)} km', '${km.toStringAsFixed(1)} км', '${km.toStringAsFixed(1)} км');
  String get openNow => _s('Ochiq', 'Открыто', 'Очиқ');
  String get closed => _s('Yopiq', 'Закрыто', 'Ёпиқ');
  String get paymentMethod => _s("To'lov usuli", 'Способ оплаты', 'Тўлов усули');
  String get paymentCash => _s('Naqd pul', 'Наличные', 'Нақд пул');
  String get paymentCard => _s('Karta', 'Карта', 'Карта');
  String get paymentWallet => _s('Hamyon', 'Кошелёк', 'Ҳамён');
  String get pay => _s("To'lash", 'Оплатить', 'Тўлаш');
  String get paymentSuccess => _s("To'lov muvaffaqiyatli", 'Оплата прошла успешно', 'Тўлов муваффақиятли');
  String get paymentFailed => _s("To'lov muvaffaqiyatsiz", 'Ошибка оплаты', 'Тўлов муваффақиятсиз');
  String get myVehicles => _s('Avtomobillarim', 'Мои авто', 'Автомобилларим');
  String get addVehicle => _s("Avtomobil qo'shish", 'Добавить авто', 'Автомобил қўшиш');
  String get brand => _s('Marka', 'Марка', 'Марка');
  String get model => _s('Model', 'Модель', 'Модел');
  String get plateNumber => _s('Davlat raqami', 'Гос. номер', 'Давлат рақами');
  String get year => _s('Yil', 'Год', 'Йил');
  String get save => _s('Saqlash', 'Сохранить', 'Сақлаш');
  String get delete => _s("O'chirish", 'Удалить', 'Ўчириш');
  String get language => _s('Til', 'Язык', 'Тил');
  String get logout => _s('Chiqish', 'Выйти', 'Чиқиш');
  String get online => _s('Onlayn', 'Онлайн', 'Онлайн');
  String get offline => _s('Oflayn', 'Офлайн', 'Офлайн');
  String get myEarnings => _s('Daromadlarim', 'Мои заработки', 'Даромадларим');
  String get todayEarnings => _s('Bugungi daromad', 'Заработок сегодня', 'Бугунги даромад');
  String get totalOrders => _s('Jami buyurtmalar', 'Всего заказов', 'Жами буюртмалар');
  String get myRating => _s('Mening reytingim', 'Мой рейтинг', 'Менинг рейтингим');
  String get newOrderAlert => _s('Yangi buyurtma!', 'Новый заказ!', 'Янги буюртма!');
  String get accept => _s('Qabul qilish', 'Принять', 'Қабул қилиш');
  String get decline => _s('Rad etish', 'Отклонить', 'Рад этиш');
  String get arrived => _s('Yetib keldim', 'Я прибыл', 'Етиб келдим');
  String get startWork => _s('Ishni boshlash', 'Начать работу', 'Ишни бошлаш');
  String get finishWork => _s('Ishni yakunlash', 'Завершить работу', 'Ишни якунлаш');
  String get noOrdersYet => _s("Hali buyurtmalar yo'q", 'Заказов пока нет', 'Ҳали буюртмалар йўқ');
  String get error => _s('Xatolik', 'Ошибка', 'Хатолик');
  String get retry => _s('Qayta urinish', 'Повторить', 'Қайта уриниш');
  String get noInternet => _s("Internet aloqasi yo'q", 'Нет подключения к интернету', 'Интернет алоқаси йўқ');
  String get loading => _s('Yuklanmoqda...', 'Загрузка...', 'Юкланмоқда...');
  String get cancel => _s('Bekor qilish', 'Отмена', 'Бекор қилиш');
  String get confirm => _s('Tasdiqlash', 'Подтвердить', 'Тасдиқлаш');
  String get done => _s('Tayyor', 'Готово', 'Тайёр');
  String get back => _s('Orqaga', 'Назад', 'Орқага');
  String get soum => _s("so'm", 'сум', 'сўм');
}

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: AppColors.amber,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: AppColors.amber.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 8))],
          ),
          child: const Icon(Icons.directions_car_rounded, color: Color(0xFF1A1100), size: 36),
        ),
        const SizedBox(height: 14),
        const Text('AvtoAssist', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.bone, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        const Text('Avtomobil xizmatlari agregatori', style: TextStyle(fontSize: 12, color: AppColors.steelLight)),
      ],
    );
  }
}
