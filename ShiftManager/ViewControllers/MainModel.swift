//
//  MainModel.swift
//  ShiftManager
//
//  Created by Даниил Дорожкин on 01/12/2020.
//

import Foundation
import Firebase
import UIKit

//MARK: EXTENSIONS

//View extensions
extension UIView {
    func makeShadowAndRadius(opacity: Float, radius: Float) {
        self.layer.cornerRadius = CGFloat(radius)
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = CGFloat(radius)
        self.layer.masksToBounds = false
    }
    
    func animateHidding(hidding: Bool) {
        UIView.animate(withDuration: 0.1, delay: 0, options: [], animations: {
            if hidding {
                self.alpha = 0
            } else {
                self.alpha = 1
            }
        }, completion: { _ in
            self.isHidden = hidding
        })
    }
}

//Dates extension
extension Date {
    var month: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        return dateFormatter.string(from: self)
    }
    var week: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "w"
        return dateFormatter.string(from: self)
    }
    var day: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: self)
    }
    var year: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: self)
    }
}

extension Calendar {
    static let iso8601 = Calendar(identifier: .iso8601)
    static let gregorian = Calendar(identifier: .gregorian)
}

extension Date {
    func byAdding(component: Calendar.Component, value: Int, wrappingComponents: Bool = false, using calendar: Calendar = .current) -> Date? {
        calendar.date(byAdding: component, value: value, to: self, wrappingComponents: wrappingComponents)
    }
    
    func dateComponents(_ components: Set<Calendar.Component>, using calendar: Calendar = .current) -> DateComponents {
        calendar.dateComponents(components, from: self)
    }
    
    func startOfWeek(using calendar: Calendar = .current) -> Date {
        calendar.date(from: dateComponents([.yearForWeekOfYear, .weekOfYear], using: calendar))!
    }
    
    var noon: Date {
        Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    
    func daysOfWeek(using calendar: Calendar = .current) -> [Date] {
        let startOfWeek = self.startOfWeek(using: calendar).noon
        return (0...6).map { startOfWeek.byAdding(component: .day, value: $0, using: calendar)! }
    }
    
    var startOfMonth: Date {
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents([.year, .month], from: self)

            return  calendar.date(from: components)!
    }
    
    var endOfMonth: Date {
            var components = DateComponents()
            components.month = 1
            components.second = -1
            return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth)!
    }
}

func getDayOfWeek(dateString: String) -> String {
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayDate = formatter.date(from: dateString)
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate!)
        let dayObj = String(formatter.weekdaySymbols[weekDay - 1])
        return dayObj
}


//Convert from date to "HH:MM" format string
func timesPickerConverter(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    return dateFormatter.string(from: date)
}

func setDateFormat(fromString: String) -> String {
    if fromString != "" {
        formatter.dateFormat = "yyyy/MM/dd"
        let preparDate = formatter.date(from: fromString)!
    
        let dayElem = preparDate.day
        let monthElem = preparDate.month
        
        return "\(dayElem)/\(monthElem)"
    } else {
        return ""
    }
}

var pathFirebaseRoot = String()
var didSignOut = false


