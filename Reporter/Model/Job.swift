//
//  Job.swift
//  Reporter
//
//  Created by Grant Singleton on 11/23/19.
//  Copyright © 2019 Grant Singleton. All rights reserved.
//

import UIKit
import os.log

class Job: NSObject, NSCoding {
    
    //MARK: NSCoding
    func encode(with coder: NSCoder) {
        coder.encode(content, forKey: PropertyKey.content)
        coder.encode(content, forKey: PropertyKey.weatherDate)
        coder.encode(date, forKey: PropertyKey.date)
        coder.encode(isWeatherLoaded, forKey: PropertyKey.isWeatherLoaded)
        coder.encode(weather, forKey: PropertyKey.weather)
        coder.encode(issuedBy, forKey: PropertyKey.issuedBy)
        coder.encode(purposeOfVisit, forKey: PropertyKey.purposeOfVisit)
        coder.encode(inAttendance, forKey: PropertyKey.inAttendance)
        coder.encode(distribution, forKey: PropertyKey.distribution)
        coder.encode(jobNumber, forKey: PropertyKey.jobNumber)
        coder.encode(reportNumber, forKey: PropertyKey.reportNumber)
    }
    
    required convenience init?(coder: NSCoder) {
        
        guard let date = coder.decodeObject(forKey: PropertyKey.date) as? String else {
            os_log("unable to decode the date for a Job object", log: OSLog.default, type: .debug)
            return nil
        }
        
        let weatherDate = coder.decodeObject(forKey: PropertyKey.weatherDate) as? Date ?? Date()
                
        let content = coder.decodeObject(forKey: PropertyKey.content) as? [JobContentItem]
        
        let isWeatherLoaded = coder.decodeBool(forKey: PropertyKey.isWeatherLoaded)
        
        let weather = coder.decodeObject(forKey: PropertyKey.weather) as? WeatherInformation
        
        self.init(date: date, weatherDate: weatherDate, content: content, isWeatherLoaded: isWeatherLoaded, weather: weather)
        
        let issuedBy = coder.decodeObject(forKey: PropertyKey.issuedBy) as? String
        let purposeOfVisit = coder.decodeObject(forKey: PropertyKey.purposeOfVisit) as? String
        let inAttendance = coder.decodeObject(forKey: PropertyKey.inAttendance) as? [Person]
        let distribution = coder.decodeObject(forKey: PropertyKey.distribution) as? [Person]
        
        let jobNumber = coder.decodeObject(forKey: PropertyKey.jobNumber) as? String
        
        let reportNumber = coder.decodeObject(forKey: PropertyKey.reportNumber) as? Int ?? 0
        
        // Set the meta data
        self.issuedBy = issuedBy
        self.purposeOfVisit = purposeOfVisit
        self.inAttendance = inAttendance
        self.distribution = distribution
        self.jobNumber = jobNumber
        self.reportNumber = reportNumber
    }
    
    
    //MARK: Properties
    // date of the job
    var date: String
    // date for weather purposes
    var weatherDate: Date
    // list of content
    var content: [JobContentItem]
    var isWeatherLoaded: Bool
    var weather: WeatherInformation?
    
    // Meta Data Properties
    var issuedBy: String?
    var purposeOfVisit: String?
    var inAttendance: [Person]?
    var distribution: [Person]?
    
    var jobNumber: String?
    var reportNumber: Int?
    
        
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    
    //MARK: Types
    struct PropertyKey {
        static let date = "date"
        static let weatherDate = "weatherDate"
        static let content = "content"
        static let isWeatherLoaded = "isWeatherLoaded"
        static let weather = "weather"
        static let issuedBy = "issuedBy"
        static let purposeOfVisit = "purposeOfVisit"
        static let inAttendance = "inAttendance"
        static let distribution = "distribution"
        static let jobNumber = "jobNumber"
        static let reportNumber = "reportNumber"
    }
    
    //MARK: Initialization
    init?(date: String, weatherDate: Date, content: [JobContentItem]?, isWeatherLoaded: Bool = false, weather: WeatherInformation?) {
        
        guard !date.isEmpty else {
            return nil
        }
        
        self.date = date
        self.weatherDate = weatherDate
        self.content = content ?? [JobContentItem]()
        self.weather = weather ?? nil
        self.isWeatherLoaded = isWeatherLoaded
        
        // Initialize Meta Data to null values, it will be set later by setters
        self.issuedBy = ""
        self.purposeOfVisit = ""
        self.inAttendance = []
        self.distribution = []
        self.jobNumber = ""
        self.reportNumber = 0
    }
    
    
}
