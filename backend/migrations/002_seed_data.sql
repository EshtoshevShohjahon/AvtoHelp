-- Demo users (passwords: all are "password123")
-- Hashed password for "password123": $2a$10$rZ8PvZqCHlQJ4cV7K5nGHe5P6sXjZ7hPyRvL5K9qYJdQxZ9wP5L9u

-- Client users
INSERT INTO users (phone, password, full_name, role) VALUES
('+998901234567', '$2a$10$rZ8PvZqCHlQJ4cV7K5nGHe5P6sXjZ7hPyRvL5K9qYJdQxZ9wP5L9u', 'Alisher Navoiy', 'client'),
('+998902345678', '$2a$10$rZ8PvZqCHlQJ4cV7K5nGHe5P6sXjZ7hPyRvL5K9qYJdQxZ9wP5L9u', 'Nodira Begim', 'client'),
('+998903456789', '$2a$10$rZ8PvZqCHlQJ4cV7K5nGHe5P6sXjZ7hPyRvL5K9qYJdQxZ9wP5L9u', 'Bobur Mirzo', 'client')
ON CONFLICT (phone) DO NOTHING;

-- Provider users
INSERT INTO users (phone, password, full_name, role) VALUES
('+998911111111', '$2a$10$rZ8PvZqCHlQJ4cV7K5nGHe5P6sXjZ7hPyRvL5K9qYJdQxZ9wP5L9u', 'Usta Karim', 'provider'),
('+998922222222', '$2a$10$rZ8PvZqCHlQJ4cV7K5nGHe5P6sXjZ7hPyRvL5K9qYJdQxZ9wP5L9u', 'Yoqilg\'i Aziz', 'provider'),
('+998933333333', '$2a$10$rZ8PvZqCHlQJ4cV7K5nGHe5P6sXjZ7hPyRvL5K9qYJdQxZ9wP5L9u', 'Yuvuvchi Jamshid', 'provider'),
('+998944444444', '$2a$10$rZ8PvZqCHlQJ4cV7K5nGHe5P6sXjZ7hPyRvL5K9qYJdQxZ9wP5L9u', 'Evakuator Sanjar', 'provider')
ON CONFLICT (phone) DO NOTHING;

-- Providers with geo-locations (Tashkent coordinates)
INSERT INTO providers (user_id, service_type, current_location, is_available, rating, total_orders)
SELECT 
    u.id,
    'technical_help',
    ST_SetSRID(ST_MakePoint(69.2401, 41.2995), 4326)::geography,
    true,
    4.8,
    127
FROM users u WHERE u.phone = '+998911111111'
ON CONFLICT (user_id, service_type) DO NOTHING;

INSERT INTO providers (user_id, service_type, current_location, is_available, rating, total_orders)
SELECT 
    u.id,
    'fuel_delivery',
    ST_SetSRID(ST_MakePoint(69.2797, 41.3111), 4326)::geography,
    true,
    4.9,
    203
FROM users u WHERE u.phone = '+998922222222'
ON CONFLICT (user_id, service_type) DO NOTHING;

INSERT INTO providers (user_id, service_type, current_location, is_available, rating, total_orders)
SELECT 
    u.id,
    'car_wash',
    ST_SetSRID(ST_MakePoint(69.2495, 41.3247), 4326)::geography,
    true,
    4.7,
    89
FROM users u WHERE u.phone = '+998933333333'
ON CONFLICT (user_id, service_type) DO NOTHING;

INSERT INTO providers (user_id, service_type, current_location, is_available, rating, total_orders)
SELECT 
    u.id,
    'tow_truck',
    ST_SetSRID(ST_MakePoint(69.2150, 41.2856), 4326)::geography,
    true,
    4.6,
    54
FROM users u WHERE u.phone = '+998944444444'
ON CONFLICT (user_id, service_type) DO NOTHING;

-- Demo vehicles for first client
INSERT INTO vehicles (user_id, brand, model, year, plate_number, current_mileage, oil_change_interval)
SELECT 
    u.id,
    'Chevrolet',
    'Lacetti',
    2015,
    '01A777AA',
    87000,
    10000
FROM users u WHERE u.phone = '+998901234567'
ON CONFLICT DO NOTHING;

INSERT INTO vehicles (user_id, brand, model, year, plate_number, current_mileage, oil_change_interval)
SELECT 
    u.id,
    'Gentra',
    'GL',
    2020,
    '01B888BB',
    32000,
    10000
FROM users u WHERE u.phone = '+998902345678'
ON CONFLICT DO NOTHING;

-- Demo oil change records
INSERT INTO oil_changes (vehicle_id, oil_type, mileage, price, location, notes)
SELECT 
    v.id,
    'Shell Helix Ultra 5W-40',
    77000,
    250000,
    'Toshkent, Yunusobod',
    'To''liq yuvish bilan'
FROM vehicles v WHERE v.plate_number = '01A777AA'
ON CONFLICT DO NOTHING;

-- Maintenance reminders
INSERT INTO maintenance_reminders (vehicle_id, reminder_type, next_service_mileage, last_service_date)
SELECT 
    v.id,
    'oil_change',
    v.current_mileage + v.oil_change_interval,
    NOW() - INTERVAL '2 months'
FROM vehicles v
ON CONFLICT (vehicle_id, reminder_type) DO UPDATE SET
    next_service_mileage = EXCLUDED.next_service_mileage,
    last_service_date = EXCLUDED.last_service_date;

-- Demo notifications
INSERT INTO notifications (user_id, title, message, type, is_read)
SELECT 
    u.id,
    'Xush kelibsiz!',
    'AvtoHelp ilovasiga xush kelibsiz. Barcha avtomobil xizmatlarini bir joyda toping!',
    'welcome',
    false
FROM users u WHERE u.role = 'client'
ON CONFLICT DO NOTHING;

-- Success message
DO $$
BEGIN
    RAISE NOTICE '✅ Demo ma''lumotlar muvaffaqiyatli qo''shildi!';
    RAISE NOTICE '📱 Test uchun telefon: +998901234567, parol: password123';
END $$;
