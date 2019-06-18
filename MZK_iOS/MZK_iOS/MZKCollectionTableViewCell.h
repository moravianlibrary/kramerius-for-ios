//
//  MZKCollectionTableViewCell.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 13/09/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZKCollectionItem.h"

@interface MZKCollectionTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *collectionTitleLabel;
@property (nonatomic, strong) MZKCollectionItem *collectionItem;
@property (weak, nonatomic) IBOutlet UIImageView *collectionImageView;
@property (weak, nonatomic) IBOutlet UILabel *numberOfDocuments;
@property (weak, nonatomic) IBOutlet UILabel *longDescription;

@end
