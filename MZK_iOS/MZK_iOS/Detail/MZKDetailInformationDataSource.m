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
    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
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
    if(lang)
    {
        NSDictionary *lanTerm = [lang objectForKey:@"languageTerm"];
        
        detailModel.languageAuthority =[lanTerm objectForKey:@"authority"]? [lanTerm objectForKey:@"authority"] :nil;
        detailModel.languageID =[lanTerm objectForKey:@"text"]? [lanTerm objectForKey:@"text"] :nil;
        detailModel.languageNme = [lanTerm objectForKey:@"type"]? [lanTerm objectForKey:@"type"] :nil;
        
        
        if (detailModel.languageID) {
            NSArray *languageArray = [((AppDelegate *)[[UIApplication sharedApplication] delegate]) getLanguageFromCode:detailModel.languageID];
            if (languageArray) {
                detailModel.languageNme = languageArray[1];
            }
        }
    }
    
    //title info - title and subtitle
    @try {
        
    
    
    if ([mods objectForKey:@"titleInfo"]) {
        
        if ([[mods objectForKey:@"titleInfo"] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *titleInfo = [mods objectForKey:@"titleInfo"];
            NSDictionary *title = [titleInfo objectForKey:@"title"];
            NSDictionary *subTitle = [titleInfo objectForKey:@"subTitle"];
            
            if (title) {
                
                detailModel.title =[title objectForKey:@"text"];
                
                
            }
            
            if (subTitle) {
                
                detailModel.subTitle =[subTitle objectForKey:@"text"];
                
                
            }
            
        }
        else if ([[mods objectForKey:@"titleInfo"] isKindOfClass:[NSArray class]])
        {
            NSArray *titleInfo = [mods objectForKey:@"titleInfo"];
            
            for (NSDictionary *tmpDict in titleInfo) {
                
                if ([tmpDict objectForKey:@"subTitle"]) {
                    NSDictionary *subTitle = [tmpDict objectForKey:@"subTitle"];
                    detailModel.subTitle =[subTitle objectForKey:@"text"];
                }
                
                if ([tmpDict objectForKey:@"title"]) {
                    NSDictionary *title = [tmpDict objectForKey:@"title"];
                    detailModel.title =[title objectForKey:@"text"];
                }
                
            }
            
        }
    }
    
    
    
    //location
    NSDictionary *location = [mods objectForKey:@"location"];
    if (location) {
        NSDictionary *physicalLoc = [location objectForKey:@"physicalLocation"];
        NSDictionary *shelfLoc = [location objectForKey:@"shelfLocator"];
        if (physicalLoc) {
            detailModel.physicalLocation = [physicalLoc objectForKey:@"text"];
            
            detailModel.physicalLocation = [((AppDelegate *)[[UIApplication sharedApplication] delegate]) getLocationFromCode:detailModel.physicalLocation];
        }
        
        if (shelfLoc) {
            detailModel.shelfLocation = [physicalLoc objectForKey:@"text"];
        }
        
    }
    
    //name
    
    MZKDetailAuthorsInfo *authorsInfo = [MZKDetailAuthorsInfo new];
    authorsInfo.namesOfAllAuthors= [NSMutableArray new];
    NSString *nameStr, *date,*givenName, *familyName;
    
    if ([mods objectForKey:@"name"]) {
        
        if ([[mods objectForKey:@"name"] isKindOfClass:[NSArray class]]) {
            
            NSArray *nameObjects =[mods objectForKey:@"name"];
            
            for (NSDictionary *name in nameObjects) {
                if ([[name objectForKey:@"type"] isEqualToString:@"personal"]) {
                    
                    
                    
                    if ([name objectForKey:@"namePart"] ) { //name part je array dictionaries...
                        
                        
                        if ([[name objectForKey:@"namePart"] isKindOfClass:[NSArray class]]) {
                            
                            for (NSDictionary *tmpDict in [name objectForKey:@"namePart"]) {
                                
                                if ([[tmpDict objectForKey:@"type"] isEqualToString:@"personal"]) {
                                    // lets take just personal names
                                    // NSArray *tmpNameParts = [tmpDict objectForKey:@"namePart"];
                                    // this gave us just another NSDictionary
                                    
                                }
                                if ([[tmpDict allKeys] count] ==1 && [tmpDict objectForKey:@"text"]) {
                                    nameStr = [tmpDict objectForKey:@"text"];
                                    [authorsInfo.namesOfAllAuthors addObject:nameStr];
                                    nameStr = nil;
                                }
                                
                                if (![tmpDict objectForKey:@"type"]) {
                                    // there is no type so just take text
                                    
                                }
                                else if ([tmpDict objectForKey:@"type"])
                                {
                                    
                                }
                                
                            }
                            
                        }else if ([[name objectForKey:@"namePart"] isKindOfClass:[NSDictionary class]])
                        {
                            NSLog(@"name dictionary");
                            NSDictionary *tmpDict = [name objectForKey:@"namePart"];
                            if ([[tmpDict objectForKey:@"type"] isEqualToString:@"personal"]) {
                                // lets take just personal names
                                // NSArray *tmpNameParts = [tmpDict objectForKey:@"namePart"];
                                // this gave us just another NSDictionary
                                
                            }
                            if ([[tmpDict allKeys] count] ==1 && [tmpDict objectForKey:@"text"]) {
                                nameStr = [tmpDict objectForKey:@"text"];
                                [authorsInfo.namesOfAllAuthors addObject:nameStr];
                                nameStr = nil;
                            }
                            
                            if (![tmpDict objectForKey:@"type"]) {
                                // there is no type so just take text
                                
                            }
                            else if ([tmpDict objectForKey:@"type"])
                            {
                                
                            }
                            
                            
                        }
                        
                    }
                }
            }
        }
        else if ([[mods objectForKey:@"name"] isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *tmpNameDictionary = [mods objectForKey:@"name"];
            if ([[tmpNameDictionary objectForKey:@"type"] isEqualToString:@"personal"]) {
                // standard situation
                if([[tmpNameDictionary objectForKey:@"namePart"] isKindOfClass:[NSArray class]])
                {
                    NSArray *tmpNameParts = [tmpNameDictionary objectForKey:@"namePart"];
                    
                    for (NSDictionary *nameDictionary in tmpNameParts) {
                        
                        if (![nameDictionary objectForKey:@"type"]) {
                            // there is no type so just take text
                            nameStr = [nameDictionary objectForKey:@"text"];
                            [authorsInfo.namesOfAllAuthors addObject:nameStr];
                            nameStr = nil;
                        }
                        else if ([nameDictionary objectForKey:@"type"])
                        {
                            
                        }
                    }
                }
                else if([[tmpNameDictionary objectForKey:@"namePart"] isKindOfClass:[NSDictionary class]] )
                {
                    NSDictionary *tmpDict = [tmpNameDictionary objectForKey:@"namePart"];
                     nameStr = [tmpDict objectForKey:@"text"];
                     [authorsInfo.namesOfAllAuthors addObject:nameStr];
                }
                
            }
        }
        
        detailModel.authorsInfo = authorsInfo;
    }
    
    //origin info
    
    //    detailModel.placeInfo = [self parseOriginInfoFrom:[mods objectForKey:@"originInfo"]];
    //
    //    // physical description
    //    if ([mods objectForKey:@"physicalDescription"]) {
    //        detailModel.physicalDescription = [[[mods objectForKey:@"physicalDescription"] objectForKey:@"extent"] objectForKey:@"text"];
    //    }
    //
    //    // lang info
    //
    //    NSDictionary *languageOfCataloging = [[[mods objectForKey:@"recordInfo"] objectForKey:@"languageOfCataloging"] objectForKey:@"languageTerm"];
    //
    //    detailModel.languageAuthority = [languageOfCataloging objectForKey:@"authority"]? [languageOfCataloging objectForKey:@"authority"] :nil;
    //    detailModel.languageNme = [languageOfCataloging objectForKey:@"text"]? [languageOfCataloging objectForKey:@"text"] :nil;
    //    detailModel.languageID = [languageOfCataloging objectForKey:@"text"]? [languageOfCataloging objectForKey:@"text"] :nil;
    //
    //    // record change dates info
    //    detailModel.recordChangeDates = [self parseRecordChangedDatesFrom:[[mods objectForKey:@"recordInfo"] objectForKey:@"recordChangeDate"]];
    //
    //    detailModel.recordContentSourceCode = [[[mods objectForKey:@"recordInfo"] objectForKey:@"recordContentSource"] objectForKey:@"text"];
    //
    //    detailModel.recordCreationDates = [self parseRecordChangedDatesFrom:[[mods objectForKey:@"recordInfo"] objectForKey:@"recordCreationDate"]];
    //
    //    // record indentifier
    //
    //    detailModel.recordSourceIdentifier = [[mods objectForKey:@"recordInfo"] objectForKey:@"recordIdentifier"] ? [[[mods objectForKey:@"recordInfo"] objectForKey:@"recordIdentifier"] objectForKey:@"source"] : nil;
    //
    //    detailModel.recordSourceTextIdentifier = [[mods objectForKey:@"recordInfo"] objectForKey:@"recordIdentifier"] ? [[[mods objectForKey:@"recordInfo"] objectForKey:@"recordIdentifier"] objectForKey:@"text"] : nil;
    
    
    if ([self.delegate respondsToSelector:@selector(detailInformationLoaded:)]) {
        [self.delegate detailInformationLoaded: detailModel];
    }
    }
    @catch (NSException *exception) {
        NSLog(@"EXCEPTION: %@", exception.description);
    }
    @finally {
        [self.delegate downloadFailed];
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
    detailInfo.dateIssued = [NSMutableArray new];
    
    if ([[originDict objectForKey:@"dateIssued"] isKindOfClass:[NSDictionary class]]) {
        NSString *date = [[originDict objectForKey:@"dateIssued"] objectForKey:@"text"];
        [detailInfo.dateIssued addObject:date];
    }
    else if ([[originDict objectForKey:@"dateIssued"] isKindOfClass:[NSArray class]])
    {
        for (NSDictionary *dateIssuedDict in [originDict objectForKey:@"dateIssued"]) {
            NSString *date = [dateIssuedDict objectForKey:@"text"];
            [detailInfo.dateIssued addObject:date];
        }
    }
    
    if ([[originDict objectForKey:@"publisher"] isKindOfClass:[NSDictionary class]]) {
        detailInfo.publisher = [[originDict objectForKey:@"publisher"] objectForKey:@"text"];
    }
    
    
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
    NSLog(@"Req: %@", [req description]);
    
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
