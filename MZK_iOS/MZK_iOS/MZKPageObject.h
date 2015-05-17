//
//  MZKPageObject.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 15/05/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MZKPageObject : NSObject
@property (readwrite) BOOL datanode;
@property (readwrite) NSInteger page;

@property (nonatomic, strong) NSString *pid;
@property (nonatomic, strong) NSString *model;
@property (nonatomic, strong) NSString *rootTitle;
@property (nonatomic, strong) NSString *rootPid;
@property (nonatomic, strong) NSString *policy;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSArray *title;

@end
