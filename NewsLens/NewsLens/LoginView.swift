//
//  ViewController.swift
//  NewsLens
//
//  Created by 허진우 on 6/14/24.
//

import UIKit
import FirebaseAuth
import FirebaseCore

import FirebaseFirestore

class LoginView: UIViewController {
    @IBOutlet weak var emailTf: UITextField!
    @IBOutlet weak var passwordTf: UITextField!
    @IBOutlet weak var credentialEventlabel: UILabel!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var joinBtn: UIButton!
    
    var auth : AuthDataResult?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func doLogin(_ sender: UIButton) {
        print("로그인 버튼 클릭")
//        performSegue(withIdentifier: "mainview", sender: self)
        
        // todo : 나중에 여기 주석 풀어야 함
        if checkAccountValid() {
            guard let email = emailTf.text else { return }
            guard let password = passwordTf.text else { return }
            
            Auth.auth().signIn(withEmail: email, password: password) { [self] authResult, error in
                if let error = error {
                    setCredentialInfo(text: "로그인에 실패했습니다.", color: .red)
                    print(error)
                }
                if let authResult = authResult {
                    setCredentialInfo(text: "로그인에 성공했습니다.", color: .blue)
                    auth = authResult
                    // 메인 화면으로 이동
                     performSegue(withIdentifier: "mainview", sender: self)
                }
            }
        }
        else {
            setCredentialInfo(text: "이메일 또는 비밀번호를 확인해주세요.", color: .red)
        }
    }
    
    @IBAction func doJoin(_ sender: UIButton) {
        print("회원가입 버튼 클릭")
        
        if checkAccountValid() {
            guard let email = emailTf.text else { return }
            guard let password = passwordTf.text else { return }
            
            Auth.auth().createUser(withEmail: email, password: password) {result,error in
                if let error = error {
                    self.setCredentialInfo(text: "회원가입에 실패했습니다.", color: .red)
                    print(error)
                }
                if let result = result {
                    self.setCredentialInfo(text: "회원가입에 성공했습니다.", color: .blue)
                }
            }
        }
        else {
            setCredentialInfo(text: "이메일 또는 비밀번호를 확인해주세요.", color: .red)
        }
    }
    
    
    func isValid(text: String, pattern: String) -> Bool {
        // text가 정규식 pattern에 match되는지 확인한다.
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: text)
    }
    
    let emailPattern = "^[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*\\.[a-zA-Z]{2,3}$"
    let passwordPattern = "^.*(?=^.{8,16}$)(?=.*\\d)(?=.*[a-zA-Z])(?=.*[!@#$%^&+=]).*$"
    
    func checkAccountValid() -> Bool{
        guard let email = emailTf.text else { return false }
        guard let password = passwordTf.text else { return false }
        
        let emailValid = isValid(text: email, pattern: emailPattern)
        let passwordValid = isValid(text: password, pattern: passwordPattern)
        let res : Bool
        
        print("email    : \(emailTf.text!) -> \(emailValid)")
        print("password : \(passwordTf.text!) -> \(passwordValid)")
        
        if emailValid && passwordValid {
            print("email, password Valid Success")
            res = true
        } else {
            print("email, password Valid Fail")
            res = false
        }
        
        return res
    }
    
    func setCredentialInfo(text : String, color : UIColor) {
        self.credentialEventlabel.text = text
        self.credentialEventlabel.textColor = color
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("세그웨이 \(segue.identifier)")
        
        guard let dest = segue.destination as? MainViewController else {return}
        
        print("이동 타겟 잡음")
        dest.auth = auth
    }
}
