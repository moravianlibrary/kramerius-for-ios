//
//  MZKDatasource.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 20/04/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MZKLibraryItem.h"

@class MZKItemResource;

@protocol DataLoadedDelegate <NSObject>

@optional
// successfull states
-(void)dataLoaded:(NSArray*)data withKey:(NSString *)key;
-(void)detailForItemLoaded:(MZKItemResource *)item;
-(void)pagesLoadedForItem:(NSArray *)pages;
-(void)collectionListLoaded:(NSArray *)collections;
-(void)collectionItemsLoaded:(NSArray *)collectionItems;
-(void)collectionItemsLoaded:(NSArray *)collectionItems withNumberOfItems:(NSInteger)numberOfItems;
-(void)childrenForItemLoaded:(NSArray *)items;
-(void)searchResultsLoaded:(NSArray *)results;
-(void)searchHintsLoaded:(NSArray *)results;
-(void)librariesLoaded:(NSArray *)results;
-(void)siblingsForItemLoaded:(NSArray *)results;


// error states
-(void)downloadFailedWithError:(NSError *)error;
-(void)downloadFailedWithError:(NSString *)title subtitle:(NSString *)subtitle;
@end

@interface MZKDatasource: NSObject {
    MZKLibraryItem *_defaultDatasourceItem;
}
@property (nonatomic, weak) __weak id<DataLoadedDelegate> delegate;
@property (nonatomic, strong) NSString *baseStringURL;

// get methos, each sends a request to current kramerius backend
-(void)getItem:(NSString *)pid;
-(void)getChildrenForItem:(NSString *)pid;
-(void)getImagePropertiesForPageItem:(NSString *)pid;

-(void)getMostRecent;
-(void)getRecommended;

-(void)getInfoAboutCollections;
-(void)getCollectionItems:(NSString *)collectionPID;

//-(void)getCollectionItems:(NSString *)collectionPID withRangeFrom:(NSInteger)from to:(NSInteger)to;

-(void)getCollectionItems:(NSString *)collectionPID withRangeFrom:(NSInteger)from numberOfItems:(NSInteger)numberOfItems;

-(void)getSearchResults:(NSString *)searchString;
-(void)getSearchResultsAsHints:(NSString *)searchString;
-(void)getFullSearchResults:(NSString *)searchString;
-(void)getLibraries;
-(void)getSiblingsForItem:(NSString *)pid;

-(id)init;
-(id)initWithoutBaseURL;

/**
 * perform facet search
 */
//-(void)performFacetSearchWithQuery(MZKFilterQuery *)query
@end
