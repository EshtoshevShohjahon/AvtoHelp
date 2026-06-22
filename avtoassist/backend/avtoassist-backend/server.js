require('dotenv').config();

const express = require('express');
const http = require('http');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const { Server } = require('socket.io');

const sequelize = require('./src/config/database');
require('./src/models');

const i18nMiddleware = require('./src/middleware/i18n.middleware');
const { notFoundHandler, errorHandler } = require('./src/middleware/errorHandler');
const apiRoutes = require('./src/routes');

const app = express();
const server = http.createServer(app);
const io = new Server(server, { cors: { origin: '*' } });

app.use(helmet());
app.use(cors());
app.use(express.json({ limit: '5mb' }));
app.use(morgan(process.env.NODE_ENV === 'production' ? 'combined' : 'dev'));
app.use(i18nMiddleware);

const authLimiter = rateLimit({ windowMs: 60 * 1000, max: 10 });
app.use('/api/auth', authLimiter);

const apiLimiter = rateLimit({ windowMs: 60 * 1000, max: 120 });
app.use('/api', apiLimiter);

app.use('/api', apiRoutes);
app.get('/health', (req, res) => res.json({ status: 'ok', time: new Date().toISOString() }));

app.use(notFoundHandler);
app.use(errorHandler);

io.on('connection', (socket) => {
  socket.on('join_order', (orderId) => {
    socket.join(`order_${orderId}`);
  });
  socket.on('join_provider', (providerId) => {
    socket.join(`provider_${providerId}`);
  });
  socket.on('disconnect', () => {});
});

app.set('io', io);

const PORT = process.env.PORT || 4000;

async function start() {
  try {
    await sequelize.authenticate();
    console.log(`✅ Ma'lumotlar bazasiga ulanish muvaffaqiyatli (${process.env.DB_DIALECT || 'sqlite'})`);
    await sequelize.sync({ alter: process.env.NODE_ENV !== 'production' });
    console.log('✅ Jadvallar tayyor');
    server.listen(PORT, () => {
      console.log(`\u{1F680} AvtoAssist API http://localhost:${PORT} portida ishga tushdi`);
      console.log(`   Sog'liqni tekshirish: http://localhost:${PORT}/health`);
      console.log(`   API: http://localhost:${PORT}/api`);
    });
  } catch (err) {
    console.error('❌ Ishga tushirishda xatolik:', err);
    process.exit(1);
  }
}

start();

module.exports = { app, server, io };
