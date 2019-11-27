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
        coder.encode(name, forKey: PropertyKey.name)
        coder.encode(content, forKey: PropertyKey.content)
    }
    
    required convenience init?(coder: NSCoder) {
    
        
        guard let name = coder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("unable to decode the name for a Job object", log: OSLog.default, type: .debug)
            return nil
        }
        
        let content = coder.decodeObject(forKey: PropertyKey.content) as? [JobContentItem]
        
        self.init(name: name, content: content)
    }
    
    
    //MARK: Properties
    // name of the job
    var name: String
    // list of content
    var content: [JobContentItem]
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("jobs")
    
    //MARK: Types
    struct PropertyKey {
        static let name = "name"
        static let content = "content"
    }
    
    //MARK: Initialization
    init?(name: String, content: [JobContentItem]?) {
        
        guard !name.isEmpty else {
            return nil
        }
        
        self.name = name
        self.content = content ?? [JobContentItem]()
    }
    
    
}
