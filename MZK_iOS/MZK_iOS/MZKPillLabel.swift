//
//  MZKPillLabel.swift
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 08/11/2017.
//  Copyright © 2017 Ondrej Vyhlidal. All rights reserved.
//

import UIKit

class MZKPillLabel: UILabel {
    
    /// The vertical padding to apply to the top and bottom of the view
    @IBInspectable var verticalPad: CGFloat = 2
    /// The horizontal padding to apply to the left and right of the view
    @IBInspectable var horizontalPad: CGFloat = 2
    
    func setup() {
        layer.cornerRadius = frame.height / 2
        clipsToBounds = true
        textAlignment = .center
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }
    
    override var intrinsicContentSize: CGSize {
        let superSize = super.intrinsicContentSize
        let newWidth = superSize.width + superSize.height + (2 * horizontalPad)
        let newHeight = superSize.height + (2 * verticalPad)
        let newSize = CGSize(width: newWidth, height: newHeight)
        return newSize
    }
    
}

