tfrom fastapi import APIRouter, Depends
from pydantic import BaseModel

from sqlalchemy.orm import Session

from app.db.database import get_db
from app.db.models import DeviceToken

router = APIRouter()


class TokenRequest(BaseModel):
    token: str


class DeviceTokenService:
    def __init__(self, session: Session):
        self.session = session

    def storeToken(self, token: str):

        existing = (
            self.session.query(DeviceToken).filter(DeviceToken.token == token).first()
        )
        if existing:
            return False

        new_token = DeviceToken(token=token)

        try:
            self.session.add(new_token)
            self.session.commit()

            return True
        except Exception:
            self.session.rollback()

            return False


@router.post("/token")
def storeDeviceToken(
    data: TokenRequest,
    db: Session = Depends(get_db),
):
    service = DeviceTokenService(db)

    stored = service.storeToken(data.token)

    if stored:
        return {"message": "Device token stored"}

    return {"message": "Token exists already"}
