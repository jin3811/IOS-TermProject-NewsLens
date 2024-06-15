//
//  MainViewController.swift
//  NewsLens
//
//  Created by 허진우 on 6/14/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class MainViewController: UIViewController {
    @IBOutlet weak var newsTable: UITableView!
    @IBOutlet weak var newsSummary: UILabel!
    
    var auth : AuthDataResult? // segue하면서 넘어온다.
    var news : [[String : String]] = []
    var db = Firestore.firestore().collection("news")
    
    var instructions : [String]?
    var systemInstruction : String?
    var openAiSite = "https://api.openai.com/v1/chat/completions"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newsTable.dataSource = self
        newsTable.delegate = self
        
        instructions = ["1. Overall summary of news", "2. Identify the main agenda items, topics of the news (by the Sixth Sense principle)"]
        systemInstruction = (["You will be provided with korean news, and your task is to summarize the korean news as follows"] + self.instructions! + ["important : The summarized result must be provided in Korean."]).joined(separator: "\n")
        
        db.getDocuments { querySnapshot, error in
            // 에러 발생
            if let error = error {
                print("뉴스를 가져오는데 문제 발생 : \(error.localizedDescription)")
                return
            }
            
            // documents가 nil이면 데이터가 없다는 뜻
            guard let documents = querySnapshot?.documents else {
                print("뉴스가 없음.")
                return
            }
            
            // 데이터가 있으면 기존의 데이터는 지운다.
            self.news.removeAll()
            
            for document in documents {
                let data = document.data()
                
                // Assuming each document contains "title" and "summary" fields
                if let title = data["title"] as? String,
                   let date = data["date"] as? String,
                   let body = data["body"] as? String,
                   let link = data["link"] as? String,
                   let tag = data["tag"] as? String
                {
                    print("데이터 추가되는 중... \(title)")
                    self.news.append(["title": title, "date": date, "body" : body, "link" : link, "tag" : tag])
                }
            }
            DispatchQueue.main.async {
                self.newsTable.reloadData()
            }
        }
    }
}

extension MainViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = newsTable.dequeueReusableCell(withIdentifier: "newsData")!
        
        for view in cell.contentView.subviews {
            view.removeFromSuperview()
        }
        
        cell.textLabel?.text = news[indexPath.row]["tag"]
        cell.detailTextLabel?.text = news[indexPath.row]["title"]
        
        cell.accessoryType = UITableViewCell.AccessoryType.detailButton
        
        return cell
    }
}

extension MainViewController : UITableViewDelegate {
    func makeUpOpenAiInformation(jsonData: Data) -> String{
        let jsonObjct = try! JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
        return String(data:jsonData, encoding: .utf8)!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // API 요청 데이터 생성
        let key = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as! String
        let org = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_ORG") as! String
        let prompt = news[indexPath.row]["body"]!
        
        let requestData: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": self.systemInstruction],
                ["role": "user", "content": prompt],
            ],
            "max_tokens": prompt.count / 2,
            "temperature": 0.3,
            // 추가적인 옵션 및 매개변수 설정 가능
        ]
        var request = URLRequest(url: URL(string: openAiSite)!)
        request.httpMethod = "POST" // POST 방식지정
        request.addValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.addValue(org, forHTTPHeaderField: "OpenAI-Organization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 전달하고자 하는 데이터를 POST 방식에 맞도록 설정
        request.httpBody = try! JSONSerialization.data(withJSONObject: requestData, options: .prettyPrinted)
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            guard let jsonData = data else{ print(error!); return }
            if let jsonStr = String(data:jsonData, encoding: .utf8){
                print("post=====>", jsonStr)
            }
            let infoStr = self.makeUpOpenAiInformation(jsonData: jsonData)
            DispatchQueue.main.async {
                self.newsSummary.text = infoStr
            }
        }
        dataTask.resume()
    }
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        <#code#>
    }
}
