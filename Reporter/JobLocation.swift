//
//  JobLocation.swift
//  Reporter
//
//  Created by Grant Singleton on 12/11/19.
//  Copyright © 2019 Grant Singleton. All rights reserved.
//

import Foundation

class JobLocation {
    
    //MARK: Properties
    var name: String
    var description: String
    var jobs: [Job]
    
    init(name: String, description: String, jobs: [Job]) {

        self.name = name
        self.description = description
        self.jobs = jobs
    }
}
