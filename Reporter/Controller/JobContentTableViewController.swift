//
//  JobContentTableViewController.swift
//  Reporter
//
//  Created by Grant Singleton on 11/24/19.
//  Copyright © 2019 Grant Singleton. All rights reserved.
//

import UIKit
import os.log
import MessageUI
import CoreLocation
import Floaty

class JobContentTableViewController: UITableViewController, UINavigationControllerDelegate, CLLocationManagerDelegate, FloatyDelegate {
    
    //MARK: Properties
    // The job passed in when the user selects a job
    var job: Job?
    var jobLocationName: String?
    var jobDescription: String?
    var previousJob: Job?
    var content: [JobContentItem] = []
    var saveJobsCallback: ((_ job: Job) -> Void)?
    let locationManager = CLLocationManager()
    var deviceLocation: CLLocationCoordinate2D?
    var weatherData: WeatherData?
    var PDF: Data?
    
    // floating action button
    var fab = Floaty(frame: CGRect(x: 0, y: 0, width: 56, height: 56))
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        if let job = job {
            navigationItem.title = job.date
            content = job.content
        }
        
        
        // Ask for Authorization from the User for location data.
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        layoutFloatingActionButton()
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // lets use one section for now
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // need as many rows as content items
        return content.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "JobContentTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? JobContentTableViewCell else {
            fatalError("The dequeued cell is not an instance of JobContentTableViewCell")
        }

        let contentItem = content[indexPath.row]
        
        cell.shortDescriptionLabel.text = contentItem.shortDescription
        cell.contentPhoto.image = contentItem.editedPhoto ?? contentItem.photo
        cell.severityIconPhoto.image = severityIcon(severity: contentItem.status)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }


    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            content.remove(at: indexPath.row)
            // update the job and pass it back to JobTableViewController to be saved
            self.job?.content = content
            saveJobsCallback?(self.job!)
            
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

    //MARK: Delegate Methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locationValue: CLLocationCoordinate2D = manager.location?.coordinate else {
            print("Unable to fetch device location")
            return
        }
        self.deviceLocation = locationValue
        
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "AddContent":
            os_log("Adding new content.", log: OSLog.default, type: .debug)
            
        case "ShowContentDetail":
            guard let contentDetailViewController = segue.destination as? JobContentViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedContentCell = sender as? JobContentTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedContentCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            // pass selected content to the content view controller
            let selectedContent = content[indexPath.row]
            contentDetailViewController.content = selectedContent
            
            // this callback is called when the user reverts the image
            contentDetailViewController.revertImageCallback = { () -> Void in
                // put the original photo in the table view cell
                selectedContentCell.contentPhoto.image = selectedContent.photo
                // destroy the edited photo
                selectedContent.editedPhoto = nil
                // initiate the save jobs callback
                self.saveJobsCallback!(self.job!)
            }
            
        case "AddMetaData":
            print("Adding Meta Data to Job Content item")
            
            guard let metaDataViewController = segue.destination as? MetaDataViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            // Check if the meta data has been set yet
            // If it hasnt, preset it to the previous reports meta data if it exists
            // Otherwise leave it blank
            let selectedJob = self.job
            
            // if there is a previous report and the current report has no meta data then set the previous reports meta data to be this reports meta data
            if (previousJob != nil) {
                print("PREVIOUS JOB NOT NULL")
                // Check if the meta data is filled out
                if (selectedJob!.issuedBy == "") {
                    selectedJob!.issuedBy = previousJob!.issuedBy
                }
                if (selectedJob!.purposeOfVisit == "") {
                    selectedJob!.purposeOfVisit = previousJob!.purposeOfVisit
                }
                if (selectedJob!.inAttendance!.count == 0) {
                    selectedJob!.inAttendance = previousJob!.inAttendance
                }
                if (selectedJob!.distribution!.count == 0) {
                    selectedJob!.distribution = previousJob!.distribution
                }
                if (selectedJob!.jobNumber == "") {
                    selectedJob!.jobNumber = previousJob!.jobNumber
                }
                if (selectedJob!.reportNumber == 0) {
                    selectedJob!.reportNumber = previousJob!.reportNumber! + 1
                }
            }
            // Set the controllers meta data before segue
            metaDataViewController.issuedBy = selectedJob!.issuedBy
            metaDataViewController.purposeOfVisit = selectedJob!.purposeOfVisit
            metaDataViewController.attendance = selectedJob!.inAttendance
            metaDataViewController.distribution = selectedJob!.distribution
            metaDataViewController.jobNumber = selectedJob!.jobNumber
            metaDataViewController.reportNumber = selectedJob!.reportNumber
            metaDataViewController.jobDate = selectedJob?.date
            
        case "displayPDF":
            print("Displaying PDF")
            
            guard let reportPreviewViewController = segue.destination as? ReportPreviewViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            // pass the PDF data
            reportPreviewViewController.PDF = self.PDF ?? Data()
            
        default:
            fatalError("Unexpected segue identifier: \(String(describing: segue.identifier))")
        }
    }

    
    //MARK: Actions
    @IBAction func unwindToJobContentList(sender: UIStoryboardSegue) {
        
        if let sourceViewController = sender.source as? JobContentViewController, let contentItem = sourceViewController.content {
            
            // update existing item if it was an edit
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                content[selectedIndexPath.row] = contentItem
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                // Add a new job content item
                let newIndexPath = IndexPath(row: content.count, section: 0)
                content.append(contentItem)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            // Pass the job back to the jobtableviewcontroller and save it there
            self.job?.content = content
            saveJobsCallback?(self.job!)
            
        }
        else if let sourceViewController = sender.source as? MetaDataViewController {
            // get the data from the MetaDataViewController
            let issuedByText = sourceViewController.issuedBy
            let purposeOfVisitText = sourceViewController.purposeOfVisit
            let inAttendanceList = sourceViewController.attendance
            let distributionList = sourceViewController.distribution
            let jobNumberString = sourceViewController.jobNumber
            let reportNumberInt = sourceViewController.reportNumber
            let dateString = sourceViewController.jobDate
            
            // Set that data to the Job
            self.job?.issuedBy = issuedByText
            self.job?.purposeOfVisit = purposeOfVisitText
            self.job?.inAttendance = inAttendanceList
            self.job?.distribution = distributionList
            self.job?.jobNumber = jobNumberString
            self.job?.reportNumber = reportNumberInt
            self.job?.date = dateString ?? self.job!.date
            
            //update navigation title in case the date was changed
            navigationItem.title = self.job?.date
            print("SET JOB DATA")
            // Pass the job back to the jobtableviewcontroller and save it there
            saveJobsCallback?(self.job!)
        }
    }

    
    @IBAction func runReport(_ sender: UIBarButtonItem) {
        
        // Set title depending on status of weather
        
        var fetchWeatherTitle = "Fetch Weather: ";

        if (isWeatherInformationLoaded()) {
            fetchWeatherTitle += "Already Fetched"
        } else {
            if (isWeatherLoaded()) {
                job?.weather = WeatherInformation(weatherData: self.weatherData!)
                saveJobsCallback?(self.job!)
                
                fetchWeatherTitle += "Already Fetched"
            } else {
                fetchWeatherTitle += "None recorded"
            }
        }
        
        // present the action sheet
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        alert.addAction(UIAlertAction(title: fetchWeatherTitle, style: .default, handler: { (alert: UIAlertAction) -> Void in
            // fetch weather
            self.loadWeather()
        }))
        
        alert.addAction(UIAlertAction(title: "Build Report", style: .default, handler: { (alert: UIAlertAction) -> Void in
            // Build Report
            let reportData = self.buildReport()
            // Present a preview of the report
            if (reportData.isEmpty) {
                // Do nothing
            } else {
                // present preview
                self.PDF = reportData
                self.performSegue(withIdentifier: "displayPDF", sender: self)

            }
        }))
        
        // cancel button (for iphone only, wont show up on ipad)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(alert:UIAlertAction!) -> Void in
            print("user canceled run report action sheet")
        }))

        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
                
        self.present(alert, animated: true)
    }
    
    // MARK: Report Actions
    func buildReport() -> Data {
        
        if job == nil {
            print("There is no job to run a report for")
            return Data()
        }
        
        if job?.content.count == 0 {
            print("No content to run report on")
            return Data()
        }
        
        if (!isWeatherInformationLoaded()) {
            // If the weather hasn't been fetched this session, fetch it. Otherwise set WeatherInformation to WeatherData
            if (!isWeatherLoaded()) {
                print("Weather has not been fetched")
                loadWeather()
                return Data()
            } else {
                job?.weather = WeatherInformation(weatherData: weatherData!)
            }
        }
        
        let pdfBuilder = PDFBuilder(job: job!, jobLocationName: self.jobLocationName!, jobDescription: self.jobDescription!)
        
        let reportPDFData = pdfBuilder.buildPDF()
        
        return reportPDFData
        
    }
    
    
    func loadWeather() {

        weatherData = WeatherData(coordinates: self.deviceLocation!, weatherDate: self.job!.weatherDate)
    
    }
    
    func isWeatherLoaded() -> Bool {
        
        return weatherData != nil ? true : false
    }
    
    func isWeatherInformationLoaded() -> Bool {
        
        return job?.weather != nil ? true : false
    }
    
    //MARK: UI Components
    func layoutFloatingActionButton() {
                
        let item = FloatyItem()
        item.handler = { item in
            // Add handler here
            print("HANDLE")
            // use the following function to seque
            // "mysegueID is the name of the segue defined in the storyboard"
            self.performSegue(withIdentifier: "AddContent", sender: self)
        }
        
        fab.addItem(item: item)
        
        fab.sticky = true
        fab.handleFirstItemDirectly = true
        
        fab.paddingX = 40
        fab.paddingY = 40
        
        fab.fabDelegate = self
        
        print(tableView!.frame)
        
        self.view.addSubview(fab)
                
    }

    //MARK: Utility
    func severityIcon(severity: JobContentItem.Severity) -> UIImage {
        
        switch severity {
        case .GREEN:
            return UIImage(named: "greenIcon")!
        case .YELLOW:
            return UIImage(named: "yellowIcon")!
        case .RED:
            return UIImage(named: "redIcon")!
        }
    }
    
}
