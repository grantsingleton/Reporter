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
        coder.encode(editedPhoto, forKey: PropertyKey.editedPhoto)
        coder.encode(status.rawValue, forKey: PropertyKey.status)
        coder.encode(longDescription, forKey: PropertyKey.longDescription)
    }
    
    required convenience init?(coder: NSCoder) {
        
        guard let shortDescription = coder.decodeObject(forKey: PropertyKey.shortDescription) as? String else {
            os_log("Unable to decode the title for a content item", log: OSLog.default, type: .debug)
            return nil
        }
        let photo = coder.decodeObject(forKey: PropertyKey.photo) as? UIImage
        let editedPhoto = coder.decodeObject(forKey: PropertyKey.editedPhoto) as? UIImage
        let status = Severity(rawValue: coder.decodeInteger(forKey: PropertyKey.status) as Int)
        let longDescription = coder.decodeObject(forKey: PropertyKey.longDescription) as? String
                
        self.init(shortDescription: shortDescription, photo: photo, editedPhoto: editedPhoto, status: status, longDescription: longDescription)
        
    }
    
    
    enum Severity: Int {
        case GREEN = 0
        case YELLOW = 1
        case RED = 2
    }
    
    //MARK: Properties
    var shortDescription: String
    var photo: UIImage?
    var editedPhoto: UIImage?
    var status: Severity
    var longDescription: String
    var containsPhoto: Bool
    var containsLongDescription: Bool

    
    //MARK: Types
    struct PropertyKey {
        static let shortDescription = "shortDescription"
        static let photo = "photo"
        static let editedPhoto = "editedPhoto"
        static let status = "status"
        static let longDescription = "longDescription"
    }
    
    
    //MARK: Initialization
    init?(shortDescription: String, photo: UIImage?, editedPhoto: UIImage?, status: Severity?, longDescription: String?, containsPhoto: Bool = false, containsLongDescription: Bool = false) {
        
        if shortDescription.isEmpty {
            return nil
        }
        
        self.shortDescription = shortDescription
        self.photo = photo
        self.editedPhoto = editedPhoto
        self.status = status ?? Severity.GREEN
        self.longDescription = longDescription ?? ""
        self.containsPhoto = containsPhoto
        self.containsLongDescription = containsLongDescription
    
       
        if longDescription != nil {
            self.containsLongDescription = true
        }
        
        if photo != UIImage(named: "defaultPhoto") {
            self.containsPhoto = true
        }
    }

}
