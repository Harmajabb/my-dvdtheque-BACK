-- database/schema.sql
-- SQL script to create the database and tables for the DVD collection application

-- Create the database
CREATE DATABASE my_dvdtheque CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE my_dvdtheque;

-- Table users
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    nom VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_email (email)
) ENGINE=InnoDB;

-- Table dvds
CREATE TABLE dvds (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    titre VARCHAR(255) NOT NULL,
    titre_original VARCHAR(255),
    realisateur VARCHAR(255),
    annee INT,
    duree INT,
    genre VARCHAR(100),
    acteurs TEXT,
    synopsis TEXT,
    image_url VARCHAR(500),
    emplacement VARCHAR(100),
    statut ENUM('disponible', 'prêté', 'perdu') DEFAULT 'disponible',
    prete_a VARCHAR(100),
    date_pret DATE,
    notes_perso TEXT,
    date_ajout TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_titre (titre),
    INDEX idx_statut (statut)
) ENGINE=InnoDB;

-- test data
INSERT INTO users (email, password_hash, nom) VALUES
('test@test.com', '$2b$10$dummyhashfordev', 'Test User');

INSERT INTO dvds (user_id, titre, realisateur, annee, genre, statut) VALUES
(1, 'Inception', 'Christopher Nolan', 2010, 'Science-fiction', 'disponible'),
(1, 'Le Parrain', 'Francis Ford Coppola', 1972, 'Drame', 'disponible');