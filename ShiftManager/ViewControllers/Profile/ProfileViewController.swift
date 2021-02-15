//
//  ProfileViewController.swift
//  ShiftManager
//
//  Created by Даниил Дорожкин on 29/11/2020.
//

import UIKit
import FirebaseAuth
import SwiftEntryKit

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //MARK: OUTLETS
    @IBOutlet weak var jobBgView: UIView!
    @IBOutlet weak var patternsBgView: UIView!
    
    @IBOutlet weak var jobNameLbl: UILabel!
    @IBOutlet weak var salaryLbl: UILabel!
  
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var patternsCollection: UICollectionView!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        patternsCollection.delegate = self
        patternsCollection.dataSource = self
        
        let _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerUpdate), userInfo: nil, repeats: true)
        designSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        designUpdate()
    }
    
    func designUpdate() {
        patternsCollection.reloadData()
        jobNameLbl.text = currentUser.jobName
        salaryLbl.text = "\(currentUser.salary)\(currentUser.currency)/per hours"
    }
    
    @objc func timerUpdate() {
        if needUserUpdate {
            needUserUpdate = false
            designUpdate()
        }
    }
    
    func designSetup() {
        let viewsArray = [jobBgView, logoutButton, patternsBgView]
        for viewElem in viewsArray {
            viewElem?.makeShadowAndRadius(opacity: 0.5, radius: 15)
        }
        
        editButton.layer.cornerRadius = 15
        patternsCollection.layer.cornerRadius = 15
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    //MARK:BUTTONS
    @IBAction func logoutButtonTapped(_ sender: Any) {
        try! Auth.auth().signOut()
        pathFirebaseRoot = ""
        self.performSegue(withIdentifier: "toIntro", sender: self)
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        SwiftEntryKit.display(entry: storyboard!.instantiateViewController(withIdentifier:"editProfile"), using: setupAttributes(type: toView.editProfile))
    }
    
    //MARK: COLLECTION VIEW
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentUser.shiftsPattern.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row < currentUser.shiftsPattern.count {
            //Shift cell
            let cell = patternsCollection.dequeueReusableCell(withReuseIdentifier: "shiftCell", for: indexPath) as! ShiftCollectionViewCell
            
            cell.cellShift = currentUser.shiftsPattern[indexPath.row]
            cell.earningLbl.text = "\(cell.cellShift.earning)\(currentUser.currency)"
            cell.timeLbl.text = cell.cellShift.time
    
            cell.makeShadowAndRadius(opacity: 0.5, radius: 8)
            cell.bgView.layer.cornerRadius = 8
    
            return cell
        } else {
            //Adding shift cell
            let cell = patternsCollection.dequeueReusableCell(withReuseIdentifier: "addCell", for: indexPath) as! AddShiftCollectionViewCell
            
            cell.makeShadowAndRadius(opacity: 0.5, radius: 8)
            cell.bgView.layer.cornerRadius = 8
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if indexPath.row < currentUser.shiftsPattern.count {
            //Editing shift
            editCalledFromPattern = true
            editingHoursString = currentUser.shiftsPattern[indexPath.row].time
            SwiftEntryKit.display(entry: storyboard.instantiateViewController(withIdentifier:"editView"), using: setupAttributes(type: toView.shifts))
        } else {
            //Adding shift
            addCalledFromPattern = true
            SwiftEntryKit.display(entry: storyboard.instantiateViewController(withIdentifier:"addView"), using: setupAttributes(type: toView.shifts))
        }
    }
    
    enum toView {
        case editProfile
        case shifts
    }
    
    //MARK:SEGUES ATTRIBUTES
    func setupAttributes(type: toView) -> EKAttributes {
        var attributes = EKAttributes.centerFloat
        
        if type == toView.shifts {
            //Editing shift
            let widthConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 0.9)
            let heightConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 0.5)
            
            attributes.positionConstraints.size = .init(width: widthConstraint, height: heightConstraint)
        } else {
            //Profile
            let widthConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 0.7)
            let heightConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 0.5)
            
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
