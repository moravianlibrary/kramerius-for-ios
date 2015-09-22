//
//  MZKCollectionDetailViewController.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 14/09/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MZKCollectionDetailViewController : UIViewController
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSString *selectedCollectionName;

@end
