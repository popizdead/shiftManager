//
//  DayCollectionViewCell.swift
//  ShiftManager
//
//  Created by Даниил Дорожкин on 05/12/2020.
//

import UIKit

class DayCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dayNameLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var shiftsLbl: UILabel!
    @IBOutlet weak var earningLbl: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var warningLbl: UILabel!
    
    func designSetup(picked: Bool) {
        let lblsArray = [self.dayNameLbl, self.dateLbl, self.earningLbl, self.shiftsLbl, self.warningLbl]
        
        self.makeShadowAndRadius(opacity: 0.5, radius: 8)
        self.bgView.layer.cornerRadius = 8
        
        if picked {
            //Picked cell
            self.shadowView.backgroundColor = UIColor(red: 0/255, green: 101/255, blue: 224/255, alpha: 1)
            for lbl in lblsArray {
                lbl?.textColor = UIColor.white
            }
        } else {
            //Normal cell
            self.shadowView.backgroundColor = UIColor.white
            for lbl in lblsArray {
                lbl?.textColor = UIColor(red: 0/255, green: 101/255, blue: 224/255, alpha: 1)
            }
        }
    }
    
    func configurateLabels(fromDay: Day?, noData: Bool) {
        let lblsArray = [self.dayNameLbl, self.dateLbl, self.earningLbl, self.shiftsLbl]
        if noData {
            //No days in week
            self.warningLbl.isHidden = false
            for lbl in lblsArray {
                lbl?.isHidden = true
            }
        } else {
            //Configurating day
            self.warningLbl.isHidden = true
            for lbl in lblsArray {
                lbl?.isHidden = false
            }
            
            self.warningLbl.isHidden = true
            self.dayNameLbl.text = fromDay!.dayString
            self.dateLbl.text = setDateFormat(fromString: fromDay!.dateString)
            self.earningLbl.text = "Earning: \(fromDay!.earning)\(currentUser.currency)"
            self.shiftsLbl.text = "Shifts: \(fromDay!.shiftArray.count)"
        }
    }
}
