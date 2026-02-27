# NoticeWatch
NoticeWatch is a FastAPI + Flutter based notification system that automatically monitors the IOE examination website for new notices and notifies users using **hash-based change detection**. The backend scrapes and stores notices, exposes simple REST APIs, and the Flutter app polls those APIs and shows local notifications when new notices are detected.

---

##  Features

-  Periodically scrapes the IOE notice website
-  Detects newly published notices using hash‑based change detection
-  Stores notices persistently in a database
-  Notifies users when a new notice is detected (local notifications on device)
-  Flutter frontend fetches notices via clean REST APIs
-  Hash comparison between backend and frontend for reliable change detection
-  Gracefully handles website downtime or server sleep (free hosting)
-  Fully automated fetching — no manual scraping required

---

##  System Architecture
``` text

Scraper / Detection (backend)
↓
Database (notices + content hashes)
↓
Page‑hash computation (`/api/notifier/`)
↓
REST API (`/api/notices/`)
↓
Flutter App (hash comparison + local notifications)
```

- **Scraper** collects notice data from the IOE website  
- **Change Detection** stores new notices and their `content_hash` in the DB  
- **Page hash** combines all `content_hash` values into a single SHA‑256 page hash  
- **Database** acts as the single source of truth  
- **API** serves both notices and the current page hash to the frontend  
- **Flutter app** compares its stored page hash to the backend page hash to decide when to fetch and notify  

---

##  Design Principles

- **Hash-based change detection** (compare hashes, not whole payloads)
- **Lightweight client polling** (minimal, hash-first checks from the app)
- **Event-driven notifications** (notify only on real changes)
- **Fail-safe scraping** (website downtime does not crash the backend)
- **Thin frontend, smart backend**
- **Separation of concerns** between scraper, detection, API, notifier, and Flutter app

---

##  Tech Stack

### Backend
- FastAPI
- Requests + BeautifulSoup (web scraping)
- SQLite / PostgreSQL (database)
- Custom hash‑based notifier (`/api/notifier/`)

### Frontend
- Flutter
- REST API integration
- `flutter_local_notifications` for on‑device notifications

---

##  Project Structure (Backend)

```text
app/
├── main.py          # FastAPI entry point
├── api/
│   └── notices.py   # /api/notices/ - list notices
├── notifier/
│   └── new_notice_notifier.py  # /api/notifier/ - current page hash
├── services/
│   ├── scrapper.py  # Website scraping logic
│   └── detection.py # Change detection + hash storage
├── db/
│   ├── models.py    # Notice + Page_hash models
│   └── database.py  # DB session / engine
└── core/
    └── security.py  # hash_notice / hash_page helpers
```
---

##  How It Works (Flow)

1. Backend scraper periodically reads the IOE notices page.
2. Each scraped notice is checked; new ones are inserted into the `notices` table with a unique `content_hash`.
3. The backend exposes:
   - `GET /api/notices/` → ordered list of notices with `title`, `published_date`, `pdf_link`, `content_hash`.
   - `GET /api/notifier/` → a single SHA‑256 **page hash** computed from all `content_hash` values.
4. The Flutter app:
   - Computes and stores its own page hash from the `/api/notices/` response.
   - Polls `/api/notifier/` in background (via Workmanager) and foreground (1‑minute timer + pull‑to‑refresh).
   - If the backend page hash differs from its stored hash, it fetches `/api/notices/`, recomputes the hash, updates local cache, and shows a local notification.

---

##  Failure Handling

- If the IOE website is down or unreachable:
  - The scraper exits gracefully
  - No database changes are made
  - No notifications are sent
  - The system retries on the next scheduled run
- Backend crashes are avoided through defensive scraping and scheduling

---

##  Deployment

- Designed to run on free hosting platforms (Render)
- Backend may sleep during inactivity on free tier
- Any API request wakes the server and resumes scheduling
- Occasional notification delay is acceptable for notice-based systems

---

##  Future Improvements

- Admin dashboard for monitoring scraper status
- Better logging and alerting
- Support for multiple notice sources
- Notice categorization and filtering
- Pagination and search in API responses

---

## License

This project is for educational and personal use.

---

##  Acknowledgements

Built as a learning project to understand:
- Backend system design
- Scheduling and background jobs
- Web scraping reliability
- Push notification architecture

