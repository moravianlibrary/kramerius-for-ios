//
//  AppDelegate.m
//  MZK_iOS
//
//  Created by Ondrej Vyhlidal on 02/04/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import "AppDelegate.h"
#import "MZKConstants.h"
#import "MZKMusicViewController.h"
#import "MZKChangeLibraryViewController.h"
#import <Google/Analytics.h>
#import "AFNetworkActivityIndicatorManager.h"
#import "MZKTabBarMenuViewController.h"
#import "MZKDatasource.h"

@interface AppDelegate ()<DataLoadedDelegate>
{
    MZKDatasource *_datasource;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *recent = [defaults objectForKey:kSettingsShowOnlyPublicDocuments];
    if (!recent) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kSettingsShowOnlyPublicDocuments];
    }
    
    // check version of stored recently opened documents - no version means that it is old app so there is no migratio of data in that case reset
    NSNumber *version = [defaults objectForKey:kMinimalRecentSearches];
    if (!version || [version integerValue] != kMinimalRecentSearchesVersion) {
        [self resetDefaults];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:kMinimalRecentSearchesVersion] forKey:kMinimalRecentSearches];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        NSLog(@"Version is OK! SEARCHES");
    }
    
    // check version of stored recently opened documents - no version means that it is old app so there is no migratio of data in that case reset
    NSNumber *versionRecentDocuments = [defaults objectForKey:kRecentlyOpenedDocumentsVersion];
    if (!versionRecentDocuments || [versionRecentDocuments integerValue] != kMinimalRecentDocumentsVersion) {
        [self resetDefaults];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:kMinimalRecentDocumentsVersion] forKey:kRecentlyOpenedDocumentsVersion];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        NSLog(@"Version is OK! DOCS");
    }
    
    NSNumber *versionBookmarks= [defaults objectForKey:kMinimalBookmarkVersionKey];
    if (!versionBookmarks || [versionBookmarks integerValue] != kMinimalBookmarkVerion) {
        [defaults removeObjectForKey:kAllBookmarks];
        
        [defaults synchronize];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:kMinimalBookmarkVerion] forKey:kMinimalBookmarkVersionKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        NSLog(@"Version is OK! Bookmarks");
    }

    NSNumber *shouldDimmDisplay = [defaults objectForKey:kShouldDimmDisplay];
    
    if (!shouldDimmDisplay) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kShouldDimmDisplay];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    // check version of stored recently opened documents - no version means that it is old app so there is no migratio of data in that case reset
    NSNumber *libVersion = [defaults objectForKey:kMinimalLibrariesCacheVersion];
    if (!libVersion || [libVersion integerValue] != kMinimalLibrariesCacheVersionNumber) {
       
        [defaults removeObjectForKey:kMinimalLibrariesCacheVersion];
        [defaults removeObjectForKey:kDefaultDatasourceItem];
       
        [defaults synchronize];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:kMinimalLibrariesCacheVersionNumber] forKey:kMinimalLibrariesCacheVersion];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"Changed Version of Libraries");
    }
    else
    {
        NSLog(@"Version is OK! Libraries");
    }    // load data for libraries from regist krameriu
    
    self.defaultDatasourceItem = [self loadDatasourceFromUserDefaults];
    
    [self downloadLibrariesJsonFromServer];

    self.menuTabBar = (MZKTabBarMenuViewController*)self.window.rootViewController;
    
    self.menuTabBar.delegate = self;
    
    // Configure tracker from GoogleService-Info.plist.
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    // Optional: configure GAI options.
    GAI *gai = [GAI sharedInstance];
    gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
    gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release
    
    // track uncaught exceptions!
    [[GAI sharedInstance] setTrackUncaughtExceptions:YES];
    
 
    // init DB manager
    __weak typeof(self) wealf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        // Do the work associated with the task, preferably in chunks.
        wealf.dbManager = [[MZKDatabaseManager alloc] initWithDatabaseFilename:@"values.sql"];
        
        [wealf loadDataForInstitutions];
        [wealf loadDataForLanguages];
        [wealf loadDataForRelations];
        
    });
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    return YES;
}

-(void)downloadLibrariesJsonFromServer
{    // download json from server
    // save json
    _datasource = [[MZKDatasource alloc] initWithoutBaseURL];
    _datasource.delegate = self;
    [_datasource getLibraries];
}

#pragma mark - data loaded delegate methods
-(void)librariesLoaded:(NSArray *)results
{
    UINavigationController *controller = [[((UITabBarController *)self.window.rootViewController) viewControllers] objectAtIndex:kLibrariesViewControllerIndex];
    MZKChangeLibraryViewController *changeLibVC = [controller.viewControllers objectAtIndex:0];
    changeLibVC.libraries = results;
    
    if (results.count >0) {
        MZKLibraryItem *libItem = results[0];
        
        if (!self.defaultDatasourceItem) {
            [self saveToUserDefaults:libItem];
            // send notification about default library
            [[NSNotificationCenter defaultCenter] postNotificationName:kDatasourceItemChanged object:nil];
        }
    }
}

// error states
-(void)downloadFailedWithError:(NSError *)error
{
    if([error.domain isEqualToString:NSURLErrorDomain])
    {
        // load from cache;
        // inform user that there is problem with connection

    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    [self saveRecentlyOpened];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)setDefaultDatasource
{
    //load from user defaults
    MZKLibraryItem *item  = [self loadDatasourceFromUserDefaults];
    if (item) {
        self.defaultDatasourceItem = item;
    }
    else
    {
        // notify user about connection problems, check wifi and try again
    }
    self.recentlyOpenedDocuments = nil;
    
    [self loadRecentlyOpened];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDatasourceItemChanged object:nil];
}

-(MZKLibraryItem*)loadDatasourceFromUserDefaults
{
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *dataRepresentingDatasource = [currentDefaults objectForKey:kDefaultDatasourceItem];
    MZKLibraryItem *savedLibrary;
    if (dataRepresentingDatasource)
    {
        savedLibrary = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingDatasource];
        if (!savedLibrary) {
            // nothing was saved - save new value!
        }
    }
    
    return savedLibrary;
}

-(void)saveToUserDefaults:(MZKLibraryItem *)item
{
    if (![self.defaultDatasourceItem.name isEqualToString:item.name]) {

        self.defaultDatasourceItem = item;
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:item] forKey:kDefaultDatasourceItem];
        
        [[NSUserDefaults standardUserDefaults] synchronize];

        [self.menuTabBar setSelectedIndex:0];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kDatasourceItemChanged object:nil];
    }
}

-(MZKLibraryItem *)getDatasourceItem
{
      return self.defaultDatasourceItem;
}

-(void)saveLastPlayedMusic:(NSString *)pid
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:pid forKey:kRecentMusicPlayed];
    [defaults synchronize];
}

-(NSString *)loadLastPlayerMusic
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *recent = [defaults objectForKey:kRecentMusicPlayed];
    return recent;
}

-(void)loadDataForInstitutions
{
    // Form the query.
    NSString *query = @"select * from institution";
    _dbInstitutionsInfo = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    if (_dbInstitutionsInfo.count ==0) {
        // insert values
        [self insertValuesToInstitution];
    }
    NSLog(@"Vaues count: %lu", (unsigned long)_dbInstitutionsInfo.count);
    
}

-(void)loadDataForRelations
{
    // Form the query.
    NSString *query = @"select * from relator";
    _dbResultsInfo = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    if (_dbResultsInfo.count ==0) {
        // insert values
        [self insertValuesToRelator];
    }
    NSLog(@"Vaues count: %lu", (unsigned long)_dbResultsInfo.count);
    
}

-(void)loadDataForLanguages
{
    // Form the query.
    NSString *query = @"select * from language";
    _dbLangInfo = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    if (_dbLangInfo.count ==0) {
        // insert values
        [self insertValuesToLanguage];
    }
    NSLog(@"Vaues count: %lu", (unsigned long)_dbLangInfo.count);
    
}

-(void)insertValuesToInstitution
{
    NSString *fileContent = [self getFileWithName:@"inst"];
    [self splitAndExecute:fileContent];
    
}

-(void)insertValuesToRelator
{
    NSString *fileContent = [self getFileWithName:@"relators"];
    [self splitAndExecute:fileContent];
    
}

-(void)insertValuesToLanguage
{
    NSString *fileContent = [self getFileWithName:@"languages"];
    [self splitAndExecute:fileContent];
}

-(NSString *)getFileWithName:(NSString *)name
{
    NSError *error;
    NSString *strFileContent = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]
                                                                   pathForResource:name ofType: @"sql"] encoding:NSUTF8StringEncoding error:&error];
    if(error) {
        NSLog(@"Error while loading a file");
    }
    
    return strFileContent;
}

-(void)splitAndExecute:(NSString *)fileContent
{
    NSArray* allLinedStrings = [fileContent componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    for (NSString *s in allLinedStrings) {
        [self.dbManager executeQuery:s];
    }
}

#pragma mark - recently opened documents handling

-(void)saveRecentlyOpened
{
    if (_recentlyOpenedDocuments) {
        
        NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
        NSData *dataRepresentingSavedArray = [currentDefaults objectForKey:kRecentlyOpenedDocuments];
        
        NSMutableDictionary *savedData = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedArray];
        
        if (!savedData) {
            savedData = [NSMutableDictionary new];
        }
        
        [savedData setObject:_recentlyOpenedDocuments forKey:self.defaultDatasourceItem.code];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:savedData] forKey:kRecentlyOpenedDocuments];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(NSMutableArray *)loadRecentlyOpened
{
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *dataRepresentingSavedArray = [currentDefaults objectForKey:kRecentlyOpenedDocuments];
    if (dataRepresentingSavedArray)
    {
        NSMutableDictionary *savedData = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedArray];
        if (!savedData) {
            savedData = [NSMutableDictionary new];
        }
        
        NSArray *recentlyOpenedDocumentForLibrary = [savedData objectForKey:self.defaultDatasourceItem.code];
        
        if (recentlyOpenedDocumentForLibrary) {
            _recentlyOpenedDocuments = [[NSMutableArray alloc] initWithArray:recentlyOpenedDocumentForLibrary];
        }
        
    }
    
    if (!_recentlyOpenedDocuments) {
        _recentlyOpenedDocuments = [NSMutableArray new];
    }
    
    return _recentlyOpenedDocuments;
}

-(void)addRecentlyOpenedDocument:(MZKItemResource *)item
{
    _recentlyOpenedDocuments = [self loadRecentlyOpened];
    
    if (_recentlyOpenedDocuments.count>0) {
        if (![self wasDocumentRecentlyOpened:item.pid]) {
            [_recentlyOpenedDocuments addObject:item];
        }
        else
        {
            [self updateRecentlyOpenedDocument:item withDate:item.lastOpened];
        }
    }
    else
    {
        [_recentlyOpenedDocuments addObject:item];
    }

    [self saveRecentlyOpened];
}

-(BOOL)wasDocumentRecentlyOpened:(NSString *)uuid
{
    for (MZKItemResource* rItem in _recentlyOpenedDocuments) {
        if ([rItem.pid caseInsensitiveCompare:uuid] == NSOrderedSame ) {
            return YES;
        }
    }
    return NO;
}

-(void)updateRecentlyOpenedDocument:(MZKItemResource *)item withDate:(NSString *)strDate
{
    for (MZKItemResource *rItem in _recentlyOpenedDocuments) {
        if (rItem.pid == item.pid) {
            rItem.lastOpened = strDate;
        }
    }
}

- (void)resetDefaults {
    // enhancement - split into separated methods (in case that we want to delete just one type of stored data)
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    [defs removeObjectForKey:kRecentlyOpenedDocuments];
    [defs removeObjectForKey:kRecentSearches];
    [defs removeObjectForKey:kAllBookmarks];

    [defs synchronize];
}


-(NSArray *)getLanguageFromCode:(NSString *)languageCode
{
    // for
    for (NSArray *array in _dbLangInfo) {
        
        if ([array[0] caseInsensitiveCompare:languageCode] ==NSOrderedSame && ([array[2] caseInsensitiveCompare:@"cs"] ==NSOrderedSame)) {
            return array;
        }
        
    }
    
    return nil;
}

-(NSString *)getLocationFromCode:(NSString *)locationCode
{
    for (NSArray *array in _dbInstitutionsInfo) {
        
        if ([array[0] caseInsensitiveCompare:locationCode] ==NSOrderedSame) {
            return array[1];
        }
        
    }
    return nil;
}

#pragma mark - menu tab bar

-(void)transitionToMusicViewControllerWithSelectedMusic:(NSString *)pid
{
    [self.menuTabBar setSelectedIndex:4];
    
    if ([[self.menuTabBar.viewControllers objectAtIndex:4] isKindOfClass:[UINavigationController class]]) {
        
        NSArray *vc =self.menuTabBar.viewControllers;
        
        NSArray *morecontrollers = [self.menuTabBar.moreNavigationController viewControllers];
        if (morecontrollers.count >1) {
            MZKMusicViewController *tmpMusicVC = [morecontrollers objectAtIndex:1];
            [tmpMusicVC setItemPID:pid];
            tmpMusicVC.view;
        }else{
            UINavigationController *tmpNav = [self.menuTabBar.viewControllers objectAtIndex:4];
            MZKMusicViewController *tmpMusicVC = tmpNav.viewControllers[0];
            [tmpMusicVC setItemPID:pid];
            tmpMusicVC.view;
        }
    }
    
}

-(void) tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if([viewController isKindOfClass:[UINavigationController class]])
    {
    }
}


@end
