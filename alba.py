import os
import csv
import requests
from bs4 import BeautifulSoup

os.system("clear")

def write_company(company):
    # 동적 경로 생성
    directory = os.path.join(os.path.expanduser("~"), "Desktop", "project", "assets", "csv_ori")
    if not os.path.exists(directory):
        os.makedirs(directory)
    
    file_path = os.path.join(directory, f"{company['name']}.csv")
    
    # CSV 파일 작성
    with open(file_path, mode="w", newline='', encoding="utf-8-sig") as file:
        writer = csv.writer(file)
        writer.writerow(["place", "title", "time", "pay", "date"])
        
        for job in company["jobs"]:
            writer.writerow(list(job.values()))
    print(f"{company['name']} 데이터를 {file_path}에 저장했습니다.")
        
alba_url = "http://www.alba.co.kr"

alba_request = requests.get(alba_url)
alba_soup = BeautifulSoup(alba_request.text, "html.parser")
main = alba_soup.find("div", {"id": "MainSuperBrand"})
brands = main.find_all("li", {"class": "impact"})
    
for brand in brands:
    link = brand.find("a", {"class": "goodsBox-info"})
    name = brand.find("span", {"class": "company"})

    if link and name:
        # a 태그 안의 href 값 가져옴
        link = link["href"]
        name = name.text

        # 브랜드 명 중 '/' 이 포함되어 csv 파일 생성 오류 발생하는 경우가 있어, replace를 이용하여 '/'를 '_'로 대체
        name = name.replace('/', '_')
        company = {'name': name, 'jobs': []}

        # 추출된 각 브랜드 링크를 이용하여, 브랜드 별 공고 정보 추출
        jobs_request = requests.get(link)
        jobs_soup = BeautifulSoup(jobs_request.text, "html.parser")
        tbody = jobs_soup.find("div", {"id": "NormalInfo"}).find("tbody")

        # class 값이 존재하지 않는 tr 태그 & 'divide'인 tr 태그 모두 제거
        rows = tbody.find_all("tr", {'class': ['', 'divide']})
        for row in rows:
            local = row.find("td", {"class": "local"})
            local = local.text.replace(u'\xa0', ' ') if local else "N/A"

            title = row.find("td", {"class": "title"})
            title = title.find("a").find("span", {"class": "company"}).text.strip() if title else "N/A"

            time = row.find("td", {"class": "data"})
            time = time.text.replace(u'\xa0', ' ') if time else "N/A"

            pay = row.find("td", {"class": "pay"})
            pay = pay.text.replace(u'\xa0', ' ') if pay else "N/A"

            date_cell = row.find("td", {"class": "regDate"})
            if date_cell:
                strong_tag = date_cell.find("strong")
                date = strong_tag.text.strip() if strong_tag else "N/A"
            else:
                date = "N/A"
        
            job = {
                "place": local,
                "title": title,
                "time" : time,
                "pay" : pay,
                "date" : date
            }
            company['jobs'].append(job)
            
        write_company(company)
