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
#import "AppDelegate.h"

@implementation MZKPageObject

-(void)loadPageResolution
{
      
    NSString *finalString = [NSString stringWithFormat:@"%@/search/zoomify/%@/ImageProperties.xml",baseURL, _pid];
    NSURL *url = [[NSURL alloc] initWithString:finalString];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:120];
    NSLog(@"req:%@", req.description);
    [NSURLConnection sendAsynchronousRequest:req queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)  {
        
        if (error) {
            NSLog(@"Download failed with error:%@", [error debugDescription]);
            if ([self.delegate respondsToSelector:@selector(pageResolutionDownloadFailed)]) {
                [self.delegate pageResolutionDownloadFailed];
            }
            
        } else {
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
            if ([httpResponse statusCode] > 399) {
                NSError *error = [NSError errorWithDomain:@"HTTP Error" code:httpResponse.statusCode userInfo:@{@"response":httpResponse}];
                // Forward the error to webView:didFailLoadWithError: or other
                if ([self.delegate respondsToSelector:@selector(pageResolutionDownloadFailedWithError:)]) {
                    [self.delegate pageResolutionDownloadFailedWithError:error];
                    //error returned for ImageProperties.
                }
            }
            else{
                
                NSDictionary *dict = [XMLReader dictionaryForXMLData:data
                                                             options:XMLReaderOptionsProcessNamespaces
                                                               error:&error];
                if(dict)
                {
                    
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
    
    switch (self.model) {
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

@end
