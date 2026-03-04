-- 1. Перевірка типу ENUM (вставляємо тестове бронювання)
INSERT INTO bookings (client_id, room_id, check_in_date, check_out_date, status) 
VALUES (1, 1, CURRENT_DATE, CURRENT_DATE + 5, 'active');

-- Перевіряємо лог (має з'явитися запис про INSERT) 
SELECT * FROM bookings_log ORDER BY changed_at DESC LIMIT 1;

-- 2. Перевірка авто-оновлення ціни та функції 
-- Дивимось початкову ціну тестового бронювання (зараз там NULL або 0)
SELECT id, total_price FROM bookings ORDER BY id DESC LIMIT 1;

-- Додаємо послугу (наприклад, сніданок) до цього бронювання
-- ID бронювання підстав своє останнє (тут для прикладу використаємо ID останнього створеного)
INSERT INTO booking_services (booking_id, service_id, quantity) 
VALUES ((SELECT MAX(id) FROM bookings), 1, 2);

-- Знову дивимось ціну - ТРИГЕР мав автоматично її перерахувати (ціна номеру за 5 днів + ціна 2 сніданків)
SELECT id, total_price FROM bookings ORDER BY id DESC LIMIT 1;

-- 3. Перевірка логування UPDATE та DELETE 
UPDATE bookings SET status = 'completed' WHERE id = (SELECT MAX(id) FROM bookings);
DELETE FROM booking_services WHERE booking_id = (SELECT MAX(id) FROM bookings);
DELETE FROM bookings WHERE id = (SELECT MAX(id) FROM bookings);

-- Дивимось лог аудиту: там мають бути записи INSERT, UPDATE та DELETE
SELECT * FROM bookings_log;