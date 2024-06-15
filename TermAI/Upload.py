import firebase_admin
from firebase_admin import firestore

# Application Default credentials are automatically created.
cred = firebase_admin.credentials.Certificate("firebase-credential.json")
app = firebase_admin.initialize_app(cred)
db = firestore.client()
collection = "news"

def upload(data : {str: str}) -> bool:
    id = f"{data["date"]}-{data["title"]}"
    doc_ref = db.collection(collection).document(id)
    doc_ref.set(data)

if __name__ == "__main__":
    print("--- Upload_test")

    cred = firebase_admin.credentials.Certificate("firebase-credential.json")
    app = firebase_admin.initialize_app(cred)
    db = firestore.client()
    print("--- ok. credential complete")

    doc_ref = db.collection("test").document("termAI2")
    doc_ref.set({"플젝" : "캡스톤인데 플젝을 내네"})
    print("--- test upload complete")

    termAI_ref = db.collection("test").stream()
    for doc in termAI_ref:
        print(f"{doc.id} => {doc.to_dict()}")