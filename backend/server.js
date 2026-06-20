const express = require('express');
const http = require('http');
const socketIO = require('socket.io');
const cors = require('cors');
const morgan = require('morgan');
require('dotenv').config();

const app = express();
const server = http.createServer(app);
const io = socketIO(server, {
  cors: {
    origin: process.env.SOCKET_CORS_ORIGIN || '*',
    methods: ['GET', 'POST']
  }
});

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(morgan('dev'));

// Database connection test
const pool = require('./config/database');
pool.query('SELECT NOW()', (err, res) => {
  if (err) {
    console.error('❌ Database ulanishida xatolik:', err.message);
  } else {
    console.log('✅ Database ulanishi muvaffaqiyatli:', res.rows[0].now);
  }
});

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/users', require('./routes/users'));
app.use('/api/providers', require('./routes/providers'));
app.use('/api/services', require('./routes/services'));
app.use('/api/orders', require('./routes/orders'));
app.use('/api/vehicles', require('./routes/vehicles'));
app.use('/api/notifications', require('./routes/notifications'));

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    message: 'AvtoHelp Backend ishlayapti',
    timestamp: new Date().toISOString()
  });
});

// Socket.IO - Real-time order tracking
const activeUsers = new Map(); // userId -> socketId

io.on('connection', (socket) => {
  console.log('🔌 Yangi foydalanuvchi ulandi:', socket.id);

  // User registers their ID
  socket.on('register', (userId) => {
    activeUsers.set(userId, socket.id);
    console.log(`👤 User ${userId} ro'yxatga olindi (socket: ${socket.id})`);
  });

  // Provider location update
  socket.on('provider-location', (data) => {
    const { orderId, location } = data;
    // Broadcast to client who made this order
    socket.broadcast.emit(`order-${orderId}-location`, location);
  });

  // Order status update
  socket.on('order-status-update', (data) => {
    const { orderId, status, userId } = data;
    const clientSocket = activeUsers.get(userId);
    if (clientSocket) {
      io.to(clientSocket).emit('order-status', { orderId, status });
    }
  });

  socket.on('disconnect', () => {
    // Remove user from active users
    for (let [userId, socketId] of activeUsers.entries()) {
      if (socketId === socket.id) {
        activeUsers.delete(userId);
        console.log(`👤 User ${userId} uzildi`);
        break;
      }
    }
    console.log('🔌 Foydalanuvchi uzildi:', socket.id);
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('❌ Server xatosi:', err.stack);
  res.status(500).json({
    success: false,
    message: 'Serverda xatolik yuz berdi',
    error: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'API endpoint topilmadi'
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`🚀 AvtoHelp Backend ishga tushdi: http://localhost:${PORT}`);
  console.log(`📡 Socket.IO server ishlayapti`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
});

module.exports = { app, server, io };
