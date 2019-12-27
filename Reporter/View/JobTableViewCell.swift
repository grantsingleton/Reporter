//
//  JobTableViewCell.swift
//  Reporter
//
//  Created by Grant Singleton on 11/23/19.
//  Copyright © 2019 Grant Singleton. All rights reserved.
//

import UIKit

class JobTableViewCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var jobLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
