//
//  MZKDetailViewController.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 12/05/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZKItemResource.h"

@interface MZKDetailViewController : UIViewController

@property (nonatomic, strong) MZKItemResource *item;

-(void)setItem:(MZKItemResource *)item;


@end
