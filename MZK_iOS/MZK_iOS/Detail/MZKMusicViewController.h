//
//  MZKMusicViewController.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 10/11/15.
//  Copyright © 2015 Ondrej Vyhlidal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZKItemResource.h"


@interface MZKMusicViewController : UIViewController

@property (nonatomic, strong) MZKItemResource *item;
+(instancetype)sharedInstance;
-(void)setItem:(MZKItemResource *)item;
-(void)setItemPID:(NSString *)itemPid;

@end
