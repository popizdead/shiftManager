//
//  StatisticModel.swift
//  ShiftManager
//
//  Created by Даниил Дорожкин on 16/11/2020.
//

import Foundation
import Firebase
import Charts

//MARK: VARIABLES
var totalEarning = Double()
var totalHoursOfWork = Double()
var averageHours = Double()
var averageEarningPerDay = Double()

var statisticSourceArray : [Day] = []
var graphErrorMessage = String()

let formatter = DateFormatter()
let calendar = Calendar.current
let date = Date()

struct staticsticCollectionItem {
    var name = String()
    var value = String()
}

var statisticCollectionSourceArray : [staticsticCollectionItem] = []
var graphStatisticDaysArray : [Day] = []

//MARK: SETTING ARRAY
func statisticViewApi() {
    statisticSourceArray.removeAll()
    
    for year in sourceSnapshot {
        if let monthsDict = year.value as? [String:Any] {
            for month in monthsDict {
                if let weeksDict = month.value as? [String:Any] {
                    for weekElem in weeksDict {
                        let weekDict = weekElem.value as! [String:Any]
                        for dayElem in weekDict {
                            let day = setDay(dict: dayElem.value as! [String:Any])
                            statisticSourceArray.append(day)
                        }
                    }
                }
            }
        }
    }
}

//MARK:CALCULATING
func calculateCustomStats(from: Date, to: Date) {
    graphStatisticDaysArray.removeAll()
    
    var moneyCounter : Double = 0
    var hourCounter : Double = 0
    var counter : Int = 0
    
    for day in statisticSourceArray {
        let dayDate = formatter.date(from: day.dateString)
        if dayDate! >= from && dayDate! <= to {
            graphStatisticDaysArray.append(day)
            
            moneyCounter += day.earning
            hourCounter += day.hoursOfWork
            counter += 1
        }
        
    }
    
    var averageHoursValue = hourCounter / Double(counter)
    var averageEarningPerDayValue = moneyCounter / Double(counter)
    
    if graphStatisticDaysArray.count == 0 {
        averageHoursValue = 0
        averageEarningPerDayValue = 0
        if from > to {
            graphErrorMessage = "Start date is later than end"
        } else {
            graphErrorMessage = "You haven't work in these days"
        }
    }
    
    var averageHoursItem = staticsticCollectionItem()
    averageHoursItem.name = "Hours per day"
    averageHoursItem.value = String(format: "%.1f", averageHoursValue) + "h"
    
    var earningItem = staticsticCollectionItem()
    earningItem.name = "Earning"
    earningItem.value = String(format: "%.2f", moneyCounter) + currentUser.currency
    
    var averageEarningItem = staticsticCollectionItem()
    averageEarningItem.name = "Earning per day"
    averageEarningItem.value = String(format: "%.1f", averageEarningPerDayValue) + currentUser.currency
    
    var totalHoursItem = staticsticCollectionItem()
    totalHoursItem.name = "Total hours of work"
    totalHoursItem.value = String(format: "%.1f", hourCounter) + "h"
    
    statisticCollectionSourceArray = [earningItem, averageEarningItem, averageHoursItem, totalHoursItem]
}

//MARK:GRAPH DATA
func getGraphDataArray() -> [BarChartDataEntry] {
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd"
    var counter = 0
    
    var dataArray : [BarChartDataEntry] = []
    graphStatisticDaysArray = graphStatisticDaysArray.sorted {df.date(from: $0.dateString)! < df.date(from: $1.dateString)!}
    
    for day in graphStatisticDaysArray {
        let dataElement = BarChartDataEntry(x: Double(counter), y: day.earning)
        dataArray.append(dataElement)
        counter += 1
    }
    
    return dataArray
}

func getGraphDataDescription() -> [String] {
    var dataArray : [String] = []
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd"
    
    let df2 = DateFormatter()
    df2.dateFormat = "dd/MM"
    
    for day in graphStatisticDaysArray {
        let dayDate = df.date(from: day.dateString)!
        let stringDate = df2.string(from: dayDate)
        dataArray.append(stringDate)
    }
    
    return dataArray
}

