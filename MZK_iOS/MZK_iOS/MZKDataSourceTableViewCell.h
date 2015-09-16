//
//  MZKDataSourceTableViewCell.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 24/08/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MZKDataSourceTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *libraryIcon;
@property (weak, nonatomic) IBOutlet UILabel *libraryName;
@property (weak, nonatomic) IBOutlet UILabel *libraryURL;

@end
