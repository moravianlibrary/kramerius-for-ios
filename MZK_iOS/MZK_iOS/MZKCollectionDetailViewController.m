//
//  MZKCollectionDetailViewController.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 14/09/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKCollectionDetailViewController.h"
#import "MZKDetailCollectionViewCell.h"
#import "MZKCollectionItemResource.h"
#import "MZKDatasource.h"
#import <SDWebImage/UIImageView+WebCache.h>


@interface MZKCollectionDetailViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, DataLoadedDelegate>
{
    MZKDatasource *_datasource;
    NSArray *_loadedItems;
}
@property (weak, nonatomic) IBOutlet UILabel *collectionName;
- (IBAction)onBack:(id)sender;

@end

@implementation MZKCollectionDetailViewController

- (void)viewDidLoad {
     // Do any additional setup after loading the view.
    [super viewDidLoad];
    self.collectionName.text = _selectedCollectionName;
    
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setItems:(NSArray *)items
{
    _items = items;
    if (!_datasource) {
        _datasource = [MZKDatasource new];
        _datasource.delegate = self;
    }
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
    MZKCollectionItemResource *item = [_items objectAtIndex:indexPath.row];
    
    newCell.itemNameLabel.text =item.title;
    
    NSString*url = @"http://kramerius.mzk.cz";
    NSString*path = [NSString stringWithFormat:@"%@//search/api/v5.0/item/%@/thumb",url, item.pid ];
    
    
    [newCell.itemIconImageview sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:nil];

    
   // newCell.cellLabel.text = [NSString stringWithFormat:@"Section:%d, Item:%d", indexPath.section, indexPath.item];
    return newCell;
}

- (IBAction)onBack:(id)sender {
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}
@end
