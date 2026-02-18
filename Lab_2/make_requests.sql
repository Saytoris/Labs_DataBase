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