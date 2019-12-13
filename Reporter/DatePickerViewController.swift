//
//  DatePickerViewController.swift
//  Reporter
//
//  Created by Grant Singleton on 12/11/19.
//  Copyright © 2019 Grant Singleton. All rights reserved.
//

import UIKit
import os.log

class DatePickerViewController: UIViewController, UINavigationControllerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var job: Job?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

        // MARK: - Navigation
    // this function is called when we navigate back to JobContentTableView
    // Use this to pass new table cell back to table
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // good habit, doesnt do anything here
        super.prepare(for: segue, sender: sender)
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        // configure destination view controller only when save button is pressed
        // the following code verifies that the saveButton was pressed
        
        guard let button = sender as? UIBarButtonItem, button == saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        // Get the String date
        let date = datePicker.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        let dateString = dateFormatter.string(from: date)
        
        // Get the weather date
        let weatherDate: Date = datePicker.date
        
        print(dateString)
        
        let emptyContent = [JobContentItem]()
        
        // set the content to be passed to JobContentTableViewController after unwind segue
        job = Job(date: dateString, weatherDate: weatherDate, content: emptyContent, isWeatherLoaded: false, weather: nil)
    }

    //MARK: Actions
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
    }
    
    
}
