//
//  MZKMenuViewController.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 04/05/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZKMenuTableViewCell.h"
#import <MSDynamicsDrawerViewController.h>

typedef NS_ENUM(NSUInteger, MSPaneViewControllerType) {
    MZKMainViewController,
    MZKCollectionsViewController,
    MSPaneViewControllerTypeBounce,
    MSPaneViewControllerTypeGestures,
    MSPaneViewControllerTypeControls,
    MSPaneViewControllerTypeMap,
    MSPaneViewControllerTypeEditableTable,
    MSPaneViewControllerTypeLongTable,
    MSPaneViewControllerTypeMonospace,
    MSPaneViewControllerTypeCount
};

@interface MZKMenuViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, assign) MSPaneViewControllerType paneViewControllerType;
@property (nonatomic, weak) MSDynamicsDrawerViewController *dynamicsDrawerViewController;
- (void)transitionToViewController:(MSPaneViewControllerType)paneViewControllerType;

@end
