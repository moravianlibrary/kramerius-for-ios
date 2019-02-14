//
//  MZKItemResource.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 20/04/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MZKConstants.h"

@interface MZKItemResource : NSObject<NSCoding>
//primary model
@property (nonatomic, assign) MZKModel model;
@property (nonatomic, strong) NSString *pid;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *authors;
@property (nonatomic, strong) NSArray *author;
@property (nonatomic, strong) NSString *rootTitle;
@property (nonatomic, strong) NSString *rootPid;
@property (nonatomic, strong) NSArray *context;
@property (nonatomic, strong) NSArray *collections;
@property (nonatomic, strong) NSArray *replicatedFrom;
@property (atomic, readwrite) BOOL datanode;

@property (nonatomic, strong) NSDictionary *zoom;
@property (nonatomic, strong) NSString *pdfUrl;
@property (nonatomic, strong) NSString *issn;
@property (nonatomic, strong) NSString *policy;
@property (nonatomic, strong) NSString *datumStr;
@property (nonatomic, strong) NSString *lastOpened;
@property (nonatomic, strong) NSString *issueNumber;
@property (nonatomic, strong) NSString *year;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *volumeNumber;
@property (nonatomic, strong) NSNumber *indexLastOpenedPage;
@property (nonatomic, strong) NSString *fallbackModel;

-(NSString *)getAuthorsStringRepresentation;
-(NSString *)getLocalizedItemType;
-(void)setModel:(MZKModel)model;
-(void)encodeWithCoder:(NSCoder *)aCoder;
-(id)initWithCoder:(NSCoder *)coder;

- (BOOL)isModelMusic;

@end
