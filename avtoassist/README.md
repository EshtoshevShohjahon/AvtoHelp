# AvtoAssist

**Avtomobil xizmatlari agregatori** — yo'lda qolib ketganda yordamga chaqirish, evakuator, yoqilg'i, moyka, ehtiyot qismlar va ustaxona xizmatlarini bir joydan topish uchun platforma.

## Loyiha tuzilmasi

```
AvtoAssist/
├── backend/          # Node.js + Express + Sequelize API
│   └── avtoassist-backend/
└── mobile/           # Flutter mobil ilova
    └── avtoassist_mobile/
```

## Backend

**Texnologiyalar:** Node.js, Express, Sequelize (SQLite / PostgreSQL), Socket.IO, JWT

### Ishga tushirish

```bash
cd backend/avtoassist-backend
npm install
cp .env.example .env
npm run dev
```

## Mobile (Flutter)

```bash
cd mobile/avtoassist_mobile
flutter pub get
flutter run
```
