from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.api.notices import router as notice_router
from app.scheduler.notice_scheduler import start_scheduler

app = FastAPI()
app.include_router(notice_router)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
@app.on_event("startup")
def startup_event():
    start_scheduler()
@app.get("/")
async def health_check():
    return {"status": "running"}
