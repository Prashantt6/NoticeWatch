from fastapi import Depends, HTTPException
from app.db.models import Users
from fastapi.security import OAuth2PasswordBearer
from app.api.auth import supabase
from app.db.database import get_db
from sqlalchemy.orm import Session

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="api/login")


def get_current_user(token: str = Depends(oauth2_scheme)):
    try:
        user = supabase.auth.get_user(token)
        # supabase.auth.get_user may return None or an object without `user`
        if user is None or getattr(user, "user", None) is None:
            raise HTTPException(status_code=401, detail="Unauthorized")
        return user.user
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid token")


def get_admin(auth_user=Depends(get_current_user), db: Session = Depends(get_db)):

    print(auth_user.id)
    user = db.query(Users).filter(Users.id == auth_user.id).first()

    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    if not user.is_admin:
        raise HTTPException(status_code=403, detail="Unauthorized action")

    return user
