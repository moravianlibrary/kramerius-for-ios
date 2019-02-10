//
//  MusicItemTableViewCell.swift
//  MZK_iOS
//
//  Created by Ondrej Vyhlidal on 30/04/2018.
//  Copyright © 2018 Ondrej Vyhlidal. All rights reserved.
//

import UIKit
protocol MusicTableViewCellDelegate: class {
    func play(item: MZKPageObject)
}

class MusicItemTableViewCell: UITableViewCell {
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var itemTimeLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!

    weak var delegate: MusicTableViewCellDelegate?

    private var item: MZKPageObject?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setup(withItem item: MZKPageObject) {
        self.item = item

        itemTitleLabel.text = item.title
    }

    @IBAction func playTapped(_ sender: Any) {
        guard let item = self.item else { return }
        delegate?.play(item: item)
    }
}
