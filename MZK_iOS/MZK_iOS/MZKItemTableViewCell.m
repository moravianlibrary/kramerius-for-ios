//
//  MZKItemTableViewCell.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 09/05/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKItemTableViewCell.h"

@implementation MZKItemTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)prepareForReuse
{
    [super prepareForReuse];
    self.item = nil;
    self.itemImage = nil;
    self.itemKindIcon = nil;
}

@end
