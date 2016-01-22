//
//  MZKPageObject.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 15/05/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKPageObject.h"
#import "XMLReader.h"
#import <CoreGraphics/CoreGraphics.h>
#import "MZKConstants.h"

@implementation MZKPageObject

-(void)loadPageResolution
{
    NSString *finalString = [NSString stringWithFormat:@"http://kramerius.mzk.cz/search/zoomify/%@/ImageProperties.xml", _pid];
    NSURL *url = [[NSURL alloc] initWithString:finalString];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:120];
    NSLog(@"req:%@", req.description);
    [NSURLConnection sendAsynchronousRequest:req queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)  {
        
        if (error) {
            NSLog(@"Download failed with error:%@", [error debugDescription]);
            
        } else {
            NSDictionary *dict = [XMLReader dictionaryForXMLData:data
                                                         options:XMLReaderOptionsProcessNamespaces
                                                           error:&error];
            if(!dict)
            {
                if ([self.delegate respondsToSelector:@selector(pageNotAvailable)]) {
                    [self.delegate pageNotAvailable];
                    NSLog(@"Resolution Skipped, not present");
                    return ;
                }
            }
            
            NSDictionary *list = [dict objectForKey:@"IMAGE_PROPERTIES"];
            NSInteger width = [[list objectForKey:@"WIDTH"] integerValue];
            NSInteger height = [[list objectForKey:@"HEIGHT"] integerValue];
            
            self.height = height;
            self.width = width;
            
            if (!self.width) {
                NSLog(@"Page Resolution not laoded");
                self.width = 400;
            }
            if (!self.height) {
                self.height = 640;
            }
            if ([self.delegate respondsToSelector:@selector(pageLoadedForItem:)]) {
                __weak typeof(self) welf = self;
                
                [self.delegate pageLoadedForItem:welf];
            }
        }
    }];

    
}

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
