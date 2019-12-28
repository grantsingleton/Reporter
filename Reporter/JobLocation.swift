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
    }
    
    required convenience init?(coder: NSCoder) {
        
        guard let jobLocationName = coder.decodeObject(forKey: PropertyKey.jobLocationName) as? String else {
            os_log("unable to decode the jobLocationName for a JobLocation object", log: OSLog.default, type: .debug)
            return nil
        }
        
        self.init(jobLocationName: jobLocationName)
    }
    
    //MARK: Properties
    var jobLocationName: String
    
    struct PropertyKey {
        static let jobLocationName = "jobLocationName"
    }
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArhiveURL = DocumentsDirectory.appendingPathComponent("Locations")
    
    init(jobLocationName: String) {
        self.jobLocationName = jobLocationName
    }
}
