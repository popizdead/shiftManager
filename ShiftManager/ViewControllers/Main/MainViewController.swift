//
//  MainViewController.swift
//  ShiftManager
//
//  Created by Даниил Дорожкин on 15/11/2020.
//

import UIKit
import SwiftEntryKit

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //MARK: OUTLETS
    //Today view labels
    @IBOutlet weak var dayNameLbl: UILabel!
    @IBOutlet weak var dayEarningLbl: UILabel!
    @IBOutlet weak var hoursOfWorkLbl: UILabel!
    
    @IBOutlet weak var shiftPatternButton: UIButton!
    
    //Statistic view labels
    @IBOutlet weak var totalWeekHour: UILabel!
    @IBOutlet weak var totalWeekEarning: UILabel!
    
    //Bg views
    @IBOutlet weak var todayBgView: UIView!
    @IBOutlet weak var hoursBgView: UIView!
    @IBOutlet weak var totalBgView: UIView!
    @IBOutlet weak var weekDescrView: UIView!
    
    //Collection views
    @IBOutlet weak var shiftsCollectionView: UICollectionView!
    @IBOutlet weak var daysCollectionView: UICollectionView!
    
    //Pickers
    @IBOutlet weak var showingDayPicker: UIDatePicker!
    @IBOutlet weak var nextDayButton: UIButton!
    @IBOutlet weak var prevDayButton: UIButton!
    
    //Current week dates
    @IBOutlet weak var minPicker: UIDatePicker!
    @IBOutlet weak var maxPicker: UIDatePicker!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var updTimer = Timer()
    
    //MARK: VIEW LOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Source download
        callSourceApi()
        currentUser.getUserInfo()
        
        delegates()
        designSetup()
        
        updTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        showingDayPicker.date = date
        
        isFirstDownload = true
    }
    
    @objc func update() {
        if sourceSetted {
            mainViewApi(toDate: showingDayPicker.date)
            if isFirstDownload {
                checkForTodayShift()
                isFirstDownload = false
            }
            designUpdate()
            sourceSetted = false
        }
        
        if needSourceUpdate {
            callSourceApi()
            needSourceUpdate = false
        }
    }
    
    //Setting delegates
    func delegates() {
        shiftsCollectionView.dataSource = self
        shiftsCollectionView.delegate = self
        
        daysCollectionView.dataSource = self
        daysCollectionView.delegate = self
    }
    
    //MARK: DESIGN
    func designSetup() {
        hiddingAllLabels(hidding: true)
        let viewsArray = [todayBgView, hoursBgView, totalBgView, weekDescrView]
        
        for viewElem in viewsArray {
            viewElem!.makeShadowAndRadius(opacity: 0.5, radius: 8)
        }
        
        shiftPatternButton.layer.cornerRadius = 8
        
        minPicker.isUserInteractionEnabled = false
        maxPicker.isUserInteractionEnabled = false
    }
    
    func designUpdate() {
        updateShowingDay()
        collectionUpdate()
        hiddingAllLabels(hidding: false)
    }
    
    //Update week labels
    func weekUpdate() {
        calculateTotalWeek()
        totalWeekLabelsUpdate()
    }
    
    func collectionUpdate() {
        shiftsCollectionView.reloadData()
        daysCollectionView.reloadData()
    }
    
    //MARK:LABELS UPDATE
    func totalWeekLabelsUpdate() {
        totalWeekHour.text = "Week hours: \(String(format: "%.1f", hoursTotalWeek))h"
        totalWeekEarning.text = "Week earning: \(String(format: "%.2f", earningTotalWeek))\(currentUser.currency)"
    }
    
    //Update showing day labels
    func updateShowingDay() {
        formatter.dateFormat = "yyyy-MM-dd"
        if let preparDate = formatter.date(from: showingDay.dateString) {
            showingDayPicker.date = preparDate
        }
        
        self.dayEarningLbl.text = "Earning: \(showingDay.earning)\(currentUser.currency)"
        self.dayNameLbl.text = getDayOfWeek(dateString: formatter.string(from: showingDayPicker.date))
        self.hoursOfWorkLbl.text = "Hours of work: \(showingDay.hoursOfWork)h"
        
        let currentDays = setWeekDesription(weekArray: sourceWeekDaysArray)
        
        if currentDays.count != 0 {
            minPicker.date = currentDays.first!
            maxPicker.date = currentDays.last!
        }
        
        weekUpdate()
    }
    
    //LOADING INDICATORS
    func hiddingAllLabels(hidding: Bool) {
        let allLabelsArray = [ dayNameLbl, dayEarningLbl, hoursOfWorkLbl, totalWeekEarning, totalWeekHour]
        let allViewsArray = [shiftsCollectionView, todayBgView, hoursBgView, totalBgView, weekDescrView, showingDayPicker, daysCollectionView]
        
        for lblElem in allLabelsArray {
            lblElem?.isHidden = hidding
        }
        for viewElem in allViewsArray {
            viewElem?.isHidden = hidding
        }
        
        loadingIndicator.startAnimating()
        loadingIndicator.isHidden = !hidding
    }
    
    //MARK: PICKER
    @IBAction func showingDayPickerChanged(_ sender: UIDatePicker) {
        let showingDate = showingDayPicker.date
        showingDay.dateString = formatter.string(from: showingDate)
        mainViewApi(toDate: showingDate)
        showingDay = findDayInSource(dateOfDay: showingDate)
        designUpdate()
        self.dismiss(animated: true, completion: nil)
    }
    
    //Calling pattern view
    @IBAction func patternButtonTapped(_ sender: UIButton) {
        SwiftEntryKit.display(entry: storyboard!.instantiateViewController(withIdentifier:"patternsView"), using: setupAttributes(type: .pattern))
    }
    
    //Today and tomorrow buttons action
    @IBAction func pickersButtonTapped(_ sender: UIButton) {
        var preparingDate = Date()
        let midnight = calendar.startOfDay(for: showingDayPicker.date)
        if sender == nextDayButton {
            //Tommorow
            preparingDate = calendar.date(byAdding: .day, value: 1, to: midnight)!
        } else {
            //Yesterday
            preparingDate = calendar.date(byAdding: .day, value: -1, to: midnight)!
        }
        
        mainViewApi(toDate: preparingDate)
        showingDay = findDayInSource(dateOfDay: preparingDate)
        
        designUpdate()
        
    }
    
    
    //MARK: COLLECTION VIEW
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == shiftsCollectionView {
            //Shifts
            if showingDay.shiftArray.count != 0 {
                return showingDay.shiftArray.count + 1
            } else {
                return 1
            }
        } else {
            //Days
            if sourceWeekDaysArray.count != 0 {
                return sourceWeekDaysArray.count
            } else {
                return 1
            }
        }
    }
    
    //MARK: CELL FOR ITEM
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == shiftsCollectionView {
            //Shifts
            if indexPath.row <= showingDay.shiftArray.count - 1 {
                //Shift cell
                let cell = shiftsCollectionView.dequeueReusableCell(withReuseIdentifier: "shiftCell", for: indexPath) as! ShiftCollectionViewCell
                
                cell.cellShift = showingDay.shiftArray[indexPath.row]
                cell.earningLbl.text = "\(cell.cellShift.earning)\(currentUser.currency)"
                cell.timeLbl.text = cell.cellShift.time
        
                cell.makeShadowAndRadius(opacity: 0.5, radius: 8)
                cell.bgView.layer.cornerRadius = 8
                
                return cell
            } else {
                //Adding shift cell
                let cell = shiftsCollectionView.dequeueReusableCell(withReuseIdentifier: "addCell", for: indexPath) as! AddShiftCollectionViewCell
                
                cell.makeShadowAndRadius(opacity: 0.5, radius: 8)
                cell.bgView.layer.cornerRadius = 8
                
                return cell
            }
        } else {
            //Days
            let cell = daysCollectionView.dequeueReusableCell(withReuseIdentifier: "DayCell", for: indexPath) as! DayCollectionViewCell
        
            if sourceWeekDaysArray.count == 0 {
                cell.configurateLabels(fromDay: nil, noData: true)
                cell.designSetup(picked: true)
            } else {
                let dayCell = sourceWeekDaysArray[indexPath.row]
                cell.configurateLabels(fromDay: dayCell, noData: false)
                if dayCell.dateString == showingDay.dateString {
                    cell.designSetup(picked: true)
                    daysCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                } else {
                    cell.designSetup(picked: false)
                }
            }
            
            return cell
        }
    }
    
    //MARK: DID SELECT
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //Setting current day
        formatter.dateFormat = "yyyy-MM-dd"
        showingDay.dateString = formatter.string(from: showingDayPicker.date)
        
        if collectionView == shiftsCollectionView {
            //Shifts collection
            if indexPath.row <= showingDay.shiftArray.count - 1 {
                //Editing shift
                editCalledFromPattern = false
                editingHoursString = showingDay.shiftArray[indexPath.row].time
                SwiftEntryKit.display(entry: storyboard.instantiateViewController(withIdentifier:"editView"), using: setupAttributes(type: .editing))
                
            } else {
                //Adding shift
                addCalledFromPattern = false
                SwiftEntryKit.display(entry: storyboard.instantiateViewController(withIdentifier:"addView"), using: setupAttributes(type: .editing))
                
            }
        } else {
            //Days collection
            if sourceWeekDaysArray.count != 0 {
                showingDay = sourceWeekDaysArray[indexPath.row]
                designUpdate()
            }
        }
    }
    
    //MARK:SEGUES ATTRIBUTES
    enum editingType {
        case editing
        case pattern
    }
    
    func setupAttributes(type: editingType) -> EKAttributes {
        var attributes = EKAttributes.centerFloat
        
        if type == editingType.editing {
            let widthConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 0.9)
            let heightConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 0.5)
            
            attributes.positionConstraints.size = .init(width: widthConstraint, height: heightConstraint)
        }
        
        if type == editingType.pattern {
            let widthConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 0.8)
            let heightConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 0.2)
            
            attributes.positionConstraints.size = .init(width: widthConstraint, height: heightConstraint)
        }
        
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 10, offset: .zero))
        attributes.roundCorners = .all(radius: 15)
        
        

        // Set its background to white
        attributes.entryBackground = .color(color: .clear)
        attributes.screenBackground = .color(color: EKColor(UIColor(white: 0, alpha: 0.5)))

        // Animate in and out using default translation
        attributes.entranceAnimation = .translation
        attributes.exitAnimation = .translation
        
        attributes.displayDuration = .infinity
        attributes.entryInteraction = .forward
        
        attributes.screenInteraction = .dismiss
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        
        return attributes
    }

}
 

