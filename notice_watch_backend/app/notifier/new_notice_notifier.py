from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from app.db.database import get_db
from app.db.models import Page_hash


router = APIRouter()

def get_page_hash(db: Session):
    page= db.query(Page_hash.page_hash).first()
    return page.page_hash if page else None

@router.get("/")
def get_change(db: Session= Depends(get_db)):
    return {
        get_page_hash(db)
    }
