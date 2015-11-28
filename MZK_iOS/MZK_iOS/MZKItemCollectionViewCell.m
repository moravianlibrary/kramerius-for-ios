//
//  MZKItemCollectionViewCell.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 14/10/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKItemCollectionViewCell.h"
#import "MZKConstants.h"

@implementation MZKItemCollectionViewCell
-(void)awakeFromNib
{
    [super awakeFromNib];
}

-(void)prepareForReuse
{
    _item = nil;
    _pObject = nil;
}

-(void)setPObject:(MZKPageObject *)pObject
{
    _pObject = pObject;
    [self setModelImage:_pObject.model];
}

-(void)setItem:(MZKItemResource *)item
{
    _item = item;
    [self setModelImage:_item.model];
    
}

-(void)setModelImage:(NSString *)model
{
    NSString *itemTypeIconImg;
    if ([model isEqualToString:kMonograph]) {
        itemTypeIconImg = @"ic_book_green";
    }
    else if ([model isEqualToString:kPeriodical] || [model rangeOfString:@"periodical"].location != NSNotFound)
    {
        itemTypeIconImg = @"ic_periodical_green";
        
    }
    else if ([model isEqualToString:kGraphic])
    {
        itemTypeIconImg = @"ic_graphic_green";
        
    }
    else if ([model isEqualToString:kArchive])
    {
        itemTypeIconImg = @"ic_archive_green";
    }
    else if ([model isEqualToString:kManuscript])
    {
        itemTypeIconImg = @"ic_manuscript_green";
    }
    else if ([model isEqualToString:kMap])
    {
        itemTypeIconImg = @"ic_map_green";
    }
    else if ([model isEqualToString:kSheetmusic])
    {
        itemTypeIconImg = @"ic_sheetmusic_green";
        
    }
    else if ([model isEqualToString:kSoundRecording] ||[model rangeOfString:@"sound"].location != NSNotFound)
    {
        itemTypeIconImg = @"ic_music_green";
    }
    
    [_itemTypeIcon setImage:[UIImage imageNamed:itemTypeIconImg]];

}

@end
