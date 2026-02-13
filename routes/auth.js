const express = require("express");
const crypto = require("node:crypto");
const jwt = require("jsonwebtoken");
const { db } = require("../config/db");
const { resend } = require("../config/resend");
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

const forgotPasswordLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 3,
  message: { message: "Trop de demandes, reessayez dans 15 minutes" },
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

  if (password.length < 8) {
    return res.status(400).json({ message: "le mot de passe doit faire au moins 8 caracteres" });
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

// forgot password - send reset email
router.post("/forgot-password", forgotPasswordLimiter, async (req, res) => {
  const { email } = req.body;

  if (!email) {
    return res.status(400).json({ message: "Email requis" });
  }

  try {
    const [users] = await db.query("SELECT id FROM users WHERE email = ?", [email]);

    if (users.length > 0) {
      const user = users[0];
      const token = crypto.randomBytes(32).toString("hex");
      const expiresAt = new Date(Date.now() + 60 * 60 * 1000); // 1 hour

      // delete old tokens for this user
      await db.query("DELETE FROM password_resets WHERE user_id = ?", [user.id]);

      await db.query("INSERT INTO password_resets (user_id, token, expires_at) VALUES (?, ?, ?)", [
        user.id,
        token,
        expiresAt,
      ]);

      const resetUrl = `${process.env.FRONTEND_URL}/reset-password/${token}`;

      await resend.emails.send({
        from: process.env.RESEND_FROM_EMAIL,
        to: email,
        subject: "Réinitialisation de votre mot de passe - Ma DVDthèque",
        html: `
          <h2>Réinitialisation de mot de passe</h2>
          <p>Vous avez demandé la réinitialisation de votre mot de passe.</p>
          <p>Cliquez sur le lien ci-dessous pour choisir un nouveau mot de passe :</p>
          <p><a href="${resetUrl}">Réinitialiser mon mot de passe</a></p>
          <p>Ce lien expire dans 1 heure.</p>
          <p>Si vous n'avez pas fait cette demande, ignorez cet email.</p>
        `,
      });
    }

    // always return the same response to prevent email enumeration
    res.json({ message: "Si cet email existe, un lien de reinitialisation a ete envoye." });
  } catch (error) {
    console.error("Error in forgot-password:", error);
    res.status(500).json({ message: "Erreur du serveur" });
  }
});

// reset password with token
router.post("/reset-password", async (req, res) => {
  const { token, password } = req.body;

  if (!token || !password) {
    return res.status(400).json({ message: "Token et mot de passe requis" });
  }

  if (password.length < 8) {
    return res.status(400).json({ message: "Le mot de passe doit faire au moins 8 caracteres" });
  }

  try {
    const [resets] = await db.query(
      "SELECT user_id FROM password_resets WHERE token = ? AND expires_at > NOW()",
      [token],
    );

    if (resets.length === 0) {
      return res.status(400).json({ message: "Lien invalide ou expire" });
    }

    const userId = resets[0].user_id;
    const hashedPassword = await bcrypt.hash(password, 10);

    await db.query("UPDATE users SET password_hash = ? WHERE id = ?", [hashedPassword, userId]);

    // delete used token and expired tokens
    await db.query("DELETE FROM password_resets WHERE user_id = ? OR expires_at <= NOW()", [
      userId,
    ]);

    res.json({ message: "Mot de passe mis a jour avec succes" });
  } catch (error) {
    console.error("Error in reset-password:", error);
    res.status(500).json({ message: "Erreur du serveur" });
  }
});

module.exports = router;
