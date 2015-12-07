//
//  MZKDatasource.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 20/04/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MZKResourceItem.h"
@class MZKItemResource;

@protocol DataLoadedDelegate <NSObject>

@optional
-(void)dataLoaded:(NSArray*)data withKey:(NSString *)key;
-(void)detailForItemLoaded:(MZKItemResource *)item;
-(void)pagesLoadedForItem:(NSArray *)pages;
-(void)collectionListLoaded:(NSArray *)collections;
-(void)collectionItemsLoaded:(NSArray *)collectionItems;
-(void)childrenForItemLoaded:(NSArray *)items;
-(void)searchResultsLoaded:(NSArray *)results;
-(void)downloadFailedWithRequest:(NSString *)request;
-(void)searchHintsLoaded:(NSDictionary *)results;

@end

@interface MZKDatasource : NSObject
{
    MZKResourceItem *_defaultDatasourceItem;
}
@property (nonatomic, weak) __weak id<DataLoadedDelegate> delegate;
@property (nonatomic, strong) NSString *baseStringURL;


-(void)getItem:(NSString *)pid;
-(void)getChildrenForItem:(NSString *)pid;
-(void)getSiblingsForItem:(NSString *)pid;
-(void)getImagePropertiesForPageItem:(NSString *)pid;

-(void)getMostRecent;
-(void)getRecommended;

-(void)getInfoAboutCollections;
-(void)getCollectionItems:(NSString *)collectionPID;
-(void)getSearchResults:(NSString *)searchQuery;
-(void)getSearchResultsAsHints:(NSString *)searchString;
-(void)getFullSearchResults:(NSString *)searchString;



@end
