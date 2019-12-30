//
//  JobLocation.swift
//  Reporter
//
//  Created by Grant Singleton on 12/27/19.
//  Copyright © 2019 Grant Singleton. All rights reserved.
//

import UIKit
import os.log

class JobLocation: NSObject, NSCoding {
    
    //MARK: NSCoding
    func encode(with coder: NSCoder) {
        coder.encode(jobLocationName, forKey: PropertyKey.jobLocationName)
        coder.encode(jobDescription, forKey: PropertyKey.jobDescription)
        coder.encode(jobs, forKey: PropertyKey.jobs)
    }
    
    required convenience init?(coder: NSCoder) {
        
        guard let jobLocationName = coder.decodeObject(forKey: PropertyKey.jobLocationName) as? String else {
            os_log("unable to decode the jobLocationName for a JobLocation object", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let jobs = coder.decodeObject(forKey: PropertyKey.jobs) as? [Job] else {
            os_log("unable to decode the jobLocationName for a JobLocation object", log: OSLog.default, type: .debug)
            return nil
        }
        
        let jobDescription = coder.decodeObject(forKey: PropertyKey.jobDescription) as? String ?? ""
        
        self.init(jobLocationName: jobLocationName, jobDescription: jobDescription, jobs: jobs)
    }
    
    //MARK: Properties
    var jobLocationName: String
    var jobDescription: String
    
    var jobs: [Job]
    
    struct PropertyKey {
        static let jobLocationName = "jobLocationName"
        static let jobDescription = "jobDescription"
        static let jobs = "jobs"
    }
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArhiveURL = DocumentsDirectory.appendingPathComponent("Locations")
    
    init(jobLocationName: String, jobDescription: String, jobs: [Job]) {
        self.jobLocationName = jobLocationName
        self.jobDescription = jobDescription
        self.jobs = jobs
    }
    
}
