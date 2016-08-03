//
//  MZKSearchViewController.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 06/08/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZKBaseViewController.h"

@protocol MZKSearchDelegateProtocol <NSObject>

-(void)searchStarted;
-(void)searchEnded;

@end

@interface MZKSearchViewController : MZKBaseViewController<UISearchBarDelegate>

@property (nonatomic, weak) IBOutlet UIView *searchBarContainerView;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, assign) id<MZKSearchDelegateProtocol> delegate;

@end
