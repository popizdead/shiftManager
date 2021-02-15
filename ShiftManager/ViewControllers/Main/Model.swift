//
//  Model.swift
//  ShiftManager
//
//  Created by Даниил Дорожкин on 15/11/2020.
//

import Foundation
import FirebaseDatabase
import Firebase

//MARK: STRUCTURES
struct Shift {
    var time = String()
    var earning = Double()
    var hours = Double()
}

struct Day {
    var shiftArray : [Shift] = []
    var hoursOfWork = Double()
    var earning = Double()
    var dateString = String()
    var dayString = String()
    var week = String()
}

//MARK:VARIABLES
var sourceSetted = false
var needSourceUpdate = false

var addCalledFromPattern = false
var editCalledFromPattern = false

var showingDay = Day()
var sourceWeekDaysArray : [Day] = []

var earningTotalWeek = Double()
var hoursTotalWeek = Double()

var isFirstDownload = false

//MARK:SEARCHING
//Searching for day in source dictionary
func findDayInSource(dateOfDay: Date) -> Day {
    var preparDay = Day()
    formatter.dateFormat = "yyyy-MM-dd"
    
    var finded = false
    
    for dayElem in sourceWeekDaysArray {
        if formatter.date(from: dayElem.dateString) == dateOfDay {
            preparDay = dayElem
            finded = true
        }
    }
    
    if !finded {
        preparDay.dateString = formatter.string(from: dateOfDay)
        preparDay = calculatingDay(day: preparDay)
    }
    
    return preparDay
}

//Checking for today
func checkForTodayShift() {
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let currentDayString = formatter.string(from: date)
    
    var finded = false
    
    for dayElem in sourceWeekDaysArray {
        if dayElem.dateString == currentDayString {
            showingDay = dayElem
            finded = true
        }
    }
    
    if !finded {
        if sourceWeekDaysArray.count != 0 {
            showingDay = sourceWeekDaysArray[0]
        }
    }
    
}

//MARK:CALCULATING
//Finding min and max day in week source array
func setWeekDesription(weekArray: [Day]) -> [Date] {
    formatter.dateFormat = "yyyy-MM-dd"
    var currentDate = Date()
    if let firstDate = weekArray.first {
        currentDate = formatter.date(from: firstDate.dateString)!
    } else {
        if showingDay.dateString != "" {
            currentDate = formatter.date(from: showingDay.dateString)!
        }
    }
    return currentDate.daysOfWeek(using: .gregorian)
}

//Week stat
func calculateTotalWeek() {
    var hoursCounter = 0.0
    var moneyCounter = 0.0
    
    for dayElem in sourceWeekDaysArray {
        hoursCounter += dayElem.hoursOfWork
        moneyCounter += dayElem.earning
    }
    
    earningTotalWeek = moneyCounter
    hoursTotalWeek = hoursCounter
}


