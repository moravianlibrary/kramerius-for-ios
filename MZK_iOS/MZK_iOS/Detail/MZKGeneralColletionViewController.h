//
//  MZKGeneralColletionViewController.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 10/11/15.
//  Copyright © 2015 Ondrej Vyhlidal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZKItemResource.h"
#import "MZKBaseViewController.h"

@interface MZKGeneralColletionViewController : MZKBaseViewController

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) MZKItemResource *parentObject;
@property (nonatomic, strong) NSString *parentPID;
@property (nonatomic, readwrite) BOOL isFirst;
@property (nonatomic, readwrite) BOOL shouldShowSearchBar;
@property (nonatomic, readwrite) BOOL shouldDisplayFilters;
@property (nonatomic, strong) NSString *searchTerm;

-(void)setItems:(NSArray *)items;
-(void)setParentObject:(MZKItemResource *)parentObject;
-(void)setParentPID:(NSString *)parentPID;
@end
