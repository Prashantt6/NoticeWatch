from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.executors.pool import ThreadPoolExecutor
from apscheduler.jobstores.memory import MemoryJobStore
from datetime import datetime

from app.services.scrapper  import getNotice

scheduler = BackgroundScheduler(
        jobstores= {
            "default": MemoryJobStore()
        },
        executors= {
            "default": ThreadPoolExecutor(max_workers=1)
        },
        job_defaults = {
            "coalesce": True,
            "max_instances":1
        },
        timezone="UTC"
    )

def start_scheduler():
    if scheduler.running:
        return
    print("Scheduler started")

    scheduler.add_job(
        func=getNotice,
        trigger= "interval",
        minutes = 10,
        next_run_time=datetime.utcnow(), 
        id = "notice_scrapper",
        replace_existing= True
    )

    scheduler.start()
    print("Notice scraper scheduler started")
