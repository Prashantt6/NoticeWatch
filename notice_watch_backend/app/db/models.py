from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.sql import func
from app.db.database import Base


class Notice(Base):
    __tablename__ = "notices"

    id = Column(Integer, primary_key=True, index=True)

    title = Column(String, nullable=False)
    published_date = Column(String, index=True)
    pdf_link = Column(String, nullable=True)
    # view_link = Column(String, nullable= True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    content_hash = Column(String, nullable=False, unique=True, index=True)


class DeviceToken(Base):
    __tablename__ = "device_tokens"

    id = Column(Integer, primary_key=True)
    token = Column(String, unique=True, nullable=False)


class NoticeVersion(Base):
    __tablename__ = "noticeversion"
    id = Column(Integer, primary_key=True)
    version = Column(Integer, nullable=False, default=0)
