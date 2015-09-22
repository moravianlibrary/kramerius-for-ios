//
//  MZKDetailCollectionViewCell.m
//  
//
//  Created by OndrejVyhlidal on 14/09/15.
//
//

#import "MZKDetailCollectionViewCell.h"

@implementation MZKDetailCollectionViewCell

-(void)prepareForReuse
{
    _itemIconImageview.image = nil;
    _itemTypeIcon.image = nil;
}

@end
