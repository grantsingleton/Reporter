//
//  JobLocationTableViewController.swift
//  Reporter
//
//  Created by Grant Singleton on 12/27/19.
//  Copyright © 2019 Grant Singleton. All rights reserved.
//

import UIKit
import os.log

class JobLocationTableViewController: UITableViewController {
    
    //MARK: Properties
    var locations = [JobLocation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadSampleLocations()
/*
        if let savedLocations = loadLocations() {
            self.locations = savedLocations
        } else {
            loadSampleLocations()
        }
        */
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // Only one section needed at the moment
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // need as many rows as there are locations
        return locations.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "JobLocationTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? JobLocationTableViewCell else {
            fatalError("The dequeued cell is not an instance of JobLocationTableViewCell")
        }
        
        let location = locations[indexPath.row]
        
        cell.titleLabel.text = location.jobLocationName

        return cell
    }


    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            locations.remove(at: indexPath.row)
            saveLocations()
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        switch(segue.identifier ?? "") {
            
        case "AddNewLocation":
        os_log("Adding a new location.", log: OSLog.default, type: .debug)
            
        case "ShowJobs":
            
            // get the view controller we are moving to
            guard let jobTableViewController = segue.destination as? JobTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            // get the cell that was selected by the user
            guard let selectedLocationCell = sender as? JobLocationTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            // get the index for the selected cell
            guard let indexPath = tableView.indexPath(for: selectedLocationCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            // this is the location that was selected by the user
            let selectedLocation = locations[indexPath.row]
            
            // pass the location name into the JobTableViewController
            jobTableViewController.jobLocation = selectedLocation
            
        default:
            fatalError("Unexpected Segue Identifier: \(String(describing: segue.identifier))")
        }
    }
    
    
    //MARK: Storage Methods
    private func saveLocations() {
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: locations, requiringSecureCoding: false)
            try data.write(to: JobLocation.ArhiveURL)
        } catch {
            print("Couldn't save Job Locations")
        }
    }
    
    private func loadLocations() -> [JobLocation]? {
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: locations, requiringSecureCoding: false)
            if let loadedLocations = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [JobLocation] {
                return loadedLocations
            }
        } catch {
            print("Couldn't load Job Locations")
        }
        return []
    }
    
    func loadSampleLocations() {
        
        let location = JobLocation(jobLocationName: "UTMB Hospital")
        
        locations += [location]
        
    }
    
}
