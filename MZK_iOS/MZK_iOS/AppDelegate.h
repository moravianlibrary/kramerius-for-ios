//
//  AppDelegate.h
//  MZK_iOS
//
//  Created by Ondrej Vyhlidal on 02/04/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZKLibraryItem.h"
#import "MZKDatabaseManager.h"
#import "MZKItemResource.h"


@class MZKTabBarMenuViewController;
@class MSDynamicsDrawerViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) MZKLibraryItem *defaultDatasourceItem;
@property (nonatomic, strong) MZKDatabaseManager *dbManager;
@property (nonatomic, strong) NSArray *dbResultsInfo;
@property (nonatomic, strong) NSArray *dbInstitutionsInfo;
@property (nonatomic, strong) NSArray *dbLangInfo;
@property (nonatomic, strong) NSMutableArray *recentlyOpenedDocuments;
@property (nonatomic, strong) MZKTabBarMenuViewController *menuTabBar;
@property (nonatomic, strong) NSMutableDictionary *recentlyOpenedDocumentsDictionary;


+(BOOL)connected;

-(void)saveToUserDefaults:(MZKLibraryItem *)item;
-(MZKLibraryItem *)getDatasourceItem;
-(void)saveLastPlayedMusic:(NSString *)pid;
-(NSString *)loadLastPlayerMusic;

-(void)saveRecentlyOpened;
-(NSMutableArray *)loadRecentlyOpened;
-(void)addRecentlyOpenedDocument:(MZKItemResource *)item;

// get information from local db
-(NSArray *)getLanguageFromCode:(NSString *)languageCode;
-(NSString *)getLocationFromCode:(NSString *)locationCode;
// deprecated method
-(void)transitionToMusicViewControllerWithSelectedMusic:(NSString *)pid;
// replacement of deprecated method
-(void)presentMusicViewControllerWithMusic:(NSString *)pid;

@end

