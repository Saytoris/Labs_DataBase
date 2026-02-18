-- 1. Таблиця клієнтів
CREATE TABLE clients (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    passport_number VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Таблиця типів номерів
CREATE TABLE room_types (
    id SERIAL PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL,
    price_per_night DECIMAL(10, 2) NOT NULL,
    capacity INT NOT NULL,
    description TEXT
);

-- 3. Таблиця номерів
CREATE TABLE rooms (
    id SERIAL PRIMARY KEY,
    room_number VARCHAR(10) NOT NULL UNIQUE,
    type_id INT REFERENCES room_types(id),
    floor INT,
    status VARCHAR(20) DEFAULT 'available',
    CONSTRAINT chk_room_status CHECK (status IN ('available', 'maintenance', 'occupied'))
);

-- 4. Таблиця бронювань
CREATE TABLE bookings (
    id SERIAL PRIMARY KEY,
    client_id INT REFERENCES clients(id),
    room_id INT REFERENCES rooms(id),
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    total_price DECIMAL(10, 2),
    status VARCHAR(20) DEFAULT 'confirmed',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_booking_status CHECK (status IN ('confirmed', 'cancelled', 'completed'))
);

-- 5. Таблиця послуг
CREATE TABLE services (
    id SERIAL PRIMARY KEY,
    service_name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

-- 6. Таблиця замовлення послуг (багато-до-багатьох)
CREATE TABLE booking_services (
    id SERIAL PRIMARY KEY,
    booking_id INT REFERENCES bookings(id),
    service_id INT REFERENCES services(id),
    quantity INT DEFAULT 1,
    ordered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
