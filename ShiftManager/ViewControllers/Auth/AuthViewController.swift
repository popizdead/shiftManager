//
//  AuthViewController.swift
//  ShiftManager
//
//  Created by Даниил Дорожкин on 28/11/2020.
//

import UIKit
import FirebaseAuth

class AuthViewController: UIViewController {
    
    var isLoginState = true
    
    //MARK: OUTLETS
    //Bg views
    @IBOutlet weak var bgAuthView: UIView!
    @IBOutlet weak var buttonsBgView: UIView!
    
    //Fields
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var conPassField: UITextField!
    @IBOutlet weak var conPassLbl: UILabel!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    //MARK:VIEW LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        designSetup()
        tapHiddingSet()
        navButtonTapped(loginButton)
    }
    
    //Hidding tap recognizer
    func tapHiddingSet() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: DESIGN
    func designSetup() {
        let viewsArray = [bgAuthView, buttonsBgView]
        
        for viewElem in viewsArray {
            viewElem?.makeShadowAndRadius(opacity: 0.5, radius: 8)
        }
        
        submitButton.layer.cornerRadius = 15
        designUpdate()
    }
    
    func designUpdate() {
        var choosenBut = UIButton()
        let hiddinArray = [conPassLbl, conPassField]
        
        if isLoginState {
            choosenBut = loginButton
        } else {
            choosenBut = signUpButton
        }
        
        let buttonsArray = [loginButton, signUpButton]
        for butElem in buttonsArray {
            if butElem == choosenBut {
                butElem?.setTitleColor(UIColor(red: 0/255, green: 101/255, blue: 224/255, alpha: 1), for: .normal)
            } else {
                butElem?.setTitleColor(.darkGray, for: .normal)
            }
        }
        
        for hideElem in hiddinArray {
            hideElem?.animateHidding(hidding: isLoginState)
        }
    }
    
    //MARK: BUTTONS
    @IBAction func navButtonTapped(_ sender: UIButton) {
        isLoginState = sender == loginButton
        if isLoginState {
            submitButton.setTitle("Login", for: .normal)
        } else {
            submitButton.setTitle("Sign Up", for: .normal)
        }
        designUpdate()
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        if isLoginState {
            if let mail = emailField.text {
                if let pass = passField.text {
                    loginToUser(mail: mail, pass: pass)
                }
            }
        } else {
            if passField.text == conPassField.text {
                if let mail = emailField.text {
                    if let pass = passField.text {
                        createUser(mail: mail, pass: pass)
                    }
                }
            }
        }
    }
    
    //MARK:USER ACTIONS
    func createUser(mail: String, pass: String){
        Auth.auth().createUser(withEmail: mail, password: pass) { (res, error) in
            if error == nil {
                pathFirebaseRoot = "Users/\(Auth.auth().currentUser!.uid)"
                self.performSegue(withIdentifier: "toFirst", sender: self)
            }
        }
    }

    func loginToUser(mail: String, pass: String) {
        Auth.auth().signIn(withEmail: mail, password: pass) {authResult, error in
            if error == nil {
                pathFirebaseRoot = "Users/\(Auth.auth().currentUser!.uid)"
                self.performSegue(withIdentifier: "toMain", sender: self)
            }
        }
    }
    
}
