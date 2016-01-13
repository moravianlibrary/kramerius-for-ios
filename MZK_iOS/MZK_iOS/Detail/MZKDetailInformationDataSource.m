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
    
    NSDictionary *modsCollection = [dict objectForKey:@"modsCollection"];
    
    NSDictionary *mods = [modsCollection objectForKey:@"mods"];
    
    NSLog(@"Mods desc:%@", [mods description]);
    MZKDetailInformationModel *detailModel = [MZKDetailInformationModel new];
    
    detailModel.identifiersInfo = [self parseIdentifiersFrom:[mods objectForKey:@"identifier"]];
    
    //lang
    NSDictionary *lang = [mods objectForKey:@"language"];
   
    detailModel.languageAuthority =[lang objectForKey:@"authority"]? [lang objectForKey:@"authority"] :nil;
    detailModel.languageID =[lang objectForKey:@"text"]? [lang objectForKey:@"text"] :nil;
    detailModel.languageNme = [lang objectForKey:@"type"]? [lang objectForKey:@"type"] :nil;
    
    //location
    NSDictionary *location = [mods objectForKey:@"location"];
    if (location) {
        NSDictionary *physicalLoc = [location objectForKey:@"physicalLocation"];
        NSDictionary *shelfLoc = [location objectForKey:@"shelfLocator"];
        if (physicalLoc) {
            detailModel.physicalLocation = [physicalLoc objectForKey:@"text"];
        }
        if (shelfLoc) {
            detailModel.shelfLocation = [physicalLoc objectForKey:@"text"];
        }
        
    }
    
    //name
    
    NSDictionary *name = [mods objectForKey:@"name"];

    NSArray *namePart = [name objectForKey:@"namePart"];
    NSString *nameStr;
    NSString *familyName;
    NSString *givenName;
    NSString *dateStr;
    
    for (NSDictionary *d in namePart) {
        if (![d objectForKey:@"type"]) {
            nameStr = [d objectForKey:@"text"];
        }else
        {
            if ([[d objectForKey:@"type"] isEqualToString:@"date"]) {
                dateStr = [d objectForKey:@"text"];
            }
            else if ([[d objectForKey:@"type"] isEqualToString:@"given"])
            {
                givenName = [d objectForKey:@"text"];
            }
            else if ([[d objectForKey:@"type"] isEqualToString:@"family"])
            {
                familyName = [d objectForKey:@"text"];
            }
        }
    }
    
    if (!familyName && !givenName) {
        detailModel.author = nameStr;
    }
    else
    {
        detailModel.author = [NSString stringWithFormat:@"%@, %@", familyName, givenName];
    }
    
    //origin info
    
    detailModel.placeInfo = [self parseOriginInfoFrom:[mods objectForKey:@"originInfo"]];
    
    // physical description
    if ([mods objectForKey:@"physicalDescription"]) {
        detailModel.physicalDescription = [[[mods objectForKey:@"physicalDescription"] objectForKey:@"extent"] objectForKey:@"text"];
    }
    
    // lang info
    
    NSDictionary *languageOfCataloging = [[[mods objectForKey:@"recordInfo"] objectForKey:@"languageOfCataloging"] objectForKey:@"languageTerm"];
    
    detailModel.languageAuthority = [languageOfCataloging objectForKey:@"authority"]? [languageOfCataloging objectForKey:@"authority"] :nil;
    detailModel.languageNme = [languageOfCataloging objectForKey:@"text"]? [languageOfCataloging objectForKey:@"text"] :nil;
    detailModel.languageID = [languageOfCataloging objectForKey:@"text"]? [languageOfCataloging objectForKey:@"text"] :nil;
    
    // record change dates info
    detailModel.recordChangeDates = [self parseRecordChangedDatesFrom:[[mods objectForKey:@"recordInfo"] objectForKey:@"recordChangeDate"]];
    
    detailModel.recordContentSourceCode = [[[mods objectForKey:@"recordInfo"] objectForKey:@"recordContentSource"] objectForKey:@"text"];
    
    detailModel.recordCreationDates = [self parseRecordChangedDatesFrom:[[mods objectForKey:@"recordInfo"] objectForKey:@"recordCreationDate"]];
    
    // record indentifier
    
    detailModel.recordSourceIdentifier = [[mods objectForKey:@"recordInfo"] objectForKey:@"recordIdentifier"] ? [[[mods objectForKey:@"recordInfo"] objectForKey:@"recordIdentifier"] objectForKey:@"source"] : nil;
    
    detailModel.recordSourceTextIdentifier = [[mods objectForKey:@"recordInfo"] objectForKey:@"recordIdentifier"] ? [[[mods objectForKey:@"recordInfo"] objectForKey:@"recordIdentifier"] objectForKey:@"text"] : nil;
    
    // title info
    
    detailModel.subTitle = [[mods objectForKey:@"titleInfo"] objectForKey:@"subTitle"] ?[[[mods objectForKey:@"titleInfo"] objectForKey:@"subTitle"] objectForKey:@"text"] : nil;
    
    detailModel.title = [[mods objectForKey:@"titleInfo"] objectForKey:@"title"] ?[[[mods objectForKey:@"titleInfo"] objectForKey:@"title"] objectForKey:@"text"] : nil;
    
    if ([self.delegate respondsToSelector:@selector(detailInformationLoaded:)]) {
        [self.delegate detailInformationLoaded: detailModel];
    }
    
    
}

-(NSArray *)parseRecordChangedDatesFrom:(NSArray *)records
{
    NSMutableArray *dates = [NSMutableArray new];
    
    for (NSDictionary *d in records) {
        MZKDetailRecordChangeDateInfo *rChangeInfo = [MZKDetailRecordChangeDateInfo new];
        
        if ([d objectForKey:@"encoding"]) {
            rChangeInfo.encoding = [d objectForKey:@"encoding"];
        }
        if ([d objectForKey:@"text"]) {
            rChangeInfo.date = [d objectForKey:@"text"];
        }
        
        [dates addObject:rChangeInfo];
    }
    
    return dates;
}

-(MZKDetailOriginInfo *)parseOriginInfoFrom:(NSDictionary *)originDict
{
    MZKDetailOriginInfo *detailInfo = [MZKDetailOriginInfo new];
    
    detailInfo.dateIssued = [originDict objectForKey:@"dateIssued"]? [[originDict objectForKey:@"dateIssued"] objectForKey:@"text"]: nil;
    
    detailInfo.publisher = [originDict objectForKey:@"publisher"]? [[originDict objectForKey:@"publisher"] objectForKey:@"text"]: nil;
    
    NSArray *places = [originDict objectForKey:@"place"];
    NSMutableArray *parsedPlaces = [NSMutableArray new];
    
    for (NSDictionary *d in places) {
        MZKDetailPlaceInfo *placeInfo = [MZKDetailPlaceInfo new];
        if ([d objectForKey:@"authority"]) {
            placeInfo.authority = [d objectForKey:@"authority"];
            
        }
        if ([d objectForKey:@"text"]) {
            placeInfo.text = [d objectForKey:@"text"];
        }
        if ([d objectForKey:@"type"]) {
            placeInfo.type = [d objectForKey:@"type"];
        }
        [parsedPlaces addObject:placeInfo];
        
    }
    
    detailInfo.places = [parsedPlaces copy];
    
    return detailInfo;
}


-(MZKDetailIdentifierInfo *)parseIdentifiersFrom:(NSArray *)arr
{
    if (!arr) return nil;
    MZKDetailIdentifierInfo *info = [MZKDetailIdentifierInfo new];
    
    for (NSDictionary *d in arr) {
        NSString *type = [d objectForKey:@"type"];
        
        if ([type isEqualToString:@"sysno"]) {
            info.sysno = [d objectForKey:@"text"];
            
        } else if ([type isEqualToString:@"uuid"])
        {
            info.uuid = [d objectForKey:@"text"];
            
        }else if ([type isEqualToString:@"issn"])
        {
            info.issn = [d objectForKey:@"text"];
        }
        else if ([type isEqualToString:@"oclc"])
        {
            info.oclc = [d objectForKey:@"text"];
        }
        else if ([type isEqualToString:@"ccnb"])
        {
            info.ccnb = [d objectForKey:@"text"];
        }
    }
    return info;
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
    
    [NSURLConnection sendAsynchronousRequest:[req copy] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)  {
        
        if (error) {
             NSLog(@"Download failed with error:%@", [error debugDescription]);
            [self.delegate downloadFailed];
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
