//
//  MZKSearchHistoryItem.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 25/07/16.
//  Copyright © 2016 Ondrej Vyhlidal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MZKSearchHistoryItem : NSObject<NSCoding>
@property (nonatomic, strong) NSNumber *timestamp;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *pid;

-(void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)coder;

@end
