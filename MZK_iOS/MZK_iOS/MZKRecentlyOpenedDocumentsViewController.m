//
//  MZKRecentlyOpenedDocumentsViewController.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 25/02/16.
//  Copyright © 2016 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKRecentlyOpenedDocumentsViewController.h"
#import "MZKDatasource.h"
#import "MZKItemCollectionViewCell.h"
#import "MZKConstants.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"
#import "MZKMusicViewController.h"

#import "MZK_iOS-Swift.h"

@interface MZKRecentlyOpenedDocumentsViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@end

@implementation MZKRecentlyOpenedDocumentsViewController

- (id)initWithCoder:(NSCoder *)decoder {
    
    self = [super initWithCoder:decoder];
    if (self) {
        self.navigationController.tabBarItem.title = NSLocalizedString(@"mzk.history", @"history title");
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self.view setNeedsLayout];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDatasourceChanged:) name:kDatasourceItemChanged object:nil];
}

-(void)onDatasourceChanged:(NSNotification *)notf
{
    NSLog(@"Datasource changes, clear recent");
    _recentlyOpened = nil;
    [_collectionView reloadData];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    __weak typeof(self) welf = self;

    if(![[NSThread currentThread] isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf refresh];

        });
        return;
    }

    [self refresh];

}

-(void) refresh {

    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.title = self.navigationController.tabBarItem.title;

    _recentlyOpened = delegate.loadRecentlyOpened;
    [_collectionView reloadData];

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

#pragma mark - CollectionView Delegate and Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    
    return _recentlyOpened.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (MZKItemCollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MZKItemCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"MZKItemCollectionViewCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    
    MZKItemResource *item = [_recentlyOpened objectAtIndex:indexPath.row];
    if (item) {
        cell.itemName.text = item.title;
    
        cell.itemAuthors.text = [NSString stringWithFormat:@"Otevřeno: %@",item.lastOpened];
        cell.item = item;
        cell.itemType.text = [item getLocalizedItemType];
        cell.publicOnlyIcon.hidden = [item.policy isEqualToString:@"public"]? YES:NO;
        
        
        __weak AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
        NSString*path = [NSString stringWithFormat:@"%@/search/api/v5.0/item/%@/thumb",delegate.defaultDatasourceItem.url, item.pid ];
        
        [cell.itemImage sd_setImageWithURL:[NSURL URLWithString:path]
                          placeholderImage:nil];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MZKItemCollectionViewCell *cell = (MZKItemCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    [self prepareDataForSegue:cell.item];
    
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
}

#pragma mark - segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"OpenReader"])
    {
        // Get reference to the destination view controller
        MZKDetailManagerViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        MZKItemResource *tmpItem = (MZKItemResource *)sender;
        
        [vc setItemPID:tmpItem.pid];
        
    }else if ([[segue identifier] isEqualToString:@"OpenSoundDetail"]) {
        MZKMusicViewController *vc = [segue destinationViewController];
        [vc setItem:sender];
        //set item
    } else if ([[segue identifier] isEqualToString:@"OpenGeneralList"]) {
        UINavigationController *navVC =[segue destinationViewController];
        MZKGeneralColletionViewController *vc =(MZKGeneralColletionViewController *)navVC.topViewController;
        [vc setParentPID:((MZKItemResource *)sender).pid];
        vc.isFirst = YES;
    }
}

-(void)prepareDataForSegue:(MZKItemResource *)item
{
//    if ([item.model isEqualToString:@"soundrecording"] || [item.model isEqualToString:@"periodical"] || [item.model isEqualToString:@"sheetmusic"]) {
//        [self performSegueWithIdentifier:@"OpenGeneralList" sender:item];
//        
//    }else if([item.model isEqualToString:@"manuscript"] || [item.model isEqualToString:@"monograph"] ||[item.model isEqualToString:@"map"] ||[item.model isEqualToString:@"graphic"] || [item.model isEqualToString:@"page"])
//    {
//        
//    }
    @try {
        [self performSegueWithIdentifier:@"OpenReader" sender:item];
    } @catch (NSException *exception) {
        NSLog(@"Exception:%@", exception.debugDescription);
    } @finally {
        
    }
    
}

#pragma mark - Collection View Flow Layout Delegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    float desiredWidth = [self calculateCellWidthFromScreenWidth:collectionView.frame.size.width];
    
    CGSize sizeOfCell = CGSizeMake(desiredWidth, 140);
    
    return sizeOfCell;
    
}

- (float)calculateCellWidthFromScreenWidth:(float)width {
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    int numberOfItemsPerRow = 0;
    int kMinCellWidth = 304;
    float collectionViewWidth = width;
    float collectionViewInsetsL = flowLayout.sectionInset.left;
    float collectionViewInsetsR = flowLayout.sectionInset.right;
    int calculatedWidth = 304;
    
    float minCellSpacing = flowLayout.minimumInteritemSpacing;
    
    numberOfItemsPerRow = collectionViewWidth / kMinCellWidth;
    float restOfWidth = collectionViewWidth - (numberOfItemsPerRow -1)* minCellSpacing - collectionViewInsetsL - collectionViewInsetsR - numberOfItemsPerRow * kMinCellWidth ;
    calculatedWidth = restOfWidth / numberOfItemsPerRow ;
    
    return calculatedWidth+kMinCellWidth;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self updateCollectionViewLayoutWithSize:size];
}

- (void)updateCollectionViewLayoutWithSize:(CGSize)size {
    
    UICollectionViewFlowLayout *flowLayout = (id)_collectionView.collectionViewLayout;
    float desiredWidth = [self calculateCellWidthFromScreenWidth:size.width];
    
    CGSize sizeOfCell = CGSizeMake(desiredWidth, 140);
    
    flowLayout.itemSize = sizeOfCell;
    
    [flowLayout invalidateLayout];
    
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
