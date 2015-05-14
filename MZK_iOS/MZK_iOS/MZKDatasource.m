//
//  MZKDatasource.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 20/04/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKDatasource.h"
#import "MZKItemResource.h"

@implementation MZKDatasource





-(void)getChildrenForItem:(NSString *)pid
{
    
}

-(void)getItem:(NSString *)pid
{
    NSString *itemDataStr =[NSString stringWithFormat:@"/search/api/v5.0/item/%@", pid];
    [self checkAndSetBaseUrl];
    
    NSString *finalString = [NSString stringWithFormat:@"%@%@", self.baseStringURL, itemDataStr];
    NSURL *url = [[NSURL alloc] initWithString:finalString];
    
    [self downloadDataFromURL:url withOperation:2];

}

-(void)getSiblingsForItem:(NSString *)pid
{
    
}

-(void)getMostRecent
{
    NSString *recent = @"/search/api/v5.0/feed/newest";
    [self checkAndSetBaseUrl];
    
    NSString *finalString = [NSString stringWithFormat:@"%@%@", self.baseStringURL, recent];

    NSURL *url = [[NSURL alloc] initWithString:finalString];
    
    [self downloadDataFromURL:url withOperation:0];
    
    
}

-(void)getRecommended
{
    NSString *desired = @"/search/api/v5.0/feed/mostdesirable";
    [self checkAndSetBaseUrl];
    
    NSString *finalString = [NSString stringWithFormat:@"%@%@", self.baseStringURL, desired];
    NSURL *url = [[NSURL alloc] initWithString:finalString];
    
    [self downloadDataFromURL:url withOperation:1];
    
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

-(NSArray *)parseJSONData:(NSData*)data error:(NSError *)error withOperation:(NSUInteger)operation
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
        case 0:
    [self.delegate dataLoaded:results withKey:@"recent"];
            break;
        case 1:
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


-(void)downloadDataFromURL:(NSURL *)strURL withOperation:(NSUInteger)operation
{
    //change this implementation
    NSURLRequest *req = [NSURLRequest requestWithURL:strURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:120];
    [NSURLConnection sendAsynchronousRequest:req queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)  {
        
        if (error) {
            NSLog(@"Download failed with error:%@", [error debugDescription]);
            [self downloadFailed];
        } else {
            switch (operation) {
                case 0:
                     [self parseJSONData:data error:error withOperation:0];
                    break;
                    
                    case 1:
                    [self parseJSONData:data error:error withOperation:1];
                    break;
                    
                    case 2:
                     [self parseJSONDataForDetail:data error:error];
                default:
                    break;
            }
           
        }
    }];

}


@end
