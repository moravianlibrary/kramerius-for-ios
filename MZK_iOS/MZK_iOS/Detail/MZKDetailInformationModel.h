//
//  MZKDetailInformationModel.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 08/01/16.
//  Copyright © 2016 Ondrej Vyhlidal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MZKDetailIdentifierInfo : NSObject
@property (nonatomic, strong) NSString *issn;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *isbn;
@property (nonatomic, strong) NSString *oclc;
@property (nonatomic, strong) NSString *ccnb;
@property (nonatomic, strong) NSString *sysno;
@end

@interface MZKDetailPublishersInfo : NSObject
@property (nonatomic, strong) NSString *publisher;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *place;

@end

@interface MZKDetailPartInfo : NSObject
@property (nonatomic, strong) NSString *volume;
@property (nonatomic, strong) NSString *issue;
@property (nonatomic, strong) NSString *part;
@property (nonatomic, strong) NSString *pageNumber;
@property (nonatomic, strong) NSString *pageIndex;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *text;

@end

@interface MZKDetailCartographicInfo : NSObject
@property (nonatomic, strong) NSString *scale;
@property (nonatomic, strong) NSString *coordinates;
@end

@interface MZKDetailAuthorsInfo : NSObject
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *sureName;

@property (nonatomic, strong) NSArray *rolesInfo;
-(NSString *)getRolesStringRepresentation;


@end

@interface MZKDetailPlaceInfo : NSObject
@property (nonatomic, strong) NSString *authority;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *type;
@end

@interface MZKDetailOriginInfo : NSObject
@property (nonatomic, strong) NSString *publisher;
@property (nonatomic, strong) NSString *place;
@property (nonatomic, strong) NSString *dateIssued;
@property (nonatomic, strong) NSArray *places;
@end

@interface MZKDetailLocationInfo : NSObject
@property (nonatomic, strong) NSString *physicalLocation;
@property (nonatomic, strong) NSArray *shelfLocations;
-(NSString *)getShelfLocationsStringRepresentation;

@end

@interface MZKDetailRecordChangeDateInfo : NSObject
@property (nonatomic, strong) NSString *encoding;
@property (nonatomic, strong) NSString *date;
@end

@interface MZKDetailInformationModel : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subTitle;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *languageNme;
@property (nonatomic, strong) NSString *languageID;
@property (nonatomic, strong) NSString *languageAuthority;
@property (nonatomic, strong) NSString *partTitle;
@property (nonatomic, strong) NSString *partNumber;
@property (nonatomic, strong) NSString *physicalDescription;
@property (nonatomic, strong) NSString *physicalFormDescription;
@property (nonatomic, strong) NSString *recordContentSourceCode;
@property (nonatomic, strong) NSString *recordSourceIdentifier;
@property (nonatomic, strong) NSString *recordSourceTextIdentifier;

@property (nonatomic, strong) NSArray *originInfos;
@property (nonatomic, strong) NSString *shelfLocation;
@property (nonatomic, strong) NSString *physicalLocation;
@property (nonatomic, strong) MZKDetailIdentifierInfo *identifiersInfo;
@property (nonatomic, strong) MZKDetailOriginInfo *placeInfo;
@property (nonatomic, strong) NSArray *publishersInfo;
@property (nonatomic, strong) NSArray *recordChangeDates;
@property (nonatomic, strong) NSArray *recordCreationDates;

@end
