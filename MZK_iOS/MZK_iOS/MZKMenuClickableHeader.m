//
//  MZKMenuClickableHeader.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 08/05/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKMenuClickableHeader.h"

@implementation MZKMenuClickableHeader

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (IBAction)onHeader:(id)sender {
    
    [self.delegate onMenuHeader];
}
@end
