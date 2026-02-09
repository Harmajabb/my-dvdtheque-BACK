const express = require("express");
const jwt = require("jsonwebtoken");
const { db } = require("../config/db");
const bcrypt = require("bcrypt");

const router = express.Router();

// register user
router.post("/register", async (req, res) => {
  if (!req.body) {
    return res.status(400).json({
      message: "Body manquant. Envoie du JSON avec Content-Type: application/json",
    });
  }

  const { nom, email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: "email et password requis" });
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
    const [result] = await db.query(
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
router.post("/login", async (req, res) => {
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
