//
//  MZKResourceItem.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 24/08/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKLibraryItem.h"

@implementation MZKLibraryItem

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:[NSNumber numberWithUnsignedInteger:_libID] forKey:@"libID"];
    [coder encodeObject:_name forKey:@"name"];
    [coder encodeObject:_nameEN forKey:@"name_en"];
    [coder encodeObject:_code forKey:@"code"];
    [coder encodeObject:_url forKey:@"url"];
    [coder encodeObject:_version forKey:@"version"];
    [coder encodeObject:_logoURL forKey:@"logo"];
    [coder encodeObject:_libraryURL forKey:@"library_url"];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self != nil)
    {
        _libID = [[coder decodeObjectForKey:@"libID"] integerValue];
        _name = [coder decodeObjectForKey:@"name"];
        _nameEN = [coder decodeObjectForKey:@"name_en"];
        _code = [coder decodeObjectForKey:@"code"];
        _url = [coder decodeObjectForKey:@"url"];
        _version = [coder decodeObjectForKey:@"version"];
        _logoURL = [coder decodeObjectForKey:@"logo"];
        _libraryURL = [coder decodeObjectForKey:@"library_url"];
    }
    return self;
}


@end
