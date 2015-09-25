//
//  AppDelegate.h
//  MZK_iOS
//
//  Created by Ondrej Vyhlidal on 02/04/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZKResourceItem.h"

@class MSDynamicsDrawerViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MSDynamicsDrawerViewController *dynamicsDrawerViewController;
@property (nonatomic, strong) MZKResourceItem *defaultDatasourceItem;

-(void)saveToUserDefaults:(MZKResourceItem *)item;
-(MZKResourceItem *)getDatasourceItem;


@end

