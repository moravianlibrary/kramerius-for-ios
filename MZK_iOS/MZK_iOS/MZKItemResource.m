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
    
    switch (_model) {
        case Monograph:
            localizedItemType = kDocumentMonograph;
            break;
            
        case Periodical:
            localizedItemType = kDocumentPeriodical;
            break;
            
        case PeriodicalItem:
            localizedItemType = kDocumentPeriodicalItem;
            break;
            
        case PeriodicalVolume:
            localizedItemType = kDocumentPeriodicalVolume;
            break;
            
        case Page:
            localizedItemType = kDocumentPage;
            break;
            
        case Map:
            localizedItemType = kDocumentMap;
            break;
            
        case Graphic:
            localizedItemType = kDocumentGraphic;
            break;
            
        case Archive:
            localizedItemType = kDocumentArchive;
            break;
            
        case Article:
            localizedItemType = kDocumentArticle;
            break;
            
        case Manuscript:
            localizedItemType = kDocumentManuscript;
            break;
            
        case Supplement:
            localizedItemType = kDocumentSupplement;
            break;
            
        case InternalPart:
            localizedItemType = kDocumentInternalpart;
            break;
            
        case Sheetmusic:
            localizedItemType = kDocumentSheetmusic;
            break;
            
        case SoundUnit:
            localizedItemType = kDocumentSoundUnit;
            break;
            
        case SoundRecording:
            localizedItemType = kDocumentSoundRecording;
            break;
            
        case Track:
            localizedItemType = kDocumentTrack;
            break;
            
        case  Unknown:
            localizedItemType = kDocumentUnknown;
            break;
            
            
        default:
            break;
    }
    return localizedItemType;
}


#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_pid forKey:@"pid"];
    [coder encodeObject:[NSNumber numberWithInt:_model] forKey:@"model"];
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
        _model = [[coder decodeObjectForKey:@"model"] intValue];
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

- (BOOL)isModelMusic {
    switch (self.model) {
        case Sheetmusic:
        case Track:
        case SoundUnit:
        case SoundRecording:
            return YES;
        default:
            return NO;
    }
}

@end
