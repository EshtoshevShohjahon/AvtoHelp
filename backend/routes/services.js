const express = require('express');
const router = express.Router();
const { authMiddleware } = require('../middleware/auth');
const pool = require('../config/database');

// Get all available services
router.get('/', async (req, res) => {
  try {
    const services = [
      {
        id: 'technical_help',
        name: 'Texnik yordam',
        name_uz: 'Texnik yordam',
        icon: '🔧',
        description: 'Yo\'lda qolgan avtomobilga tezkor texnik yordam',
        base_price: 50000
      },
      {
        id: 'fuel_delivery',
        name: 'Yoqilg\'i yetkazish',
        name_uz: 'Yoqilg\'i yetkazish',
        icon: '⛽',
        description: 'Benzin tugasa, sizga yetkazib beramiz',
        base_price: 30000
      },
      {
        id: 'car_wash',
        name: 'Avtomobil yuvish',
        name_uz: 'Avtomobil yuvish',
        icon: '🚿',
        description: 'Sifatli avtomobil yuvish xizmati',
        base_price: 25000
      },
      {
        id: 'parts_catalog',
        name: 'Ehtiyot qismlar',
        name_uz: 'Ehtiyot qismlar',
        icon: '🏪',
        description: 'Yaqin atrofdagi ehtiyot qismlar do\'konlari',
        base_price: 0
      },
      {
        id: 'workshops',
        name: 'Ustaxonalar',
        name_uz: 'Ustaxonalar',
        icon: '🏭',
        description: 'Yaqin atrofdagi avtomobil ustaxonalari',
        base_price: 0
      },
      {
        id: 'tow_truck',
        name: 'Evakuator',
        name_uz: 'Evakuator',
        icon: '🚚',
        description: 'Avtomobilni olib ketish xizmati',
        base_price: 100000
      }
    ];

    res.json({
      success: true,
      data: services
    });

  } catch (error) {
    console.error('Get services xatosi:', error);
    res.status(500).json({
      success: false,
      message: 'Xizmatlarni olishda xatolik',
      error: error.message
    });
  }
});

// Get service statistics
router.get('/stats', authMiddleware, async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        service_type,
        COUNT(*) as total_orders,
        COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed_orders,
        AVG(CASE WHEN rating IS NOT NULL THEN rating END) as avg_rating
      FROM orders
      GROUP BY service_type
    `);

    res.json({
      success: true,
      data: result.rows
    });

  } catch (error) {
    console.error('Get service stats xatosi:', error);
    res.status(500).json({
      success: false,
      message: 'Statistikani olishda xatolik',
      error: error.message
    });
  }
});

module.exports = router;
