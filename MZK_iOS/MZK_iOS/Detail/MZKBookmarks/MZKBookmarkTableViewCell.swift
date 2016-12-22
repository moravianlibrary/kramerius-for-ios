//
//  MZKBookmarkTableViewCell.swift
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 20/11/2016.
//  Copyright © 2016 Ondrej Vyhlidal. All rights reserved.
//

import UIKit

class MZKBookmarkTableViewCell: UITableViewCell {

    @IBOutlet weak var bookmarkImageView: UIImageView!
    @IBOutlet weak var bookmarkLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
