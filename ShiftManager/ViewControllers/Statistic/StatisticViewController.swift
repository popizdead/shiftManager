//
//  StatisticViewController.swift
//  ShiftManager
//
//  Created by Даниил Дорожкин on 16/11/2020.
//

import UIKit
import Charts

class StatisticViewController: UIViewController, ChartViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //MARK: OUTLETS
    @IBOutlet weak var requestBgView: UIView!
    @IBOutlet weak var weekButton: UIButton!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var customButton: UIButton!
    
    @IBOutlet weak var fromField: UIDatePicker!
    @IBOutlet weak var toField: UIDatePicker!
    
    @IBOutlet weak var statGraph: BarChartView!
    @IBOutlet weak var statCollectionView: UICollectionView!
    @IBOutlet weak var warningLbl: UILabel!
    
    
    //MARK:VIEW LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        designSetup()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        statisticViewApi()
        weekButtonTapped(weekButton!)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: DESIGN
    var buttonChoosed = UIButton()
    
    //Setting UI
    func designSetup() {
        let viewsArray : [UIView] = [requestBgView]
        for viewElem in viewsArray {
            viewElem.makeShadowAndRadius(opacity: 0.5, radius: 8)
        }
        
        let buttonArray = [weekButton,customButton,monthButton]
        for viewElem in buttonArray {
            viewElem?.makeShadowAndRadius(opacity: 0.5, radius: 8)
        }
        
        statCollectionView.delegate = self
        statCollectionView.dataSource = self
        
        setGraphDesign()
    }
    
    //Updating UI
    func designUpdate() {
        buttonsDesignUpdate()
        statCollectionView.reloadData()
        updateGraph()
    }
    
    //Updating buttons when tapped
    func buttonsDesignUpdate() {
        let buttonsArray = [weekButton,monthButton,customButton]
        for butElem in buttonsArray {
            if butElem == buttonChoosed {
                butElem?.backgroundColor = UIColor(red: 0/255, green: 101/255, blue: 224/255, alpha: 1)
                butElem?.setTitleColor(.white, for: .normal)
            } else {
                butElem?.backgroundColor = UIColor.white
                butElem?.setTitleColor(UIColor(red: 0/255, green: 101/255, blue: 224/255, alpha: 1), for: .normal)
            }
        }
    }
    
    
    //MARK: COLLECTION VIEW
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return statisticCollectionSourceArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = statCollectionView.dequeueReusableCell(withReuseIdentifier: "statCell", for: indexPath) as! StatCollectionViewCell
        let statItem = statisticCollectionSourceArray[indexPath.row]
        
        cell.nameLbl.text = statItem.name
        cell.valueLbl.text = statItem.value
        
        cell.makeShadowAndRadius(opacity: 0.5, radius: 8)
        cell.contentView.layer.cornerRadius = 15
        
        return cell
    }
    
    
    //MARK: DATE PICKER
    @IBAction func pickersValueChanged(_ sender: UIDatePicker) {
        customButtonTapped(self)
        
        calculateCustomStats(from: fromField.date, to: toField.date)
        
        designUpdate()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: BUTTONS OUTLETS
    //Calculating for week
    @IBAction func weekButtonTapped(_ sender: Any) {
        buttonChoosed = weekButton
        
        let today = Date()
        let weekDatesArray = today.daysOfWeek(using: .gregorian)
        
        if let minimal = weekDatesArray.first {
            fromField.date = minimal
        }
        
        if let maximum = weekDatesArray.last {
            toField.date = maximum
        }

        calculateCustomStats(from: fromField.date, to: toField.date)
        designUpdate()
        
    }
    //Calculating for month
    @IBAction func monthButtonTapped(_ sender: Any) {
        buttonChoosed = monthButton
        
        let today = Date()
        
        fromField.date = today.startOfMonth
        toField.date = today.endOfMonth
        
        calculateCustomStats(from: fromField.date, to: toField.date)
        designUpdate()
    }
    //Custom calculating
    @IBAction func customButtonTapped(_ sender: Any) {
        buttonChoosed = customButton
        designUpdate()
    }
    
    //MARK:GRAPH
    func updateGraph() {
        if graphStatisticDaysArray.count == 0 {
            warningLbl.text = graphErrorMessage
            warningLbl.isHidden = false
        } else { 
            warningLbl.isHidden = true
        }
        let dataSet = BarChartDataSet(entries: getGraphDataArray(), label: "Earning")
        
        dataSet.colors = [UIColor(red: 0/255, green: 101/255, blue: 224/255, alpha: 1)]
        dataSet.stackLabels = getGraphDataDescription()
        dataSet.drawValuesEnabled = true
        dataSet.valueFont = UIFont(name: "AvenirNext-Regular", size: 13.0)!
        dataSet.barShadowColor = UIColor.lightGray
        dataSet.highlightEnabled = false
        
        let data = BarChartData(dataSet: dataSet)
        
        statGraph.data = data
        
        statGraph.xAxis.valueFormatter = IndexAxisValueFormatter(values: getGraphDataDescription())
        statGraph.leftAxis.valueFormatter = YAxisValueFormatter()
    }
    
    func setGraphDesign() {
        statGraph.rightAxis.enabled = false
        statGraph.leftAxis.enabled = true
        
        statGraph.legend.enabled = false
        
        statGraph.xAxis.granularity = 1
        statGraph.xAxis.drawGridLinesEnabled = false
        
        statGraph.leftAxis.drawGridLinesEnabled = false
        
        statGraph.xAxis.labelFont = UIFont(name: "AvenirNext-Regular", size: 13.0)!
        statGraph.leftAxis.labelFont = UIFont(name: "AvenirNext-Regular", size: 13.0)!
    }
}

class YAxisValueFormatter: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return String(Int(value)) + currentUser.currency
    }
}
