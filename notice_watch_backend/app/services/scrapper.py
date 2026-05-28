import requests
from bs4 import BeautifulSoup
from app.db.database import SessionLocal
from app.services.detection import checkChange, update_version
from app.notifier.firebasenotifier import send_notification

URL = "https://exam.ioe.tu.edu.np/notices"  # Notice page url
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
        awakeRender()
        res = requests.get(
            URL, headers=HEADERS, verify=False, timeout=10
        )  # Fetching all the content of websites
        if res.status_code != 200:
            print("Server error:", res.status_code)
            return
        soup = BeautifulSoup(
            res.content, "html.parser"
        )  # Parsing  the content using html-parser

        notices = soup.find_all("div", class_="recent-post-wrapper shdow")
        # handling bad structure
        if not notices:
            print("Invalid page: notice table not found")
            return
        for notice in notices:
            try:
                notice_date = (
                    notice.find("div", class_="date")
                    .find("span", class_="nep_date")
                    .text.strip()
                )

                title = notice.find("h5").text.strip()

                pdf_link = notice.find("a")["href"]

                notice_data = {
                    "title": title,
                    "date": notice_date,
                    "pdf": pdf_link,
                }

                is_new = checkChange(db, notice_data)

                if is_new:
                    print("New Notice Detected", notice_data["title"])
                    update_version(db)
                    send_notification(db, notice_data["title"])

            except Exception as e:
                print("Notice parse failed:", e)
    finally:
        db.close()


# getNotice()
# notices =[]
# notices.append(getNotice())

# for notice in notices:
#     print(notice)


def awakeRender():
    try:
        res1 = requests.get(
            "https://noticewatch.onrender.com/api/version", headers=HEADERS, timeout=10
        )
        if res1.status_code == 200:
            print("Render awaked")
    except Exception as e:
        print("Render down", e)
