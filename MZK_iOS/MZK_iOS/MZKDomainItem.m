//
//  MZKDomainItem.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 09/05/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKDomainItem.h"

@implementation MZKDomainItem

-(NSString *)getURLString
{
    return [NSString stringWithFormat:@"%@://%@", self.protocol, self.domain];
}

@end
