from fastapi import APIRouter, Depends
from app.db.models import AppVersion
from app.db.database import get_db
from sqlalchemy.orm import Session

router = APIRouter()


@router.get("/app-version")
def get_latest_version(db: Session = Depends(get_db)):

    latest = db.query(AppVersion).order_by(AppVersion.version_code.desc()).first()

    return latest
