from apscheduler.schedulers.background import BackgroundScheduler
from app.services.scrapper  import getNotice

scheduler = BackgroundScheduler()
def start_scheduler():
    # print("Scheduler started")
   
    scheduler.add_job(
        getNotice,
        trigger= "interval",
        minutes = 10,
        id = "notice_scrapper",
        replace_existing= True
    )

    scheduler.start()
