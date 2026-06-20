const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('../config/database');

// Register new user
exports.register = async (req, res) => {
  const client = await pool.connect();
  try {
    const { phone, password, full_name, role } = req.body;

    // Validation
    if (!phone || !password || !full_name || !role) {
      return res.status(400).json({
        success: false,
        message: 'Barcha maydonlarni to\'ldiring'
      });
    }

    if (!['client', 'provider'].includes(role)) {
      return res.status(400).json({
        success: false,
        message: 'Rol client yoki provider bo\'lishi kerak'
      });
    }

    // Check if user exists
    const existingUser = await client.query(
      'SELECT id FROM users WHERE phone = $1',
      [phone]
    );

    if (existingUser.rows.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Bu telefon raqami allaqachon ro\'yxatdan o\'tgan'
      });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insert user
    const result = await client.query(
      `INSERT INTO users (phone, password, full_name, role, created_at) 
       VALUES ($1, $2, $3, $4, NOW()) 
       RETURNING id, phone, full_name, role, created_at`,
      [phone, hashedPassword, full_name, role]
    );

    const user = result.rows[0];

    // Generate JWT token
    const token = jwt.sign(
      { 
        id: user.id, 
        phone: user.phone, 
        role: user.role 
      },
      process.env.JWT_SECRET,
      { expiresIn: '30d' }
    );

    res.status(201).json({
      success: true,
      message: 'Ro\'yxatdan o\'tish muvaffaqiyatli',
      data: {
        user: {
          id: user.id,
          phone: user.phone,
          full_name: user.full_name,
          role: user.role,
          created_at: user.created_at
        },
        token
      }
    });

  } catch (error) {
    console.error('Register xatosi:', error);
    res.status(500).json({
      success: false,
      message: 'Ro\'yxatdan o\'tishda xatolik',
      error: error.message
    });
  } finally {
    client.release();
  }
};

// Login
exports.login = async (req, res) => {
  try {
    const { phone, password } = req.body;

    if (!phone || !password) {
      return res.status(400).json({
        success: false,
        message: 'Telefon va parol talab qilinadi'
      });
    }

    // Find user
    const result = await pool.query(
      'SELECT * FROM users WHERE phone = $1',
      [phone]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({
        success: false,
        message: 'Telefon yoki parol noto\'g\'ri'
      });
    }

    const user = result.rows[0];

    // Check password
    const isValidPassword = await bcrypt.compare(password, user.password);
    if (!isValidPassword) {
      return res.status(401).json({
        success: false,
        message: 'Telefon yoki parol noto\'g\'ri'
      });
    }

    // Generate token
    const token = jwt.sign(
      { 
        id: user.id, 
        phone: user.phone, 
        role: user.role 
      },
      process.env.JWT_SECRET,
      { expiresIn: '30d' }
    );

    res.json({
      success: true,
      message: 'Tizimga kirish muvaffaqiyatli',
      data: {
        user: {
          id: user.id,
          phone: user.phone,
          full_name: user.full_name,
          role: user.role,
          avatar_url: user.avatar_url,
          created_at: user.created_at
        },
        token
      }
    });

  } catch (error) {
    console.error('Login xatosi:', error);
    res.status(500).json({
      success: false,
      message: 'Tizimga kirishda xatolik',
      error: error.message
    });
  }
};

// Get current user profile
exports.getProfile = async (req, res) => {
  try {
    const userId = req.user.id;

    const result = await pool.query(
      `SELECT id, phone, full_name, role, avatar_url, created_at 
       FROM users WHERE id = $1`,
      [userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Foydalanuvchi topilmadi'
      });
    }

    res.json({
      success: true,
      data: result.rows[0]
    });

  } catch (error) {
    console.error('Get profile xatosi:', error);
    res.status(500).json({
      success: false,
      message: 'Profil ma\'lumotlarini olishda xatolik',
      error: error.message
    });
  }
};
