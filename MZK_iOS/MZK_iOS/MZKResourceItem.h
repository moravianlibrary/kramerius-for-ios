//
//  MZKResourceItem.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 24/08/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MZKResourceItem : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *protocol;
@property (nonatomic, strong) NSString *stringURL;
@property (nonatomic, strong) NSString *imageName;

@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *libraryURL;
@property (nonatomic, strong) NSString *code;
@property (atomic) NSUInteger libID;

@end
