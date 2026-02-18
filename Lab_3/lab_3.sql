-- Лабораторна робота №3
-- З дисципліни: Бази даних та інформаційні системи
-- Студента групи МІТ-31 Лаптєва Олександра

-- =======================================================
-- БЛОК 1: Базові запити та логічні оператори (1-5)
-- =======================================================

-- Запит 1. Отримати всі дані про бронювання зі статусом 'completed'
SELECT * FROM bookings WHERE status = 'completed';

-- Запит 2. Використання AND та OR: Знайти вільні номери на 1 або 2 поверсі
SELECT room_number, floor, status 
FROM rooms 
WHERE status = 'available' AND (floor = 1 OR floor = 2);

-- Запит 3. Використання IN: Знайти клієнтів з конкретними ID
SELECT first_name, last_name, email 
FROM clients 
WHERE id IN (1, 3, 5);

-- Запит 4. Використання NOT та BETWEEN: Бронювання поза певним діапазоном цін
SELECT id, total_price 
FROM bookings 
WHERE total_price NOT BETWEEN 1000 AND 5000;

-- Запит 5. Пошук за шаблоном (LIKE/ILIKE у PostgreSQL): Клієнти, чия пошта на 'example.com'
SELECT first_name, last_name, email 
FROM clients 
WHERE email ILIKE '%@example.com';

-- =======================================================
-- БЛОК 2: Агрегатні функції та групування (6-10)
-- =======================================================

-- Запит 6. COUNT: Підрахувати загальну кількість номерів у готелі
SELECT COUNT(*) AS total_rooms FROM rooms;

-- Запит 7. SUM та AVG: Загальний дохід та середня вартість бронювання
SELECT SUM(total_price) AS total_revenue, AVG(total_price) AS average_booking_price 
FROM bookings;

-- Запит 8. MIN та MAX: Найдешевша та найдорожча послуга
SELECT MIN(price) AS min_service_price, MAX(price) AS max_service_price 
FROM services;

-- Запит 9. GROUP BY: Кількість номерів за кожним статусом
SELECT status, COUNT(*) AS room_count 
FROM rooms 
GROUP BY status;

-- Запит 10. GROUP BY + HAVING: Типи номерів, де місткість більше 2 осіб
SELECT type_name, MAX(capacity) AS max_capacity 
FROM room_types 
GROUP BY type_name 
HAVING MAX(capacity) > 2;

-- =======================================================
-- БЛОК 3: Усі типи JOIN (11-18)
-- =======================================================

-- Запит 11. INNER JOIN: Отримати імена клієнтів та дати їх заїздів
SELECT c.first_name, c.last_name, b.check_in_date 
FROM clients c
INNER JOIN bookings b ON c.id = b.client_id;

-- Запит 12. LEFT JOIN: Всі номери і їх бронювання (включаючи номери, які ніколи не бронювали)
SELECT r.room_number, b.id AS booking_id
FROM rooms r
LEFT JOIN bookings b ON r.id = b.room_id;

-- Запит 13. RIGHT JOIN: Всі послуги та кількість їх замовлень (вкл. послуги, які не замовляли)
SELECT s.service_name, bs.quantity
FROM booking_services bs
RIGHT JOIN services s ON bs.service_id = s.id;

-- Запит 14. FULL OUTER JOIN: Клієнти та бронювання (всі клієнти і всі бронювання, навіть якщо зв'язок втрачено)
SELECT c.first_name, b.total_price
FROM clients c
FULL OUTER JOIN bookings b ON c.id = b.client_id;

-- Запит 15. CROSS JOIN: Усі можливі комбінації номерів та послуг (для аналізу крос-продажів)
SELECT r.room_number, s.service_name
FROM rooms r
CROSS JOIN services s;

-- Запит 16. SELF JOIN: Знайти пари номерів, які знаходяться на одному поверсі
SELECT r1.room_number AS room1, r2.room_number AS room2, r1.floor
FROM rooms r1
JOIN rooms r2 ON r1.floor = r2.floor AND r1.id < r2.id;

-- Запит 17. JOIN 3-х таблиць: Клієнт -> Бронювання -> Номер
SELECT c.last_name, b.check_in_date, r.room_number
FROM clients c
JOIN bookings b ON c.id = b.client_id
JOIN rooms r ON b.room_id = r.id;

-- Запит 18. JOIN 4-х таблиць з підрахунком вартості послуг
SELECT c.last_name, s.service_name, bs.quantity, (bs.quantity * s.price) AS total_service_cost
FROM clients c
JOIN bookings b ON c.id = b.client_id
JOIN booking_services bs ON b.id = bs.booking_id
JOIN services s ON bs.service_id = s.id;

-- =======================================================
-- БЛОК 4: Підзапити (Subqueries) (19-25)
-- =======================================================

-- Запит 19. Підзапит у WHERE: Клієнти, які витратили більше середнього
SELECT first_name, last_name FROM clients
WHERE id IN (
    SELECT client_id FROM bookings WHERE total_price > (SELECT AVG(total_price) FROM bookings)
);

-- Запит 20. Підзапит у SELECT: Вивести клієнта та загальну кількість його бронювань
SELECT first_name, last_name, 
    (SELECT COUNT(*) FROM bookings b WHERE b.client_id = c.id) AS total_bookings
FROM clients c;

-- Запит 21. EXISTS: Знайти клієнтів, які замовляли додаткові послуги
SELECT first_name, last_name FROM clients c
WHERE EXISTS (
    SELECT 1 FROM bookings b 
    JOIN booking_services bs ON b.id = bs.booking_id 
    WHERE b.client_id = c.id
);

-- Запит 22. NOT EXISTS: Знайти номери, які жодного разу не бронювалися
SELECT room_number FROM rooms r
WHERE NOT EXISTS (
    SELECT 1 FROM bookings b WHERE b.room_id = r.id
);

-- Запит 23. Корельований підзапит: Бронювання, ціна якого вища за середню ціну бронювань цього ж клієнта
SELECT b1.id, b1.client_id, b1.total_price
FROM bookings b1
WHERE b1.total_price > (
    SELECT AVG(b2.total_price) FROM bookings b2 WHERE b2.client_id = b1.client_id
);

-- Запит 24. Вкладений підзапит (2 рівні): Знайти імена клієнтів, які бронювали найдорожчий тип номеру
SELECT first_name, last_name FROM clients
WHERE id IN (
    SELECT client_id FROM bookings WHERE room_id IN (
        SELECT id FROM rooms WHERE type_id = (
            SELECT id FROM room_types ORDER BY price_per_night DESC LIMIT 1
        )
    )
);

-- Запит 25. Глибоко вкладений підзапит (Максимальний бал): 
-- Знайти клієнтів, які замовляли послуги, вартість яких більша за середню вартість послуг, 
-- замовлених клієнтами, що проживали в номерах типу 'Deluxe'
SELECT c.first_name, c.last_name 
FROM clients c
WHERE c.id IN (
    SELECT b.client_id FROM bookings b 
    JOIN booking_services bs ON b.id = bs.booking_id
    JOIN services s ON bs.service_id = s.id
    WHERE s.price > (
        SELECT AVG(s2.price) FROM services s2
        JOIN booking_services bs2 ON s2.id = bs2.service_id
        JOIN bookings b2 ON bs2.booking_id = b2.id
        JOIN rooms r2 ON b2.room_id = r2.id
        JOIN room_types rt2 ON r2.type_id = rt2.id
        WHERE rt2.type_name = 'Deluxe'
    )
);

-- =======================================================
-- БЛОК 5: Операції над множинами (26-30)
-- =======================================================

-- Запит 26. UNION: Усі ідентифікатори об'єктів (Клієнти + Номери) - суто для демонстрації
SELECT id, 'Client' AS type FROM clients
UNION
SELECT id, 'Room' AS type FROM rooms;

-- Запит 27. UNION ALL: Об'єднання всіх статусів номерів і бронювань зі збереженням дублікатів
SELECT status FROM rooms
UNION ALL
SELECT status FROM bookings;

-- Запит 28. INTERSECT: Знайти спільні ID клієнтів, які бронювали номери у жовтні ТА листопаді 2023
SELECT client_id FROM bookings WHERE EXTRACT(MONTH FROM check_in_date) = 10
INTERSECT
SELECT client_id FROM bookings WHERE EXTRACT(MONTH FROM check_in_date) = 11;

-- Запит 29. EXCEPT: Клієнти, які мають бронювання, АЛЕ не замовляли жодних додаткових послуг
SELECT client_id FROM bookings
EXCEPT
SELECT b.client_id FROM bookings b JOIN booking_services bs ON b.id = bs.booking_id;

-- Запит 30. Складний UNION з підзапитами: ТОП-1 найдорожче бронювання та ТОП-1 найдешевше
(SELECT 'Most Expensive' AS category, id, total_price FROM bookings ORDER BY total_price DESC LIMIT 1)
UNION
(SELECT 'Least Expensive' AS category, id, total_price FROM bookings ORDER BY total_price ASC LIMIT 1);

-- =======================================================
-- БЛОК 6: Common Table Expressions (CTE) (31-35)
-- =======================================================

-- Запит 31. Просте CTE: Отримати список розширених даних про номери
WITH RoomDetails AS (
    SELECT r.room_number, rt.type_name, rt.price_per_night
    FROM rooms r JOIN room_types rt ON r.type_id = rt.id
)
SELECT * FROM RoomDetails WHERE price_per_night > 1500;

-- Запит 32. CTE з агрегацією: Знайти клієнтів з сумою витрат більше 5000
WITH ClientSpending AS (
    SELECT client_id, SUM(total_price) AS total_spent
    FROM bookings GROUP BY client_id
)
SELECT c.last_name, cs.total_spent 
FROM clients c JOIN ClientSpending cs ON c.id = cs.client_id 
WHERE cs.total_spent > 5000;

-- Запит 33. Декілька CTE в одному запиті: Порівняння витрат клієнта із середнім по готелю
WITH TotalPerClient AS (
    SELECT client_id, SUM(total_price) AS spent FROM bookings GROUP BY client_id
),
AvgHotelSpending AS (
    SELECT AVG(spent) AS avg_spent FROM TotalPerClient
)
SELECT tpc.client_id, tpc.spent, ahs.avg_spent
FROM TotalPerClient tpc CROSS JOIN AvgHotelSpending ahs
WHERE tpc.spent > ahs.avg_spent;

-- Запит 34. Рекурсивне CTE (генерація дат для звітів): Отримати перші 5 днів жовтня
WITH RECURSIVE DateSeries AS (
    SELECT '2023-10-01'::DATE AS report_date
    UNION ALL
    SELECT report_date + INTERVAL '1 day' FROM DateSeries WHERE report_date < '2023-10-05'
)
SELECT * FROM DateSeries;

-- Запит 35. CTE для аналізу завантаженості (кількість днів оренди по кожному номеру)
WITH RoomUsage AS (
    SELECT room_id, SUM(check_out_date - check_in_date) AS days_rented
    FROM bookings WHERE status = 'completed' GROUP BY room_id
)
SELECT r.room_number, COALESCE(ru.days_rented, 0) AS days_rented
FROM rooms r LEFT JOIN RoomUsage ru ON r.id = ru.room_id;

-- =======================================================
-- БЛОК 7: Віконні функції (Window Functions) (36-40)
-- =======================================================

-- Запит 36. ROW_NUMBER(): Пронумерувати бронювання кожного клієнта за датою
SELECT client_id, check_in_date, total_price,
       ROW_NUMBER() OVER (PARTITION BY client_id ORDER BY check_in_date) as booking_sequence
FROM bookings;

-- Запит 37. RANK() та DENSE_RANK(): Ранжування клієнтів за сумою витрат (DENSE_RANK не пропускає позиції)
SELECT client_id, total_price,
       RANK() OVER (ORDER BY total_price DESC) as rank,
       DENSE_RANK() OVER (ORDER BY total_price DESC) as dense_rank
FROM bookings;

-- Запит 38. SUM() OVER(): Обчислення накопичувального підсумку (Running Total) доходу готелю за часом
SELECT check_in_date, total_price,
       SUM(total_price) OVER (ORDER BY check_in_date) as running_total_revenue
FROM bookings;

-- Запит 39. LAG(): Знайти різницю у вартості між поточним і попереднім бронюванням конкретного клієнта
SELECT client_id, check_in_date, total_price,
       LAG(total_price) OVER (PARTITION BY client_id ORDER BY check_in_date) as previous_booking_price,
       total_price - LAG(total_price) OVER (PARTITION BY client_id ORDER BY check_in_date) as price_difference
FROM bookings;

-- Запит 40. LEAD(): Визначити кількість днів між поточним виїздом і наступним заїздом клієнта (чиста аналітика)
SELECT client_id, check_out_date,
       LEAD(check_in_date) OVER (PARTITION BY client_id ORDER BY check_in_date) as next_check_in,
       (LEAD(check_in_date) OVER (PARTITION BY client_id ORDER BY check_in_date)) - check_out_date as days_between_visits
FROM bookings;

-- =======================================================
-- БЛОК 8: Просунута аналітика PostgreSQL (Запити 41-50)
-- =======================================================

-- Запит 41. Віконна функція з фреймами (Moving Average): 
-- Ковзне середнє вартості останніх 3-х бронювань для кожного клієнта
SELECT client_id, check_in_date, total_price,
       AVG(total_price) OVER (
           PARTITION BY client_id 
           ORDER BY check_in_date 
           ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ) as moving_avg_price
FROM bookings;

-- Запит 42. Віконна функція NTILE(): 
-- Розподіл клієнтів на 4 групи (квартилі) за загальною сумою їхніх витрат
WITH ClientTotals AS (
    SELECT client_id, SUM(total_price) as total_spent 
    FROM bookings 
    GROUP BY client_id
)
SELECT client_id, total_spent,
       NTILE(4) OVER (ORDER BY total_spent DESC) as spending_quartile
FROM ClientTotals;

-- Запит 43. Оператор ALL з підзапитом: 
-- Знайти типи номерів, ціна за ніч яких строго більша за ВСІ номери на 1-му поверсі
SELECT type_name, price_per_night 
FROM room_types 
WHERE price_per_night > ALL (
    SELECT rt.price_per_night 
    FROM rooms r JOIN room_types rt ON r.type_id = rt.id 
    WHERE r.floor = 1
);

-- Запит 44. Агрегація з FILTER (Специфічна функція PostgreSQL): 
-- Підрахунок кількості бронювань за різними статусами в одному рядку без використання CASE
SELECT 
    COUNT(*) FILTER (WHERE status = 'completed') AS completed_count,
    COUNT(*) FILTER (WHERE status = 'cancelled') AS cancelled_count,
    COUNT(*) FILTER (WHERE status = 'confirmed') AS confirmed_count
FROM bookings;

-- Запит 45. Складна генерація дат (RECURSIVE CTE) + LEFT JOIN: 
-- Знайти дні у жовтні 2023 року, коли до готелю не було ЖОДНОГО заїзду
WITH RECURSIVE OctoberDays AS (
    SELECT '2023-10-01'::DATE as day
    UNION ALL
    SELECT day + INTERVAL '1 day' FROM OctoberDays WHERE day < '2023-10-31'
)
SELECT od.day AS empty_checkin_days
FROM OctoberDays od
LEFT JOIN bookings b ON od.day = b.check_in_date
WHERE b.id IS NULL;

-- Запит 46. Віконна функція FIRST_VALUE(): 
-- Порівняння вартості поточного бронювання з найпершим бронюванням цього ж клієнта
SELECT client_id, check_in_date, total_price,
       FIRST_VALUE(total_price) OVER (PARTITION BY client_id ORDER BY check_in_date) as first_booking_price,
       total_price - FIRST_VALUE(total_price) OVER (PARTITION BY client_id ORDER BY check_in_date) as diff_from_first
FROM bookings;

-- Запит 47. Агрегація рядків (STRING_AGG): 
-- Вивести ID бронювання і через кому назви всіх замовлених додаткових послуг
SELECT b.id AS booking_id, 
       STRING_AGG(s.service_name, ', ') AS ordered_services_list
FROM bookings b
JOIN booking_services bs ON b.id = bs.booking_id
JOIN services s ON bs.service_id = s.id
GROUP BY b.id;

-- Запит 48. Вкладені підзапити з ANY: 
-- Знайти імена клієнтів, які хоча б раз бронювали номер найвищого класу ('Suite')
SELECT first_name, last_name FROM clients
WHERE id = ANY (
    SELECT client_id FROM bookings WHERE room_id = ANY (
        SELECT id FROM rooms WHERE type_id = (
            SELECT id FROM room_types WHERE type_name = 'Suite'
        )
    )
);

-- Запит 49. Корельований підзапит в блоці SELECT: 
-- Знайти для кожного клієнта його "найулюбленіший" тип номеру (який він бронював найчастіше)
SELECT c.first_name, c.last_name,
       (SELECT rt.type_name 
        FROM bookings b 
        JOIN rooms r ON b.room_id = r.id 
        JOIN room_types rt ON r.type_id = rt.id
        WHERE b.client_id = c.id
        GROUP BY rt.type_name 
        ORDER BY COUNT(*) DESC 
        LIMIT 1) AS favorite_room_type
FROM clients c;

-- Запит 50. Комбінація CTE, JOIN, підзапитів та Window Functions (Аналіз VIP-клієнтів):
-- Знайти клієнтів, чиї витрати входять у ТОП-3 по готелю, та показати, який відсоток від загального доходу вони принесли
WITH ClientRevenue AS (
    SELECT client_id, SUM(total_price) as total_spent
    FROM bookings 
    WHERE status = 'completed'
    GROUP BY client_id
),
RankedClients AS (
    SELECT client_id, total_spent,
           RANK() OVER (ORDER BY total_spent DESC) as rev_rank,
           (SELECT SUM(total_price) FROM bookings WHERE status = 'completed') as global_revenue
    FROM ClientRevenue
)
SELECT c.first
-- Висновки: 
-- Під час виконання лабораторної роботи було складено 40 SQL-запитів до реляційної бази даних "Готель". 
-- На практиці закріплено використання логічних операторів, агрегатних функцій для аналізу даних, 
-- застосовано всі види з'єднань (JOIN) для роботи зі зв'язаними таблицями. 
-- Особливу увагу приділено оптимізації та структуруванню запитів за допомогою CTE, 
-- глибоко вкладених підзапитів та віконних функцій для побудови складної аналітики (накопичувальні підсумки, ранжування).