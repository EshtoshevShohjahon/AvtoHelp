# 🚗 AvtoHelp - Avtomobil Yordamchisi

[![Build APK](https://github.com/EshtoshevShohjahon/AvtoHelp/actions/workflows/build-apk.yml/badge.svg)](https://github.com/EshtoshevShohjahon/AvtoHelp/actions/workflows/build-apk.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.19.6-blue.svg)](https://flutter.dev/)
[![Node.js](https://img.shields.io/badge/Node.js-18+-green.svg)](https://nodejs.org/)

**AvtoHelp** — Yandex Taxi modelidagi yagona mobil ilova bo'lib, barcha avtomobil xizmatlarini bir joyda birlashtiradi.

[O'zbek](README.md) | [English](README.en.md)

---

## 📋 Mundarija

- [Xususiyatlar](#-xususiyatlar)
- [Texnologiyalar](#-texnologiyalar)
- [Tez Boshlash](#-tez-boshlash)
- [Arxitektura](#-arxitektura)
- [API Hujjatlari](#-api-hujjatlari)
- [Skriptlar](#-skriptlar)
- [GitHub Actions](#-github-actions)
- [Hissa Qo'shish](#-hissa-qoshish)
- [Litsenziya](#-litsenziya)

---

## ✨ Xususiyatlar

### 🔧 **6 ta Xizmat**

1. **Texnik yordam** — Yo'lda qolgan avtomobilga tezkor yordam
2. **Yoqilg'i yetkazish** — Benzin tugasa, sizga yetkazib beramiz
3. **Avtomobil yuvish** — Sifatli yuvish xizmati
4. **Ehtiyot qismlar** — Yaqin atrofdagi do'konlar katalogi
5. **Ustaxonalar** — Yaqin ustaxonalar xaritasi
6. **Evakuator** — Avtomobilni olib ketish xizmati

### 🚀 **Asosiy Imkoniyatlar**

- ✅ **Real-time Tracking** — Socket.IO orqali jonli kuzatuv
- ✅ **Moy Almashtirish Eslatmalari** — Avtomatik eslatma tizimi (500 km qolganda)
- ✅ **Dark Mode** — Qorong'u va yorug' rejim
- ✅ **JWT Authentication** — Xavfsiz autentifikatsiya
- ✅ **PostGIS** — Geografik ma'lumotlar bilan ishlash
- ✅ **Avtomobil Boshqaruvi** — Ko'p avtomobilni qo'shish va boshqarish
- ✅ **Buyurtmalar Tarixi** — Barcha xizmatlar tarixi

---

## 🛠 Texnologiyalar

### **Backend**
- **Node.js** + **Express.js** — REST API
- **PostgreSQL** + **PostGIS** — Ma'lumotlar bazasi
- **Socket.IO** — Real-time xabarlar
- **JWT** — Autentifikatsiya
- **bcrypt** — Parol shifrlash

### **Mobile**
- **Flutter 3.19.6** — Cross-platform
- **Provider** — State management
- **Google Maps** — Xarita
- **Socket.IO Client** — Real-time
- **Shared Preferences** — Local storage
- **HTTP/Dio** — API calls

### **DevOps**
- **GitHub Actions** — CI/CD
- **Docker** (opsional) — Konteynerizatsiya

---

## 🚀 Tez Boshlash

### **Talablar**

- **Node.js** 18+
- **PostgreSQL** 14+ + **PostGIS**
- **Flutter** 3.19+
- **Git**

### **1️⃣ Avtomatik O'rnatish (Tavsiya etiladi)**

```bash
# Repozitoriyani klonlash
git clone https://github.com/EshtoshevShohjahon/AvtoHelp.git
cd AvtoHelp

# Avtomatik sozlash
chmod +x setup.sh
./setup.sh

# Ilovani ishga tushirish
./start.sh
```

### **2️⃣ Qo'lda O'rnatish**

#### **Backend**

```bash
cd backend

# Dependencylar
npm install

# .env fayli
cp .env.example .env
# .env faylida ma'lumotlar bazasi sozlamalarini yangilang

# Ma'lumotlar bazasi
createdb avtohelp
psql -d avtohelp -c "CREATE EXTENSION postgis;"

# Migrationlar
npm run migrate

# Serverni ishga tushirish
npm start
```

#### **Mobile**

```bash
cd mobile

# Dependencylar
flutter pub get

# Emulyator/qurilmani ishga tushirish
flutter run
```

---

## 📐 Arxitektura

### **Backend Tuzilmasi**

```
backend/
├── config/           # Database ulanishi
├── controllers/      # Business logic
├── middleware/       # Auth, validation
├── models/           # Ma'lumotlar modellari
├── routes/           # API endpoint'lari
├── migrations/       # Database migrationlari
└── server.js         # Asosiy server fayli
```

### **Mobile Tuzilmasi**

```
mobile/lib/
├── models/           # Ma'lumotlar modellari
├── providers/        # State management
├── screens/          # UI ekranlar
│   ├── auth/         # Login, Register
│   ├── home/         # Bosh sahifa
│   ├── orders/       # Buyurtmalar
│   ├── vehicle/      # Avtomobil boshqaruvi
│   └── profile/      # Profil
└── utils/            # Yordamchi funksiyalar
```

### **Ma'lumotlar Bazasi Sxemasi**

8 ta asosiy jadval:

- `users` — Foydalanuvchilar
- `providers` — Xizmat ko'rsatuvchilar
- `orders` — Buyurtmalar
- `vehicles` — Avtomobillar
- `oil_changes` — Moy almashtirish tarixi
- `maintenance_reminders` — Eslatmalar
- `services` — Xizmatlar
- `notifications` — Bildirishnomalar

---

## 📡 API Hujjatlari

### **Base URL**

```
http://localhost:3000/api
```

### **Autentifikatsiya**

#### **Ro'yxatdan o'tish**

```http
POST /auth/register
Content-Type: application/json

{
  "phone": "+998901234567",
  "password": "password123",
  "full_name": "Alisher Navoiy",
  "role": "client"
}
```

#### **Tizimga kirish**

```http
POST /auth/login
Content-Type: application/json

{
  "phone": "+998901234567",
  "password": "password123"
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 1,
      "phone": "+998901234567",
      "full_name": "Alisher Navoiy",
      "role": "client"
    }
  }
}
```

### **Buyurtmalar**

#### **Yangi buyurtma yaratish**

```http
POST /orders
Authorization: Bearer {token}
Content-Type: application/json

{
  "service_type": "technical_help",
  "pickup_location": {
    "latitude": 41.2995,
    "longitude": 69.2401
  },
  "description": "Mashina ishlamayapti"
}
```

#### **Buyurtmalarni olish**

```http
GET /orders?status=pending
Authorization: Bearer {token}
```

### **Avtomobillar**

#### **Avtomobil qo'shish**

```http
POST /vehicles
Authorization: Bearer {token}
Content-Type: application/json

{
  "brand": "Chevrolet",
  "model": "Lacetti",
  "year": 2015,
  "plate_number": "01A777AA",
  "current_mileage": 87000,
  "oil_change_interval": 10000
}
```

#### **Moy almashtirish qo'shish**

```http
POST /vehicles/{vehicle_id}/oil-changes
Authorization: Bearer {token}
Content-Type: application/json

{
  "oil_type": "Shell Helix Ultra 5W-40",
  "mileage": 87000,
  "price": 250000,
  "location": "Toshkent, Yunusobod"
}
```

### **To'liq API hujjatlari**

Barcha endpointlar uchun to'liq hujjatlar: [API.md](docs/API.md)

---

## 🔧 Skriptlar

### **setup.sh** — Bir martalik sozlash

```bash
./setup.sh
```

- PostgreSQL, Node.js, Flutter tekshirish
- Dependencylar o'rnatish
- Database yaratish va migrationlar
- `.env` fayli sozlash

### **start.sh** — Tezkor ishga tushirish

```bash
./start.sh
```

- Backend va mobile birga ishga tushirish
- Health check
- Avtomatik qurilma tekshirish

### **build-apk.sh** — APK yaratish

```bash
./build-apk.sh
```

- Flutter clean
- Dependencies
- Release APK build
- APK ma'lumotlarini ko'rsatish

### **test-api.sh** — API testlari

```bash
./test-api.sh
```

- 8 ta asosiy endpoint test
- Rangli natijalar
- Pass/Fail statistikasi

---

## 🤖 GitHub Actions

### **Avtomatik APK Build**

Har safar `main` yoki `develop` branchga push qilinganida:

1. ✅ Kod tekshirish (Flutter analyze)
2. ✅ Testlar (Flutter test)
3. ✅ APK build
4. ✅ Artifact sifatida saqlash (30 kun)
5. ✅ Tag push bo'lsa — GitHub Release yaratish

### **Manual Trigger**

```bash
# GitHub'da: Actions → Build Android APK → Run workflow
```

### **APK yuklab olish**

1. GitHub'da repository → **Actions**
2. So'nggi successful workflow
3. **Artifacts** → `avtohelp-release-{sha}` yuklab olish

---

## 📦 Deployment

### **Backend (Heroku)**

```bash
# Heroku CLI orqali
heroku create avtohelp-backend
heroku addons:create heroku-postgresql:hobby-dev
heroku config:set JWT_SECRET=your_secret_key
git push heroku main
```

### **Database Backup**

```bash
pg_dump avtohelp > backup.sql
```

---

## 🧪 Testing

### **Backend Tests**

```bash
cd backend
npm test
```

### **Mobile Tests**

```bash
cd mobile
flutter test
```

### **API Manual Test**

```bash
./test-api.sh
```

---

## 📱 Demo

### **Login Credentials**

```
Telefon: +998901234567
Parol:   password123
```

### **Demo Ma'lumotlar**

- 3 ta mijoz
- 4 ta xizmat ko'rsatuvchi
- 2 ta avtomobil (moy almashtirish tarixi bilan)
- 1 ta eslatma (500 km qolgan)

---

## 🎨 Screenshots

| Bosh sahifa | Buyurtmalar | Avtomobil | Dark Mode |
|-------------|-------------|-----------|-----------|
| ![Home](docs/screenshots/home.png) | ![Orders](docs/screenshots/orders.png) | ![Vehicle](docs/screenshots/vehicle.png) | ![Dark](docs/screenshots/dark.png) |

---

## 🤝 Hissa Qo'shish

Hissa qo'shmoqchimisiz? Rahmat! 🎉

1. **Fork** qiling
2. Feature branch yarating (`git checkout -b feature/awesome-feature`)
3. Commit qiling (`git commit -m 'Add awesome feature'`)
4. Push qiling (`git push origin feature/awesome-feature`)
5. **Pull Request** oching

---

## 📄 Litsenziya

Bu loyiha **MIT License** ostida. Batafsil: [LICENSE](LICENSE)

---

## 👨‍💻 Muallif

**Eshtoshev Shohjahon**

- GitHub: [@EshtoshevShohjahon](https://github.com/EshtoshevShohjahon)
- Email: your.email@example.com

---

## 🙏 Minnatdorchilik

- [Flutter](https://flutter.dev/)
- [Node.js](https://nodejs.org/)
- [PostgreSQL](https://www.postgresql.org/)
- [PostGIS](https://postgis.net/)

---

## 📞 Qo'llab-quvvatlash

Savol yoki muammo bo'lsa:

- **Issues** — [GitHub Issues](https://github.com/EshtoshevShohjahon/AvtoHelp/issues)
- **Discussions** — [GitHub Discussions](https://github.com/EshtoshevShohjahon/AvtoHelp/discussions)

---

<div align="center">
  
**⭐ Loyiha foydali bo'lsa, star bering! ⭐**

</div>
