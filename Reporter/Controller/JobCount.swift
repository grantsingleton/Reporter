//
//  JobCount.swift
//  Reporter
//
//  Created by Grant Singleton on 12/27/19.
//  Copyright © 2019 Grant Singleton. All rights reserved.
//

import UIKit
import os.log

class JobCount: NSObject, NSCoding {
    
    //MARK: NSCoding
    func encode(with coder: NSCoder) {
        coder.encode(count, forKey: PropertyKey.count)
    }
    
    
    required convenience init?(coder: NSCoder) {
        let count = coder.decodeInteger(forKey: PropertyKey.count)
        
        self.init(count: count)
    }
    
    //MARK: Archive Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("jobCount")
    
    //MARK: Properties
    var count: Int
    
    struct PropertyKey {
        static let count = "count"
    }
    
    
    init(count: Int) {
        self.count = count
    }
    
    func increment() {
        self.count += 1
    }
    
    func decrement() {
        self.count -= 1
    }
}
