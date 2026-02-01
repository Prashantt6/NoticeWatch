import requests
from bs4 import BeautifulSoup
from app.db.database import SessionLocal
from app.services.detection import checkChange
from app.services.detection import store_hash_code

URL= 'http://exam.ioe.edu.np/' #Notice page url
BASE_URL = "http://exam.ioe.edu.np"   #Used to redirect to original page   
HEADERS = {
    "User-Agent": "Mozilla/5.0 (NoticeWatch Bot)"
}

def getNotice():
    print("hi from scrapper")
    db = SessionLocal()
    try:
    
        res = requests.get(URL, headers= HEADERS,timeout=10) # Fetching all the content of websites
        if(res.status_code!= 200):
            print("Server error:", res.status_code)
            return
        soup = BeautifulSoup(res.content, 'html.parser') #Parsing  the content using html-parser

        # Filtering only the notices
        table = soup.find("table", id= "datatable") #notice table

        #handling bad structure
        if not table: 
            print("Invalid page: notice table not found")
            return
        rows = table.tbody.find_all("tr") #getting rows of notice table
        
        for row in rows:
            tds = row.find_all("td") #Extracting all the data from each rows
            if len(tds) < 4:
                continue
            # print(tds)
            sno = tds[0].get_text(strip = True) #serial no of notices
            title_tag = tds[1].find("a")      #extracting title stored in a tag
            if not title_tag:
                continue
            title = title_tag.get_text(strip = True) #getting only title of notice
            pdf_link = title_tag["href"]

            notice_date = tds[2].get_text(strip = True)
            view_link = tds[3].find("a")["href"] #getting the view link of notice   

                
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
            
            #Detect change
            is_new =checkChange(db, notice)
            
            if is_new:
                print("New Notice Detected")
                store_hash_code(db)
    except Exception as e:
            print("Scrapping failed", e)
    finally:
        db.close()
        
   
# getNotice()
# notices =[]
# notices.append(getNotice())

# for notice in notices:
#     print(notice)

