//
//  MZKPageObject.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 15/05/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MZKPageObject;
@protocol PageResolutionLoadedDelegate <NSObject>


-(void)pageLoadedForItem:(MZKPageObject *)pageObject;

@end

@interface MZKPageObject : NSObject
@property (nonatomic, weak) __weak id<PageResolutionLoadedDelegate> delegate;
@property (readwrite) BOOL datanode;
@property (readwrite) NSInteger page;
@property (nonatomic, strong) NSArray *author;
@property (nonatomic, strong) NSString *pid;
@property (nonatomic, strong) NSString *model;
@property (nonatomic, strong) NSString *rootTitle;
@property (nonatomic, strong) NSString *rootPid;
@property (nonatomic, strong) NSString *policy;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSArray *title;
@property (nonatomic, strong) NSNumber *titleStringValue;
@property (atomic, readwrite) NSInteger width;
@property (atomic, readwrite) NSInteger height;
@property (nonatomic, strong) NSString *stringTitleHack;

-(void)loadPageResolution;
-(NSString *)getAuthorsStringRepresentation;

@end
