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
#import "AFNetworking.h"

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
    libraries,
};
typedef enum _downloadOperation downloadOperation;

@implementation MZKDatasource
{
    NSURLRequest *_lastRequest;
    NSURL *_lastURL;
    downloadOperation lastOperation;
    NSOperationQueue *downloadQ;
    AFHTTPRequestOperation *currentOperation;
}

-(id)init
{
    self = [super init];
    if (self) {
        [self checkAndSetBaseUrl];
    }
    
    downloadQ = [NSOperationQueue new];
    downloadQ.name = @"download";
    
    return self;
}

-(id)initWithoutBaseURL
{
    self = [super init];
    if (self) {
        
    }
    
    downloadQ = [NSOperationQueue new];
    downloadQ.name = @"download";
    
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
    //  BOOL showOnlyPublic = [[[NSUserDefaults standardUserDefaults] objectForKey:kSettingsShowOnlyPublicDocuments] boolValue];
    //according to this: https://github.com/moravianlibrary/kramerius-for-ios/issues/110
    // show only public in most recent document ignoring settings
    NSString *recent = @"/search/api/v5.0/feed/newest?policy=public";
    
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
    
    [self checkAndSetBaseUrl];
    
    NSURL *tmpURL = [NSURL URLWithString:self.baseStringURL];
    
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = tmpURL.scheme;
    components.host = tmpURL.host;
    components.path = @"/search/api/v5.0/search/";
    components.query = [NSString stringWithFormat:@"fl=dc.title&q=dc.title:%@*+AND+%@(fedora.model:monograph^4+OR+fedora.model:periodical^4+OR+fedora.model:map+OR+fedora.model:soundrecording+OR+fedora.model:graphic+OR+fedora.model:archive+OR+fedora.model:manuscript)+AND+(dostupnost:public^3+OR+dostupnost:private)&rows=20", [searchString lowercaseString], visible?@"dostupnost:*public*+AND+":@""];
    
    NSURL *url = components.URL;
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
    
    [self checkAndSetBaseUrl];
    NSURL *tmpURL = [NSURL URLWithString:self.baseStringURL];
    
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = tmpURL.scheme;
    components.host = tmpURL.host;
    components.path = @"/search/api/v5.0/search/";
    components.query = [NSString stringWithFormat:@"q=dc.title:%@*+AND+%@(fedora.model:monograph+OR+fedora.model:periodical+OR+fedora.model:map+OR+fedora.model:soundrecording+OR+fedora.model:graphic+OR+fedora.model:archive+OR+fedora.model:manuscript)&rows=30", [searchString lowercaseString],visible?@"dostupnost:*public*+AND+":@""];
    
    NSLog(@"Percent encoded:%@",[components percentEncodedQuery]) ;
    NSURL *url = components.URL;
    
    
    [self downloadDataFromURL:url withOperation:searchFullResults];
}



-(void)getSearchResults:(NSString *)searchString
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *recent = [defaults objectForKey:kSettingsShowOnlyPublicDocuments];
    BOOL visible = NO;
    if (recent) {
        visible= [recent boolValue];
    }
    //
    //    NSString *sq1 = [NSString stringWithFormat: @"/search/api/v5.0/search/?fl=PID,dostupnost,keywords,dc.creator,dc.title,datum_str,fedora.model,img_full_mime&q=%@*AND%@(fedora.model:monograph OR fedora.model:periodical OR fedora.model:soundrecording OR fedora.model:map OR fedora.model:graphic OR fedora.model:sheetmusic OR fedora.model:archive OR fedora.model:manuscript)&rows=30&start=0&defType=edismax&qf=dc.title^20.0+dc.creator^3+keywords^0.3", [[searchString lowercaseString] URLEncodedString_ch], visible?@"dostupnost:*public*+AND+":@""];
    //
    [self checkAndSetBaseUrl];
    NSURL *tmpURL = [NSURL URLWithString:self.baseStringURL];
    
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = tmpURL.scheme;
    components.host = tmpURL.host;
    components.path = @"/search/api/v5.0/search/";
    components.query = [NSString stringWithFormat:@"fl=PID,dostupnost,keywords,dc.creator,dc.title,datum_str,fedora.model,img_full_mime&q=%@*+AND+%@(fedora.model:monograph+OR+fedora.model:periodical+OR+fedora.model:soundrecording+OR+fedora.model:map+OR+fedora.model:graphic+OR+fedora.model:sheetmusic+OR+fedora.model:archive+OR+fedora.model:manuscript)&rows=30&start=0&defType=edismax&qf=dc.title^20.0+dc.creator^3+keywords^0.3", [searchString lowercaseString],visible?@"dostupnost:*public*+AND":@""];
    
    NSLog(@"Percent encoded:%@",[components URL]) ;
    NSURL *url = components.URL;
    
    
    [self downloadDataFromURL:url withOperation:search];
}

-(void)getLibraries
{
    // dedicated url for getting libraries
    // response as JSON
    // implement caching mechanism (when app is offline show the cached list)
    // refresh list of libraries after every start of the app...
    
    NSString *defaultURL = @"http://registrkrameriu.mzk.cz/libraries.json";
    
    [self downloadDataFromURL:[NSURL URLWithString:defaultURL] withOperation:libraries];
    
}

#pragma mark - privateMethods
-(void)checkAndSetBaseUrl
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    MZKLibraryItem *item = appDelegate.getDatasourceItem;
    if (item) {
        self.baseStringURL = item.url;
    }
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
    NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSData *theData = [dataStr dataUsingEncoding:NSUTF8StringEncoding];

    
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:theData options:0 error:&localError];
    
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
        
        if ([self.delegate respondsToSelector:@selector(downloadFailedWithError:)]) {
            [self.delegate downloadFailedWithError:error];
        }
        
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
            NSString *model = [currentObject objectForKey:@"model"];
            page.model = [MZKConstants stringToModel:model];
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
    else
    {
        if ([self.delegate respondsToSelector:@selector(downloadFailedWithError:)]) {
            [self.delegate downloadFailedWithError:[NSError errorWithDomain:@"Nothing downloaded" code:-10000 userInfo:[NSMutableDictionary new]]];
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
        
        NSString *model = [itemDict objectForKey:@"fedora.model"];
        
        cItem.model = [MZKConstants stringToModel:model];
        cItem.numFound = numberOfResults;
        cItem.start = start;
        cItem.pid = [itemDict objectForKey:@"PID"];
        cItem.datumStr = [itemDict objectForKey:@"datum_str"];
        
        NSMutableString *authors = [NSMutableString new];
        if ([[itemDict objectForKey:@"dc.creator"] isKindOfClass:[NSArray class]]) {
            for (NSString *name in [itemDict objectForKey:@"dc.creator"]) {
                [authors appendString:name];
                
            }
        }
        else
        {
            authors = [itemDict objectForKey:@"dc.creator"];
        }
        
        cItem.documentCreator = [authors copy];
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


// AF Networking parsing method!
-(NSArray *)parseJSONDataForHints:(NSDictionary*)response error:(NSError *)error
{
    // paging not used for hints!
    //    NSInteger numberOfResults =[[[response objectForKey:@"response"] objectForKey:@"numFound"] integerValue];
    //    NSInteger start =[[[response objectForKey:@"response"] objectForKey:@"start"] integerValue];
    if ([response objectForKey:@"message"] && [response objectForKey:@"status"]) {
        NSLog(@"Message: %@ and Status:%@", [response objectForKey:@"message"],[response objectForKey:@"status"] );
        
        if ([[response objectForKey:@"status"] isEqualToString:@"500"]) {
            if ([self.delegate respondsToSelector:@selector(downloadFailedWithError:)]) {
                [self.delegate downloadFailedWithError:[NSError errorWithDomain:@"Nothing downloaded" code:-10000 userInfo:[NSMutableDictionary new]]];
                return nil;
            }
            
        }
    }
    
    NSArray *parsedObject = [[response objectForKey:@"response"] objectForKey:@"docs"];
    NSMutableArray *resultsArray = [NSMutableArray new];
    
    for (int i = 0; i<parsedObject.count; i++) {
        NSDictionary *itemDict =[parsedObject objectAtIndex:i];
        NSString *s = [itemDict objectForKey:@"dc.title"];
        [resultsArray addObject:s];
    }
    
    
    if ([self.delegate respondsToSelector:@selector(searchHintsLoaded:)]) {
        [self.delegate searchHintsLoaded:[resultsArray copy]];
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
    return [resultsArray copy];
}

-(NSArray *)parseJSONdataForSearchHints:(NSData *)data error:(NSError *)error
{
    NSError *localError = nil;
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
    
    if (localError != nil) {
        error = localError;
        return nil;
    }
    
    if ([response objectForKey:@"message"] && [response objectForKey:@"status"]) {
        NSLog(@"Message: %@ and Status:%@", [response objectForKey:@"message"],[response objectForKey:@"status"] );
        
        if ([[response objectForKey:@"status"] isEqualToString:@"500"]) {
            if ([self.delegate respondsToSelector:@selector(downloadFailedWithError:)]) {
                [self.delegate downloadFailedWithError:[NSError errorWithDomain:@"Nothing downloaded" code:-10000 userInfo:[NSMutableDictionary new]]];
                return nil;
            }
            
        }
    }
    
    NSInteger numberOfResults =[[[response objectForKey:@"response"] objectForKey:@"numFound"] integerValue];
    NSInteger start =[[[response objectForKey:@"response"] objectForKey:@"start"] integerValue];
    
    NSArray *parsedObject = [ [response objectForKey:@"response"] objectForKey:@"docs"];
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    NSMutableArray *resultsArray = [NSMutableArray new];
    
    for (int i = 0; i<parsedObject.count; i++) {
        NSDictionary *itemDict =[parsedObject objectAtIndex:i];
        NSString *s = [itemDict objectForKey:@"dc.title"];
        [resultsArray addObject:s];
    }
    
    
    if ([self.delegate respondsToSelector:@selector(searchHintsLoaded:)]) {
        [self.delegate searchHintsLoaded:[resultsArray copy]];
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
    return [resultsArray copy];
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
        
        NSString *model = [itemDict objectForKey:@"fedora.model"];
        cItem.model = [MZKConstants stringToModel:model];
        cItem.policy = [itemDict objectForKey:@"dostupnost"];
        
        [results addObject:cItem];
    }
    
    
    if ([self.delegate respondsToSelector:@selector(searchResultsLoaded:)]) {
        [self.delegate searchResultsLoaded:[results copy]];
    }
    
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
    
    return [results copy];
}

-(void)parseJSONDataForLibraries:(NSData *)data error:(NSError *)error
{
    NSError *localError = nil;
    NSArray *result = [NSJSONSerialization JSONObjectWithData:data
                                                      options:kNilOptions error:&error];
    
    if (localError != nil) {
        error = localError;
    }
    
    NSMutableArray *librariesArray = [NSMutableArray new];
    if (!error && result) {
        for (NSDictionary *lib in result) {
            if ([[lib objectForKey:@"ios"] integerValue] >=2) {
                MZKLibraryItem *item = [MZKLibraryItem new];
                item.libID = [[lib objectForKey:@"id"] integerValue];
                item.name = [lib objectForKey:@"name"];
                item.code = [lib objectForKey:@"code"];
                item.version = [lib objectForKey:@"version"];
                item.libraryURL = [lib objectForKey:@"library_url"];
                item.logoURL = [lib objectForKey:@"logo"];
                item.nameEN = [lib objectForKey:@"name_en"];
                item.url = [lib objectForKey:@"url"];
                [librariesArray addObject:item];
            }
        }
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
    
    if ([self.delegate respondsToSelector:@selector(librariesLoaded:)]) {
        [self.delegate librariesLoaded:[librariesArray copy]];
    }
    
}

-(MZKItemResource *)parseObjectFromDictionary:(NSDictionary *)rawData
{
    MZKItemResource *newItem = [MZKItemResource new];
    
    newItem.pid = [rawData objectForKey:@"pid"];
    NSString *model = [rawData objectForKey:@"model"];
    
    newItem.model = [MZKConstants stringToModel:model];
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
    
    if([rawData objectForKey:@"details"]){
        //   page.type = [[rawData objectForKey:@"details"] objectForKey:@"type"];
        
        if ([[[rawData objectForKey:@"details"] objectForKey:@"year"] isKindOfClass:[NSString class]]) {
            newItem.year =[[rawData objectForKey:@"details"] objectForKey:@"year"];
        }
        
        if ([[[rawData objectForKey:@"details"] objectForKey:@"date"] isKindOfClass:[NSString class]]) {
            newItem.date =[[rawData objectForKey:@"details"] objectForKey:@"date"];
        }
        
        if ([[[rawData objectForKey:@"details"] objectForKey:@"volumeNumber"] isKindOfClass:[NSString class]]) {
            newItem.volumeNumber =[[rawData objectForKey:@"details"] objectForKey:@"volumeNumber"];
        }
        
        if ([[[rawData objectForKey:@"details"] objectForKey:@"issueNumber"] isKindOfClass:[NSString class]]) {
            newItem.issueNumber =[[rawData objectForKey:@"details"] objectForKey:@"issueNumber"];
            if ([newItem.issueNumber isEqualToString:@""]) {
                if ([[[rawData objectForKey:@"details"] objectForKey:@"partNumber"] isKindOfClass:[NSString class]]) {
                    newItem.issueNumber =[[rawData objectForKey:@"details"] objectForKey:@"partNumber"];
                }
            }
        }
    }
    
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
    
    NSLog(@"URL! %@", [strURL description]);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:strURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    
    if (operation ==downloadCollectionItems || operation == search || operation == searchHints) {
        [req addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    }
    
    _lastURL = strURL;
    lastOperation = operation;
    
    if (operation == searchHints) {
        [self downloadSearchHintsWithRequest:req withOperation:operation];
        return;
    }
    
    
    
    __weak typeof(self) wealf = self;
    
    [NSURLConnection sendAsynchronousRequest:[req copy] queue:downloadQ completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)  {
        
        if (error) {
            NSLog(@"Download failed with error:%@", [error debugDescription]);
            [wealf downloadFailedWithError:error];
        } else {
            NSLog(@"Download sucessful with operation:%lu", (unsigned long)operation);
            
            switch (operation) {
                case downloadMostRecent:
                    [wealf parseJSONData:data error:error withOperation:operation];
                    break;
                    
                case downloadRecommended:
                    [wealf parseJSONData:data error:error withOperation:operation];
                    break;
                    
                case downloadItem:
                    [wealf parseJSONDataForDetail:data error:error];
                    break;
                case downloadChildren:
                    [wealf parseJSONDataForChildren:data error:error];
                    break;
                    
                case downloadImageProperties:
                    [wealf parseImagePropertiesWithData:data error:error];
                    break;
                    
                case downloadCollectionInfo:
                    [wealf parseJSONDataForCollections:data error:error];
                    
                    break;
                case downloadCollectionItems:
                    [wealf parseJSONDataForCollectionItems:data error:error];
                    break;
                    
                case search:
                    [wealf parseJSONdataForSearch:data error:error];
                    break;
                    
                case searchHints:
                    
                    [wealf parseJSONdataForSearchHints:data error:error];
                    break;
                    
                case searchFullResults:
                    [wealf parseJSONdataForSearch:data error:error];
                    break;
                    
                case libraries:
                    [wealf parseJSONDataForLibraries:data error:error];
                    
                default:
                    break;
            }
        }
    }];
    
    
}

-(NSString*) encodeToPercentEscapeString:(NSString *)string  {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (CFStringRef) string,
                                                                                 NULL,
                                                                                 (CFStringRef) @"!*'();:@&=+$,/?%#[]",
                                                                                 kCFStringEncodingUTF8)); }
#pragma mark - AFNetworking
-(void)downloadSearchHintsWithRequest:(NSMutableURLRequest *)request withOperation:(downloadOperation)operation
{
    __weak typeof(self) wealf = self;
    
    if (currentOperation) {
        [currentOperation cancel];
        NSLog(@"Cancel current operation!");
    }
    
    currentOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    currentOperation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [currentOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSError *localError = nil;
        [wealf parseJSONDataForHints:(NSDictionary *)responseObject error:localError];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([wealf.delegate respondsToSelector:@selector(downloadFailedWithError:)]) {
            [wealf.delegate downloadFailedWithError:error];
        }
    }];
    
    // 5
    [currentOperation start];
    
}
@end
