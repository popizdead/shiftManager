//
//  EditingViewController.swift
//  ShiftManager
//
//  Created by Даниил Дорожкин on 03/12/2020.
//

import UIKit
import SwiftEntryKit

class EditingViewController: UIViewController {
    
    //MARK:OUTLETS
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    //MARK:VIEW LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        setPickers()
        
        //To write values
        pickerChanged(startTimePicker)
        pickerChanged(endTimePicker)
    }
    
    //MARK:PICKERS
    func setPickers() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        formatter.dateFormat = "yyyy-MM-dd"
        let dayDate = formatter.date(from: showingDay.dateString)
        startTimePicker.date = dayDate!
        endTimePicker.date = dayDate!
        
        startTimePicker.date = dateFormatter.date(from: editingHoursString.components(separatedBy: "-")[0])!
        endTimePicker.date = dateFormatter.date(from: editingHoursString.components(separatedBy: "-")[1])!
    }
    
    //Peparing values to calculate
    @IBAction func pickerChanged(_ sender: UIDatePicker) {
        if sender == startTimePicker {
            startEditingDate = startTimePicker.date
        } else {
            endEditingDate = endTimePicker.date
        }
    }
    
    //MARK:BUTTONS
    @IBAction func editButtonTapped(_ sender: UIButton) {
        updatingShift(fromHours: editingHoursString, delete: false)
        SwiftEntryKit.dismiss()
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        updatingShift(fromHours: editingHoursString, delete: true)
        SwiftEntryKit.dismiss()
    }
    
}
