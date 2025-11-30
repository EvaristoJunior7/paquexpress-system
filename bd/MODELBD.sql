CREATE DATABASE IF NOT EXISTS paquexpress_db;
USE paquexpress_db;

-- 2. TABLA DE USUARIOS (AGENTES)
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. TABLA DE PAQUETES
CREATE TABLE IF NOT EXISTS packages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tracking_number VARCHAR(20) UNIQUE NOT NULL,
    address VARCHAR(255) NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    latitude DOUBLE,  -- Coordenada destino
    longitude DOUBLE, -- Coordenada destino
    status ENUM('PENDING', 'DELIVERED') DEFAULT 'PENDING',
    assigned_to INT, -- FK al agente
    evidence_photo_path VARCHAR(255), -- Ruta de la foto local
    delivery_latitude DOUBLE, -- GPS donde se entregó
    delivery_longitude DOUBLE, -- GPS donde se entregó
    delivered_at TIMESTAMP NULL,
    FOREIGN KEY (assigned_to) REFERENCES users(id)
);