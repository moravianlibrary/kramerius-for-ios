//
//  MZKSearchHistoryItem.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 25/07/16.
//  Copyright © 2016 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKSearchHistoryItem.h"

@implementation MZKSearchHistoryItem

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_pid forKey:@"pid"];
    [coder encodeObject:_title forKey:@"title"];
    [coder encodeObject:_timestamp forKey:@"timestamp"];
    
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self != nil)
    {
        _pid = [coder decodeObjectForKey:@"pid"];
        _title = [coder decodeObjectForKey:@"title"];
        _timestamp = [coder decodeObjectForKey:@"timestamp"];
    }
    return self;
}


@end
