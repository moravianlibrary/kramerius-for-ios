//
//  MZKFilterTableViewCell.swift
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 03/10/2017.
//  Copyright © 2017 Ondrej Vyhlidal. All rights reserved.
//

import UIKit

class MZKFilterTableViewCell: UITableViewCell {
    @IBOutlet weak var filterCountLabel: UILabel!
    @IBOutlet weak var filterTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
