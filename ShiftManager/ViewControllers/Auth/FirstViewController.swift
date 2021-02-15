//
//  FirstViewController.swift
//  ShiftManager
//
//  Created by Даниил Дорожкин on 01/12/2020.
//

import UIKit
import FirebaseAuth

class FirstViewController: UIViewController {
    
    //MARK:OUTLETS
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var jobField: UITextField!
    @IBOutlet weak var currencyField: UITextField!
    @IBOutlet weak var salaryField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tap)
        pathFirebaseRoot = "Users/\(Auth.auth().currentUser!.uid)"
        designSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        pathFirebaseRoot = "Users/\(Auth.auth().currentUser!.uid)"
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    func designSetup() {
        bgView.makeShadowAndRadius(opacity: 0.5, radius: 15)
        nextButton.layer.cornerRadius = 15
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        if let jobString = jobField.text {
            if let currencyString = currencyField.text {
                if let salaryString = salaryField.text {
                    if let salaryInt = Int(salaryString) {
                        currentUser.currency = currencyString
                        currentUser.jobName = jobString
                        currentUser.salary = salaryInt
                        currentUser.currency = currencyString
                        currentUser.updateUserInFirebase()
                        self.performSegue(withIdentifier: "toMain", sender: self)
                    }
                }
            }
        }
    }
}
