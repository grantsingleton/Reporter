//
//  AttendanceTableViewCell.swift
//  Reporter
//
//  Created by Grant Singleton on 12/26/19.
//  Copyright © 2019 Grant Singleton. All rights reserved.
//

import UIKit

class AttendanceTableViewCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
