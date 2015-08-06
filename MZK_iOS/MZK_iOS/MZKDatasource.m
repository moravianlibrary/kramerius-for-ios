 //
//  MZKDatasource.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 20/04/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKDatasource.h"
#import "MZKItemResource.h"
#import "MZKPageObject.h"
#import "XMLReader.h"
#import <CoreGraphics/CoreGraphics.h>


enum _downloadOperation{
    downloadItem,
    downloadChildren,
    downloadSiblings,
    downloadImageProperties,
    downloadMostRecent,
    downloadRecommended,
};
typedef enum _downloadOperation downloadOperation;


@implementation MZKDatasource





-(void)getChildrenForItem:(NSString *)pid
{
    NSString *itemDataStr =[NSString stringWithFormat:@"/search/api/v5.0/item/%@/children", pid];
    [self checkAndSetBaseUrl];
    
    NSString *finalString = [NSString stringWithFormat:@"%@%@", self.baseStringURL, itemDataStr];
    NSURL *url = [[NSURL alloc] initWithString:finalString];
    
    [self downloadDataFromURL:url withOperation:downloadChildren];
}

-(void)getItem:(NSString *)pid
{
    NSString *itemDataStr =[NSString stringWithFormat:@"/search/api/v5.0/item/%@", pid];
    [self checkAndSetBaseUrl];
    
    NSString *finalString = [NSString stringWithFormat:@"%@%@", self.baseStringURL, itemDataStr];
    NSURL *url = [[NSURL alloc] initWithString:finalString];
    
    [self downloadDataFromURL:url withOperation:downloadItem];

}

-(void)getSiblingsForItem:(NSString *)pid
{
    
}

-(void)getImagePropertiesForPageItem:(NSString *)pid
{
    NSString *finalString = [NSString stringWithFormat:@"http://kramerius.mzk.cz/search/zoomify/%@/ImageProperties.xml", pid];
    NSURL *url = [[NSURL alloc] initWithString:finalString];
    
    [self downloadDataFromURL:url withOperation:downloadImageProperties];
}

-(void)getMostRecent
{
    NSString *recent = @"/search/api/v5.0/feed/custom";
    [self checkAndSetBaseUrl];
    
    NSString *finalString = [NSString stringWithFormat:@"%@%@", self.baseStringURL, recent];

    NSURL *url = [[NSURL alloc] initWithString:finalString];
    
    [self downloadDataFromURL:url withOperation:downloadMostRecent];
    
    
}

-(void)getRecommended
{
    NSString *desired = @"/search/api/v5.0/feed/mostdesirable";
    [self checkAndSetBaseUrl];
    
    NSString *finalString = [NSString stringWithFormat:@"%@%@", self.baseStringURL, desired];
    NSURL *url = [[NSURL alloc] initWithString:finalString];
    
    [self downloadDataFromURL:url withOperation:downloadRecommended];

}

#pragma mark - privateMethods
-(void)checkAndSetBaseUrl
{
    if (!self.baseStringURL) {
       self.baseStringURL = @"http://kramerius.mzk.cz"; //search/api/v5.0/feed/mostdesirable
    }
}

-(void)downloadFailed
{
    NSLog(@"Download Failed");
    
}

-(NSArray *)parseJSONData:(NSData*)data error:(NSError *)error withOperation:(downloadOperation)operation
{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
    
    if (localError != nil) {
        error = localError;
        return nil;
    }
    
    NSArray *tmpObjects = [parsedObject objectForKey:@"data"];
    
     NSMutableArray *results = [[NSMutableArray alloc] init];
    
    for (int i; i<tmpObjects.count; i++) {
    
        NSDictionary *tmpDataObject = [tmpObjects objectAtIndex:i];
        if (![[tmpDataObject allKeys] containsObject:@"exception"]) {
             [results addObject:[self parseObjectFromDictionary:tmpDataObject]];
        }
       
    }
    
    switch (operation) {
        case downloadMostRecent:
    [self.delegate dataLoaded:results withKey:@"recent"];
            break;
        case downloadRecommended:
      [self.delegate dataLoaded:results withKey:@"reccomended"];
            break;
            
        default:
            break;
    }
    
    
    return results;
}

-(NSArray *)parseJSONDataForDetail:(NSData*)data error:(NSError *)error
{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
    
    if (localError != nil) {
        error = localError;
        return nil;
    }
     NSMutableArray *results = [[NSMutableArray alloc] init];
    MZKItemResource *resItem;
    
    [self.delegate detailForItemLoaded:resItem];
    
    return results;
}

-(NSArray *)parseJSONDataForChildren:(NSData*)data error:(NSError *)error
{
    NSError *localError = nil;
    NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
    
    if (localError != nil) {
        error = localError;
        return nil;
    }
    
    NSMutableArray *pages = [NSMutableArray new];
    
    for (int i = 0; i<parsedObject.count; i++) {
        
         MZKPageObject *page = [MZKPageObject new];
        
        page.pid = [[parsedObject objectAtIndex:i] objectForKey:@"pid"];
        page.model = [[parsedObject objectAtIndex:i] objectForKey:@"model"];
        page.rootPid =  [[parsedObject objectAtIndex:i] objectForKey:@"root_pid"];
        page.rootTitle =  [[parsedObject objectAtIndex:i] objectForKey:@"root_title"];
        page.policy =  [[parsedObject objectAtIndex:i] objectForKey:@"public"];
        page.page =  [[[[parsedObject objectAtIndex:i] objectForKey:@"details"] objectForKey:@"pagenumber"] integerValue];
        page.type = [[[parsedObject objectAtIndex:i] objectForKey:@"details"] objectForKey:@"type"];
        page.title = [[parsedObject objectAtIndex:i] objectForKey:@"title"];
        
        [pages addObject:page];
        
    }
    
    if ([self.delegate respondsToSelector:@selector(pagesLoadedForItem:)]) {
        [self.delegate pagesLoadedForItem:pages];
    }
    
    
   
    return pages;
}

-(MZKItemResource *)parseObjectFromDictionary:(NSDictionary *)rawData
{
    MZKItemResource *newItem = [MZKItemResource new];
    
    newItem.pid = [rawData objectForKey:@"pid"];
    newItem.model = [rawData objectForKey:@"model"];
    newItem.issn = [rawData objectForKey:@"issn"];
    newItem.datumStr = [rawData objectForKey:@"datumStr"];
    
      newItem.rootPid = [rawData objectForKey:@"root_pid"];
    
    if ([[rawData objectForKey:@"title"] isKindOfClass:[NSString class]]) {
         newItem.title = [rawData objectForKey:@"title"];
    }
    
      newItem.rootTitle = [rawData objectForKey:@"root_title"];
      newItem.policy = [rawData objectForKey:@"public"];
    
    
    
    [rawData objectForKey:@""];
    
    return newItem;
}


-(CGRect)parseImagePropertiesWithData:(NSData *)data error:(NSError *)error
{
    NSDictionary *dict = [XMLReader dictionaryForXMLData:data
                                                 options:XMLReaderOptionsProcessNamespaces
                                                   error:&error];
    
    NSDictionary *list = [dict objectForKey:@"IMAGE_PROPERTIES"];
    NSInteger width = [[list objectForKey:@"WIDTH"] integerValue];
    NSInteger height = [[list objectForKey:@"HEIGHT"] integerValue];
    
    return CGRectMake(0,0,width,height);
    
}


-(void)downloadDataFromURL:(NSURL *)strURL withOperation:(downloadOperation)operation
{
    //change this implementation
    NSURLRequest *req = [NSURLRequest requestWithURL:strURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:120];
    [NSURLConnection sendAsynchronousRequest:req queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)  {
        
        if (error) {
            NSLog(@"Download failed with error:%@", [error debugDescription]);
            [self downloadFailed];
        } else {
            NSLog(@"operation:%lu", (unsigned long)operation);
            switch (operation) {
                case downloadMostRecent:
                     [self parseJSONData:data error:error withOperation:operation];
                    break;
                    
                    case downloadRecommended:
                    [self parseJSONData:data error:error withOperation:operation];
                    break;
                    
                    case downloadItem:
                     [self parseJSONDataForDetail:data error:error];
                case downloadChildren:
                    [self parseJSONDataForChildren:data error:error];
                    break;
                    
                case downloadImageProperties:
                    [self parseImagePropertiesWithData:data error:error];
                    break;
                default:
                    break;
            }
           
        }
    }];

}


@end
