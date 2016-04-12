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
#import "MZKConstants.h"

enum _downloadOperation{
    downloadItem,
    downloadChildren,
    downloadSiblings,
    downloadImageProperties,
    downloadMostRecent,
    downloadRecommended,
    downloadCollectionInfo,
    downloadCollectionItems,
    search,
    searchHints,
    searchFullResults,
};
typedef enum _downloadOperation downloadOperation;



@implementation MZKDatasource
{
    NSURLRequest *_lastRequest;
    NSURL *_lastURL;
    downloadOperation lastOperation;
    
}

-(id)init
{
    self = [super init];
    if (self) {
        [self checkAndSetBaseUrl];
    }
    
    return self;
}

-(void)resendLastRequest
{
    if (_lastURL && lastOperation) {
        [self downloadDataFromURL:_lastURL withOperation:lastOperation];
    }
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

-(void)getCollectionItems:(NSString *)collectionPID withNumberOfResults:(NSInteger)numberOfResults
{
    if (numberOfResults != 0) {
        NSString *itemDataStr =[NSString stringWithFormat:@"/search/api/v5.0/search?q=collection:\"%@\" AND dostupnost:*public* AND (fedora.model:monograph OR fedora.model:periodical OR fedora.model:graphic OR fedora.model:archive OR fedora.model:manuscript OR fedora.model:map OR fedora.model:sheetmusic OR fedora.model:soundrecording)&rows=%ld", collectionPID, (long)numberOfResults];
        
        [self checkAndSetBaseUrl];
        NSString *finalStringURL = [NSString stringWithFormat:@"%@%@", self.baseStringURL, itemDataStr];
        NSString *finalString  = [finalStringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [[NSURL alloc] initWithString:finalString];
        
        [self downloadDataFromURL:url withOperation:downloadCollectionItems];
    }
    else
    {
        [self getCollectionItems:collectionPID];
    }
   
   
}

-(void)getCollectionItems:(NSString *)collectionPID
{
    NSString *itemDataStr =[NSString stringWithFormat:@"/search/api/v5.0/search?q=collection:\"%@\" AND dostupnost:*public* AND (fedora.model:monograph OR fedora.model:periodical OR fedora.model:graphic OR fedora.model:archive OR fedora.model:manuscript OR fedora.model:map OR fedora.model:sheetmusic OR fedora.model:soundrecording)&rows=30", collectionPID];
    
    [self checkAndSetBaseUrl];
    
    NSString *finalStringURL = [NSString stringWithFormat:@"%@%@", self.baseStringURL, itemDataStr];
    NSString *finalString  = [finalStringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [[NSURL alloc] initWithString:finalString];
    
    [self downloadDataFromURL:url withOperation:downloadCollectionItems];
}

-(void)getCollectionItems:(NSString *)collectionPID withRangeFrom:(NSInteger)from numberOfItems:(NSInteger)numberOfItems
{
    NSString *itemDataStr =[NSString stringWithFormat:@"/search/api/v5.0/search?q=collection:\"%@\" AND dostupnost:*public* AND (fedora.model:monograph OR fedora.model:periodical OR fedora.model:graphic OR fedora.model:archive OR fedora.model:manuscript OR fedora.model:map OR fedora.model:sheetmusic OR fedora.model:soundrecording)&start=%ld&rows=%ld", collectionPID, from, numberOfItems];
    
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
    
    BOOL showOnlyPublic = [[[NSUserDefaults standardUserDefaults] objectForKey:kSettingsShowOnlyPublicDocuments] boolValue];
    NSString *recent = showOnlyPublic ? @"/search/api/v5.0/feed/newest?policy=public" : @"/search/api/v5.0/feed/newest";
    
    [self checkAndSetBaseUrl];
    
    NSString *finalString = [NSString stringWithFormat:@"%@%@", self.baseStringURL, recent];
    
    NSURL *url = [[NSURL alloc] initWithString:finalString];
    
    [self downloadDataFromURL:url withOperation:downloadMostRecent];
    
    
}

-(void)getRecommended
{
    BOOL showOnlyPublic = [[[NSUserDefaults standardUserDefaults] objectForKey:kSettingsShowOnlyPublicDocuments] boolValue];
    NSString *desired = showOnlyPublic ? @"/search/api/v5.0/feed/custom?policy=public" : @"/search/api/v5.0/feed/custom";

    [self checkAndSetBaseUrl];
    
    NSString *finalString = [NSString stringWithFormat:@"%@%@", self.baseStringURL, desired];
    NSURL *url = [[NSURL alloc] initWithString:finalString];
    
    [self downloadDataFromURL:url withOperation:downloadRecommended];
    
}

-(void)getSearchResultsAsHints:(NSString *)searchString
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *recent = [defaults objectForKey:kSettingsShowOnlyPublicDocuments];
    BOOL visible = NO;
    if (recent) {
        visible= [recent boolValue];
    }

    NSString *sq = [NSString stringWithFormat:@"/search/api/v5.0/search/?fl=PID,dc.title&q=dc.title:%@*+AND+%@(fedora.model:monograph+OR+fedora.model:periodical+OR+fedora.model:map+OR+fedora.model:soundrecording+OR+fedora.model:graphic+OR+fedora.model:archive+OR+fedora.model:manuscript)&rows=30", [searchString lowercaseString],visible?@"dostupnost:*public*+AND+":@""];
    
   
    [self checkAndSetBaseUrl];
    
    NSString *finalString = [NSString stringWithFormat:@"%@%@", self.baseStringURL, sq];
    NSURL *url = [[NSURL alloc] initWithString:finalString];
    
    [self downloadDataFromURL:url withOperation:searchHints];
}

-(void)getFullSearchResults:(NSString *)searchString
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *recent = [defaults objectForKey:kSettingsShowOnlyPublicDocuments];
    BOOL visible = NO;
    if (recent) {
        visible= [recent boolValue];
    }
    
    NSString *sq = [NSString stringWithFormat:@"/search/api/v5.0/search/?q=dc.title:%@*+AND+%@(fedora.model:monograph+OR+fedora.model:periodical+OR+fedora.model:map+OR+fedora.model:soundrecording+OR+fedora.model:graphic+OR+fedora.model:archive+OR+fedora.model:manuscript)&rows=30", [searchString lowercaseString],visible?@"dostupnost:*public*+AND":@""];
    
    [self checkAndSetBaseUrl];
    
    NSString *finalString = [NSString stringWithFormat:@"%@%@", self.baseStringURL, sq];
    finalString = [finalString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [[NSURL alloc] initWithString:finalString];
    
    [self downloadDataFromURL:url withOperation:searchFullResults];
}



-(void)getSearchResults:(NSString *)searchQuery
{
    NSString *sq = [NSString stringWithFormat:@"/search/api/v5.0/search?q=%@", [searchQuery lowercaseString]];
    if (!searchQuery) {
        sq = @"/search/api/v5.0/search?q=*:*";
    }
    [self checkAndSetBaseUrl];
    
    NSString *finalString = [NSString stringWithFormat:@"%@%@", self.baseStringURL, sq];
    NSURL *url = [[NSURL alloc] initWithString:finalString];
    
    [self downloadDataFromURL:url withOperation:search];
}

#pragma mark - privateMethods
-(void)checkAndSetBaseUrl
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    MZKResourceItem *item = appDelegate.getDatasourceItem;
    if (!item) {
       // NSLog(@"Default URL not set!");
    }
    self.baseStringURL = [NSString stringWithFormat:@"%@://%@", item.protocol, item.stringURL];
}



-(void)downloadFailedWithError:(NSError *)error
{
    NSLog(@"Download Failed with error");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
    
    if ([self.delegate respondsToSelector:@selector(downloadFailedWithError:)]) {
        [self.delegate downloadFailedWithError:error];
    }
    
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
    
    NSMutableArray *results = [NSMutableArray new];
    
    for (int i =0; i<tmpObjects.count; i++) {
        
        NSDictionary *tmpDataObject = [tmpObjects objectAtIndex:i];
        if (![[tmpDataObject allKeys] containsObject:@"exception"]) {
            [results addObject:[self parseObjectFromDictionary:tmpDataObject]];
        }
    }
    
    switch (operation) {
        case downloadMostRecent:
            [self.delegate dataLoaded:results withKey:kRecent];
            break;
        case downloadRecommended:
            [self.delegate dataLoaded:results withKey:kRecommended];
            break;
            
        default:
            break;
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
    
    return results;
}

-(void)parseJSONDataForDetail:(NSData*)data error:(NSError *)error
{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
    
    if (localError != nil) {
        error = localError;
        return;
    }
    MZKItemResource *resItem = [self parseObjectFromDictionary:parsedObject];
    if ([self.delegate respondsToSelector:@selector(detailForItemLoaded:)]) {
        [self.delegate detailForItemLoaded:resItem];
    }
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
        NSDictionary *currentObject =[parsedObject objectAtIndex:i];
        NSString *model = [currentObject objectForKey:@"model"];
        if (![model isEqualToString:@"internalpart"]) {
            
            MZKPageObject *page = [MZKPageObject new];
            page.pid = [currentObject objectForKey:@"pid"];
            page.model = [currentObject objectForKey:@"model"];
            page.author = [currentObject objectForKey:@"author"];
            page.rootPid =  [currentObject objectForKey:@"root_pid"];
            page.rootTitle =  [currentObject objectForKey:@"root_title"];
            page.policy = [currentObject objectForKey:@"policy"];
            
            NSString *pageTitle = nil;
            if ([[currentObject objectForKey:@"title"] isKindOfClass:[NSArray class]]) {
                NSArray *objArray = [currentObject objectForKey:@"title"];
                
                if ([[objArray objectAtIndex:0] isKindOfClass:[NSString class]]) {
                    pageTitle = [objArray objectAtIndex:0];
                }
                else if ([[objArray objectAtIndex:0] isKindOfClass:[NSNumber class]])
                {
                    NSNumber *number = [objArray objectAtIndex:0];
                    
                    pageTitle = [number stringValue];
                }
                
            }
            else if ([[currentObject objectForKey:@"title"] isKindOfClass:[NSString class]])
            {
                pageTitle = [currentObject objectForKey:@"title"];
            }
            
            page.title = pageTitle;
                        
            if([currentObject objectForKey:@"details"]){
                page.type = [[currentObject objectForKey:@"details"] objectForKey:@"type"];
                
                if ([[[currentObject objectForKey:@"details"] objectForKey:@"year"] isKindOfClass:[NSString class]]) {
                    page.year =[[currentObject objectForKey:@"details"] objectForKey:@"year"];
                }
                
                if ([[[currentObject objectForKey:@"details"] objectForKey:@"date"] isKindOfClass:[NSString class]]) {
                    page.date =[[currentObject objectForKey:@"details"] objectForKey:@"date"];
                }
                
                if ([[[currentObject objectForKey:@"details"] objectForKey:@"volumeNumber"] isKindOfClass:[NSString class]]) {
                    page.volumeNumber =[[currentObject objectForKey:@"details"] objectForKey:@"volumeNumber"];
                }
                
                if ([[[currentObject objectForKey:@"details"] objectForKey:@"issueNumber"] isKindOfClass:[NSString class]]) {
                    page.issueNumber =[[currentObject objectForKey:@"details"] objectForKey:@"issueNumber"];
                    if ([page.issueNumber isEqualToString:@""]) {
                        if ([[[currentObject objectForKey:@"details"] objectForKey:@"partNumber"] isKindOfClass:[NSString class]]) {
                            page.issueNumber =[[currentObject objectForKey:@"details"] objectForKey:@"partNumber"];
                        }
                    }
                }
                
                
            }
            
            page.datanode= [[currentObject objectForKey:@"datanode"] boolValue];
            
            
            [pages addObject:page];
        }
    }
    
    if(pages.count >0)
    {
        if ([self.delegate respondsToSelector:@selector(pagesLoadedForItem:)]) {
            [self.delegate pagesLoadedForItem:pages];
        }
        else if ([self.delegate respondsToSelector:@selector(childrenForItemLoaded:)])
        {
            [self.delegate childrenForItemLoaded:pages];
        }
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
    NSLog(@"Number of Results for Collections: %ld", (long)numberOfResults);
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
        cItem.rootPid = [itemDict objectForKey:@"root_pid"] ;
        cItem.rootTitle =[itemDict objectForKey:@"root_title"];
        cItem.policy = [itemDict objectForKey:@"dostupnost"];
        
        [results addObject:cItem];
        
    }
        
    if ([self.delegate respondsToSelector:@selector(collectionItemsLoaded:)]) {
        [self.delegate collectionItemsLoaded:[results copy]];
       
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
    
    
    return results;
}

-(NSDictionary *)parseJSONdataForSearchHints:(NSData *)data error:(NSError *)error
{
    NSError *localError = nil;
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
    
    if (localError != nil) {
        error = localError;
        return nil;
    }
    NSInteger numberOfResults =[[[response objectForKey:@"response"] objectForKey:@"numFound"] integerValue];
    NSInteger start =[[[response objectForKey:@"response"] objectForKey:@"start"] integerValue];
    
    NSArray *parsedObject = [ [response objectForKey:@"response"] objectForKey:@"docs"];
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    
    for (int i = 0; i<parsedObject.count; i++) {
        NSDictionary *itemDict =[parsedObject objectAtIndex:i];
        NSString *s = [itemDict objectForKey:@"dc.title"];
        NSString *sPid = [itemDict objectForKey:@"PID"];
        
        [results setObject:sPid forKey:s];
    }
    
    
    if ([self.delegate respondsToSelector:@selector(searchHintsLoaded:)]) {
        [self.delegate searchHintsLoaded:[results copy]];
    }
    
    return results;
}

-(NSArray *)parseJSONdataForSearch:(NSData *)data error:(NSError *)error
{
    NSError *localError = nil;
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
    
    if (localError != nil) {
        error = localError;
        return nil;
    }
    NSInteger numberOfResults =[[[response objectForKey:@"response"] objectForKey:@"numFound"] integerValue];
    NSInteger start =[[[response objectForKey:@"response"] objectForKey:@"start"] integerValue];
    
    NSArray *parsedObject = [ [response objectForKey:@"response"] objectForKey:@"docs"];
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    
    for (int i = 0; i<parsedObject.count; i++) {
        
        MZKItemResource *cItem = [MZKItemResource new];
        NSDictionary *itemDict =[parsedObject objectAtIndex:i];
        
        cItem.pid = [itemDict objectForKey:@"PID"];
        cItem.datumStr = [itemDict objectForKey:@"datum_str"];
        cItem.title = [itemDict objectForKey:@"dc.title"];
        cItem.rootPid = [itemDict objectForKey:@"root_pid"];
        cItem.rootTitle =[itemDict objectForKey:@"root_title"];
        cItem.model = [itemDict objectForKey:@"fedora.model"];
        cItem.policy = [itemDict objectForKey:@"policy"];
        
        [results addObject:cItem];
    }
    
    return [NSArray new];
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
    newItem.policy = [rawData objectForKey:@"policy"];
    
    newItem.datanode= [[rawData objectForKey:@"datanode"] boolValue];
    
    newItem.author = [rawData objectForKey:@"author"];
    
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
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:strURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
    
    if (operation ==downloadCollectionItems || operation == search || operation == searchHints) {
        [req addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    }

    _lastURL = strURL;
    lastOperation = operation;
    
   // NSLog(@"Request: %@, with operation:%u", [req description], operation);
    
    [NSURLConnection sendAsynchronousRequest:[req copy] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)  {
        
        if (error) {
            NSLog(@"Download failed with error:%@", [error debugDescription]);
            NSDictionary *d = error.userInfo;
            NSString *key = [d objectForKey:@"_kCFStreamErrorDomainKey"];
            [self downloadFailedWithError:error];
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
                    break;
                    
                case search:
                    
                    [self parseJSONdataForSearch:data error:error];
                    
                    break;
                    
                case searchHints:
                    
                    [self parseJSONdataForSearchHints:data error:error];
                    break;
                    
                case searchFullResults:
                    [self parseJSONdataForSearch:data error:error];
                    break;
                    
                default:
                    break;
            }
            
        }
    }];
    
}


@end
