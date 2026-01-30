from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from app.db.models import Notice
from app.core.security import hash_notice


def checkChange(db: Session,notice: dict) -> bool:
    content_hash = hash_notice(notice)

    new_notice = Notice(
        title = notice["title"],
        pdf_link= notice["pdf"],
        view_link= notice["view"],
        published_date = notice["date"],
        content_hash = content_hash
    )

    try:
        db.add(new_notice)
        db.commit()
        return True
    except IntegrityError:
        db.rollback()
        return False


