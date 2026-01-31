from app.db.models import Notice
from sqlalchemy.orm import Session


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

