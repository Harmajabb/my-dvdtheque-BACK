const express = require("express");
const { db } = require("../config/db");
const authMiddleware = require("../middleware/auth");
const router = express.Router();

// all routes in this file are protected by authMiddleware
router.use(authMiddleware);

// get api/dvds
router.get("/", async (req, res) => {
  try {
    // pagination with page and limit query parameters,
    // default to page 1 and limit 30, max limit 100
    const page = Math.max(1, parseInt(req.query.page, 10) || 1);
    const limit = Math.min(100, Math.max(1, parseInt(req.query.limit, 10) || 30));
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

// get api/dvds/search?q=searchTerm search dvds by title or director or actors

router.get("/search", async (req, res) => {
  try {
    const query = req.query.q || "";
    const page = Math.max(1, parseInt(req.query.page, 10) || 1);
    const limit = Math.min(100, Math.max(1, parseInt(req.query.limit, 10) || 30));
    const offset = (page - 1) * limit;

    const searchPattern = `%${query}%`;
    const whereClause =
      "WHERE user_id = ? AND (titre LIKE ? OR titre_original LIKE ? OR realisateur LIKE ? OR acteurs LIKE ?)";
    const params = [req.userId, searchPattern, searchPattern, searchPattern, searchPattern];

    const [dvds] = await db.query(
      `SELECT * FROM dvds ${whereClause} ORDER BY titre LIMIT ? OFFSET ?`,
      [...params, limit, offset],
    );

    const [countResult] = await db.query(`SELECT COUNT(*) as total FROM dvds ${whereClause}`, params);
    const total = countResult[0].total;

    res.json({ dvds, total, page, totalPages: Math.ceil(total / limit) });
  } catch (error) {
    console.error("Error searching DVDs:", error);
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

// post api/dvds add a new dvd

router.post("/", async (req, res) => {
  try {
    // validate input
    const {
      titre,
      titre_original,
      realisateur,
      annee,
      duree,
      genre,
      nationalite,
      acteurs,
      synopsis,
      image_url,
      emplacement,
      statut,
      prete_a,
      date_pret,
      notes_perso,
    } = req.body;

    // titre is required
    if (!titre) {
      return res.status(400).json({ error: "Le titre est requis" });
    }

    if (
      annee !== undefined &&
      annee !== null &&
      (Number.isNaN(Number(annee)) || annee < 1888 || annee > new Date().getFullYear() + 5)
    ) {
      return res.status(400).json({ error: "Annee invalide" });
    }

    if (duree !== undefined && duree !== null && (Number.isNaN(Number(duree)) || duree < 1)) {
      return res.status(400).json({ error: "Duree invalide" });
    }

    // insert the new dvd into the database
    const [result] = await db.query(
      "INSERT INTO dvds (user_id, titre, titre_original, realisateur, annee, duree, genre, nationalite, acteurs, synopsis, image_url, emplacement, statut, prete_a, date_pret, notes_perso) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      [
        req.userId,
        titre,
        titre_original,
        realisateur,
        annee,
        duree,
        genre,
        nationalite,
        acteurs,
        synopsis,
        image_url,
        emplacement,
        statut || "en collection",
        prete_a,
        date_pret,
        notes_perso,
      ],
    );

    // Fetch the newly created DVD to return in the response
    const [newDvd] = await db.query("SELECT * FROM dvds WHERE id = ?", [result.insertId]);

    res.status(201).json(newDvd[0]);
  } catch (error) {
    console.error("Error adding DVD:", error);
    res.status(500).json({ error: "Erreur du serveur" });
  }
});

// put api/dvds/:id update a dvd

router.put("/:id", async (req, res) => {
  try {
    const {
      titre,
      titre_original,
      realisateur,
      annee,
      duree,
      genre,
      nationalite,
      acteurs,
      synopsis,
      image_url,
      emplacement,
      statut,
      prete_a,
      date_pret,
      notes_perso,
    } = req.body;

    if (
      annee !== undefined &&
      annee !== null &&
      (Number.isNaN(Number(annee)) || annee < 1888 || annee > new Date().getFullYear() + 5)
    ) {
      return res.status(400).json({ error: "Annee invalide" });
    }

    if (duree !== undefined && duree !== null && (Number.isNaN(Number(duree)) || duree < 1)) {
      return res.status(400).json({ error: "Duree invalide" });
    }

    // check if the dvd exists and belongs to the user
    const [existing] = await db.query("SELECT id FROM dvds WHERE id = ? AND user_id = ?", [
      req.params.id,
      req.userId,
    ]);
    if (existing.length === 0) {
      return res.status(404).json({ error: "DVD non trouve" });
    }

    // update the dvd
    await db.query(
      "UPDATE dvds SET titre = ?, titre_original = ?, realisateur = ?, annee = ?, duree = ?, genre = ?, nationalite = ?, acteurs = ?, synopsis = ?, image_url = ?, emplacement = ?, statut = ?, prete_a = ?, date_pret = ?, notes_perso = ? WHERE id = ? AND user_id = ?",
      [
        titre,
        titre_original,
        realisateur,
        annee,
        duree,
        genre,
        nationalite,
        acteurs,
        synopsis,
        image_url,
        emplacement,
        statut,
        prete_a,
        date_pret,
        notes_perso,
        req.params.id,
        req.userId,
      ],
    );

    // Fetch the updated DVD to return in the response
    const [updatedDvd] = await db.query("SELECT * FROM dvds WHERE id = ?", [req.params.id]);
    res.json(updatedDvd[0]);
  } catch (error) {
    console.error("Error updating DVD:", error);
    res.status(500).json({ error: "Erreur du serveur" });
  }
});

// delete api/dvds/:id delete a dvd

router.delete("/:id", async (req, res) => {
  try {
    const [existing] = await db.query("SELECT id FROM dvds WHERE id = ? AND user_id = ?", [
      req.params.id,
      req.userId,
    ]);
    if (existing.length === 0) {
      return res.status(404).json({ error: "DVD non trouve" });
    }

    await db.query("DELETE FROM dvds WHERE id = ? AND user_id = ?", [req.params.id, req.userId]);

    res.json({ message: "DVD supprime avec succes" });
  } catch (error) {
    console.error("Error deleting DVD:", error);
    res.status(500).json({ error: "Erreur du serveur" });
  }
});

module.exports = router;
