from dotenv import load_dotenv
from openai import OpenAI
import os

load_dotenv()

credential = OpenAI(
    api_key=os.getenv("OPENAI_API_KEY"),
    organization=os.getenv("OPENAI_API_ORG")
)
instructions = ["1. Overall summary of news", "2. Identify the main agenda items, topics of the news (by the Sixth Sense principle)"] #, "If applicable, the key points of the news."
system_instruction = "\n".join(["You will be provided with korean news, and your task is to summarize the korean news as follows", *instructions, "important : The summarized result must be provided in Korean."])

def summary(msg : str) -> str :
    try :
        return credential.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                { "role": "system", "content": system_instruction },
                { "role" : "user" , "content" : msg }
            ],
            temperature=0.3,
            max_tokens=len(msg)//2
        ).choices[0].message.content

    except Exception as e:
        print(e)
        return "요약에 실패했습니다."

if __name__ == "__main__" :
    print("--- summary test")
    msg="""
    군기훈련(얼차려)을 받다 쓰러져 이틀 뒤 숨진 훈련병을 처음 진료한 신병교육대 의무실에 의무기록이 존재하지 않는 것으로 확인됐다. 민간병원에 후송돼 치료받다 숨진 이 훈련병의 사망진단서에는 사인이 ‘패혈성 쇼크에 따른 다발성장기부전’으로 기록됐다. 군인권센터는 12일 서울 마포구 사무실에서 기자회견을 열어 이렇게 밝히며 진료기록이 작성되지 않았다면 관련 법령을 명백히 어긴 것이라고 했다.
    군인권센터는 지난달 23일 강원 인제군 소재 12사단 신병교육대에서 군기훈련을 받아 쓰려져 이틀 뒤 숨진 훈련병 가족이 군 병원에 신병교육대 의무실의 의무기록을 요청했으나 “의무기록이 존재하지 않는다”는 답변을 들었다고 밝혔다. 군보건의료에 관한 법률에 따르면 군 보건의료인의 진료기록 작성은 의무사항이다.
    앞서 육군 공보과장은 지난달 28일 훈련병 사망 사건 관련 언론브리핑을 하면서 “군의관이 응급구조사와 수액, 체온 조절을 위한 응급조치를 진행했고 응급의료종합상황센터와 연계해 환자 상태와 이송 수단 등을 고려해 긴급 후송했다”고 밝혔다. 군인권센터는 “이 브리핑이 내용이 사실이라면 전산상 의무기록이 존재해야 한다”고 지적했다. 군인권센터는 “기록이 없다는 건 명백히 관계 법령을 위반한 행위”라며 “수사를 통해 사건 초기 상황을 면밀히 파악해야 한다”고 말했다.
    군인권센터는 숨진 훈련병의 사망진단서 등 민간병원이 작성한 의무기록도 공개했다. 강릉아산병원이 작성한 사망진단서 등에 기재된 직접사인은 패혈성 쇼크에 따른 다발성 장기부전으로, 사망 원인은 열사병으로 기록됐다. 군인권센터는 훈련병을 사망에 이르게 한 군기훈련은 사실상 가혹행위에 해당한다고 주장했다. 임태훈 군인권센터 소장은 “응급의학 전문의에게 자문한 결과 의무기록 상으론 건강 상태가 매우 급격히 나빠지는 양상을 보였다”며 “상당히 가혹한 수준으로 얼차려가 이뤄졌던 것으로 추정된다”고 말했다. 군인권센터는 군사경찰이 유족에게 사고 당시 상황을 설명하면서 의무병이 쓰러진 훈련병의 맥박을 확인할 때 중대장이 ‘일어나, 너 때문에 애들이 못 가고 있잖아’라는 취지로 말했다고 전했다.
    군인권센터는 얼차려를 지시한 중대장이 ‘선탑’(군 차량을 운행할 때 운전병 옆에 간부가 탑승해 상황을 통제하는 것)해 훈련병을 후송하는 과정에서 가혹행위에 관한 상황 전달이 제대로 이뤄지지 않았을 가능성도 제기했다. 중대장이 군의관과 최초 이송된 속초의료원 등 의료인과 주변 간부들에게 상황을 축소해서 보고했을 가능성이 있다는 취지의 문제 제기다. 군인권센터는 “경찰은 중대장이 가혹한 얼차려를 강제했다는 사실관계를 의료인 등에게 정확하게 진술했는지 면밀히 수사해야 한다”고 말했다.
    """
    print(f"총 길이 : {len(msg)}, 미리보기 : {msg[:20]}")
    res = summary(msg)
    print(res)