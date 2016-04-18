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
    //_authors = [names copy];
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


#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_pid forKey:@"pid"];
    [coder encodeObject:_model forKey:@"model"];
    [coder encodeObject:_title forKey:@"title"];
    [coder encodeObject:[self getAuthorsStringRepresentation] forKey:@"authors"];
    [coder encodeObject:_rootPid forKey:@"rootPid"];
    [coder encodeObject:_rootTitle forKey:@"rootTitle"];
    [coder encodeObject:_context forKey:@"context"];
    [coder encodeObject:_collections forKey:@"collections"];
    [coder encodeObject:_zoom forKey:@"zoom"];
    [coder encodeObject:_issn forKey:@"issn"];
    [coder encodeBool:_datanode forKey:@"datanode"];
    [coder encodeObject:_policy forKey:@"policy"];
    [coder encodeObject:_datumStr forKey:@"datumStr"];
    [coder encodeObject:_lastOpened forKey:@"lastOpened"];
    [coder encodeObject:_indexLastOpenedPage forKey:@"indexLastOpenedPage"];

}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self != nil)
    {
        _pid = [coder decodeObjectForKey:@"pid"];
        _model = [coder decodeObjectForKey:@"model"];
        _title = [coder decodeObjectForKey:@"title"];
        _authors = [coder decodeObjectForKey:@"authors"];
        _rootTitle = [coder decodeObjectForKey:@"rootTitle"];
        _rootPid = [coder decodeObjectForKey:@"rootPid"];
        _context = [coder decodeObjectForKey:@"context"];
        _collections = [coder decodeObjectForKey:@"collections"];
        _zoom = [coder decodeObjectForKey:@"zoom"];
        _issn = [coder decodeObjectForKey:@"issn"];
        _datanode = [coder decodeBoolForKey:@"datanode"];
        _policy = [coder decodeObjectForKey:@"policy"];
        _datumStr = [coder decodeObjectForKey:@"datumStr"];
        _lastOpened = [coder decodeObjectForKey:@"lastOpened"];
        _indexLastOpenedPage = [coder decodeObjectForKey:@"indexLastOpenedPage"];
       
    }
    return self;
}

@end
