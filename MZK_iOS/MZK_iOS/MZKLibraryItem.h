//
//  MZKResourceItem.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 24/08/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MZKLibraryItem : NSObject<NSCoding>

@property (atomic) NSUInteger libID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *nameEN;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *logoURL;
@property (nonatomic, strong) NSString *libraryURL;// url for detail info about lib

-(void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)coder;

@end
