from sqlalchemy import Column, Integer, String
from app.db.database import Base

class Notice(Base):
    __tablename__ = "notices"

    id= Column(Integer, primary_key=True, index= True)

    
    title= Column(String, nullable=False)
    published_date= Column(String,index= True)
    pdf_link = Column(String, nullable= True)
    view_link = Column(String, nullable= True)

    content_hash = Column(String, nullable=False, unique=True, index= True)
    
class Page_hash(Base):
    __tablename__ = "pagehash"

    id = Column(Integer, primary_key=True, index=True)
    page_hash = Column(String,unique= True, index = True )
