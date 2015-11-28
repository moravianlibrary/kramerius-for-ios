//
//  MZKSearchBarCollectionReusableView.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 28/11/15.
//  Copyright © 2015 Ondrej Vyhlidal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MZKSearchBarCollectionReusableView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

-(void)removeSearchBarBorder;

@end
