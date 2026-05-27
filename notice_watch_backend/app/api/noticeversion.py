from fastapi import APIRouter, Depends
from app.db.database import get_db
from app.db.models import NoticeVersion
from sqlalchemy.orm import Session

router = APIRouter()

@router.get("/version")
def notice_version(
    db: Session = Depends(get_db)
):
    version_row = db.query(NoticeVersion).first()
    if not version_row:
        return {"notice_version": 0}
    return {"notice_version": version_row.version}
