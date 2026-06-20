const pool = require('../config/database');

// Create new order
exports.createOrder = async (req, res) => {
  const client = await pool.connect();
  try {
    const userId = req.user.id;
    const { 
      service_type, 
      description, 
      pickup_location, 
      destination_location,
      vehicle_info 
    } = req.body;

    // Validation
    if (!service_type || !pickup_location) {
      return res.status(400).json({
        success: false,
        message: 'Xizmat turi va manzil talab qilinadi'
      });
    }

    // Start transaction
    await client.query('BEGIN');

    // Insert order
    const orderResult = await client.query(
      `INSERT INTO orders 
       (user_id, service_type, description, pickup_location, destination_location, 
        vehicle_info, status, created_at) 
       VALUES ($1, $2, $3, ST_SetSRID(ST_MakePoint($4, $5), 4326), 
               ST_SetSRID(ST_MakePoint($6, $7), 4326), $8, 'pending', NOW()) 
       RETURNING id, user_id, service_type, description, 
                 ST_X(pickup_location::geometry) as pickup_lng,
                 ST_Y(pickup_location::geometry) as pickup_lat,
                 ST_X(destination_location::geometry) as dest_lng,
                 ST_Y(destination_location::geometry) as dest_lat,
                 vehicle_info, status, created_at`,
      [
        userId, 
        service_type, 
        description || null,
        pickup_location.longitude,
        pickup_location.latitude,
        destination_location?.longitude || null,
        destination_location?.latitude || null,
        vehicle_info ? JSON.stringify(vehicle_info) : null
      ]
    );

    const order = orderResult.rows[0];

    // Find available providers
    const providersResult = await client.query(
      `SELECT p.id, p.user_id, u.full_name, u.phone,
              ST_Distance(
                p.current_location::geography,
                ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography
              ) as distance,
              ST_X(p.current_location::geometry) as lng,
              ST_Y(p.current_location::geometry) as lat
       FROM providers p
       JOIN users u ON p.user_id = u.id
       WHERE p.service_type = $3 
         AND p.is_available = true 
         AND p.is_active = true
       ORDER BY distance
       LIMIT 10`,
      [pickup_location.longitude, pickup_location.latitude, service_type]
    );

    await client.query('COMMIT');

    res.status(201).json({
      success: true,
      message: 'Buyurtma yaratildi',
      data: {
        order: {
          ...order,
          pickup_location: {
            latitude: order.pickup_lat,
            longitude: order.pickup_lng
          },
          destination_location: order.dest_lat ? {
            latitude: order.dest_lat,
            longitude: order.dest_lng
          } : null
        },
        available_providers: providersResult.rows.map(p => ({
          id: p.id,
          user_id: p.user_id,
          full_name: p.full_name,
          phone: p.phone,
          distance: Math.round(p.distance),
          location: {
            latitude: p.lat,
            longitude: p.lng
          }
        }))
      }
    });

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Create order xatosi:', error);
    res.status(500).json({
      success: false,
      message: 'Buyurtma yaratishda xatolik',
      error: error.message
    });
  } finally {
    client.release();
  }
};

// Get user orders
exports.getUserOrders = async (req, res) => {
  try {
    const userId = req.user.id;
    const { status } = req.query;

    let query = `
      SELECT o.id, o.service_type, o.description,
             ST_X(o.pickup_location::geometry) as pickup_lng,
             ST_Y(o.pickup_location::geometry) as pickup_lat,
             ST_X(o.destination_location::geometry) as dest_lng,
             ST_Y(o.destination_location::geometry) as dest_lat,
             o.vehicle_info, o.status, o.created_at, o.completed_at,
             o.price, o.rating, o.review,
             p.id as provider_id, u.full_name as provider_name, u.phone as provider_phone
      FROM orders o
      LEFT JOIN providers p ON o.provider_id = p.id
      LEFT JOIN users u ON p.user_id = u.id
      WHERE o.user_id = $1
    `;

    const params = [userId];

    if (status) {
      query += ` AND o.status = $2`;
      params.push(status);
    }

    query += ` ORDER BY o.created_at DESC`;

    const result = await pool.query(query, params);

    res.json({
      success: true,
      data: result.rows.map(order => ({
        id: order.id,
        service_type: order.service_type,
        description: order.description,
        pickup_location: {
          latitude: order.pickup_lat,
          longitude: order.pickup_lng
        },
        destination_location: order.dest_lat ? {
          latitude: order.dest_lat,
          longitude: order.dest_lng
        } : null,
        vehicle_info: order.vehicle_info,
        status: order.status,
        created_at: order.created_at,
        completed_at: order.completed_at,
        price: order.price,
        rating: order.rating,
        review: order.review,
        provider: order.provider_id ? {
          id: order.provider_id,
          name: order.provider_name,
          phone: order.provider_phone
        } : null
      }))
    });

  } catch (error) {
    console.error('Get user orders xatosi:', error);
    res.status(500).json({
      success: false,
      message: 'Buyurtmalarni olishda xatolik',
      error: error.message
    });
  }
};

// Get order by ID
exports.getOrderById = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const result = await pool.query(
      `SELECT o.id, o.user_id, o.service_type, o.description,
              ST_X(o.pickup_location::geometry) as pickup_lng,
              ST_Y(o.pickup_location::geometry) as pickup_lat,
              ST_X(o.destination_location::geometry) as dest_lng,
              ST_Y(o.destination_location::geometry) as dest_lat,
              o.vehicle_info, o.status, o.created_at, o.completed_at,
              o.price, o.rating, o.review,
              p.id as provider_id, u.full_name as provider_name, 
              u.phone as provider_phone, u.avatar_url as provider_avatar
       FROM orders o
       LEFT JOIN providers p ON o.provider_id = p.id
       LEFT JOIN users u ON p.user_id = u.id
       WHERE o.id = $1 AND (o.user_id = $2 OR p.user_id = $2)`,
      [id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Buyurtma topilmadi'
      });
    }

    const order = result.rows[0];

    res.json({
      success: true,
      data: {
        id: order.id,
        user_id: order.user_id,
        service_type: order.service_type,
        description: order.description,
        pickup_location: {
          latitude: order.pickup_lat,
          longitude: order.pickup_lng
        },
        destination_location: order.dest_lat ? {
          latitude: order.dest_lat,
          longitude: order.dest_lng
        } : null,
        vehicle_info: order.vehicle_info,
        status: order.status,
        created_at: order.created_at,
        completed_at: order.completed_at,
        price: order.price,
        rating: order.rating,
        review: order.review,
        provider: order.provider_id ? {
          id: order.provider_id,
          name: order.provider_name,
          phone: order.provider_phone,
          avatar_url: order.provider_avatar
        } : null
      }
    });

  } catch (error) {
    console.error('Get order by ID xatosi:', error);
    res.status(500).json({
      success: false,
      message: 'Buyurtmani olishda xatolik',
      error: error.message
    });
  }
};

// Cancel order
exports.cancelOrder = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const result = await pool.query(
      `UPDATE orders 
       SET status = 'cancelled', completed_at = NOW()
       WHERE id = $1 AND user_id = $2 AND status IN ('pending', 'accepted')
       RETURNING id, status`,
      [id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Buyurtmani bekor qilib bo\'lmaydi'
      });
    }

    res.json({
      success: true,
      message: 'Buyurtma bekor qilindi',
      data: result.rows[0]
    });

  } catch (error) {
    console.error('Cancel order xatosi:', error);
    res.status(500).json({
      success: false,
      message: 'Buyurtmani bekor qilishda xatolik',
      error: error.message
    });
  }
};

// Rate order
exports.rateOrder = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;
    const { rating, review } = req.body;

    if (!rating || rating < 1 || rating > 5) {
      return res.status(400).json({
        success: false,
        message: 'Reyting 1 dan 5 gacha bo\'lishi kerak'
      });
    }

    const result = await pool.query(
      `UPDATE orders 
       SET rating = $1, review = $2
       WHERE id = $3 AND user_id = $4 AND status = 'completed'
       RETURNING id, rating, review`,
      [rating, review || null, id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Buyurtmani baholab bo\'lmaydi'
      });
    }

    res.json({
      success: true,
      message: 'Buyurtma baholandi',
      data: result.rows[0]
    });

  } catch (error) {
    console.error('Rate order xatosi:', error);
    res.status(500).json({
      success: false,
      message: 'Buyurtmani baholashda xatolik',
      error: error.message
    });
  }
};
