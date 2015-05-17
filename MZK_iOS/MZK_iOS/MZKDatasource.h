//
//  MZKDatasource.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 20/04/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MZKItemResource;

@protocol DataLoadedDelegate <NSObject>

@optional
-(void)dataLoaded:(NSArray*)data withKey:(NSString *)key;
-(void)detailForItemLoaded:(MZKItemResource *)item;
-(void)pagesLoadedForItem:(NSArray *)pages;

@end

@interface MZKDatasource : NSObject
@property (nonatomic, weak) __weak id<DataLoadedDelegate> delegate;
@property (nonatomic, strong) NSString *baseStringURL;


-(void)getItem:(NSString *)pid;
-(void)getChildrenForItem:(NSString *)pid;
-(void)getSiblingsForItem:(NSString *)pid;

-(void)getMostRecent;
-(void)getRecommended;

@end
