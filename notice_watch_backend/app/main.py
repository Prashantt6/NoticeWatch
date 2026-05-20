from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.notices import router as notice_router
from app.notifier.new_notice_notifier import router as notfier_router
from app.api.devicetokens import router as device_token_router
from app.scheduler.notice_scheduler import start_scheduler
from app.firebase.firebase import initialize_firebase
from app.db.database import Base, engine

app = FastAPI()
app.include_router(notice_router, prefix="/api/notices", tags=["Notices"])
app.include_router(notfier_router, prefix="/api/notifier", tags=["Notifier"])
app.include_router(device_token_router, prefix="/api/device", tags=["Device Token"])

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
def startup_event():

    Base.metadata.create_all(bind=engine)
    initialize_firebase()
    start_scheduler()


@app.get("/")
async def health_check():
    return {"status": "running"}
