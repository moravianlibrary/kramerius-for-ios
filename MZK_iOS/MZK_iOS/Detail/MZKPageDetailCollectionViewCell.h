//
//  MZKPageDetailCollectionViewCell.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 08/11/15.
//  Copyright © 2015 Ondrej Vyhlidal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZKPageObject.h"

@interface MZKPageDetailCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *pageThumbnail;
@property (weak, nonatomic) IBOutlet UILabel *pageNumber;
@property (nonatomic, weak) MZKPageObject *page;

@end
