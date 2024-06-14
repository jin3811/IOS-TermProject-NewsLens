# 크롤링시 필요한 라이브러리 불러오기
from typing import Tuple

from bs4 import BeautifulSoup, Tag, NavigableString
import requests
import re
from tqdm import tqdm
import sys
import os
from dotenv import load_dotenv
import xml.etree.ElementTree as ET

load_dotenv()

apiHeaders = {
    'X-Naver-Client-Id': os.getenv("NAVER_APT_APP_ID"),
    'X-Naver-Client-Secret': os.getenv("NAVER_API_KEY"),
}

crawlHeaders = {
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36"
}

def clearTag(data: str) -> str:
    return BeautifulSoup(data, 'html.parser').getText()

def setNews(querys: [str],
            display: int = 30,
            sort: str = "date") -> [{str: str}]:
    news = []
    for query in querys:
        res = requests.get(f"https://openapi.naver.com/v1/search/news.xml?query={query}&diplay={display}&sort={sort}", headers=apiHeaders)
        root = ET.fromstring(res.content)
        items = root.findall('.//item')

        for item in items:
            title = clearTag(item.find('title').text)
            link = item.find('link').text
            date = item.find('pubDate').text

            if "news.naver" in link: # 네이버 뉴스만 사용. 크롤러 개발 시간 단축하기 위해서.
                news.append({
                    "title" : title,
                    "link" : link,
                    "date" : date
                })

    return news


def crawl(url: str) -> tuple[str | Tag | NavigableString | None, str]:
    html = requests.get(url, headers=crawlHeaders).text
    soup = BeautifulSoup(html, "html.parser")

    # 뉴스 타입을 찾는다.
    # 뉴스 타입들 모아둔 헤더
    tag = soup.select_one("#_LNB > ul")

    # 그중 활성화되있는 것이 해당 뉴스의 분류이다.
    tag = tag.find("li", class_='is_active')
    if tag:
        tag = tag.find('span', class_='Nitem_link_menu').text
    else:
        print("해당 요소를 찾을 수 없습니다.")

    # 본문 찾기
    body = soup.select_one("article#dic_area")
    if len(body) == 0:
        body = soup.select_one("#articeBody")

    if body is None: raise TypeError("얘 왜 None이냐")

    # 태그 제거 및 전처리
    body = clearTag(body.text)
    body = body.replace("""[\n\n\n\n\n// flash 오류를 우회하기 위한 함수 추가\nfunction _flash_removeCallback() {}""", '')
    body = body.replace("\n", '')

    # 본문 내용 합치기
    # body = ''.join(str(body))

    return tag, body