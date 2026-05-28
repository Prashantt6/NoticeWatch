import os
from typing import Any
from supabase import create_client
from fastapi import APIRouter, HTTPException
from dotenv import load_dotenv
load_dotenv()

# Environment variables must be present; fail fast if missing so types are non-Optional
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_ANON_KEY = os.getenv("SUPABASE_ANON_KEY")
assert SUPABASE_URL is not None and SUPABASE_ANON_KEY is not None, (
    "Missing SUPABASE environment variables: DATABASE_URL and SUPABASE_ANON_KEY are required"
)

supabase = create_client(
    SUPABASE_URL,
    SUPABASE_ANON_KEY
)

router = APIRouter()

@router.post("/login")
def login(email:str, password:str):
    try:
        response = supabase.auth.sign_in_with_password({
            "email": email,
            "password": password
        })

        # response.session may be None; guard before accessing attributes
        session = getattr(response, "session", None)
        if session is None or getattr(session, "access_token", None) is None:
            raise HTTPException(status_code=401, detail="Invalid Credentials")

        return {
            "access_token": session.access_token,
            "token_type": "bearer"
        }
    except Exception:
        raise HTTPException(
            status_code=401,
            detail="Invalid Credentials"
        )