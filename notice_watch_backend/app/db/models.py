from sqlalchemy import Column, Integer, String, DateTime,Boolean,UUID
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


class AppVersion(Base):
    __tablename__ = "app_versions"
    id = Column(Integer, primary_key=True)
    version_code = Column(Integer, nullable=False)
    version_name = Column(String, nullable=False)
    apk_url = Column(String, nullable=False)
    changelog = Column(String)
    force_update = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class Users(Base):
    __tablename__= "users"
    id = Column(UUID, primary_key=True)
    is_admin = Column(Boolean, default=False)