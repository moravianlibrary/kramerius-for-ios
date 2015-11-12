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
#import "MZKDatasource.h"
#import "MZKPageObject.h"
#import "MZKMusicViewController.h"
#import "MZKDetailViewController.h"

@interface MZKGeneralColletionViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, DataLoadedDelegate>
{
    MZKDatasource *_datasource;
    MZKItemResource *parentItemResource;
}
@property (weak, nonatomic) IBOutlet UICollectionView *_collectionView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;

@end

@implementation MZKGeneralColletionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.backButton.title = @"Zpět";
    
    if (_items) {
        [self._collectionView reloadData];
    }
    
    // Do any additional setup after loading the view.
}

-(void)refreshTitle
{
    self.navigationItem.title = parentItemResource.title;
}

-(IBAction)onClose:(id)sender
{
    NSLog(@"ONCLose");
    
    if (self.isFirst) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setItems:(NSArray *)items
{
    _items = items;
 
}

-(void)setParentObject:(MZKItemResource *)parentObject
{
    _parentObject = parentObject;
    if (!_datasource) {
        _datasource  = [MZKDatasource new];
        _datasource.delegate = self;
    }
    
    [_datasource getChildrenForItem:_parentObject.pid];
}

-(void)setParentPID:(NSString *)parentPID
{
    _parentPID = parentPID;
    if (!_datasource) {
        _datasource  = [MZKDatasource new];
        _datasource.delegate = self;
    }
    [_datasource getItem:_parentPID];
   
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
    
    MZKPageObject *item = [_items objectAtIndex:indexPath.row];
    if (item) {
        cell.itemName.text = item.stringTitleHack;
        //cell.itemAuthors.text = item.authors;
        //cell.item = item;
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
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    MZKPageObject *po =[_items objectAtIndex:indexPath.row];
   // [_datasource getItem:po.pid];
    
    if ([po.model isEqualToString:@"soundunit"]) {
        NSLog(@"Soundunit");
        [[MZKMusicViewController sharedInstance] setItemPID:po.pid];
        [self presentViewController:[MZKMusicViewController sharedInstance] animated:YES completion:nil];
        

    }
    else if (po.datanode) {
        //should dive deeper
        NSLog(@"Datanode");
        
        
      //  MZKGeneralColletionViewController *nextViewController = [[MZKGeneralColletionViewController alloc] init];
        MZKGeneralColletionViewController *nextViewController = [storyboard instantiateViewControllerWithIdentifier:@"MZKGeneralColletionViewController"];
        [nextViewController setParentPID:po.pid];
        nextViewController.isFirst = NO;
        
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
    
    
    if ([po.model isEqualToString:@"periodicalvolume"])
    {
        //[self performSegueWithIdentifier:@"OpenDetail" sender:cell.item];
        
        MZKDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MZKDetailViewController"];
        
        // Pass any objects to the view controller here, like...
        [vc setItemPID:po.pid];
        
        [self presentViewController:vc animated:YES completion:^{
        
        }];

    }
    
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item

   // YourViewControllerClass *viewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"ViewController"];

   // self presentViewController:<#(nonnull UIViewController *)#> animated:<#(BOOL)#> completion:<#^(void)completion#>
}

#pragma mark - Data Loaded delegate and Datasource methods
-(void)childrenForItemLoaded:(NSArray *)items
{
    _items = items;
    
    __weak typeof(self) wealf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [wealf._collectionView reloadData];
        
    });
}

-(void)detailForItemLoaded:(MZKItemResource *)item
{
    parentItemResource = item;
    NSLog(@"item datanode: %s", item.datanode? "JOP":"NOPE");
    //NSLog(@"")
    
    __weak typeof(self) wealf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [wealf refreshTitle];
         [_datasource getChildrenForItem:item.pid];
    });

}



@end
