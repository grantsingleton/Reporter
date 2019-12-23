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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        // load any saved meals, otherwise load sample data
        if let savedJobs = loadJobs() {
            jobs += savedJobs
        } else {
            loadSampleJobs()
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
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                // Add a new job content item
                let newIndexPath = IndexPath(row: jobs.count, section: 0)
                jobs.append(job)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
    }

    //MARK: Private Methods
    private func loadSampleJobs() {
        
        let photo1 = UIImage(named: "img1")
        let photo2 = UIImage(named: "defaultPhoto")
        let photo3 = UIImage(named: "img2")
        
        var contentList = [JobContentItem]()
        
        guard let content1 = JobContentItem(shortDescription: "Found leakage in the window", photo: photo1, status: JobContentItem.Severity.RED, severityIconPhoto: nil, longDescription: "This leakage has caused a major issue for everyone involved with the company. Many employees have been soaked during a storm while walking by this window. Much mold has been discovered which has given people lung issues. Must remedy this asap.") else { fatalError("Unable to instantiate content") }
        
        guard let content2 = JobContentItem(shortDescription: "Nothing here", photo: photo2, status: JobContentItem.Severity.YELLOW, severityIconPhoto: nil, longDescription: "") else { fatalError("Unable to instantiate content") }
        
        guard let content3 = JobContentItem(shortDescription: "This is great work, no leaks.", photo: photo3, status: JobContentItem.Severity.GREEN, severityIconPhoto: nil, longDescription: "This is a really great improvement over last inspection. No leaks found in upper five floors.") else { fatalError("Unable to instantiate content") }
        
        contentList += [content1, content2, content3]
        
        guard let job1 = Job(date: "December 9th", weatherDate: Date(), content: contentList, weather: nil) else {
            fatalError("Unable to instantiate Job")
        }
        
        guard let job2 = Job(date: "December 10th", weatherDate: Date(), content: [JobContentItem](), weather: nil) else {
            fatalError("Unable to instantiate Job")
        }
        
        guard let job3 = Job(date: "December 11th", weatherDate: Date(), content: [JobContentItem](), weather: nil) else {
            fatalError("Unable to instantiate Job")
        }
        
        jobs += [job1, job2, job3]
    }
    
    private func saveExistingJob(job: Job) {
        
        // Replace the outdated job with the new one
        for index in 0..<jobs.count {
            if jobs[index].date == job.date {
                jobs[index] = job
            }
        }
        
        let isSuccesfulSave = NSKeyedArchiver.archiveRootObject(jobs, toFile: Job.ArchiveURL.path)
        
        if isSuccesfulSave {
            os_log("Jobs succesfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Jobs failed to save...", log: OSLog.default, type: .error)
        }
    }
    
    private func saveJobs() {
        
        let isSuccesfulSave = NSKeyedArchiver.archiveRootObject(jobs, toFile: Job.ArchiveURL.path)
        
        if isSuccesfulSave {
            os_log("Jobs succesfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Jobs failed to save...", log: OSLog.default, type: .error)
        }
    }
    
    private func loadJobs() -> [Job]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Job.ArchiveURL.path) as? [Job]
    }

}

