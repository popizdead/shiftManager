//
//  NetworkModel.swift
//  ShiftManager
//
//  Created by Даниил Дорожкин on 01/02/2021.
//

import Foundation
import FirebaseDatabase

//Call source from firebase
func callSourceApi() {
    sourceSnapshot.removeAll()
    let ref = Database.database().reference().child("\(pathFirebaseRoot)").child("Years")
    ref.observeSingleEvent(of: .value) { (snapshot) in
        if let source = snapshot.value as? [String:Any] {
            sourceSnapshot = source
        }
        sourceSetted = true
    }
}

//Update day in Firebase
func updatingDayInFirebase(day: Day) {
    let writingDay = calculatingDay(day: day)
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let dayDate = formatter.date(from: writingDay.dateString)!
    
    showingDay = writingDay
    
    if writingDay.shiftArray.count != 0 {
        let dayDictionary : [String:Any] = [
            "earning" : writingDay.earning,
            "fullDate" : writingDay.dateString,
            "hoursOfWork" : writingDay.hoursOfWork
        ]
        
        Database.database().reference().child("\(pathFirebaseRoot)/Years/\(dayDate.year)/\(dayDate.month)/\(dayDate.week)/\(writingDay.dateString)").setValue(dayDictionary)
        
        for shiftElement in writingDay.shiftArray {
            Database.database().reference().child("\(pathFirebaseRoot)/Years/\(dayDate.year)/\(dayDate.month)/\(dayDate.week)/\(writingDay.dateString)").child("shiftArray").childByAutoId().setValue(convertShiftToDict(shift: shiftElement))
        }
    } else {
        Database.database().reference().child("\(pathFirebaseRoot)").child("Years").child(dayDate.year).child(dayDate.month).child(dayDate.week).child(day.dateString).removeValue { (error, ref) in }
    }
   
    
    needSourceUpdate = true
}

//Setting day from dictionary
func setDay(dict: [String:Any]) -> Day {
    var preparDay = Day()
    
    preparDay.earning = dict["earning"] as! Double
    preparDay.dateString = dict["fullDate"] as! String
    preparDay.dayString = getDayOfWeek(dateString: preparDay.dateString)
    
    preparDay.hoursOfWork = dict["hoursOfWork"] as! Double
    
    if let shiftDict = dict["shiftArray"] as? [String:Any] {
        for shiftElement in shiftDict {
            preparDay.shiftArray.append(setShift(dict: shiftElement.value as! [String:Any]))
        }
    } else {
        
    }
    
    return preparDay
}

//Setting shift from dictionary
func setShift(dict: [String:Any]) -> Shift {
    var preparShift = Shift()
    
    preparShift.earning = dict["earning"] as! Double
    preparShift.time = dict["time"] as! String
    preparShift.hours = dict["hours"] as! Double
    
    return preparShift
}

//Setting week array
func mainViewApi(toDate: Date) {
    sourceWeekDaysArray.removeAll()
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd"
    for yearElem in sourceSnapshot {
        if yearElem.key == toDate.year {
            if let yearDict = yearElem.value as? [String:Any] {
                for monthElem in yearDict {
                    if monthElem.key == toDate.month {
                        //Dictionary in response from firebase
                        if let monthValue = monthElem.value as? [String:Any] {
                            for dictElem in monthValue {
                                if let preparDict = dictElem.value as? [String:Any] {
                                    for dayElem in preparDict {
                                        if let dayDate = df.date(from: dayElem.key) {
                                            if dayDate.week == toDate.week {
                                                let day = setDay(dict: dayElem.value as! [String : Any])
                                                sourceWeekDaysArray.append(day)
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            //MARK:FIXME
                            //Array in response from firebase
                            if let monthValue = monthElem.value as? [Any] {
                                for weekElem in monthValue {
                                    if let weekDict = weekElem as? [String:Any] {
                                        for dayElem in weekDict {
                                            if let dayDate = df.date(from: dayElem.key) {
                                                if dayDate.week == toDate.week {
                                                    let day = setDay(dict: dayElem.value as! [String : Any])
                                                    sourceWeekDaysArray.append(day)
                                                }
                                            }
                                        }
                                    }
                                    
                                }
                            }
                        }
                        sourceWeekDaysArray = sourceWeekDaysArray.sorted {df.date(from: $0.dateString)! < df.date(from: $1.dateString)!}
                        sourceSetted = true
                    }
                }
            }
        }
    }
}
