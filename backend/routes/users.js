const express = require('express');
const router = express.Router();
const { authMiddleware } = require('../middleware/auth');
const pool = require('../config/database');

// Update user profile
router.put('/profile', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id;
    const { full_name, avatar_url } = req.body;

    const result = await pool.query(
      `UPDATE users 
       SET full_name = COALESCE($1, full_name),
           avatar_url = COALESCE($2, avatar_url)
       WHERE id = $3
       RETURNING id, phone, full_name, role, avatar_url, created_at`,
      [full_name, avatar_url, userId]
    );

    res.json({
      success: true,
      message: 'Profil yangilandi',
      data: result.rows[0]
    });

  } catch (error) {
    console.error('Update profile xatosi:', error);
    res.status(500).json({
      success: false,
      message: 'Profilni yangilashda xatolik',
      error: error.message
    });
  }
});

module.exports = router;
