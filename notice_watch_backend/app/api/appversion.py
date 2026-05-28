from fastapi import APIRouter, Depends
from app.db.models import AppVersion,Users
from app.db.database import get_db
from sqlalchemy.orm import Session
from app.core.dependencies import get_admin
from pydantic import BaseModel
router = APIRouter()

class AppReleaseSchema(BaseModel):
    version_code: int
    version_name: str
    apk_url:str
    changelog:str | None = None
    force_update: bool


@router.get("/app-version")
def get_latest_version(db: Session = Depends(get_db)):

    latest = db.query(AppVersion).order_by(AppVersion.version_code.desc()).first()

    return latest

@router.post("/app-release")
def release_notice(
    payload: AppReleaseSchema,
    db: Session = Depends(get_db),
    admin: Users = Depends(get_admin)
) -> AppReleaseSchema:
    
    new_release = AppVersion(
        version_code = payload.version_code,
        version_name = payload.version_name,
        apk_url = payload.apk_url,
        changelog = payload.changelog,
        force_update = payload.force_update
    )
    
    db.add(new_release)
    db.commit()

    return new_release