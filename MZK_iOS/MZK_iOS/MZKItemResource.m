//
//  MZKItemResource.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 20/04/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKItemResource.h"
#import "MZKConstants.h"

@implementation MZKItemResource

-(NSString *)getAuthorsStringRepresentation
{
     NSMutableString *names = [NSMutableString new];
    if (_author) {
        for (NSString *author in _author) {
            
            [names appendString:author];
            if (![author isEqualToString:[_author lastObject]]) {
                [names appendString:@", "];
            }
        }
    }
    return [names copy];
}

-(NSString *)getLocalizedItemType
{
    NSString *localizedItemType =kDocumentUnknown;
    
    if ([self.model caseInsensitiveCompare:kTrack] == NSOrderedSame) {
        localizedItemType = kDocumentTrack;
    }
    
    if ([self.model caseInsensitiveCompare:kSoundRecording] == NSOrderedSame) {
        localizedItemType = kDocumentSoundRecording;
    }
    
    if ([self.model caseInsensitiveCompare:kVirtualCollection] == NSOrderedSame) {
        //localizedItemType = kdocu;
    }
    
    if ([self.model caseInsensitiveCompare:kMonograph] == NSOrderedSame) {
        localizedItemType = kDocumentMonograph;
    }
    
    if ([self.model caseInsensitiveCompare:kPeriodical] == NSOrderedSame) {
        localizedItemType = kDocumentPeriodical;
    }
    
    if ([self.model caseInsensitiveCompare:kPeriodicalItem] == NSOrderedSame) {
        localizedItemType = kDocumentPeriodicalItem;
    }
    
    if ([self.model caseInsensitiveCompare:kPeriodicalVolume] == NSOrderedSame) {
        localizedItemType = kDocumentPeriodicalVolume;
    }
    
    if ([self.model caseInsensitiveCompare:kGraphic] == NSOrderedSame) {
        localizedItemType = kDocumentGraphic;
    }
    
    if ([self.model caseInsensitiveCompare:kManuscript] == NSOrderedSame) {
        localizedItemType = kDocumentManuscript;
    }
    
    if ([self.model caseInsensitiveCompare:kSheetmusic] == NSOrderedSame) {
        localizedItemType = kDocumentSheetmusic;
    }
    
    if ([self.model caseInsensitiveCompare:kMap] == NSOrderedSame) {
        localizedItemType = kDocumentMap;
    }
    
    if ([self.model caseInsensitiveCompare:kPage] == NSOrderedSame) {
        localizedItemType = kDocumentPage;
    }
    
    if ([self.model caseInsensitiveCompare:kPhoto] == NSOrderedSame) {
        localizedItemType = kDocumentUnknown;
    }
    
    if ([self.model caseInsensitiveCompare:kArchive] == NSOrderedSame) {
        localizedItemType = kDocumentArchive;
    }
    
    if ([self.model caseInsensitiveCompare:kBook] == NSOrderedSame) {
        localizedItemType = kDocumentUnknown;
    }
    
    if ([self.model caseInsensitiveCompare:kManuscript] == NSOrderedSame) {
        localizedItemType = kDocumentManuscript;
    }
    
    if ([self.model caseInsensitiveCompare:kSoundUnit] == NSOrderedSame) {
        localizedItemType = kDocumentSoundUnit;
    }

    return localizedItemType;
}

@end
