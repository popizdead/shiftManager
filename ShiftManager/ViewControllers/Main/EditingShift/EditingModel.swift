//
//  EditingModel.swift
//  ShiftManager
//
//  Created by Даниил Дорожкин on 03/12/2020.
//

import Foundation
import Firebase

//New hours of shift
var startEditingDate = Date()
var endEditingDate = Date()

//Editing shift hours
var editingHoursString = String()

//Updating source
func updatingShift(fromHours: String, delete: Bool) {
    if editCalledFromPattern {
        //Pattern shift edit
        for shiftElem in currentUser.shiftsPattern {
            if shiftElem.time == fromHours {
                currentUser.shiftsPattern = currentUser.shiftsPattern.filter { $0.time != shiftElem.time }
                if !delete {
                    let preparingShift = getShift(startTime: startEditingDate, endTime: endEditingDate)
                    currentUser.shiftsPattern.append(preparingShift)
                }
                currentUser.updateUserInFirebase()
            }
        }
    } else {
        //Day shift edit
        for shiftElem in showingDay.shiftArray {
            if shiftElem.time == fromHours {
                showingDay.shiftArray = showingDay.shiftArray.filter { $0.time != shiftElem.time }
                if !delete {
                    let preparingShift = getShift(startTime: startEditingDate, endTime: endEditingDate)
                    showingDay.shiftArray.append(preparingShift)
                }
                updatingDayInFirebase(day: showingDay)
            }
        }
    }
}

//Setting dictionary from shift
func convertShiftToDict(shift: Shift) -> [String:Any] {
    let preparingDict : [String:Any] = [
        "earning" : shift.earning,
        "hours" : shift.hours,
        "time" : shift.time
    ]
    return preparingDict
}

//Add shift to day or pattern
func addShift(startTimeOf: Date, endTimeOf: Date) {
    let preparShift = getShift(startTime: startTimeOf, endTime: endTimeOf)
    if addCalledFromPattern {
        //Adding to pattern
        currentUser.shiftsPattern.append(preparShift)
        needUserUpdate = true
        currentUser.updateUserInFirebase()
    } else {
        //Adding to day
        showingDay.shiftArray.append(preparShift)
        updatingDayInFirebase(day: showingDay)
    }
}

//Calculating shift from dates
func getShift(startTime: Date, endTime: Date) -> Shift {
    var shift = Shift()
    var diffComponents = Calendar.current.dateComponents([.minute], from: startTime, to: endTime)
    if endTime < startTime {
        //Shift end in next day
        let newEndDate = Calendar.current.date(byAdding: .day, value: 1, to: endTime)
        diffComponents = Calendar.current.dateComponents([.minute], from: startTime, to: newEndDate!)
    }
    let minutesDiffirent = diffComponents.minute

    let salaryPerMinute : Double = Double(currentUser.salary) / Double(60)
    let earningValue = Double(minutesDiffirent!) * salaryPerMinute
    let earning = Double(String(format: "%.2f", earningValue))!
    let time = "\(timesPickerConverter(date: startTime))-\(timesPickerConverter(date: endTime))"
    let hours = Double(String(format: "%.1f", Double(minutesDiffirent! / 60)))!
    
    shift.earning = Double(earning)
    shift.hours = hours
    shift.time = time
    
    return shift
}

//Calculating day
func calculatingDay(day: Day) -> Day {
    var preparDay = day
    
    var moneyCounter : Double = 0
    var hourCounter : Double = 0
    
    for shift in day.shiftArray {
        moneyCounter += shift.earning
        hourCounter += shift.hours
    }   
    
    preparDay.earning = Double(String(format: "%.2f", moneyCounter))!
    preparDay.hoursOfWork = Double(String(format: "%.1f", Double(hourCounter)))!
    
    return preparDay
}
