//
//  JobContent.swift
//  Reporter
//
//  Created by Grant Singleton on 11/24/19.
//  Copyright © 2019 Grant Singleton. All rights reserved.
//

import UIKit
import os.log

class JobContentItem: NSObject, NSCoding {
    
    func encode(with coder: NSCoder) {
        coder.encode(shortDescription, forKey: PropertyKey.shortDescription)
        coder.encode(photo, forKey: PropertyKey.photo)
        coder.encode(status.rawValue, forKey: PropertyKey.status)
        coder.encode(severityIconPhoto, forKey: PropertyKey.severityIconPhoto)
        coder.encode(longDescription, forKey: PropertyKey.longDescription)
    }
    
    required convenience init?(coder: NSCoder) {
        
        guard let shortDescription = coder.decodeObject(forKey: PropertyKey.shortDescription) as? String else {
            os_log("Unable to decode the title for a content item", log: OSLog.default, type: .debug)
            return nil
        }
        let photo = coder.decodeObject(forKey: PropertyKey.photo) as? UIImage
        let status = Severity(rawValue: coder.decodeInteger(forKey: PropertyKey.status) as Int)
        let severityIconPhoto = coder.decodeObject(forKey: PropertyKey.severityIconPhoto) as? UIImage
        let longDescription = coder.decodeObject(forKey: PropertyKey.longDescription) as? String
                
        self.init(shortDescription: shortDescription, photo: photo, status: status, severityIconPhoto: severityIconPhoto, longDescription: longDescription)
        
    }
    
    
    enum Severity: Int {
        case GREEN = 0
        case YELLOW = 1
        case RED = 2
    }
    
    //MARK: Properties
    var shortDescription: String
    var photo: UIImage?
    var status: Severity
    var severityIconPhoto: UIImage?
    var longDescription: String
    var containsPhoto: Bool
    var containsLongDescription: Bool

    
    //MARK: Types
    struct PropertyKey {
        static let shortDescription = "shortDescription"
        static let photo = "photo"
        static let status = "status"
        static let severityIconPhoto = "severityIconPhoto"
        static let longDescription = "longDescription"
    }
    
    
    //MARK: Initialization
    init?(shortDescription: String, photo: UIImage?, status: Severity?, severityIconPhoto: UIImage?, longDescription: String?, containsPhoto: Bool = false, containsLongDescription: Bool = false) {
        
        if shortDescription.isEmpty {
            return nil
        }
        
        self.shortDescription = shortDescription
        self.photo = photo
        self.status = status ?? Severity.GREEN
        self.longDescription = longDescription ?? ""
        self.containsPhoto = containsPhoto
        self.containsLongDescription = containsLongDescription
    
        
        if status == Severity.GREEN {
            self.severityIconPhoto = UIImage(named: "greenIcon")
        } else if status == Severity.YELLOW {
            self.severityIconPhoto = UIImage(named: "yellowIcon")
        } else {
            self.severityIconPhoto = UIImage(named: "redIcon")
        }
       
        if longDescription != nil {
            self.containsLongDescription = true
        }
        
        if photo != UIImage(named: "defaultPhoto") {
            self.containsPhoto = true
        }
    }

}
