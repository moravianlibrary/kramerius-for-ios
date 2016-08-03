//
//  MZKSearchTableViewCell.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 25/07/16.
//  Copyright © 2016 Ondrej Vyhlidal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MZKSearchTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *searchTypeIcon;
@property (weak, nonatomic) IBOutlet UILabel *searchHintLabel;

@end
