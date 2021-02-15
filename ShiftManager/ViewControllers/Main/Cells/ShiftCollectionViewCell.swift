//
//  ShiftCollectionViewCell.swift
//  ShiftManager
//
//  Created by Даниил Дорожкин on 15/11/2020.
//

import UIKit

class ShiftCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var earningLbl: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    var cellShift = Shift()
    
    override class func awakeFromNib() {

    }
}
