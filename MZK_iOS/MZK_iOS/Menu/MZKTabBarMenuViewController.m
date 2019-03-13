//
//  TabBarMenuViewController.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 05/04/16.
//  Copyright © 2016 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKTabBarMenuViewController.h"
#import "MZKPlaceholderViewController.h"
#import "AppDelegate.h"

@interface MZKTabBarMenuViewController ()

@end

@implementation MZKTabBarMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.customizableViewControllers = @[];

    NSLog(@"ViewControllers: %@", [self.viewControllers description]);

    if (self.viewControllers.count < 6) {
        NSMutableArray *controllers = [NSMutableArray arrayWithArray:self.viewControllers];

        UITabBarItem *musicItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"mzk.musicPlayer", @"Player title") image:[UIImage imageNamed:@"player_filled_b"] tag:5];

        MZKPlaceholderViewController *musicVc = [[MZKPlaceholderViewController alloc] init];

        [controllers addObject:musicVc];
        [self setViewControllers:controllers];

        UIViewController *last = [self.viewControllers lastObject];
        last.tabBarItem = musicItem;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
