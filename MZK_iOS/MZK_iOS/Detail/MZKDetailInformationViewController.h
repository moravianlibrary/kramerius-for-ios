//
//  MZKDetailInformationViewController.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 04/01/16.
//  Copyright © 2016 Ondrej Vyhlidal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZKBaseViewController.h"

@interface MZKDetailInformationViewController : MZKBaseViewController
@property (nonatomic, strong) NSString *item;

-(void)setItem:(NSString *)item;

@end
