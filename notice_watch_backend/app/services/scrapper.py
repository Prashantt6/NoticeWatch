import requests
from bs4 import BeautifulSoup
from app.db.database import SessionLocal
from app.services.detection import checkChange
from app.services.detection import store_hash_code

URL= 'https://exam.ioe.tu.edu.np/notices?title=BE&start_date=&nep_start_date=&end_date=&nep_end_date=&notice_type=930' #Notice page url
# BASE_URL = "http://exam.ioe.edu.np"   #Used to redirect to original page   
HEADERS = {
     "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
                  "AppleWebKit/537.36 (KHTML, like Gecko) "
                  "Chrome/120.0.0.0 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.9",
    "Connection": "keep-alive",
}

def getNotice():
    print("hi from scrapper")
    db = SessionLocal()
    try:
    
        res = requests.get(URL, headers= HEADERS,verify=False,timeout=10) # Fetching all the content of websites
        if(res.status_code!= 200):
            print("Server error:", res.status_code)
            return
        soup = BeautifulSoup(res.content, 'html.parser') #Parsing  the content using html-parser

        notices = soup.find_all("div", class_="recent-post-wrapper shdow")
        for notice in notices:
            dates = soup.find_all("div",class_="date")
            for date in dates:
                notice_date= date.find("span", class_="nep_date").text.strip()
                title= notice.find("h5").text.strip()
                pdf_link = notice.find("a")["href"]
                
            print({
            # "sno": sno,
            "title": title,
            "date": notice_date,
            "pdf": pdf_link,
            # "view": view_link
            
             })
            
            
            # Detect change
            # is_new =checkChange(db, notice)
            
            # if is_new:
            #     print("New Notice Detected")
            #     store_hash_code(db)
    except Exception as e:
            print("Scrapping failed", e)
    finally:
        db.close()
        
   
# getNotice()
# notices =[]
# notices.append(getNotice())

# for notice in notices:
#     print(notice)

