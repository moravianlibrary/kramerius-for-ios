//
//  TabBarMenuViewController.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 05/04/16.
//  Copyright © 2016 Ondrej Vyhlidal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZKMusicViewController.h"
#import "MZKChangeLibraryViewController.h"

@interface MZKTabBarMenuViewController : UITabBarController<UINavigationControllerDelegate>

@property (nonatomic, strong) IBOutlet MZKMusicViewController *musicVC;

@end
