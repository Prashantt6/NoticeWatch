import json
import firebase_admin
from firebase_admin import credentials
from app.core.config import settings


def initialize_firebase():
    if not firebase_admin._apps:
        cred_dict = json.loads(settings.FIREBASE_CREDENTIALS)

        cred = credentials.Certificate(cred_dict)

        firebase_admin.initialize_app(cred)

    print("Firebase initialized")
