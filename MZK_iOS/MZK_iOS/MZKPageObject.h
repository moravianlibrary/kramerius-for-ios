//
//  MZKPageObject.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 15/05/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MZKConstants.h"

@class MZKPageObject;
@protocol PageResolutionLoadedDelegate <NSObject>
-(void)pageLoadedForItem:(MZKPageObject *)pageObject;
-(void)pageNotAvailable;
-(void)pageResolutionDownloadFailed;

@optional
-(void)pageResolutionDownloadFailedWithError:(NSError *)error;

@end

@interface MZKPageObject : NSObject
{
    NSString *baseURL;
}

@property (nonatomic, weak) __weak id<PageResolutionLoadedDelegate> delegate;
@property (readwrite) BOOL datanode;
@property (readwrite) NSInteger page;
@property (nonatomic, strong) NSArray *author;
@property (nonatomic, strong) NSString *pid;
@property (nonatomic, assign) MZKModel model;
@property (nonatomic, strong) NSString *rootTitle;
@property (nonatomic, strong) NSString *rootPid;
@property (nonatomic, strong) NSString *policy;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *title;
@property (atomic, readwrite) NSInteger width;
@property (atomic, readwrite) NSInteger height;
@property (nonatomic, strong) NSString *year;
@property (nonatomic, strong) NSString *volumeNumber; // rocnik
@property (nonatomic, strong) NSString *partNumber; //
@property (nonatomic, strong) NSString *date; //
@property (nonatomic, strong) NSString *issueNumber; //

-(void)loadPageResolution;
-(NSString *)getAuthorsStringRepresentation;
-(NSString *)getLocalizedItemType;

@end
