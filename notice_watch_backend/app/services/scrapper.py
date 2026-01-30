import requests
from bs4 import BeautifulSoup
from app.db.database import SessionLocal

from app.services.detection import checkChange

def getNotice():
    db = SessionLocal()
    print("hi")
    try:
        res = requests.get('http://exam.ioe.edu.np/') # Fetching all the content of websites
        soup = BeautifulSoup(res.content, 'html.parser') #Parsing  the content using html-parser

        # Filtering the only notice

        table = soup.find("table", id= "datatable") #notice table

        rows = table.tbody.find_all("tr") #getting rows of notice table
        
        for row in rows:
            tds = row.find_all("td") #Extracting all the data from each rows

            # print(tds)
            sno = tds[0].get_text(strip = True) #serial no of notices
            title_tag = tds[1].find("a")      #extracting title stored in a tag
            title = title_tag.get_text(strip = True) #getting only title of notice
            pdf_link = title_tag["href"]

            notice_date = tds[2].get_text(strip = True)
            view_link = tds[3].find("a")["href"] #getting the view link of notice   

            BASE_URL = "http://exam.ioe.edu.np"   #Used to redirect to original page      
            # print({
            # "sno": sno,
            # "title": title,
            # "date": notice_date,
            # "pdf": pdf_link,
            # "view": view_link
            #  })
            notice ={
                "sno": sno,
                "title": title,
                "date": notice_date,
                "pdf": BASE_URL + pdf_link,
                "view": BASE_URL + view_link
            }
            
            
            is_new =checkChange(db, notice)
            
            if is_new:
                print("NEW NOTICE:", notice["title"])
    finally:
        db.close()
        
   
getNotice()
# notices =[]
# notices.append(getNotice())

# for notice in notices:
#     print(notice)

