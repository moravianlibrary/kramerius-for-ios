//
//  MZKDetailInformationDataSource.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 04/01/16.
//  Copyright © 2016 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKDetailInformationDataSource.h"
#import "XMLReader.h"
#import "AppDelegate.h"


@implementation MZKDetailInformationDataSource

-(id)init
{
    self = [super init];
    if (self) {
        [self checkAndSetBaseUrl];
    }
    
    return self;
}

-(void)parseXMLData:(NSData *)data error:(NSError *)error
{
    NSDictionary *dict = [XMLReader dictionaryForXMLData:data
                                                 options:XMLReaderOptionsProcessNamespaces
                                                   error:&error];
    
}

-(void)getDetailInformationAboutDocument:(NSString *)pid
{
    [self checkAndSetBaseUrl];
    
    NSString *itemDataStr =[NSString stringWithFormat:@"/search/api/v5.0/item/%@/streams/BIBLIO_MODS", pid];
    
    
    NSString *finalString = [NSString stringWithFormat:@"%@%@", baseStringURL, itemDataStr];
    NSURL *url = [[NSURL alloc] initWithString:finalString];
    
    [self downloadInformationWithURL:url];
    
}

-(void)downloadInformationWithURL:(NSURL *)url
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
    
    //if (operation ==downloadCollectionItems || operation == search) {
    [req addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        // NSLog(@"%@", req.allHTTPHeaderFields);;
   // }
//
//    NSLog(@"Request: %@, with operation:%u", [req description], operation);
    
    [NSURLConnection sendAsynchronousRequest:[req copy] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)  {
        
        if (error) {
             NSLog(@"Download failed with error:%@", [error debugDescription]);
           // [self downloadFailed];
        } else {
            [self parseXMLData:data error:error];
        }
        
    }];
    
}



#pragma mark - privateMethods
-(void)checkAndSetBaseUrl
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    MZKResourceItem *item = appDelegate.getDatasourceItem;
    if (!item) {
        // NSLog(@"Default URL not set!");
    }
    baseStringURL = [NSString stringWithFormat:@"%@://%@", item.protocol, item.stringURL];
}


@end
