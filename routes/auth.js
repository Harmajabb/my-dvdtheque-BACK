const express = require("express");
const jwt = require("jsonwebtoken");
const { db } = require("../config/db");
const bcrypt = require("bcrypt");
const rateLimit = require("express-rate-limit");

const router = express.Router();

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5,
  message: { message: "Trop de tentatives de connexion, reessayez dans 15 minutes" },
});

const registerLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 heure
  max: 3,
  message: { message: "Trop de comptes crees, reessayez plus tard" },
});

const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

// register user
router.post("/register", registerLimiter, async (req, res) => {
  if (!req.body) {
    return res.status(400).json({
      message: "Body manquant. Envoie du JSON avec Content-Type: application/json",
    });
  }

  const { nom, email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: "email et password requis" });
  }

  if (!emailRegex.test(email)) {
    return res.status(400).json({ message: "format email invalide" });
  }

  if (password.length < 6) {
    return res.status(400).json({ message: "le mot de passe doit faire au moins 6 caracteres" });
  }
  try {
    // Check if the user already exists
    const [existingUser] = await db.query("SELECT id FROM users WHERE email = ?", [email]);
    if (existingUser.length > 0) {
      return res.status(400).json({ message: "Cet email est deja utilise" });
    }

    // Hash the password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insert the new user into the database
    const [_result] = await db.query(
      "INSERT INTO users (nom, email, password_hash) VALUES (?, ?, ?)",
      [nom, email, hashedPassword],
    );

    res.status(201).json({ message: "Utilisateur enregistre avec succes" });
  } catch (error) {
    console.error("Error registering user:", error);
    res.status(500).json({ message: "Erreur du serveur" });
  }
});

// login user
// loginLimiter is used to prevent brute-force attacks
// by limiting the number of login attempts from a single IP address
// within a specified time window.
// In this case, it allows a maximum of 5 login attempts every 15 minutes.
// If the limit is exceeded, it responds with a message indicating
// that there have been too many login attempts and to try again later.
router.post("/login", loginLimiter, async (req, res) => {
  if (!req.body) {
    return res.status(400).json({
      message: "Body manquant. Envoie du JSON avec Content-Type: application/json",
    });
  }

  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: "email et password requis" });
  }

  try {
    // check the user
    const [user] = await db.query("SELECT * FROM users WHERE email = ?", [email]);
    if (user.length === 0) {
      return res.status(401).json({ message: "Email ou mot de passe incorrect" });
    }

    const userData = user[0];

    // check the password
    const validPassword = await bcrypt.compare(password, userData.password_hash);
    if (!validPassword) {
      return res.status(401).json({ message: "Email ou mot de passe incorrect" });
    }

    // generate a token jwt
    const token = jwt.sign({ id: userData.id }, process.env.JWT_SECRET, { expiresIn: "1h" });

    res.json({ token, user: { id: userData.id, nom: userData.nom, email: userData.email } });
  } catch (error) {
    console.error("Error logging in user:", error);
    res.status(500).json({ message: "Erreur du serveur" });
  }
});

module.exports = router;
