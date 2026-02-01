from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.executors.pool import ThreadPoolExecutor
from apscheduler.jobstores.memory import MemoryJobStore
from app.services.scrapper  import getNotice


scheduler = BackgroundScheduler()
def start_scheduler():
    # print("Scheduler started")
    scheduler = BackgroundScheduler(
        jobstores= {
            "default": MemoryJobStore()
        },
        executors= {
            "default": ThreadPoolExecutor(max_workers=1)
        },
        job_defaults = {
            "colaesce": True,
            "max_instance":1
        },
        timezone="UTC"
    )
    scheduler.add_job(
        func= getNotice,
        trigger= "interval",
        minutes = 10,
        id = "notice_scrapper",
        replace_existing= True
    )

    scheduler.start()
    print("Notice scraper scheduler started")
