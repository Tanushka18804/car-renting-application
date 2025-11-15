-- Create Database
CREATE DATABASE IF NOT EXISTS car_rental;
USE car_rental;

-----------------------------------------------------------
-- USERS TABLE (For login/signup)
-----------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('customer', 'admin') DEFAULT 'customer',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-----------------------------------------------------------
-- CARS TABLE (Full car inventory)
-----------------------------------------------------------
CREATE TABLE IF NOT EXISTS cars (
    car_id INT AUTO_INCREMENT PRIMARY KEY,
    car_model VARCHAR(100) NOT NULL,
    car_number VARCHAR(50) UNIQUE NOT NULL,
    car_type VARCHAR(50),
    status ENUM('available', 'rented') DEFAULT 'available',
    price_per_day DECIMAL(10,2) NOT NULL DEFAULT 50.00
);

-----------------------------------------------------------
-- RENTALS TABLE (Main booking table)
-----------------------------------------------------------
CREATE TABLE IF NOT EXISTS rentals (
    rental_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    car_id INT NOT NULL,
    rental_date DATE NOT NULL,
    return_date DATE NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    status ENUM('active', 'completed', 'cancelled') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (car_id) REFERENCES cars(car_id)
);

-----------------------------------------------------------
-- PAYMENT TABLE (Stores payment details)
-----------------------------------------------------------
CREATE TABLE IF NOT EXISTS payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    rental_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(50) DEFAULT 'cash',
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (rental_id) REFERENCES rentals(rental_id)
);

-----------------------------------------------------------
-- RENTAL HISTORY TABLE (Stores old bookings)
-----------------------------------------------------------
CREATE TABLE IF NOT EXISTS rental_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    rental_id INT NOT NULL,
    user_id INT NOT NULL,
    car_id INT NOT NULL,
    rental_date DATE NOT NULL,
    return_date DATE NOT NULL,
    total_amount DECIMAL(10,2),
    completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (rental_id) REFERENCES rentals(rental_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (car_id) REFERENCES cars(car_id)
);

-----------------------------------------------------------
-- INSERT SAMPLE CARS (Optional)
-----------------------------------------------------------
INSERT INTO cars (car_model, car_number, car_type, status, price_per_day)
VALUES
('Honda City', 'MH12AB1234', 'Sedan', 'available', 60.00),
('Hyundai i20', 'MH14CD5678', 'Hatchback', 'available', 50.00),
('Mahindra Thar', 'MH16EF9999', 'SUV', 'available', 80.00);
