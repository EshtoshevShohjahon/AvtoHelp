# AvtoAssist Backend

Node.js + Express + Sequelize REST API with Socket.IO real-time support.

## Quickstart

```bash
npm install
cp .env.example .env
npm run dev          # http://localhost:4000
```

## Seed sample data

```bash
node seed.js
```

## Environment variables

| Variable | Default | Description |
|---|---|---|
| `PORT` | `4000` | Server port |
| `NODE_ENV` | `development` | Environment |
| `JWT_SECRET` | — | Required in production |
| `DB_DIALECT` | `sqlite` | `sqlite` or `postgres` |
| `DB_HOST` | `localhost` | Postgres host |
| `DB_PORT` | `5432` | Postgres port |
| `DB_NAME` | `avtoassist` | Postgres DB name |
| `DB_USER` | `postgres` | Postgres user |
| `DB_PASS` | — | Postgres password |
| `OTP_DEBUG_MODE` | `true` | Returns OTP in response (dev only) |
| `OTP_EXPIRY_MINUTES` | `5` | OTP lifetime |

## API Endpoints

| Method | Path | Auth | Description |
|---|---|---|---|
| POST | `/api/auth/send-otp` | — | Send OTP to phone |
| POST | `/api/auth/verify-otp` | — | Verify OTP, get tokens |
| POST | `/api/auth/refresh` | — | Refresh access token |
| POST | `/api/auth/logout` | — | Revoke refresh token |
| GET | `/api/users/me` | JWT | Get current user |
| PATCH | `/api/users/me` | JWT | Update profile |
| GET | `/api/users/me/vehicles` | JWT | List vehicles |
| POST | `/api/users/me/vehicles` | JWT | Add vehicle |
| DELETE | `/api/users/me/vehicles/:id` | JWT | Remove vehicle |
| POST | `/api/providers/register` | JWT | Register as provider (KYC) |
| GET | `/api/providers/me` | JWT | Get provider profile |
| PATCH | `/api/providers/me/status` | JWT | Toggle online/offline |
| PATCH | `/api/providers/me/location` | JWT | Update GPS location |
| POST | `/api/orders` | JWT | Create order |
| GET | `/api/orders/mine` | JWT | List my orders |
| GET | `/api/orders/:id` | JWT | Get order |
| PATCH | `/api/orders/:id/status` | JWT | Update order status |
| GET | `/api/parts-stores/nearby` | JWT | Nearby parts stores |
| GET | `/api/parts-stores/:id/inventory` | JWT | Store inventory |
| GET | `/api/workshops/nearby` | JWT | Nearby workshops |
| GET | `/api/workshops/:id` | JWT | Workshop detail |
| POST | `/api/payments` | JWT | Process payment |
| POST | `/api/reviews` | JWT | Submit review |
| GET | `/api/reviews/:providerId` | JWT | Provider reviews |
| GET | `/api/content/services` | — | Service list |
| GET | `/health` | — | Health check |

## Socket.IO Events

| Event | Direction | Payload |
|---|---|---|
| `join_order` | client→server | `{ orderId }` |
| `order_update` | server→client | `{ status }` |
| `join_provider` | client→server | `{ providerId }` |
| `provider_location` | server→broadcast | `{ providerId, lat, lon }` |
| `new_order` | server→provider | `{ orderId }` |
