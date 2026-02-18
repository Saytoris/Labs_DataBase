CREATE TABLE Cars (
	car_id SERIAL PRIMARY KEY,
	model VARCHAR(100) NOT NULL UNIQUE,
	description TEXT,
	license_plate VARCHAR(100) UNIQUE  
);
CREATE TABLE Clients(
	client_id SERIAL PRIMARY KEY,
	client_name VARCHAR(100) NOT NULL, 
	car_id INT, 
	age VARCHAR(100) NOT NULL,
	wealth INT NOT NULL,
	CONSTRAINT fk_cars
		FOREIGN KEY(car_id)
		REFERENCES Cars(car_id)
		ON DELETE SET NULL
);
CREATE TABLE Repairs(
	repair_id SERIAL PRIMARY KEY,
	client_id INT NOT NULL,
	repair_cost DECIMAL(10,2) NOT NULL,
	repair_date DATE DEFAULT CURRENT_DATE,
	CONSTRAINT fk_repairs
		FOREIGN KEY(client_id)
		REFERENCES Clients(client_id)
		ON DELETE CASCADE
);
	
DELETE FROM Clients 
WHERE client_id = 15;

UPDATE public.clients SET
car_id = '13'::integer WHERE
client_id = 13;

UPDATE Repairs 
SET repair_cost = 500.00 
WHERE repair_id = 21;








	

