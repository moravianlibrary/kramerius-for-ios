//
//  MZKSearchBarCollectionReusableView.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 28/11/15.
//  Copyright © 2015 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKSearchBarCollectionReusableView.h"

@implementation MZKSearchBarCollectionReusableView

-(void)removeSearchBarBorder
{
    if ([self.searchBar respondsToSelector:@selector(setBarTintColor:)]) {
        self.searchBar.barTintColor = [UIColor clearColor];
    }
}


@end
