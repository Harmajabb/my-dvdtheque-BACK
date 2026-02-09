const express = require("express");
const { db } = require("../config/db");
const authMiddleware = require("../middleware/auth");
const router = express.Router();

// all routes in this file are protected by authMiddleware
router.use(authMiddleware);

// get api/dvds
router.get("/", async (req, res) => {
  try {
    // pagination
    const page = parseInt(req.query.page, 10) || 1;
    const limit = parseInt(req.query.limit, 10) || 30;
    const offset = (page - 1) * limit;

    const [dvds] = await db.query(
      "SELECT * FROM dvds WHERE user_id = ? ORDER BY titre LIMIT ? OFFSET ?",
      [req.userId, limit, offset],
    );

    // get total count for pagination
    const [countResult] = await db.query("SELECT COUNT(*) as total FROM dvds WHERE user_id = ?", [
      req.userId,
    ]);
    const total = countResult[0].total;
    res.json({ dvds, total, page, totalPages: Math.ceil(total / limit) });
  } catch (error) {
    console.error("Error fetching DVDs:", error);
    res.status(500).json({ error: "Erreur du serveur" });
  }
});

// get api/dvds/:id details of a single dvd
router.get("/:id", async (req, res) => {
  try {
    const [dvds] = await db.query("SELECT * FROM dvds WHERE id = ? AND user_id = ?", [
      req.params.id,
      req.userId,
    ]);

    if (dvds.length === 0) {
      return res.status(404).json({ error: "DVD non trouve" });
    }

    res.json(dvds[0]);
  } catch (error) {
    console.error("Error fetching DVD:", error);
    res.status(500).json({ error: "Erreur du serveur" });
  }
});

module.exports = router;
