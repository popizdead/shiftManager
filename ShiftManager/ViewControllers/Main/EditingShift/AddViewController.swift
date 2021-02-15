//
//  AddViewController.swift
//  ShiftManager
//
//  Created by Даниил Дорожкин on 03/12/2020.
//

import UIKit
import SwiftEntryKit

class AddViewController: UIViewController {

    @IBOutlet weak var startTime: UIDatePicker!
    @IBOutlet weak var endTime: UIDatePicker!
    
    @IBOutlet weak var addButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addButton.layer.cornerRadius = 15
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        addShift(startTimeOf: startTime.date, endTimeOf: endTime.date)
        self.dismiss(animated: true, completion: nil)
        SwiftEntryKit.dismiss()
    }
}
