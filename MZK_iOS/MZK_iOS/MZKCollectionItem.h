//
//  MZKCollectionItem.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 07/08/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MZKCollectionItem: NSObject
@property (nonatomic, strong) NSString *pid;
@property (nonatomic, strong) NSString *nameCZ;
@property (nonatomic, strong) NSString *nameENG;
@property (nonatomic, strong) NSString *label;
@property (readwrite) BOOL canLeave;
@property (nonatomic, readwrite) NSInteger numberOfDocuments;
@property (nonatomic, strong) NSString *longDescriptionCZ;
@property (nonatomic, strong) NSString *longDescriptionENG;

@end
