from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from app.db.models import Notice
from app.db.models import Page_hash
from app.core.security import hash_page
from app.core.security import hash_notice


def checkChange(db: Session,notice: dict) -> bool:
    content_hash = hash_notice(notice)

    new_notice = Notice(
        title = notice["title"],
        pdf_link= notice["pdf"],
        # view_link= notice["view"],
        published_date = notice["date"],
        content_hash = content_hash
    )   

    try:
        db.add(new_notice)
        db.commit()
        db.refresh(new_notice)
        return True
    except IntegrityError:
        db.rollback()
        return False

def store_hash_code(db: Session):
    hashed_value = send_hash_code(db)
    try:
        page = db.query(Page_hash).first()

        if page is None:
            page= Page_hash(page_hash = hashed_value)
            db.add(page)

        else:
            page.page_hash = hashed_value
        db.commit()

    except IntegrityError:
        db.rollback()


def send_hash_code(db: Session):
    rows = db.query(Notice.content_hash).order_by(Notice.created_at.desc(), Notice.id.desc()).all()
    hashes= [row[0] for row in rows]

    hashed_value = hash_page(hashes)

    return hashed_value
