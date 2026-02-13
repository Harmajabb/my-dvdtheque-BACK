# My DVDtheque - Backend API

REST API for a personal DVD collection manager. Built with Node.js, Express 5, and MySQL.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Runtime | Node.js |
| Framework | Express 5 |
| Database | MySQL 8+ (mysql2 with connection pooling) |
| Auth | JWT (jsonwebtoken) + bcrypt |
| Email | Resend (password reset) |
| Security | Helmet, CORS, express-rate-limit |
| Linter | Biome |

## Project Structure

```
.
├── server.js              # Entry point - Express app, middleware, routes
├── config/
│   ├── db.js              # MySQL connection pool (mysql2/promise)
│   └── resend.js          # Resend email client init
├── middleware/
│   └── auth.js            # JWT verification middleware
├── routes/
│   ├── auth.js            # Auth endpoints (register, login, password reset)
│   └── dvds.js            # DVD CRUD + search (all protected)
├── database/
│   └── schema.sql         # Full schema + test data
├── uploads/               # Reserved for future file uploads
├── .env.sample            # Environment template
├── biome.json             # Linter/formatter config
└── package.json
```

## Prerequisites

- **Node.js** >= 18
- **MySQL** >= 8.0
- **Resend account** (optional - only needed for password reset emails)

## Setup

### 1. Install dependencies

```bash
git clone https://github.com/Harmajabb/my-dvdtheque-BACK.git
cd my-dvdtheque-BACK
npm install
```

### 2. Configure environment

```bash
cp .env.sample .env
```

Edit `.env` with your values:

| Variable | Description | Example |
|----------|-------------|---------|
| `PORT` | Server listening port | `5000` |
| `DB_HOST` | MySQL host | `localhost` or `db.example.com` |
| `DB_USER` | MySQL user | `dvdtheque_user` |
| `DB_PASSWORD` | MySQL password | - |
| `DB_NAME` | MySQL database name | `my_dvdtheque` |
| `JWT_SECRET` | Secret for signing JWT tokens (min 32 chars) | Generate with `node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"` |
| `FRONTEND_URL` | Allowed CORS origin | `http://localhost:5173` |
| `RESEND_API_KEY` | Resend API key for emails | `re_...` |
| `RESEND_FROM_EMAIL` | Sender email address | `noreply@yourdomain.com` |

### 3. Initialize the database

```bash
mysql -u root -p < database/schema.sql
```

This creates the `my_dvdtheque` database with 3 tables:

- **users** - id, email (unique, indexed), password_hash, nom, created_at
- **password_resets** - token-based reset with 1h expiration, cascade on user delete
- **dvds** - Full DVD metadata (title, director, year, genre, actors, synopsis, poster URL, physical location, loan status). Indexed on user_id, titre, statut

### 4. Run

```bash
# Development (auto-reload with nodemon)
npm run dev

# Production
npm start
```

The server starts on `http://localhost:<PORT>` (default 5000).

## Available Scripts

| Script | Command | Description |
|--------|---------|-------------|
| `dev` | `nodemon server.js` | Dev server with auto-reload |
| `start` | `node server.js` | Production server |
| `lint` | `biome lint .` | Lint code |
| `format` | `biome format . --write` | Auto-format code |
| `check` | `biome check .` | Check code issues |
| `check:fix` | `biome check . --write` | Auto-fix code issues |

## API Endpoints

Base URL: `/api`

### Authentication - `/api/auth`

| Method | Endpoint | Rate Limit | Description |
|--------|----------|-----------|-------------|
| POST | `/register` | 3 req/hour | Create account (email, password, nom) |
| POST | `/login` | 5 req/15min | Login - returns JWT + user info |
| POST | `/forgot-password` | 3 req/15min | Send password reset email |
| POST | `/reset-password` | - | Complete password reset with token |

**Login response:**
```json
{
  "token": "eyJhbG...",
  "user": { "id": 1, "nom": "John", "email": "john@example.com" }
}
```

### DVDs - `/api/dvds` (requires `Authorization: Bearer <token>`)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | List user's DVDs (paginated) |
| GET | `/search?q=term` | Search by title, director, or actors |
| GET | `/:id` | Get single DVD |
| POST | `/` | Add new DVD |
| PUT | `/:id` | Update DVD |
| DELETE | `/:id` | Delete DVD |

**Pagination** - applies to `GET /` and `GET /search`:
- `page` (default: 1)
- `limit` (default: 30, max: 100)

Response includes: `dvds[]`, `total`, `page`, `totalPages`.

## Security

| Feature | Details |
|---------|---------|
| Password hashing | bcrypt (10 salt rounds) |
| Authentication | JWT with 1h expiration |
| Security headers | Helmet (CSP, HSTS, X-Frame-Options, etc.) |
| CORS | Restricted to `FRONTEND_URL` origin |
| Rate limiting | Global: 100 req/15min per IP. Per-endpoint limits on auth routes |
| SQL injection | Parameterized queries (prepared statements) via mysql2 |
| Data isolation | Users can only access their own DVDs |
| Body size | JSON payloads limited to 10KB |
| Email enumeration | Forgot-password returns same response regardless of email existence |

## Deployment Notes

- No Docker configuration - requires Node.js runtime and external MySQL
- The app uses a **connection pool** (mysql2) - no manual connection management needed
- All configuration is via environment variables (12-factor compatible)
- No health check endpoint currently exists — the server listens on `PORT` and can be probed with a TCP check
- Logs go to stdout - pipe to your logging infrastructure as needed
