//
//  MZKDomainHolder.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 09/05/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKDomainHolder.h"
#import "MZKDomainItem.h"

@implementation MZKDomainHolder
{
    NSMutableArray *items;
}

-(void)createArray
{
    items = [NSMutableArray new];
    MZKDomainItem *item1 = [MZKDomainItem new];
    item1.domain = @"http://kramerius.mzk.cz/";
    item1.protocol = @"http";
    item1.title = @"Kramerius";
    [items addObject:item1];
}

-(MZKDomainItem *)getItemForKey:(NSString *)key
{
    return [items objectAtIndex:0];
}

@end
