//
//  MZKDetailInformationModel.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 08/01/16.
//  Copyright © 2016 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKDetailInformationModel.h"
@implementation MZKDetailPlaceInfo

@end

@implementation MZKDetailOriginInfo

@end

@implementation MZKDetailIdentifierInfo

@end

@implementation MZKDetailRecordChangeDateInfo

@end

@implementation MZKDetailInfoLineModel

@end

@implementation MZKDetailAuthorsInfo
-(NSString *)getRolesStringRepresentation
{
    return [NSString new];
}
@end


@implementation MZKDetailInformationModel

-(NSArray *)transformModelIntoArray
{
    _arrayToBeDisplayed = [NSMutableArray new];
    
    return _arrayToBeDisplayed;
}

@end
