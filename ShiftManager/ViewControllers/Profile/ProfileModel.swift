//
//  ProfileModel.swift
//  ShiftManager
//
//  Created by Даниил Дорожкин on 29/11/2020.
//

import Foundation
import Firebase

var needUserUpdate = false
var currentUser = User()

struct User {
    var jobName = String()
    var currency = String()
    var salary = Int()
    var shiftsPattern : [Shift] = []
    
    func getUserInfo() {
        if pathFirebaseRoot != "" {
            let ref = Database.database().reference().child(pathFirebaseRoot).child("userInfo")
            ref.observeSingleEvent(of: .value) { (snapshot) in
            if let sourceDict = snapshot.value as? [String:Any] {
                currentUser.currency = sourceDict["currency"] as! String
                currentUser.jobName = sourceDict["nameOfJob"] as! String
                currentUser.salary = Int(truncating: sourceDict["salary"] as! NSNumber)
                currentUser.shiftsPattern.removeAll()
                if let shiftsDict = sourceDict["shiftPatterns"] as? [String:Any] {
                    for shiftElem in shiftsDict {
                        if let shift = shiftElem.value as? [String:Any] {
                            currentUser.shiftsPattern.append(setShift(dict: shift))
                        }
                    }
                }
                needUserUpdate = true
            }
            }
        }
    }
    
    func updateUserInFirebase() {
        let ref = Database.database().reference().child(pathFirebaseRoot).child("userInfo")
        let userDictionary : [String:Any] = [
            "currency" : currentUser.currency,
            "nameOfJob" : currentUser.jobName,
            "salary" : currentUser.salary
        ]
        ref.child("shiftPatterns").removeValue()
        ref.updateChildValues(userDictionary)
        for shift in currentUser.shiftsPattern {
            let shiftDict = convertShiftToDict(shift: shift)
            ref.child("shiftPatterns").childByAutoId().setValue(shiftDict)
        }
        needUserUpdate = true
    }
}




