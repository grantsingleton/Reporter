//
//  MetaDataViewController.swift
//  Reporter
//
//  Created by Grant Singleton on 12/23/19.
//  Copyright © 2019 Grant Singleton. All rights reserved.
//

import UIKit
import os.log

class MetaDataViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var issuedByTextField: UITextField!
    @IBOutlet weak var purposeOfVisitTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var addInAttendanceButton: UIButton!
    @IBOutlet weak var addDistributionButton: UIButton!
    @IBOutlet weak var attendanceNameTextField: UITextField!
    @IBOutlet weak var attendanceFromTextField: UITextField!
    @IBOutlet weak var distributionNameTextField: UITextField!
    @IBOutlet weak var distributionFromTextField: UITextField!
    @IBOutlet weak var inAttendanceTableView: UITableView!
    @IBOutlet weak var distributionTableView: UITableView!
    
    
    //MARK: Properties
    var issuedBy: String?
    var purposeOfVisit: String?
    var attendance: [(name: String, from: String)]?
    var distribution: [(name: String, from: String)]?
    
    var attendanceList: [(name: String, from: String)] = []
    var distributionList: [(name: String, from: String)] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        issuedByTextField.delegate = self
        purposeOfVisitTextField.delegate = self
        
        inAttendanceTableView.dataSource = self
        inAttendanceTableView.delegate = self
        
        distributionTableView.dataSource = self
        distributionTableView.delegate = self

        // Do any additional setup after loading the view.
        if let issuedBy = issuedBy {
            issuedByTextField.text = issuedBy
        }
        if let purposeOfVisit = purposeOfVisit {
            purposeOfVisitTextField.text = purposeOfVisit
        }
        if let attendance = attendance {
            attendanceList = attendance
        }
        if let distribution = distribution {
            distributionList = distribution
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
            attendance = attendanceList
            distribution = distributionList
        }
    }
    
    //MARK: TableView Protocol Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.inAttendanceTableView {
            return attendanceList.count
        }
        else {
            return distributionList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.inAttendanceTableView {
            
            let cellIdentifier = "AttendanceTableViewCell"
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? AttendanceTableViewCell else {
                fatalError("The dequeued cell is not an instance of AttendanceTableViewCell")
            }
            
            let name = attendanceList[indexPath.row].name
            let from = attendanceList[indexPath.row].from
            
            cell.nameLabel.text = name
            cell.fromLabel.text = from
            
            return cell
        }
        else {
            
            let cellIdentifier = "DistributionTableViewCell"
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? DistributionTableViewCell else {
                fatalError("The dequeued cell is not an instance of DistributionTableViewCell")
            }
            
            let name = distributionList[indexPath.row].name
            let from = distributionList[indexPath.row].from
            
            cell.nameLabel.text = name
            cell.fromLabel.text = from
            
            return cell
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
    
    //MARK: Add new people Actions
    @IBAction func addPersonInAttendance(_ sender: UIButton) {
        if (!attendanceNameTextField.text!.isEmpty && !attendanceFromTextField.text!.isEmpty) {
            // add the new person to the table view
            let newName = attendanceNameTextField.text!
            let newFrom = attendanceFromTextField.text!
            let newPerson = [(name: newName, from: newFrom)]
            attendanceList += newPerson
            inAttendanceTableView.reloadData()
        }
    }
    
    @IBAction func addPersonInDistribution(_ sender: UIButton) {
        if (!distributionNameTextField.text!.isEmpty && !distributionFromTextField.text!.isEmpty) {
            // add the new person to the list
            let newName = distributionNameTextField.text!
            let newFrom = distributionFromTextField.text!
            let newPerson = [(name: newName, from: newFrom)]
            distributionList += newPerson
            distributionTableView.reloadData()
        }
    }
    

}
