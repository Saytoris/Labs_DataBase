--Створення ролей (користувачів)
-- Адміністратор
CREATE USER hotel_admin WITH PASSWORD 'admin_pass';
GRANT ALL PRIVILEGES ON DATABASE hotel_db TO hotel_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO hotel_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO hotel_admin;

-- Модератор
CREATE USER hotel_mod WITH PASSWORD 'mod_pass';
GRANT CONNECT ON DATABASE hotel_db TO hotel_mod;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO hotel_mod;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO hotel_mod;

-- Звичайний користувач
CREATE USER hotel_user WITH PASSWORD 'user_pass';
GRANT CONNECT ON DATABASE hotel_db TO hotel_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO hotel_user;
DROP TABLE IF EXISTS booking_services;
DROP TABLE IF EXISTS services;
DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS rooms;
DROP TABLE IF EXISTS room_types;
DROP TABLE IF EXISTS clients;