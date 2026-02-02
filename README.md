# NoticeWatch
NoticeWatch is a backend-driven notification system that automatically monitors the IOE examination website for new notices and notifies users in real time via push notifications. The system is designed to be efficient, fault-tolerant, and suitable for low-frequency but important updates such as college notices.

---

## ✨ Features

- 🔍 Periodically scrapes the IOE notice website (every 10 minutes)
- 🧠 Detects newly published notices using change-detection logic
- 💾 Stores notices persistently in a database
- 🔔 Sends push notifications when a new notice is detected
- 📱 Flutter frontend fetches notices via clean REST APIs
- 💤 Gracefully handles website downtime or server sleep (free hosting)
- ⚙️ Fully automated — no user-triggered scraping

---

## 🏗️ System Architecture

APScheduler (every 10 minutes)
↓
Scraper
↓
Change Detection
↓
Database
↓
Notifier 
↓
User Devices


- **Scheduler** decides *when* scraping happens  
- **Scraper** collects notice data from the website  
- **Change Detection** checks whether a notice is new  
- **Database** acts as the single source of truth  
- **Notifier** sends push notifications for new notices  
- **API** serves stored notices to the frontend  

---

## 🧠 Design Principles

- **Server-side monitoring** (no client-side polling)
- **Event-driven notifications** (notify only on real changes)
- **Fail-safe scraping** (website downtime does not crash the backend)
- **Thin frontend, smart backend**
- **Separation of concerns** between scheduler, scraper, API, and notifier

---

## 🛠️ Tech Stack

### Backend
- FastAPI
- APScheduler (background scheduling)
- Requests + BeautifulSoup (web scraping)
- SQLite / PostgreSQL (database)
- Firebase Cloud Messaging (push notifications)

### Frontend
- Flutter
- REST API integration
- FCM for notifications

---

## 📂 Project Structure (Backend)

```text
app/ 
├── main.py # FastAPI entry point 
├── api/ # API routes (read-only)
├── scheduler/ # APScheduler setup 
├── services/ 
│ ├── scrapper.py # Website scraping logic 
│ └── detection.py # Change detection logic 
├── notifier/ # Push notification logic
├── db/ # Database models and sessions 
└── core/ # Config and settings
```
---

## 🔄 How It Works (Flow)

1. Backend starts and initializes APScheduler
2. Every 10 minutes, the scheduler triggers the scraper
3. Scraper fetches and parses the notice table
4. Each notice is checked against stored data
5. If a new notice is found:
   - It is saved to the database
   - A push notification is sent to users
6. Flutter app fetches notices via API and displays them

---

## 🛡️ Failure Handling

- If the IOE website is down or unreachable:
  - The scraper exits gracefully
  - No database changes are made
  - No notifications are sent
  - The system retries on the next scheduled run
- Backend crashes are avoided through defensive scraping and scheduling

---

## 🚀 Deployment

- Designed to run on free hosting platforms (Render)
- Backend may sleep during inactivity on free tier
- Any API request wakes the server and resumes scheduling
- Occasional notification delay is acceptable for notice-based systems

---

## 📌 Future Improvements

- Admin dashboard for monitoring scraper status
- Better logging and alerting
- Support for multiple notice sources
- Notice categorization and filtering
- Pagination and search in API responses

---

## 📄 License

This project is for educational and personal use.

---

## 🙌 Acknowledgements

Built as a learning project to understand:
- Backend system design
- Scheduling and background jobs
- Web scraping reliability
- Push notification architecture

