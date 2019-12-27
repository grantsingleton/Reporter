//
//  People.swift
//  Reporter
//
//  Created by Grant Singleton on 12/26/19.
//  Copyright © 2019 Grant Singleton. All rights reserved.
//

import Foundation
import os.log

class Person: NSObject, NSCoding {
    
    //MARK: Properties
    var name: String
    var from: String
    
    struct PropertyKey {
        static let name = "name"
        static let from = "from"
    }
    
    //MARK: Init
    init(name: String, from: String) {
        self.name = name
        self.from = from
    }
    
    //MARK: NSCoding Protocol
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: PropertyKey.name)
        coder.encode(from, forKey: PropertyKey.from)
    }
    
    required convenience init?(coder: NSCoder) {
        
        guard let name = coder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the data for a Person Object", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let from = coder.decodeObject(forKey: PropertyKey.from) as? String else {
            os_log("Unable to decode the data for a Person Object", log: OSLog.default, type: .debug)
            return nil
        }
        
        self.init(name: name, from: from)
    }
}
