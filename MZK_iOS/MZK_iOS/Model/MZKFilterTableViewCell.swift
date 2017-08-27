//
//  MZKFilterCellTableViewCell.swift
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 27/08/2017.
//  Copyright © 2017 Ondrej Vyhlidal. All rights reserved.
//

import UIKit

class MZKFilterTableViewCell: UITableViewCell {

    @IBOutlet weak var filterTitleLabel: UILabel!
    @IBOutlet weak var filterTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
