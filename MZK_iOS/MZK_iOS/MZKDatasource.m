 //
//  MZKDatasource.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 20/04/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import "XMLReader.h"
#import <CoreGraphics/CoreGraphics.h>
#import "MZKDatasource.h"
#import "MZKItemResource.h"
#import "MZKPageObject.h"
#import "MZKCollectionItem.h"
#import "MZKCollectionItemResource.h"
#import "AppDelegate.h"

enum _downloadOperation{
    downloadItem,
    downloadChildren,
    downloadSiblings,
    downloadImageProperties,
    downloadMostRecent,
    downloadRecommended,
    downloadCollectionInfo,
    downloadCollectionItems,
};
typedef enum _downloadOperation downloadOperation;



@implementation MZKDatasource

-(id)init
{
    self = [super init];
    if (self) {
        [self checkAndSetBaseUrl];
    }
    
    return self;
}


-(void)getInfoAboutCollections
{
    [self checkAndSetBaseUrl];
    
    NSString *itemDataStr =@"/search/api/v5.0/vc";
    NSString *finalString = [NSString stringWithFormat:@"%@%@", self.baseStringURL, itemDataStr];
    NSURL *url = [[NSURL alloc] initWithString:finalString];
    
    [self downloadDataFromURL:url withOperation:downloadCollectionInfo];
}


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
-(void)getCollectionItems:(NSString *)collectionPID
{
    NSString *itemDataStr =[NSString stringWithFormat:@"/search/api/v5.0/search?q=collection:\"%@\" AND dostupnost:*public* AND (fedora.model:monograph OR fedora.model:periodical OR fedora.model:graphic OR fedora.model:archive OR fedora.model:manuscript OR fedora.model:map OR fedora.model:sheetmusic OR fedora.model:soundrecording)", collectionPID];
    
    [self checkAndSetBaseUrl];
    
    NSString *finalStringURL = [NSString stringWithFormat:@"%@%@", self.baseStringURL, itemDataStr];
    NSString *finalString  = [finalStringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [[NSURL alloc] initWithString:finalString];
    
    [self downloadDataFromURL:url withOperation:downloadCollectionItems];
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
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    MZKResourceItem *item = appDelegate.getDatasourceItem;
    if (!item) {
        NSLog(@"Default URL not set!");
    }
    self.baseStringURL = [NSString stringWithFormat:@"%@://%@", item.protocol, item.stringURL];
    
}



-(void)downloadFailed
{
    NSLog(@"Download Failed");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
    
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
    
     [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
    
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
    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
    
    
   
    return pages;
}

-(NSArray *)parseJSONDataForCollections:(NSData*)data error:(NSError *)error
{
    NSError *localError = nil;
    NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
    
    if (localError != nil) {
        error = localError;
        return nil;
    }
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    for (int i = 0; i<parsedObject.count; i++) {
        
        MZKCollectionItem *cItem = [MZKCollectionItem new];
        
        cItem.pid = [[parsedObject objectAtIndex:i] objectForKey:@"pid"];
        cItem.nameENG = [[[parsedObject objectAtIndex:i] objectForKey:@"descs"] objectForKey:@"en"];
        cItem.nameCZ = [[[parsedObject objectAtIndex:i] objectForKey:@"descs"] objectForKey:@"cs"];
        cItem.label =[[parsedObject objectAtIndex:i] objectForKey:@"label"];
       
        
        [results addObject:cItem];
        
    }
    
    if ([self.delegate respondsToSelector:@selector(collectionListLoaded:)]) {
        [self.delegate collectionListLoaded:[results copy]];
        NSLog(@"Collections count:%lu", (unsigned long)results.count);
    }
    
 
    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
    return results;
}

-(NSArray *)parseJSONDataForCollectionItems:(NSData*)data error:(NSError *)error
{
    NSError *localError = nil;
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
    
    if (localError != nil) {
        error = localError;
        return nil;
    }
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    NSInteger numberOfResults =[[[response objectForKey:@"response"] objectForKey:@"numFound"] integerValue];
    NSInteger start =[[[response objectForKey:@"response"] objectForKey:@"start"] integerValue];
    
    NSArray *parsedObject = [ [response objectForKey:@"response"] objectForKey:@"docs"];
    
    
    for (int i = 0; i<parsedObject.count; i++) {
        
        MZKCollectionItemResource *cItem = [MZKCollectionItemResource new];
        NSDictionary *itemDict =[parsedObject objectAtIndex:i];
        cItem.numFound = numberOfResults;
        cItem.start = start;
        cItem.pid = [itemDict objectForKey:@"PID"];
        cItem.datumStr = [itemDict objectForKey:@"datum_str"];
        cItem.documentCreator = [itemDict objectForKey:@"dc.creator"];
        cItem.title = [itemDict objectForKey:@"dc.title"];
        cItem.rootPid = [itemDict objectForKey:@"root_pid"];
        cItem.rootTitle =[itemDict objectForKey:@"root_title"];
        
        [results addObject:cItem];
        
    }
    
    if ([self.delegate respondsToSelector:@selector(collectionItemsLoaded:)]) {
        [self.delegate collectionItemsLoaded:[results copy]];
        NSLog(@"Collections count:%lu", (unsigned long)results.count);
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
    
    
    return results;
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

-(void)parseCollectionData:(NSData *)data error:(NSError *)error
{
    NSDictionary *dict = [XMLReader dictionaryForXMLData:data
                                                 options:XMLReaderOptionsProcessNamespaces
                                                   error:&error];
    
    NSDictionary *list = [dict objectForKey:@"IMAGE_PROPERTIES"];
    NSInteger width = [[list objectForKey:@"WIDTH"] integerValue];
    NSInteger height = [[list objectForKey:@"HEIGHT"] integerValue];

}


-(void)downloadDataFromURL:(NSURL *)strURL withOperation:(downloadOperation)operation
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:strURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
    
    if (operation ==downloadCollectionItems) {
         [req addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        NSLog(@"%@", req.allHTTPHeaderFields);;
    }
   
    
    NSLog(@"Request: %@, with operation:%u", [req description], operation);
    
    [NSURLConnection sendAsynchronousRequest:[req copy] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)  {
        
        if (error) {
            NSLog(@"Download failed with error:%@", [error debugDescription]);
            [self downloadFailed];
        } else {
            NSLog(@"Download sucessful with operation:%lu", (unsigned long)operation);

            switch (operation) {
                case downloadMostRecent:
                     [self parseJSONData:data error:error withOperation:operation];
                    break;
                    
                    case downloadRecommended:
                    [self parseJSONData:data error:error withOperation:operation];
                    break;
                    
                    case downloadItem:
                     [self parseJSONDataForDetail:data error:error];
                    break;
                case downloadChildren:
                    [self parseJSONDataForChildren:data error:error];
                    break;
                    
                case downloadImageProperties:
                    [self parseImagePropertiesWithData:data error:error];
                    break;
                    
                case downloadCollectionInfo:
                    [self parseJSONDataForCollections:data error:error];
                
                    break;
                case downloadCollectionItems:
                    [self parseJSONDataForCollectionItems:data error:error];
                
                default:
                    
                    
                    break;
            }
           
        }
    }];

}


@end
