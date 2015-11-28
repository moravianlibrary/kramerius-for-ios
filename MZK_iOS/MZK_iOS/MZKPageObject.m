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

@implementation MZKPageObject

-(void)loadPageResolution
{
    NSString *finalString = [NSString stringWithFormat:@"http://kramerius.mzk.cz/search/zoomify/%@/ImageProperties.xml", _pid];
    NSURL *url = [[NSURL alloc] initWithString:finalString];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:120];
    [NSURLConnection sendAsynchronousRequest:req queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)  {
        
        if (error) {
            NSLog(@"Download failed with error:%@", [error debugDescription]);
            
        } else {
            NSDictionary *dict = [XMLReader dictionaryForXMLData:data
                                                         options:XMLReaderOptionsProcessNamespaces
                                                           error:&error];
            
            NSDictionary *list = [dict objectForKey:@"IMAGE_PROPERTIES"];
            NSInteger width = [[list objectForKey:@"WIDTH"] integerValue];
            NSInteger height = [[list objectForKey:@"HEIGHT"] integerValue];
            
            self.height = height;
            self.width = width;
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



@end
