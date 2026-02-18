
-- Типи номерів
INSERT INTO room_types (type_name, price_per_night, capacity) VALUES 
('Standard', 1000.00, 2),
('Deluxe', 2500.00, 2),
('Suite', 5000.00, 4);

-- Номери
INSERT INTO rooms (room_number, type_id, floor) VALUES 
('101', 1, 1), ('102', 1, 1), ('103', 1, 1),
('201', 2, 2), ('202', 2, 2),
('301', 3, 3);

-- Послуги
INSERT INTO services (service_name, price) VALUES 
('Breakfast', 200.00),
('Airport Transfer', 500.00),
('SPA Access', 800.00),
('Mini Bar', 300.00);

-- Клієнти (Олександр Лаптєв - для персоналізації)
INSERT INTO clients (first_name, last_name, email, phone) VALUES 
('Олександр', 'Лаптєв', 'laptev@example.com', '+380501112233'),
('Іван', 'Петренко', 'ivan@example.com', '+380671112233'),
('Марія', 'Коваль', 'maria@example.com', '+380931112233'),
('Джон', 'Доу', 'john@example.com', '+1234567890');

-- Бронювання
INSERT INTO bookings (client_id, room_id, check_in_date, check_out_date, total_price, status) VALUES 
(1, 1, '2023-10-01', '2023-10-05', 4000.00, 'completed'), 
(1, 4, '2023-11-10', '2023-11-12', 5000.00, 'completed'), 
(2, 2, '2023-10-02', '2023-10-03', 1000.00, 'completed'),
(3, 6, '2023-10-01', '2023-10-10', 45000.00, 'completed'),
(4, 1, '2023-12-01', '2023-12-05', 4000.00, 'confirmed');

-- Замовлення послуг
INSERT INTO booking_services (booking_id, service_id, quantity) VALUES 
(1, 1, 4), 
(1, 2, 1), 
(2, 4, 2), 
(4, 3, 5);