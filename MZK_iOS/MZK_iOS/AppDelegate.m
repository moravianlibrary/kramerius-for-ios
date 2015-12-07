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
#import <MSDynamicsDrawerViewController.h>
#import "MZKConstants.h"
#import <Google/Analytics.h>

@interface AppDelegate ()<MSDynamicsDrawerViewControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
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
    

    self.window.rootViewController = self.dynamicsDrawerViewController;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
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
        NSLog(@"ItemLoaded");
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
    
    [self setDefaultDatasource];
}

-(MZKResourceItem *)getDatasourceItem
{
    if (!self.defaultDatasourceItem) {
        [self setDefaultDatasource];
    }
    
    return self.defaultDatasourceItem;
}

@end
