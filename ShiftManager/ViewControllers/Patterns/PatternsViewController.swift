//
//  PatternsViewController.swift
//  ShiftManager
//
//  Created by Даниил Дорожкин on 18/01/2021.
//

import UIKit
import SwiftEntryKit

class PatternsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var patternsCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        patternsCollection.delegate = self
        patternsCollection.dataSource = self
    }
    
    //MARK:COLLECTION VIEW
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentUser.shiftsPattern.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            //Shift cell
            let cell = patternsCollection.dequeueReusableCell(withReuseIdentifier: "shiftCell", for: indexPath) as! ShiftCollectionViewCell
            
            cell.cellShift = currentUser.shiftsPattern[indexPath.row]
            cell.earningLbl.text = "\(cell.cellShift.earning)\(currentUser.currency)"
            cell.timeLbl.text = cell.cellShift.time
    
            cell.makeShadowAndRadius(opacity: 0.5, radius: 15)
            cell.bgView.layer.cornerRadius = 15
    
            return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let choosedShift = currentUser.shiftsPattern[indexPath.row]
        showingDay.shiftArray.append(choosedShift)
        updatingDayInFirebase(day: showingDay)
        SwiftEntryKit.dismiss()
    }
    
}
