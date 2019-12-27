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
    
    var jobs = [Job]()
    var jobCount: JobCount!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        self.jobCount = JobCount(count: 0)
        self.jobs = []
        
        //get a saved job count
        if let count = loadJobCount() {
            self.jobCount = count
            print("Job Count: " + String(count.count))
        }
        
        // If there are saved jobs, then load them
        if (jobCount.count > 0) {
            
            if let savedJobs = loadJobs() {
                jobs += savedJobs
            } else {
                // do nothing
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // only one section needed at the moment
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // need as many rows as there are jobs
        return jobs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "JobTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? JobTableViewCell else {
            fatalError("The dequeued cell is not an instance of JobTableViewCell")
        }
        
        let job = jobs[indexPath.row]
        
        cell.jobLabel.text = job.date
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            jobs.remove(at: indexPath.row)
            saveJobs()
            tableView.deleteRows(at: [indexPath], with: .fade)
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
            
        case "SeeJobContent":
            
            // get the view controller that we are moving to
            guard let jobContentTableViewController = segue.destination as? JobContentTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            jobContentTableViewController.callback = { (job) -> Void in
                self.saveExistingJob(job: job)
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
            let selectedJob = jobs[indexPath.row]
            
            // If the selected job isnt the first job in the list then pass the previous job in so we can get the meta data
            if (indexPath.row > 0) {
                let previousJob = jobs[indexPath.row - 1]
                jobContentTableViewController.previousJob = previousJob
            }
            // pass this selected job into the jobContentTableView by setting its member variable "job" to selectedJob
            jobContentTableViewController.job = selectedJob
        
        default:
            fatalError("Unexpected Segue Identifier: \(String(describing: segue.identifier))")
        }
    }
    
    @IBAction func unwindToJobList(sender: UIStoryboardSegue) {
        
        if let sourceViewController = sender.source as? DatePickerViewController, let job = sourceViewController.job {
            // update existing item if it was an edit
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                jobs[selectedIndexPath.row] = job
                saveJob(job: job, index: selectedIndexPath.row)
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                // Add a new job content item
                let newIndexPath = IndexPath(row: jobs.count, section: 0)
                jobs.append(job)
                saveJob(job: job, index: jobs.count - 1)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
    }

    //MARK: Memory Methods
    private func saveExistingJob(job: Job) -> Void {
        
        // Replace the outdated job with the new one
        for index in 0..<jobs.count {
            if jobs[index].date == job.date {
                saveJob(job: job, index: index)
            }
        }
    
    }
    
    private func saveJob(job: Job, index: Int) {
        
        // give the job its own ArchiveURL inside the documents "jobs" folder
        let JobArchiveURL = Job.DocumentsDirectory.appendingPathComponent("Job" + String(index))
        
        let isSuccesfulSave = NSKeyedArchiver.archiveRootObject(job, toFile: JobArchiveURL.path)
        
        if isSuccesfulSave {
            // update jobCount if this is a new job
            if (index + 1 > self.jobCount.count) {
                self.jobCount.count = index + 1
                saveJobCount()
            }
            os_log("Job succesfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Job failed to save...", log: OSLog.default, type: .error)
        }
        
    }
    
    private func saveJobs() {
        
        var index = 0
        for job in self.jobs {
            saveJob(job: job, index: index)
            index += 1
        }
        // reset job count
        self.jobCount.count = self.jobs.count
        saveJobCount()
    }
    
    private func loadJobs() -> [Job]? {
        
        var jobList: [Job] = []
        
        for index in 0..<self.jobCount.count {
            
            //Get the url for this job
            let jobURL = Job.DocumentsDirectory.appendingPathComponent("Job" + String(index))
            
            // Read this job from memory
            let newJob = NSKeyedUnarchiver.unarchiveObject(withFile: jobURL.path) as? Job
            
            // Add the job to the job list
            jobList.append(newJob!)
        }
        return jobList
    }
    
    private func loadJobCount() -> JobCount? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: JobCount.ArchiveURL.path) as? JobCount
    }
    
    private func saveJobCount() {
                
        let isSuccesfulSave = NSKeyedArchiver.archiveRootObject(self.jobCount!, toFile: JobCount.ArchiveURL.path)
        
        if isSuccesfulSave {
            os_log("JobCount succesfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("JobCount failed to save...", log: OSLog.default, type: .error)
        }
    }

}

