//
//  MZKRecentlyOpenedDocumentsViewController.h
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 25/02/16.
//  Copyright © 2016 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKBaseViewController.h"
#import "MZKGeneralColletionViewController.h"

@interface MZKRecentlyOpenedDocumentsViewController : MZKGeneralColletionViewController<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) NSMutableArray *recentlyOpened;

-(void)setRecentlyOpened:(NSMutableArray *)recentlyOpened;

@end
