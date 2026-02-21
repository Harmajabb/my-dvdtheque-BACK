-- database/schema.sql
-- SQL script to create the database and tables for the DVD collection application

-- Table users
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    nom VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_email (email)
) ENGINE=InnoDB;

-- Table password_resets
CREATE TABLE password_resets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    token VARCHAR(64) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_token (token)
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
    nationalite VARCHAR(100),
    acteurs TEXT,
    synopsis TEXT,
    image_url VARCHAR(500),
    emplacement VARCHAR(100),
    statut ENUM('en collection', 'prêté', 'perdu') DEFAULT 'en collection',
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

