//
//  MZKCollectionItemResource.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 17/09/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKItemResource.h"

@interface MZKCollectionItemResource : MZKItemResource

@property (nonatomic, strong) NSString *documentType;
@property (nonatomic, strong) NSString *documentCreator;
@property (nonatomic, strong) NSString *documentTitle;
@property (nonatomic, strong) NSString *parentPID;
@property (nonatomic, strong) NSString *year;
@property (nonatomic, strong) NSString *collectionID;
@property (nonatomic, readwrite) NSInteger start;
@property (nonatomic, readwrite) NSInteger numFound;

@end
