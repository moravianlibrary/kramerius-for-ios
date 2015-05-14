//
//  MZKDomainItem.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 09/05/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MZKDomainItem : NSObject


@property (nonatomic, strong) NSString *protocol;
@property (nonatomic, strong) NSString *domain;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *image;
@property (atomic, readwrite) BOOL unlocked;

-(NSString *)getURLString;
@end
