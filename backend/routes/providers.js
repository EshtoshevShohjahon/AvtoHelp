const express = require('express');
const router = express.Router();
const { authMiddleware, roleMiddleware } = require('../middleware/auth');
const pool = require('../config/database');

// Get nearby providers
router.get('/nearby', authMiddleware, async (req, res) => {
  try {
    const { latitude, longitude, service_type, radius } = req.query;

    if (!latitude || !longitude) {
      return res.status(400).json({
        success: false,
        message: 'Latitude va longitude talab qilinadi'
      });
    }

    let query = `
      SELECT p.id, p.user_id, p.service_type, p.rating,
             u.full_name, u.phone, u.avatar_url,
             ST_Distance(
               p.current_location::geography,
               ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography
             ) as distance,
             ST_X(p.current_location::geometry) as lng,
             ST_Y(p.current_location::geometry) as lat
      FROM providers p
      JOIN users u ON p.user_id = u.id
      WHERE p.is_available = true AND p.is_active = true
    `;

    const params = [longitude, latitude];

    if (service_type) {
      query += ` AND p.service_type = $${params.length + 1}`;
      params.push(service_type);
    }

    if (radius) {
      query += ` AND ST_DWithin(
        p.current_location::geography,
        ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography,
        $${params.length + 1}
      )`;
      params.push(radius);
    }

    query += ` ORDER BY distance LIMIT 50`;

    const result = await pool.query(query, params);

    res.json({
      success: true,
      data: result.rows.map(p => ({
        id: p.id,
        user_id: p.user_id,
        full_name: p.full_name,
        phone: p.phone,
        avatar_url: p.avatar_url,
        service_type: p.service_type,
        rating: p.rating,
        distance: Math.round(p.distance),
        location: {
          latitude: p.lat,
          longitude: p.lng
        }
      }))
    });

  } catch (error) {
    console.error('Get nearby providers xatosi:', error);
    res.status(500).json({
      success: false,
      message: 'Providerlarni olishda xatolik',
      error: error.message
    });
  }
});

// Get provider by ID
router.get('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      `SELECT p.*, u.full_name, u.phone, u.avatar_url,
              ST_X(p.current_location::geometry) as lng,
              ST_Y(p.current_location::geometry) as lat
       FROM providers p
       JOIN users u ON p.user_id = u.id
       WHERE p.id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Provider topilmadi'
      });
    }

    const provider = result.rows[0];

    res.json({
      success: true,
      data: {
        ...provider,
        location: {
          latitude: provider.lat,
          longitude: provider.lng
        }
      }
    });

  } catch (error) {
    console.error('Get provider xatosi:', error);
    res.status(500).json({
      success: false,
      message: 'Providerni olishda xatolik',
      error: error.message
    });
  }
});

// Update provider availability (for providers only)
router.patch('/availability', authMiddleware, roleMiddleware(['provider']), async (req, res) => {
  try {
    const userId = req.user.id;
    const { is_available } = req.body;

    const result = await pool.query(
      `UPDATE providers 
       SET is_available = $1
       WHERE user_id = $2
       RETURNING id, is_available`,
      [is_available, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Provider topilmadi'
      });
    }

    res.json({
      success: true,
      message: `Status: ${is_available ? 'Mavjud' : 'Band'}`,
      data: result.rows[0]
    });

  } catch (error) {
    console.error('Update availability xatosi:', error);
    res.status(500).json({
      success: false,
      message: 'Statusni yangilashda xatolik',
      error: error.message
    });
  }
});

// Update provider location (for providers only)
router.patch('/location', authMiddleware, roleMiddleware(['provider']), async (req, res) => {
  try {
    const userId = req.user.id;
    const { latitude, longitude } = req.body;

    if (!latitude || !longitude) {
      return res.status(400).json({
        success: false,
        message: 'Latitude va longitude talab qilinadi'
      });
    }

    const result = await pool.query(
      `UPDATE providers 
       SET current_location = ST_SetSRID(ST_MakePoint($1, $2), 4326)
       WHERE user_id = $3
       RETURNING id`,
      [longitude, latitude, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Provider topilmadi'
      });
    }

    res.json({
      success: true,
      message: 'Joylashuv yangilandi'
    });

  } catch (error) {
    console.error('Update location xatosi:', error);
    res.status(500).json({
      success: false,
      message: 'Joylashuvni yangilashda xatolik',
      error: error.message
    });
  }
});

module.exports = router;
