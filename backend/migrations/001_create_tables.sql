-- Enable PostGIS extension for geolocation
CREATE EXTENSION IF NOT EXISTS postgis;

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    phone VARCHAR(20) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('client', 'provider')),
    avatar_url TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_role ON users(role);

-- Providers table
CREATE TABLE IF NOT EXISTS providers (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    service_type VARCHAR(50) NOT NULL CHECK (service_type IN (
        'technical_help', 
        'fuel_delivery', 
        'car_wash', 
        'parts_catalog', 
        'workshops',
        'tow_truck'
    )),
    current_location GEOGRAPHY(POINT, 4326),
    is_available BOOLEAN DEFAULT true,
    is_active BOOLEAN DEFAULT true,
    rating DECIMAL(3,2) DEFAULT 5.0,
    total_orders INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, service_type)
);

CREATE INDEX idx_providers_service_type ON providers(service_type);
CREATE INDEX idx_providers_location ON providers USING GIST(current_location);
CREATE INDEX idx_providers_available ON providers(is_available, is_active);

-- Orders table
CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    provider_id INTEGER REFERENCES providers(id) ON DELETE SET NULL,
    service_type VARCHAR(50) NOT NULL,
    description TEXT,
    pickup_location GEOGRAPHY(POINT, 4326) NOT NULL,
    destination_location GEOGRAPHY(POINT, 4326),
    vehicle_info JSONB,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN (
        'pending', 
        'accepted', 
        'in_progress', 
        'completed', 
        'cancelled'
    )),
    price DECIMAL(10,2),
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    review TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP
);

CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_provider_id ON orders(provider_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);
CREATE INDEX idx_orders_pickup_location ON orders USING GIST(pickup_location);

-- Vehicles table
CREATE TABLE IF NOT EXISTS vehicles (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    brand VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    year INTEGER NOT NULL,
    plate_number VARCHAR(20) NOT NULL,
    current_mileage INTEGER NOT NULL,
    oil_change_interval INTEGER DEFAULT 10000,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_vehicles_user_id ON vehicles(user_id);
CREATE INDEX idx_vehicles_plate ON vehicles(plate_number);

-- Oil changes table
CREATE TABLE IF NOT EXISTS oil_changes (
    id SERIAL PRIMARY KEY,
    vehicle_id INTEGER REFERENCES vehicles(id) ON DELETE CASCADE,
    oil_type VARCHAR(100) NOT NULL,
    mileage INTEGER NOT NULL,
    price DECIMAL(10,2),
    location VARCHAR(255),
    notes TEXT,
    change_date TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_oil_changes_vehicle_id ON oil_changes(vehicle_id);
CREATE INDEX idx_oil_changes_date ON oil_changes(change_date DESC);

-- Maintenance reminders table
CREATE TABLE IF NOT EXISTS maintenance_reminders (
    id SERIAL PRIMARY KEY,
    vehicle_id INTEGER REFERENCES vehicles(id) ON DELETE CASCADE,
    reminder_type VARCHAR(50) NOT NULL CHECK (reminder_type IN (
        'oil_change', 
        'tire_rotation', 
        'brake_check', 
        'general_maintenance'
    )),
    next_service_mileage INTEGER NOT NULL,
    last_service_date TIMESTAMP,
    is_notified BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(vehicle_id, reminder_type)
);

CREATE INDEX idx_reminders_vehicle_id ON maintenance_reminders(vehicle_id);
CREATE INDEX idx_reminders_notified ON maintenance_reminders(is_notified);

-- Notifications table
CREATE TABLE IF NOT EXISTS notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(100) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) DEFAULT 'general',
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);

-- Success message
DO $$
BEGIN
    RAISE NOTICE '✅ Barcha jadvallar muvaffaqiyatli yaratildi!';
END $$;
