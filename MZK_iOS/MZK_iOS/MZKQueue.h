//
//  MZKQueue.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 05/08/16.
//  Copyright © 2016 Ondrej Vyhlidal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MZKQueue : NSObject<NSCoding>
-(void)enqueue:(id)anObject;
-(id)dequeue;
-(NSUInteger)count;

-(id)objectAtIndex:(NSUInteger)index;

-(void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)coder;

@end
