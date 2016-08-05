//
//  MZKQueue.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 05/08/16.
//  Copyright © 2016 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKQueue.h"

@interface MZKQueue()

@property (strong) NSMutableArray *data;
@end

@implementation MZKQueue

-(instancetype)init{
    if (self = [super init]){
        _data = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)enqueue:(id)anObject{
    [self.data addObject:anObject];
}

-(id)dequeue{
    id headObject = [self.data objectAtIndex:0];
    if (headObject != nil) {
        [self.data removeObjectAtIndex:0];
    }
    return headObject;
}

-(NSUInteger)count
{
    return _data.count;
}


#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_data forKey:@"data"];
    
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self != nil)
    {
        _data = [coder decodeObjectForKey:@"data"];
    }
    return self;
}

@end
