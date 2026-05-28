from fastapi import APIRouter, Depends, HTTPException
from app.db.models import AppVersion, Users
from app.db.database import get_db
from sqlalchemy.orm import Session
from app.core.dependencies import get_admin
from pydantic import BaseModel, ConfigDict

router = APIRouter()


class AppReleaseSchema(BaseModel):
    version_code: int
    version_name: str
    apk_url: str
    changelog: str | None = None
    force_update: bool
    model_config = ConfigDict(from_attributes=True)


@router.get("/app-version")
def get_latest_version(db: Session = Depends(get_db)) -> AppReleaseSchema:

    latest = db.query(AppVersion).order_by(AppVersion.version_code.desc()).first()

    if latest is None:
        raise HTTPException(status_code=404, detail="No app version found")

    return AppReleaseSchema.from_orm(latest)


@router.post("/app-release")
def release_notice(
    payload: AppReleaseSchema,
    db: Session = Depends(get_db),
    admin: Users = Depends(get_admin),
) -> AppReleaseSchema:

    new_release = AppVersion(
        version_code=payload.version_code,
        version_name=payload.version_name,
        apk_url=payload.apk_url,
        changelog=payload.changelog,
        force_update=payload.force_update,
    )

    db.add(new_release)
    db.commit()
    db.refresh(new_release)

    return AppReleaseSchema.from_orm(new_release)
