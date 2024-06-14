import Naver
import Summary
import Upload

from pprint import pprint
import random
from time import sleep


querys = ["훈련병", "채해병", "이재명", "야당", "윤석열", "여당", "국민의힘", "국힘", "더불어민주당", "금리", "러시아", "우크라이나"]

newsList : dict = Naver.setNews(querys, 100)

for news in newsList:

    # 크롤링
    tag, body = Naver.crawl(news["link"])
    news["tag"] = tag
    pprint(f"크롤링 완료 : {news}")

    # 뉴스 요약
    summary = Summary.summary(body)
    news["summary"] = summary
    print(f"요약 완료 : {summary}")

    # 파이어 베이스 업로드
    Upload.upload(news)
    sleep(random.randint(3,5))
