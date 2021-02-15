//
//  SecondViewController.swift
//  ShiftManager
//
//  Created by Даниил Дорожкин on 01/12/2020.
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var dayPicker: UIDatePicker!
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    @IBOutlet weak var addButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        designSetup()
    }
    
    func designSetup() {
        bgView.makeShadowAndRadius(opacity: 0.5, radius: 15)
        addButton.layer.cornerRadius = 15
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        let firstShift = getShift(startTime: startTimePicker.date, endTime: endTimePicker.date)
        var firstDay = Day()
        formatter.dateFormat = "yyyy-MM-dd"
        firstDay.dateString = formatter.string(from: dayPicker.date)
        firstDay.shiftArray.append(firstShift)
        firstDay = calculatingDay(day: firstDay)
        updatingDayInFirebase(day: firstDay)
        currentUser.updateUserInFirebase()
        callSourceApi()
        self.performSegue(withIdentifier: "fromSec", sender: self)
    }
}
