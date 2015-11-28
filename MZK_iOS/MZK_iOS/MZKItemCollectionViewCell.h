//
//  MZKItemCollectionViewCell.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 14/10/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZKItemResource.h"
#import "MZKPageObject.h"

@interface MZKItemCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *itemName;
@property (weak, nonatomic) IBOutlet UIImageView *itemImage;
@property (weak, nonatomic) IBOutlet UILabel *itemAuthors;
@property (weak, nonatomic) IBOutlet UIImageView *itemTypeIcon;
@property (weak, nonatomic) IBOutlet UILabel *itemType;
@property (nonatomic, strong) MZKItemResource *item;
@property (nonatomic, strong) MZKPageObject *pObject;

-(void)setItem:(MZKItemResource *)item;
-(void)setPObject:(MZKPageObject *)pObject;

@end
