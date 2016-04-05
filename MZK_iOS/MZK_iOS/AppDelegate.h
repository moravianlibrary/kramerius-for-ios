//
//  AppDelegate.h
//  MZK_iOS
//
//  Created by Ondrej Vyhlidal on 02/04/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZKResourceItem.h"
#import "MZKDatabaseManager.h"
#import "MZKItemResource.h"
#import "MZKTabBarMenuViewController.h"

@class MSDynamicsDrawerViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) MZKResourceItem *defaultDatasourceItem;
@property (nonatomic, strong) MZKDatabaseManager *dbManager;
@property (nonatomic, strong) NSArray *dbResultsInfo;
@property (nonatomic, strong) NSArray *dbInstitutionsInfo;
@property (nonatomic, strong) NSArray *dbLangInfo;
@property (nonatomic, strong) NSMutableArray *recentlyOpenedDocuments;
@property (nonatomic, strong) MZKTabBarMenuViewController *menuTabBar;


-(void)saveToUserDefaults:(MZKResourceItem *)item;
-(MZKResourceItem *)getDatasourceItem;
-(void)saveLastPlayedMusic:(NSString *)pid;
-(NSString *)loadLastPlayerMusic;

-(void)saveRecentlyOpened;
-(NSMutableArray *)loadRecentlyOpened;
-(void)addRecentlyOpenedDocument:(MZKItemResource *)item;

// get information from local db
-(NSArray *)getLanguageFromCode:(NSString *)languageCode;
-(NSString *)getLocationFromCode:(NSString *)locationCode;

-(void)transitionToMusicViewController;

@end

