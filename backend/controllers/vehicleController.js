const pool = require('../config/database');

// Add new vehicle
exports.addVehicle = async (req, res) => {
  try {
    const userId = req.user.id;
    const { 
      brand, 
      model, 
      year, 
      plate_number, 
      current_mileage,
      oil_change_interval 
    } = req.body;

    if (!brand || !model || !year || !plate_number || !current_mileage) {
      return res.status(400).json({
        success: false,
        message: 'Barcha majburiy maydonlarni to\'ldiring'
      });
    }

    const result = await pool.query(
      `INSERT INTO vehicles 
       (user_id, brand, model, year, plate_number, current_mileage, oil_change_interval, created_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, NOW())
       RETURNING *`,
      [
        userId, 
        brand, 
        model, 
        year, 
        plate_number, 
        current_mileage,
        oil_change_interval || 10000
      ]
    );

    res.status(201).json({
      success: true,
      message: 'Avtomobil qo\'shildi',
      data: result.rows[0]
    });

  } catch (error) {
    console.error('Add vehicle xatosi:', error);
    res.status(500).json({
      success: false,
      message: 'Avtomobil qo\'shishda xatolik',
      error: error.message
    });
  }
};

// Get user vehicles
exports.getUserVehicles = async (req, res) => {
  try {
    const userId = req.user.id;

    const result = await pool.query(
      `SELECT v.*,
              (SELECT COUNT(*) FROM oil_changes WHERE vehicle_id = v.id) as oil_change_count,
              (SELECT change_date FROM oil_changes WHERE vehicle_id = v.id ORDER BY change_date DESC LIMIT 1) as last_oil_change
       FROM vehicles v
       WHERE v.user_id = $1
       ORDER BY v.created_at DESC`,
      [userId]
    );

    res.json({
      success: true,
      data: result.rows
    });

  } catch (error) {
    console.error('Get vehicles xatosi:', error);
    res.status(500).json({
      success: false,
      message: 'Avtomobillarni olishda xatolik',
      error: error.message
    });
  }
};

// Get vehicle by ID
exports.getVehicleById = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const result = await pool.query(
      `SELECT v.*,
              (SELECT COUNT(*) FROM oil_changes WHERE vehicle_id = v.id) as oil_change_count,
              (SELECT change_date FROM oil_changes WHERE vehicle_id = v.id ORDER BY change_date DESC LIMIT 1) as last_oil_change
       FROM vehicles v
       WHERE v.id = $1 AND v.user_id = $2`,
      [id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Avtomobil topilmadi'
      });
    }

    res.json({
      success: true,
      data: result.rows[0]
    });

  } catch (error) {
    console.error('Get vehicle xatosi:', error);
    res.status(500).json({
      success: false,
      message: 'Avtomobilni olishda xatolik',
      error: error.message
    });
  }
};

// Update vehicle
exports.updateVehicle = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;
    const { 
      brand, 
      model, 
      year, 
      plate_number, 
      current_mileage,
      oil_change_interval 
    } = req.body;

    const result = await pool.query(
      `UPDATE vehicles 
       SET brand = COALESCE($1, brand),
           model = COALESCE($2, model),
           year = COALESCE($3, year),
           plate_number = COALESCE($4, plate_number),
           current_mileage = COALESCE($5, current_mileage),
           oil_change_interval = COALESCE($6, oil_change_interval)
       WHERE id = $7 AND user_id = $8
       RETURNING *`,
      [brand, model, year, plate_number, current_mileage, oil_change_interval, id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Avtomobil topilmadi'
      });
    }

    res.json({
      success: true,
      message: 'Avtomobil yangilandi',
      data: result.rows[0]
    });

  } catch (error) {
    console.error('Update vehicle xatosi:', error);
    res.status(500).json({
      success: false,
      message: 'Avtomobilni yangilashda xatolik',
      error: error.message
    });
  }
};

// Delete vehicle
exports.deleteVehicle = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const result = await pool.query(
      'DELETE FROM vehicles WHERE id = $1 AND user_id = $2 RETURNING id',
      [id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Avtomobil topilmadi'
      });
    }

    res.json({
      success: true,
      message: 'Avtomobil o\'chirildi'
    });

  } catch (error) {
    console.error('Delete vehicle xatosi:', error);
    res.status(500).json({
      success: false,
      message: 'Avtomobilni o\'chirishda xatolik',
      error: error.message
    });
  }
};

// Add oil change record
exports.addOilChange = async (req, res) => {
  const client = await pool.connect();
  try {
    const userId = req.user.id;
    const { vehicle_id } = req.params;
    const { 
      oil_type, 
      mileage, 
      price, 
      location, 
      notes 
    } = req.body;

    if (!oil_type || !mileage) {
      return res.status(400).json({
        success: false,
        message: 'Moy turi va kilometr talab qilinadi'
      });
    }

    await client.query('BEGIN');

    // Verify vehicle belongs to user
    const vehicleCheck = await client.query(
      'SELECT id, oil_change_interval FROM vehicles WHERE id = $1 AND user_id = $2',
      [vehicle_id, userId]
    );

    if (vehicleCheck.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({
        success: false,
        message: 'Avtomobil topilmadi'
      });
    }

    const vehicle = vehicleCheck.rows[0];

    // Add oil change record
    const oilChangeResult = await client.query(
      `INSERT INTO oil_changes 
       (vehicle_id, oil_type, mileage, price, location, notes, change_date)
       VALUES ($1, $2, $3, $4, $5, $6, NOW())
       RETURNING *`,
      [vehicle_id, oil_type, mileage, price || null, location || null, notes || null]
    );

    // Create maintenance reminder
    const nextOilChangeMileage = parseInt(mileage) + vehicle.oil_change_interval;
    
    await client.query(
      `INSERT INTO maintenance_reminders 
       (vehicle_id, reminder_type, next_service_mileage, last_service_date)
       VALUES ($1, 'oil_change', $2, NOW())
       ON CONFLICT (vehicle_id, reminder_type) 
       DO UPDATE SET 
         next_service_mileage = $2,
         last_service_date = NOW(),
         is_notified = false`,
      [vehicle_id, nextOilChangeMileage]
    );

    // Update vehicle current mileage
    await client.query(
      'UPDATE vehicles SET current_mileage = $1 WHERE id = $2',
      [mileage, vehicle_id]
    );

    await client.query('COMMIT');

    res.status(201).json({
      success: true,
      message: 'Moy almashtirish qayd etildi',
      data: {
        oil_change: oilChangeResult.rows[0],
        next_oil_change_mileage: nextOilChangeMileage
      }
    });

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Add oil change xatosi:', error);
    res.status(500).json({
      success: false,
      message: 'Moy almashtirish qo\'shishda xatolik',
      error: error.message
    });
  } finally {
    client.release();
  }
};

// Get oil change history
exports.getOilChangeHistory = async (req, res) => {
  try {
    const userId = req.user.id;
    const { vehicle_id } = req.params;

    // Verify vehicle belongs to user
    const vehicleCheck = await pool.query(
      'SELECT id FROM vehicles WHERE id = $1 AND user_id = $2',
      [vehicle_id, userId]
    );

    if (vehicleCheck.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Avtomobil topilmadi'
      });
    }

    const result = await pool.query(
      `SELECT * FROM oil_changes 
       WHERE vehicle_id = $1 
       ORDER BY change_date DESC`,
      [vehicle_id]
    );

    res.json({
      success: true,
      data: result.rows
    });

  } catch (error) {
    console.error('Get oil change history xatosi:', error);
    res.status(500).json({
      success: false,
      message: 'Moy almashtirish tarixini olishda xatolik',
      error: error.message
    });
  }
};

// Get maintenance reminders
exports.getMaintenanceReminders = async (req, res) => {
  try {
    const userId = req.user.id;

    const result = await pool.query(
      `SELECT mr.*, v.brand, v.model, v.plate_number, v.current_mileage
       FROM maintenance_reminders mr
       JOIN vehicles v ON mr.vehicle_id = v.id
       WHERE v.user_id = $1
       ORDER BY (mr.next_service_mileage - v.current_mileage)`,
      [userId]
    );

    res.json({
      success: true,
      data: result.rows.map(reminder => ({
        ...reminder,
        mileage_remaining: reminder.next_service_mileage - reminder.current_mileage,
        should_notify: (reminder.next_service_mileage - reminder.current_mileage) <= 500
      }))
    });

  } catch (error) {
    console.error('Get reminders xatosi:', error);
    res.status(500).json({
      success: false,
      message: 'Eslatmalarni olishda xatolik',
      error: error.message
    });
  }
};
