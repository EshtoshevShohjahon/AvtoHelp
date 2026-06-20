const express = require('express');
const router = express.Router();
const { authMiddleware } = require('../middleware/auth');
const pool = require('../config/database');

// Get user notifications
router.get('/', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id;
    const { unread_only } = req.query;

    let query = `
      SELECT * FROM notifications
      WHERE user_id = $1
    `;

    if (unread_only === 'true') {
      query += ` AND is_read = false`;
    }

    query += ` ORDER BY created_at DESC LIMIT 50`;

    const result = await pool.query(query, [userId]);

    res.json({
      success: true,
      data: result.rows
    });

  } catch (error) {
    console.error('Get notifications xatosi:', error);
    res.status(500).json({
      success: false,
      message: 'Bildirishnomalarni olishda xatolik',
      error: error.message
    });
  }
});

// Mark notification as read
router.patch('/:id/read', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const result = await pool.query(
      `UPDATE notifications 
       SET is_read = true
       WHERE id = $1 AND user_id = $2
       RETURNING id, is_read`,
      [id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Bildirishnoma topilmadi'
      });
    }

    res.json({
      success: true,
      message: 'Bildirishnoma o\'qilgan deb belgilandi',
      data: result.rows[0]
    });

  } catch (error) {
    console.error('Mark notification read xatosi:', error);
    res.status(500).json({
      success: false,
      message: 'Bildirishnomani yangilashda xatolik',
      error: error.message
    });
  }
});

// Mark all notifications as read
router.patch('/read-all', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id;

    const result = await pool.query(
      `UPDATE notifications 
       SET is_read = true
       WHERE user_id = $1 AND is_read = false
       RETURNING id`,
      [userId]
    );

    res.json({
      success: true,
      message: `${result.rows.length} ta bildirishnoma o'qilgan deb belgilandi`
    });

  } catch (error) {
    console.error('Mark all read xatosi:', error);
    res.status(500).json({
      success: false,
      message: 'Bildirishnomalarni yangilashda xatolik',
      error: error.message
    });
  }
});

module.exports = router;
