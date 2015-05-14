//
//  MZKItemTableViewCell.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 09/05/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZKItemResource.h"

@interface MZKItemTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *itemImage;
@property (weak, nonatomic) IBOutlet UILabel *itemName;
@property (weak, nonatomic) IBOutlet UILabel *itemInfo;

@property (weak, nonatomic) IBOutlet UIImageView *itemKindIcon;
@property (weak, nonatomic) IBOutlet UILabel *itemKind;

@property (nonatomic, strong) MZKItemResource *item;

@end
