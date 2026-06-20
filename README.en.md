# 🚗 AvtoHelp - Automobile Assistant

[![Build APK](https://github.com/EshtoshevShohjahon/AvtoHelp/actions/workflows/build-apk.yml/badge.svg)](https://github.com/EshtoshevShohjahon/AvtoHelp/actions/workflows/build-apk.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.19.6-blue.svg)](https://flutter.dev/)
[![Node.js](https://img.shields.io/badge/Node.js-18+-green.svg)](https://nodejs.org/)

**AvtoHelp** — A mobile application following the Yandex Taxi model that unifies all automobile services in one place.

[O'zbek](README.md) | [English](README.en.md)

---

## 📋 Table of Contents

- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Quick Start](#-quick-start)
- [Architecture](#-architecture)
- [API Documentation](#-api-documentation)
- [Scripts](#-scripts)
- [GitHub Actions](#-github-actions)
- [Contributing](#-contributing)
- [License](#-license)

---

## ✨ Features

### 🔧 **6 Services**

1. **Technical Help** — Quick assistance for broken-down vehicles
2. **Fuel Delivery** — Fuel delivery when you run out
3. **Car Wash** — Quality car washing service
4. **Auto Parts** — Catalog of nearby auto parts stores
5. **Workshops** — Map of nearby auto repair shops
6. **Tow Truck** — Vehicle towing service

### 🚀 **Key Features**

- ✅ **Real-time Tracking** — Live tracking via Socket.IO
- ✅ **Oil Change Reminders** — Automatic reminder system (at 500 km remaining)
- ✅ **Dark Mode** — Dark and light themes
- ✅ **JWT Authentication** — Secure authentication
- ✅ **PostGIS** — Geographic data handling
- ✅ **Vehicle Management** — Add and manage multiple vehicles
- ✅ **Order History** — Complete service history

---

## 🛠 Tech Stack

### **Backend**
- **Node.js** + **Express.js** — REST API
- **PostgreSQL** + **PostGIS** — Database
- **Socket.IO** — Real-time messaging
- **JWT** — Authentication
- **bcrypt** — Password encryption

### **Mobile**
- **Flutter 3.19.6** — Cross-platform
- **Provider** — State management
- **Google Maps** — Mapping
- **Socket.IO Client** — Real-time
- **Shared Preferences** — Local storage
- **HTTP/Dio** — API calls

### **DevOps**
- **GitHub Actions** — CI/CD
- **Docker** (optional) — Containerization

---

## 🚀 Quick Start

### **Requirements**

- **Node.js** 18+
- **PostgreSQL** 14+ + **PostGIS**
- **Flutter** 3.19+
- **Git**

### **1️⃣ Automatic Setup (Recommended)**

```bash
# Clone repository
git clone https://github.com/EshtoshevShohjahon/AvtoHelp.git
cd AvtoHelp

# Automatic setup
chmod +x setup.sh
./setup.sh

# Start application
./start.sh
```

### **2️⃣ Manual Setup**

#### **Backend**

```bash
cd backend

# Dependencies
npm install

# .env file
cp .env.example .env
# Update database settings in .env

# Database
createdb avtohelp
psql -d avtohelp -c "CREATE EXTENSION postgis;"

# Migrations
npm run migrate

# Start server
npm start
```

#### **Mobile**

```bash
cd mobile

# Dependencies
flutter pub get

# Start emulator/device
flutter run
```

---

## 📐 Architecture

### **Backend Structure**

```
backend/
├── config/           # Database connection
├── controllers/      # Business logic
├── middleware/       # Auth, validation
├── models/           # Data models
├── routes/           # API endpoints
├── migrations/       # Database migrations
└── server.js         # Main server file
```

### **Mobile Structure**

```
mobile/lib/
├── models/           # Data models
├── providers/        # State management
├── screens/          # UI screens
│   ├── auth/         # Login, Register
│   ├── home/         # Home screen
│   ├── orders/       # Orders
│   ├── vehicle/      # Vehicle management
│   └── profile/      # Profile
└── utils/            # Utility functions
```

### **Database Schema**

8 main tables:

- `users` — Users
- `providers` — Service providers
- `orders` — Orders
- `vehicles` — Vehicles
- `oil_changes` — Oil change history
- `maintenance_reminders` — Reminders
- `services` — Services
- `notifications` — Notifications

---

## 📡 API Documentation

### **Base URL**

```
http://localhost:3000/api
```

### **Authentication**

#### **Register**

```http
POST /auth/register
Content-Type: application/json

{
  "phone": "+998901234567",
  "password": "password123",
  "full_name": "John Doe",
  "role": "client"
}
```

#### **Login**

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
      "full_name": "John Doe",
      "role": "client"
    }
  }
}
```

### **Orders**

#### **Create Order**

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
  "description": "Car won't start"
}
```

#### **Get Orders**

```http
GET /orders?status=pending
Authorization: Bearer {token}
```

### **Vehicles**

#### **Add Vehicle**

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

#### **Add Oil Change**

```http
POST /vehicles/{vehicle_id}/oil-changes
Authorization: Bearer {token}
Content-Type: application/json

{
  "oil_type": "Shell Helix Ultra 5W-40",
  "mileage": 87000,
  "price": 250000,
  "location": "Tashkent, Yunusobod"
}
```

---

## 🔧 Scripts

### **setup.sh** — One-time setup

```bash
./setup.sh
```

- Check PostgreSQL, Node.js, Flutter
- Install dependencies
- Create database and run migrations
- Configure `.env`

### **start.sh** — Quick start

```bash
./start.sh
```

- Start backend and mobile together
- Health check
- Auto device detection

### **build-apk.sh** — Build APK

```bash
./build-apk.sh
```

- Flutter clean
- Dependencies
- Release APK build
- Display APK info

### **test-api.sh** — API tests

```bash
./test-api.sh
```

- Test 8 main endpoints
- Colored output
- Pass/Fail statistics

---

## 🤖 GitHub Actions

### **Automatic APK Build**

On every push to `main` or `develop`:

1. ✅ Code analysis (Flutter analyze)
2. ✅ Tests (Flutter test)
3. ✅ APK build
4. ✅ Save as artifact (30 days)
5. ✅ On tag push — Create GitHub Release

### **Manual Trigger**

```bash
# On GitHub: Actions → Build Android APK → Run workflow
```

### **Download APK**

1. GitHub repository → **Actions**
2. Latest successful workflow
3. **Artifacts** → Download `avtohelp-release-{sha}`

---

## 📱 Demo

### **Login Credentials**

```
Phone:    +998901234567
Password: password123
```

### **Demo Data**

- 3 clients
- 4 service providers
- 2 vehicles (with oil change history)
- 1 reminder (500 km remaining)

---

## 🤝 Contributing

Want to contribute? Thank you! 🎉

1. **Fork** the project
2. Create feature branch (`git checkout -b feature/awesome-feature`)
3. Commit changes (`git commit -m 'Add awesome feature'`)
4. Push to branch (`git push origin feature/awesome-feature`)
5. Open **Pull Request**

---

## 📄 License

This project is licensed under **MIT License**. See [LICENSE](LICENSE)

---

## 👨‍💻 Author

**Eshtoshev Shohjahon**

- GitHub: [@EshtoshevShohjahon](https://github.com/EshtoshevShohjahon)
- Email: your.email@example.com

---

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev/)
- [Node.js](https://nodejs.org/)
- [PostgreSQL](https://www.postgresql.org/)
- [PostGIS](https://postgis.net/)

---

## 📞 Support

For questions or issues:

- **Issues** — [GitHub Issues](https://github.com/EshtoshevShohjahon/AvtoHelp/issues)
- **Discussions** — [GitHub Discussions](https://github.com/EshtoshevShohjahon/AvtoHelp/discussions)

---

<div align="center">
  
**⭐ If you find this project useful, give it a star! ⭐**

</div>
