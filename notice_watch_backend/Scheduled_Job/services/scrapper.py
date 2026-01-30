import requests
from bs4 import BeautifulSoup

def getNotice():
    res = requests.get('http://exam.ioe.edu.np/') # Fetching all the content of websites
    soup = BeautifulSoup(res.content, 'html.parser') #Parsing  the content using html-parser

    # Filtering the only notice

    table = soup.find("table", id= "datatable") #notice table

    rows = table.tbody.find_all("tr") #getting rows of notice table
    notices = []
    for row in rows:
        tds = row.find_all("td") #Extracting all the data from each rows

        # print(tds)
        sno = tds[0].get_text(strip = True) #serial no of notices
        title_tag = tds[1].find("a")      #extracting title stored in a tag
        title = title_tag.get_text(strip = True) #getting only title of notice
        pdf_link = title_tag["href"]

        notice_date = tds[2].get_text(strip = True)
        view_link = tds[3].find("a")["href"] #getting the view link of notice   

        notice ={
            "sno": sno,
            "title": title,
            "date": notice_date,
            "pdf": pdf_link,
            "view": view_link
        }
        print({
        "sno": sno,
        "title": title,
        "date": notice_date,
        "pdf": pdf_link,
        "view": view_link
         })
        
        notices.append (notice)
        return notices
notices = getNotice()

# for notice in notices:
#     print(notice)
