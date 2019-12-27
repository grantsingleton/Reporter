//
//  JobContentTableViewCell.swift
//  Reporter
//
//  Created by Grant Singleton on 11/24/19.
//  Copyright © 2019 Grant Singleton. All rights reserved.
//

import UIKit

class JobContentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var shortDescriptionLabel: UILabel!
    @IBOutlet weak var contentPhoto: UIImageView!
    @IBOutlet weak var severityIconPhoto: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
