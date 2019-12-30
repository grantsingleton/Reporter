//
//  NewLocationViewController.swift
//  Reporter
//
//  Created by Grant Singleton on 12/28/19.
//  Copyright © 2019 Grant Singleton. All rights reserved.
//

import UIKit
import os.log

class NewLocationViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var jobLocationTextField: UITextField!
    @IBOutlet weak var jobDescriptionTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var jobLocation: JobLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        jobLocationTextField.delegate = self
        
        if let jobLocation = jobLocation {
            jobLocationTextField.text = jobLocation.jobLocationName
            jobDescriptionTextField.text = jobLocation.jobDescription
        }

    }
    

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button == saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let jobLocationName = jobLocationTextField.text ?? ""
        let jobDescription = jobDescriptionTextField.text ?? ""
        
        jobLocation = JobLocation(jobLocationName: jobLocationName, jobDescription: jobDescription, jobs: [])
    }
    
    //MARK: Cancel Method
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)

    }
    
    //MARK: UITextField Delegate
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
}
