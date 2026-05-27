from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from app.db.models import Notice, NoticeVersion
from app.core.security import hash_notice
from sqlalchemy import update


def checkChange(db: Session, notice: dict) -> bool:
    content_hash = hash_notice(notice)

    new_notice = Notice(
        title=notice["title"],
        pdf_link=notice["pdf"],
        published_date=notice["date"],
        content_hash=content_hash,
    )

    try:
        db.add(new_notice)
        db.commit()
        db.refresh(new_notice)
        return True
    except IntegrityError:
        db.rollback()
        return False


def update_version(db: Session):

    db.execute(update(NoticeVersion).values(version=NoticeVersion.version + 1))
    db.commit()
