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
        coder.encode(date, forKey: PropertyKey.date)
    }
    
    required convenience init?(coder: NSCoder) {
        
        guard let date = coder.decodeObject(forKey: PropertyKey.date) as? String else {
            os_log("unable to decode the date for a Job object", log: OSLog.default, type: .debug)
            return nil
        }
                
        let content = coder.decodeObject(forKey: PropertyKey.content) as? [JobContentItem]
        
        self.init(date: date, content: content)
    }
    
    
    //MARK: Properties
    // date of the job
    var date: String
    // list of content
    var content: [JobContentItem]
    var isWeatherLoaded: Bool
    var weather: WeatherData?
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("jobs")
    
    //MARK: Types
    struct PropertyKey {
        static let date = "date"
        static let content = "content"
    }
    
    //MARK: Initialization
    init?(date: String, content: [JobContentItem]?) {
        
        guard !date.isEmpty else {
            return nil
        }
        
        self.date = date
        self.content = content ?? [JobContentItem]()
        self.isWeatherLoaded = false
    }
    
    
}
