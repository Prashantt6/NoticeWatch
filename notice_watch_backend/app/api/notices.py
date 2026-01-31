from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.db.models import Notice

router = APIRouter(prefix="/api")

def fetch_notices_from_db(db:Session):
    notices = db.query(Notice).all()

    return [
        {
            "title": notice.title,
            "published_date": notice.published_date,
            "pdf_link": notice.pdf_link,
            "view_link": notice.view_link
        }
        for notice in notices
    ]

@router.get("/notices")
def get_notices(db: Session = Depends(get_db)):
    return fetch_notices_from_db(db)
