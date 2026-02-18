CREATE USER hotel_admin WITH PASSWORD 'admin_pass';
GRANT ALL PRIVILEGES ON DATABASE hotel_db TO hotel_admin;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO hotel_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO hotel_admin;

CREATE USER hotel_mod WITH PASSWORD 'mod_pass';
GRANT CONNECT ON DATABASE hotel_db TO hotel_mod;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO hotel_mod;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO hotel_mod;

CREATE USER hotel_user WITH PASSWORD 'user_pass';
GRANT CONNECT ON DATABASE hotel_db TO hotel_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO hotel_user;

DROP TABLE IF EXISTS booking_services;
DROP TABLE IF EXISTS services;
DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS rooms;
DROP TABLE IF EXISTS room_types;
DROP TABLE IF EXISTS clients;

CREATE TABLE clients (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    passport_number VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE room_types (
    id SERIAL PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL,
    price_per_night DECIMAL(10, 2) NOT NULL,
    capacity INT NOT NULL,
    description TEXT
);

CREATE TABLE rooms (
    id SERIAL PRIMARY KEY,
    room_number VARCHAR(10) NOT NULL UNIQUE,
    type_id INT REFERENCES room_types(id),
    floor INT,
    status VARCHAR(20) DEFAULT 'available',
    CONSTRAINT chk_room_status CHECK (status IN ('available', 'maintenance', 'occupied'))
);

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

CREATE TABLE services (
    id SERIAL PRIMARY KEY,
    service_name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

CREATE TABLE booking_services (
    id SERIAL PRIMARY KEY,
    booking_id INT REFERENCES bookings(id),
    service_id INT REFERENCES services(id),
    quantity INT DEFAULT 1,
    ordered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO room_types (type_name, price_per_night, capacity) VALUES 
('Standard', 1000.00, 2),
('Deluxe', 2500.00, 2),
('Suite', 5000.00, 4);
('Vip', 10000.00, 4);

INSERT INTO rooms (room_number, type_id, floor) VALUES 
('101', 1, 1), ('102', 1, 1), ('103', 1, 1),
('201', 2, 2), ('202', 2, 2),
('301', 3, 3);

INSERT INTO services (service_name, price) VALUES 
('Breakfast', 200.00),
('Airport Transfer', 500.00),
('SPA Access', 800.00),
('Mini Bar', 300.00);

INSERT INTO clients (first_name, last_name, email, phone) VALUES 
('Олександр', 'Лаптєв', 'laptev@example.com', '+380501112233'),
('Іван', 'Петренко', 'ivan@example.com', '+380671112233'),
('Марія', 'Коваль', 'maria@example.com', '+380931112233'),
('Джон', 'Доу', 'john@example.com', '+1234567890');

INSERT INTO bookings (client_id, room_id, check_in_date, check_out_date, total_price, status) VALUES 
(1, 1, '2023-10-01', '2023-10-05', 4000.00, 'completed'), 
(1, 4, '2023-11-10', '2023-11-12', 5000.00, 'completed'), 
(2, 2, '2023-10-02', '2023-10-03', 1000.00, 'completed'),
(3, 6, '2023-10-01', '2023-10-10', 45000.00, 'completed'),
(4, 1, '2023-12-01', '2023-12-05', 4000.00, 'confirmed');

INSERT INTO booking_services (booking_id, service_id, quantity) VALUES 
(1, 1, 4), 
(1, 2, 1), 
(2, 4, 2), 
(4, 3, 5);

-- ==========================================
-- ЗАПИТИ ДЛЯ POSTGRESQL (ВАРІАНТ 13)
-- ==========================================

-- 1. Типи номерів
SELECT * FROM room_types;

-- 2. Бронювання за жовтень 2023
SELECT COUNT(*) AS bookings_in_october
FROM bookings 
WHERE check_in_date BETWEEN '2023-10-01' AND '2023-10-31';

-- 3. Середня ціна
SELECT type_name, AVG(price_per_night) as avg_price
FROM room_types
GROUP BY type_name;

-- 4. Клієнти з найдовшим бронюванням (Заміна DATEDIFF на просте віднімання)
SELECT c.first_name, c.last_name, (b.check_out_date - b.check_in_date) as nights
FROM bookings b
JOIN clients c ON b.client_id = c.id
ORDER BY nights DESC
LIMIT 1;

-- 5. Прибуття та виїзди
SELECT 
    (SELECT COUNT(*) FROM bookings WHERE check_in_date BETWEEN '2023-10-01' AND '2023-10-31') as arrivals,
    (SELECT COUNT(*) FROM bookings WHERE check_out_date BETWEEN '2023-10-01' AND '2023-10-31') as departures;

-- 6. Клієнти з найбільшою кількістю послуг
SELECT c.first_name, c.last_name, COUNT(bs.id) as total_services_ordered
FROM clients c
JOIN bookings b ON c.id = b.client_id
JOIN booking_services bs ON b.id = bs.booking_id
GROUP BY c.id, c.first_name, c.last_name -- У Postgres треба групувати по всіх вибраних колонках
ORDER BY total_services_ordered DESC
LIMIT 1;

-- 7. Вільні номери
SELECT COUNT(*) as free_rooms_count 
FROM rooms 
WHERE status = 'available';

-- 8. Загальна кількість ночей за місяць
SELECT SUM(check_out_date - check_in_date) as total_nights_october
FROM bookings
WHERE check_in_date >= '2023-10-01' AND check_in_date <= '2023-10-31';

-- 9. Повторні бронювання
SELECT c.first_name, c.last_name, COUNT(b.id) as booking_count
FROM clients c
JOIN bookings b ON c.id = b.client_id
GROUP BY c.id, c.first_name, c.last_name
HAVING COUNT(b.id) > 1;

-- 10. Унікальні статуси
SELECT DISTINCT status FROM bookings;

-- 11. Макс/Мін ціна послуги
SELECT MAX(price) as max_service_price, MIN(price) as min_service_price FROM services;

-- 12. Загальна виручка
SELECT SUM(total_price) as total_revenue FROM bookings;