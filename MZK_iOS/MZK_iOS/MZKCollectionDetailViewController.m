//
//  MZKCollectionDetailViewController.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 14/09/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKCollectionDetailViewController.h"
#import "MZKDetailCollectionViewCell.h"

@interface MZKCollectionDetailViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@end

@implementation MZKCollectionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - Collection View Delegate and Datasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    // just one section
    return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [_items count];
}

- (MZKDetailCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MZKDetailCollectionViewCell* newCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"MZKDetailCollectionViewCell"
                                                                           forIndexPath:indexPath];
    
   // newCell.cellLabel.text = [NSString stringWithFormat:@"Section:%d, Item:%d", indexPath.section, indexPath.item];
    return newCell;
}

@end
