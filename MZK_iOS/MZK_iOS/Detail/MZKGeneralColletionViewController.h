//
//  MZKGeneralColletionViewController.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 10/11/15.
//  Copyright © 2015 Ondrej Vyhlidal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZKItemResource.h"

@interface MZKGeneralColletionViewController : UIViewController

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) MZKItemResource *parentObject;
@property (nonatomic, strong) NSString *parentPID;
@property (nonatomic, readwrite) BOOL isFirst;

-(void)setItems:(NSArray *)items;
-(void)setParentObject:(MZKItemResource *)parentObject;
-(void)setParentPID:(NSString *)parentPID;
@end
