const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
require("dotenv").config();

const authRoutes = require("./routes/auth");
const dvdsRoutes = require("./routes/dvds");
const app = express();

// Middleware
// security headers with helmet, CORS for frontend communication,
// and JSON body parsing with a size limit to prevent abuse
app.use(helmet());
app.use(
  cors({
    origin: process.env.FRONTEND_URL || "http://localhost:5173",
    credentials: true,
  }),
);
app.use(express.json({ limit: "10kb" }));

// Routes
app.use("/api/auth", authRoutes);

// dvd routes
app.use("/api/dvds", dvdsRoutes);

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Le serveur est lance sur http://localhost:${PORT}`);
});
