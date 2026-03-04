-- ==============================================================================
-- 1. СТВОРЕННЯ КОРИСТУВАЦЬКОГО ТИПУ ДАНИХ (ENUM)
-- Замінюємо текстове поле status у таблиці bookings на спеціалізований ENUM 
-- ==============================================================================

-- Створюємо тип ENUM для статусів бронювання 
CREATE TYPE booking_status AS ENUM ('confirmed', 'active', 'completed', 'cancelled');

-- Видаляємо старе обмеження (якщо воно є з Лаб 2)
ALTER TABLE bookings DROP CONSTRAINT IF EXISTS chk_booking_status;

-- Змінюємо тип існуючої колонки з автоматичним приведенням типів (casting) 
ALTER TABLE bookings 
    ALTER COLUMN status DROP DEFAULT,
    ALTER COLUMN status TYPE booking_status USING status::booking_status,
    ALTER COLUMN status SET DEFAULT 'confirmed';

-- ==============================================================================
-- 2. СТВОРЕННЯ КОРИСТУВАЦЬКОЇ ФУНКЦІЇ
-- Функція для динамічного підрахунку загальної вартості бронювання 
-- (Ціна номеру * кількість ночей + вартість усіх замовлених послуг)
-- ==============================================================================

CREATE OR REPLACE FUNCTION calculate_booking_total(b_id INT) 
RETURNS DECIMAL(10,2) AS $$
DECLARE
    room_cost DECIMAL(10,2) := 0;
    services_cost DECIMAL(10,2) := 0;
BEGIN
    -- Підрахунок вартості проживання
    SELECT (b.check_out_date - b.check_in_date) * rt.price_per_night
    INTO room_cost
    FROM bookings b
    JOIN rooms r ON b.room_id = r.id
    JOIN room_types rt ON r.type_id = rt.id
    WHERE b.id = b_id;

    -- Підрахунок вартості додаткових послуг
    SELECT COALESCE(SUM(s.price * bs.quantity), 0)
    INTO services_cost
    FROM booking_services bs
    JOIN services s ON bs.service_id = s.id
    WHERE bs.booking_id = b_id;

    -- Повертаємо загальну суму
    RETURN room_cost + services_cost;
END;
$$ LANGUAGE plpgsql;

-- ==============================================================================
-- 3. СТВОРЕННЯ ТРИГЕРІВ
-- ==============================================================================

-- 3.1 Тригер для логування змін у таблиці bookings 
CREATE TABLE bookings_log (
    log_id SERIAL PRIMARY KEY,
    booking_id INT,
    operation VARCHAR(10),
    old_status booking_status,
    new_status booking_status,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION log_booking_changes() 
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO bookings_log (booking_id, operation, old_status)
        VALUES (OLD.id, TG_OP, OLD.status);
        RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO bookings_log (booking_id, operation, old_status, new_status)
        VALUES (NEW.id, TG_OP, OLD.status, NEW.status);
        RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO bookings_log (booking_id, operation, new_status)
        VALUES (NEW.id, TG_OP, NEW.status);
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Прив'язуємо тригер до таблиці 
CREATE TRIGGER trg_audit_bookings
AFTER INSERT OR UPDATE OR DELETE ON bookings
FOR EACH ROW EXECUTE FUNCTION log_booking_changes();


-- 3.2 Тригер для АВТОМАТИЧНОГО оновлення пов'язаних таблиць 
-- Коли клієнт замовляє нову послугу, загальна вартість (total_price) у bookings перераховується автоматично
CREATE OR REPLACE FUNCTION auto_update_booking_total() 
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        UPDATE bookings 
        SET total_price = calculate_booking_total(OLD.booking_id) 
        WHERE id = OLD.booking_id;
        RETURN OLD;
    ELSE
        UPDATE bookings 
        SET total_price = calculate_booking_total(NEW.booking_id) 
        WHERE id = NEW.booking_id;
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_total_price
AFTER INSERT OR UPDATE OR DELETE ON booking_services
FOR EACH ROW EXECUTE FUNCTION auto_update_booking_total();
