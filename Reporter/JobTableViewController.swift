//
//  ViewController.swift
//  Reporter
//
//  Created by Grant Singleton on 11/23/19.
//  Copyright © 2019 Grant Singleton. All rights reserved.
//

import UIKit
import os.log

class JobTableViewController: UITableViewController {
    
    //MARK: Properties
    
    var jobLocation: JobLocation!
    var callback: ((_ jobLocation: JobLocation) -> Void)?


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // remove this for now since the left button item should be back to location
        //navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.title = jobLocation!.jobLocationName
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // only one section needed at the moment
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // need as many rows as there are jobs
        return jobLocation.jobs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "JobTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? JobTableViewCell else {
            fatalError("The dequeued cell is not an instance of JobTableViewCell")
        }
        
        let job = jobLocation.jobs[indexPath.row]
        
        cell.jobLabel.text = job.date
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            jobLocation.jobs.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.callback?(self.jobLocation)
        } else if editingStyle == .insert {
            
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        // Get the new view controller using segue.destinationViewController
        // Pass the selected object to the new view controller
            
        switch(segue.identifier ?? "") {
            
        // TODO: implement this first case
        case "AddNewJob":
            os_log("Adding a new job.", log: OSLog.default, type: .debug)
            
        case "EditLocation":
            
            guard let editLocationViewController = segue.destination as? NewLocationViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            editLocationViewController.jobLocation = self.jobLocation
            
            
        case "SeeJobContent":
            
            // get the view controller that we are moving to
            guard let jobContentTableViewController = segue.destination as? JobContentTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
         
            // get the cell that was selected by the user
            guard let selectedJobCell = sender as? JobTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            // get the index for the selected cell
            guard let indexPath = tableView.indexPath(for: selectedJobCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            // this is the job that was selected by the user
            let selectedJob = jobLocation.jobs[indexPath.row]
            
            jobContentTableViewController.callback = { (job) -> Void in
                //self.saveExistingJob(job: job)
                // Add a callback to job locations
                self.jobLocation.jobs[indexPath.row] = job
                self.callback?(self.jobLocation)
            }
            
            // If the selected job isnt the first job in the list then pass the previous job in so we can get the meta data
            if (indexPath.row > 0) {
                let previousJob = jobLocation.jobs[indexPath.row - 1]
                jobContentTableViewController.previousJob = previousJob
            }
            // pass this selected job into the jobContentTableView by setting its member variable "job" to selectedJob
            jobContentTableViewController.job = selectedJob
            jobContentTableViewController.jobLocationName = self.jobLocation.jobLocationName
            jobContentTableViewController.jobDescription = self.jobLocation.jobDescription
        
        default:
            fatalError("Unexpected Segue Identifier: \(String(describing: segue.identifier))")
        }
    }
    
    //MARK: Unwind
    @IBAction func unwindFromJobLocationMetaDataViewController(sender: UIStoryboardSegue) {
        
        if let sourceViewController = sender.source as? NewLocationViewController, let returnedJobLocation = sourceViewController.jobLocation {
            
            self.jobLocation.jobLocationName = returnedJobLocation.jobLocationName
            self.jobLocation.jobDescription = returnedJobLocation.jobDescription
            
            // Save the edited Job
            self.callback?(self.jobLocation)
        }
    }
    
    @IBAction func unwindToJobList(sender: UIStoryboardSegue) {
        
        if let sourceViewController = sender.source as? DatePickerViewController, let job = sourceViewController.job {
            // update existing item if it was an edit
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                jobLocation.jobs[selectedIndexPath.row] = job
                //saveJob(job: job, index: selectedIndexPath.row)
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
                
                // Save the edited Job
                self.callback?(self.jobLocation)
            }
            else {
                // Add a new job content item
                let newIndexPath = IndexPath(row: jobLocation.jobs.count, section: 0)
                jobLocation.jobs.append(job)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
                
                // Save the new job
                self.callback?(self.jobLocation)
            }
        }
    }


    
    
    
}

