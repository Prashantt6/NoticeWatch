from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.services.detection import send_hash_code


router = APIRouter()


@router.get("/")
def get_change(db: Session = Depends(get_db)) -> str:
    """
    Return the current page hash calculated from all notices.
    This is recomputed on every call so any insert/update/delete
    in the notices table changes the returned hash.
    """
    return send_hash_code(db)
