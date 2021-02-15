//
//  EditProfileViewController.swift
//  ShiftManager
//
//  Created by Даниил Дорожкин on 18/01/2021.
//

import UIKit
import SwiftEntryKit

class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var jobNameField: UITextField!
    @IBOutlet weak var salaryField: UITextField!
    @IBOutlet weak var currencyField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        currentUser.jobName = jobNameField.text!
        currentUser.currency = currencyField.text!
        currentUser.salary = Int(salaryField.text!)!
        currentUser.updateUserInFirebase()
        needUserUpdate = true
        SwiftEntryKit.dismiss()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.layer.cornerRadius = 15
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fillFields()
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    func fillFields() {
        jobNameField.text = currentUser.jobName
        salaryField.text = String(currentUser.salary)
        currencyField.text = currentUser.currency
    }

}
