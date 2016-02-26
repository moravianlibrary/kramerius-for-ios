//
//  AppDelegate.m
//  MZK_iOS
//
//  Created by Ondrej Vyhlidal on 02/04/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import "AppDelegate.h"
#import "MZKMenuViewController.h"
#import  "MZKConstants.h"
#import "MSDynamicsDrawerViewController.h"
#import "MZKConstants.h"
#import <Google/Analytics.h>

@interface AppDelegate ()<MSDynamicsDrawerViewControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *recent = [defaults objectForKey:kSettingsShowOnlyPublicDocuments];
    if (!recent) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kSettingsShowOnlyPublicDocuments];
    }
    
    
    self.dynamicsDrawerViewController = (MSDynamicsDrawerViewController *)self.window.rootViewController;
    
    //setup menu and dynamic drawer
    self.dynamicsDrawerViewController.delegate = self;
    [self.dynamicsDrawerViewController addStylersFromArray:@[[MSDynamicsDrawerParallaxStyler styler]] forDirection:MSDynamicsDrawerDirectionLeft];
    
    
    MZKMenuViewController *menuViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"MZKMenuViewController"];
    menuViewController.dynamicsDrawerViewController = self.dynamicsDrawerViewController;
    [self.dynamicsDrawerViewController setDrawerViewController:menuViewController forDirection:MSDynamicsDrawerDirectionLeft];
    
    
    // Transition to the first view controller
    [menuViewController transitionToViewController:MZKMainViewController];
    
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
    
    
    
    if (!self.defaultDatasourceItem) {
        [self setDefaultDatasource];
    }
    
    // init DB manager
    
    __weak typeof(self) wealf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        // Do the work associated with the task, preferably in chunks.
        wealf.dbManager = [[MZKDatabaseManager alloc] initWithDatabaseFilename:@"values.sql"];
        
        [wealf loadDataForInstitutions];
        [wealf loadDataForLanguages];
        [wealf loadDataForRelations];
        
    });
    
    self.window.rootViewController = self.dynamicsDrawerViewController;
    
    [self loadRecentlyOpened];
    
    return YES;
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
    MZKResourceItem *item  = [self loadDatasourceFromUserDefaults];
    if (item) {
        self.defaultDatasourceItem = item;
    }else
    {
        MZKResourceItem *item1 = [MZKResourceItem new];
        item1.name = @"Moravská zemská knihovna";
        item1.protocol = @"http";
        item1.stringURL = @"kramerius.mzk.cz";
        item1.imageName = @"logo_mzk";
        
        self.defaultDatasourceItem = item1;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDatasourceItemChanged object:nil];
}

-(MZKResourceItem*)loadDatasourceFromUserDefaults
{
    MZKResourceItem *item = [MZKResourceItem new];
    item.protocol = [[NSUserDefaults standardUserDefaults] stringForKey:kDefaultDatasourceProtocol];
    item.name = [[NSUserDefaults standardUserDefaults] stringForKey:kDefaultDatasourceName];
    item.stringURL = [[NSUserDefaults standardUserDefaults] stringForKey:kDefaultDatasourceStringURL];
    item.imageName = [[NSUserDefaults standardUserDefaults] stringForKey:kDefaultImageName];
    
    
    if (item.protocol && item.stringURL && item.imageName &&item.name) {
        //NSLog(@"ItemLoaded");
        return item;
    }else return nil;
}

-(void)saveToUserDefaults:(MZKResourceItem *)item
{
    self.defaultDatasourceItem  =item;
    [[NSUserDefaults standardUserDefaults] setObject:item.name forKey:kDefaultDatasourceName];
    [[NSUserDefaults standardUserDefaults] setObject:item.stringURL forKey:kDefaultDatasourceStringURL];
    [[NSUserDefaults standardUserDefaults] setObject:item.imageName forKey:kDefaultImageName];
    [[NSUserDefaults standardUserDefaults] setObject:item.protocol forKey:kDefaultDatasourceProtocol];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self setDefaultDatasource];
}

-(MZKResourceItem *)getDatasourceItem
{
    if (!self.defaultDatasourceItem) {
        [self setDefaultDatasource];
    }
    
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
    _dbInstitutionsInfo = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    if (_dbInstitutionsInfo.count ==0) {
        // insert values
        [self insertValuesToRelator];
    }
    NSLog(@"Vaues count: %lu", (unsigned long)_dbInstitutionsInfo.count);
    
}

-(void)loadDataForLanguages
{
    // Form the query.
    NSString *query = @"select * from language";
    _dbInstitutionsInfo = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    if (_dbInstitutionsInfo.count ==0) {
        // insert values
        [self insertValuesToLanguage];
    }
    NSLog(@"Vaues count: %lu", (unsigned long)_dbInstitutionsInfo.count);
    
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

        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_recentlyOpenedDocuments] forKey:kRecentlyOpenedDocuments];
                [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(NSMutableArray *)loadRecentlyOpened
{
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *dataRepresentingSavedArray = [currentDefaults objectForKey:kRecentlyOpenedDocuments];
    if (dataRepresentingSavedArray)
    {
        NSArray *oldSavedArray = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedArray];
        if (oldSavedArray )
            _recentlyOpenedDocuments = [[NSMutableArray alloc] initWithArray:oldSavedArray];
        
    }

    if (!_recentlyOpenedDocuments) {
        _recentlyOpenedDocuments = [NSMutableArray new];
    }
    
    return _recentlyOpenedDocuments;
}

-(void)addRecentlyOpenedDocument:(MZKItemResource *)document
{
    if (!_recentlyOpenedDocuments) {
        _recentlyOpenedDocuments = [self loadRecentlyOpened];
    }
    
    [_recentlyOpenedDocuments addObject:document];
    [self saveRecentlyOpened];
}



@end
