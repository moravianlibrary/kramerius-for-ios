//
//  MZKCollectionDetailViewController.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 14/09/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZKBaseViewController.h"

@interface MZKCollectionDetailViewController : MZKBaseViewController
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSString *selectedCollectionName;
@property (nonatomic, strong) NSString *collectionPID;

@end
