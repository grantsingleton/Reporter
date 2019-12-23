//
//  MetaDataViewController.swift
//  Reporter
//
//  Created by Grant Singleton on 12/23/19.
//  Copyright © 2019 Grant Singleton. All rights reserved.
//

import UIKit
import os.log

class MetaDataViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var issuedByTextField: UITextField!
    @IBOutlet weak var purposeOfVisitTextField: UITextField!
    @IBOutlet weak var editAttendanceButton: UIButton!
    @IBOutlet weak var editDistributionButton: UIButton!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    //MARK: Properties
    var issuedBy: String?
    var purposeOfVisit: String?
    var inAttendance: [(name: String, from: String)]?
    var distribution: [(name: String, from: String)]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        issuedByTextField.delegate = self
        purposeOfVisitTextField.delegate = self

        // Do any additional setup after loading the view.
        if let issuedBy = issuedBy {
            issuedByTextField.text = issuedBy
        }
        if let purposeOfVisit = purposeOfVisit {
            purposeOfVisitTextField.text = purposeOfVisit
        }
      
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        default:
            print("SAVE")
            guard let button = sender as? UIBarButtonItem, button == saveButton else {
                os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
                return
            }
            
            issuedBy = issuedByTextField.text ?? ""
            purposeOfVisit = purposeOfVisitTextField.text ?? ""
            //**FIXME** add inAttendance and Distribution
        }
    }
    
    
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        saveButton.isEnabled = true
    }
    
    //MARK: Actions
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        print("cancel")
        if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The JobContentViewController is not inside a navigation controller")
        }
    }


}
