//
//  MZKGeneralColletionViewController.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 10/11/15.
//  Copyright © 2015 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKGeneralColletionViewController.h"
#import "MZKItemCollectionViewCell.h"
#import "AppDelegate.h"
#import <UIImageView+WebCache.h>

@interface MZKGeneralColletionViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *_collectionView;
@property (weak, nonatomic) IBOutlet UIView *_headerView;
@property (weak, nonatomic) IBOutlet UIButton *_backButton;

@end

@implementation MZKGeneralColletionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setItems:(NSArray *)items
{
    _items = items;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - CollectionView Delegate and Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    
   return _items.count;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (MZKItemCollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MZKItemCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"MZKItemCollectionViewCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    
    MZKItemResource *item = [_items objectAtIndex:indexPath.row];
    if (item) {
        cell.itemName.text = item.title;
        cell.itemAuthors.text = item.authors;
        cell.item = item;
        cell.itemType.text = item.model;
        
        
        AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        
        NSString*url = [NSString stringWithFormat:@"%@://%@", delegate.defaultDatasourceItem.protocol, delegate.defaultDatasourceItem.stringURL];
        NSString*path = [NSString stringWithFormat:@"%@//search/api/v5.0/item/%@/thumb",url, item.pid ];
        
        
        [cell.itemImage sd_setImageWithURL:[NSURL URLWithString:path]
                          placeholderImage:nil];
    }
    
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MZKItemCollectionViewCell *cell = (MZKItemCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    NSLog(@"Model:%@",  cell.item.model);
    
    
    if ([cell.item.model isEqualToString:@"soundrecording"]) {
        [self performSegueWithIdentifier:@"OpenSoundDetail" sender:cell.item];
    }else
    {
        [self performSegueWithIdentifier:@"OpenDetail" sender:cell.item];
    }
    
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item

   // YourViewControllerClass *viewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"ViewController"];

   // self presentViewController:<#(nonnull UIViewController *)#> animated:<#(BOOL)#> completion:<#^(void)completion#>
}



@end
