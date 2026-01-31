from app.db.database import SessionLocal
from app.db.models import Notice

db = SessionLocal()

notice = db.query(Notice).all()

print("Total notices:", len(notice))

for n in notice[:3]:
    print(n.title)

db.close()