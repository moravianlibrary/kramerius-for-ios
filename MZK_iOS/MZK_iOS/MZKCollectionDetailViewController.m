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
#import "MZKDetailViewController.h"
#import "MZKMusicViewController.h"
#import "MZKItemCollectionViewCell.h"
#import <Google/Analytics.h>
#import "AppDelegate.h"
#import "MZK_iOS-Swift.h"

@import SDWebImage;

@interface MZKCollectionDetailViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, DataLoadedDelegate>
{
    MZKDatasource *_datasource;
    NSMutableArray *_loadedItems;
    MZKCollectionItemResource *_selectedItem;
    NSInteger numberOfItemsForCollection;
}
@property (weak, nonatomic) IBOutlet UILabel *collectionName;
- (IBAction)onBack:(id)sender;

@end

@implementation MZKCollectionDetailViewController

- (void)viewDidLoad {
    // Do any additional setup after loading the view.
    [super viewDidLoad];
    self.title = _selectedCollectionName;
    
    [self initGoogleAnalytics];
}

-(void)initGoogleAnalytics
{
    NSString *name = [NSString stringWithFormat:@"Pattern~%@", @"MZKCollectionDetailViewController"];
    
    // The UA-XXXXX-Y tracker ID is loaded automatically from the
    // GoogleService-Info.plist by the `GGLContext` in the AppDelegate.
    // If you're copying this to an app just using Analytics, you'll
    // need to configure your tracking ID here.
    // [START screen_view_hit_objc]
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:name];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    // [END screen_view_hit_objc]
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setCollectionPID:(NSString *)collectionPID
{
    _collectionPID = collectionPID;
    [self loadDataForController];
    
}

-(void)loadDataForController
{
    if (!_datasource) {
        _datasource = [MZKDatasource new];
        _datasource.delegate = self;
    }
    
    [_datasource getCollectionItems:_collectionPID];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - Datasource Delegate
-(void)downloadFailedWithError:(NSError *)error
{
    __weak typeof(self) welf = self;
    if(![[NSThread currentThread] isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf downloadFailedWithError:error];
        });
        return;
    }
    //[self hideLoadingIndicator];
    if ([error.domain isEqualToString:NSURLErrorDomain]) {
        //NSError Domain Code
        [self showTsErrorWithNSError:error andConfirmAction:^{

            [welf loadDataForController];
        }];
    }
}


#pragma mark - Collection View Delegate and Datasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    // just one section
    return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [_loadedItems count];
}

- (MZKItemCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MZKItemCollectionViewCell* newCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"MZKItemCollectionViewCell"
                                                                                          forIndexPath:indexPath];
    MZKCollectionItemResource *item = [_loadedItems objectAtIndex:indexPath.row];
    
    newCell.itemName.text =item.title;
    newCell.itemAuthors.text = item.authors;
    newCell.item = item;
    
    newCell.itemType.text = [item getLocalizedItemType];
    
    newCell.publicOnlyIcon.hidden = [item.policy isEqualToString:@"public"]? YES:NO;
 
    
    AppDelegate *del = (AppDelegate* )[[UIApplication sharedApplication] delegate];
    MZKLibraryItem *resItem = del.getDatasourceItem;
    
    NSString*url = [NSString stringWithFormat:@"%@://%@", resItem.protocol, resItem.stringURL];
    NSString*path = [NSString stringWithFormat:@"%@/search/api/v5.0/item/%@/thumb",url, item.pid ];
    
    
    [newCell.itemImage sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:nil];

    return newCell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MZKCollectionItemResource *item = [_loadedItems objectAtIndex:indexPath.row];
    
     _selectedItem = item;
    
    if ([item.policy isEqualToString:@"public"]) {
        
        if (item.model == SoundUnit || item.model ==SoundRecording) {
        
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            [delegate transitionToMusicViewControllerWithSelectedMusic:item.pid];
       
        }
        else{
            [self performSegueWithIdentifier:@"OpenReader" sender:nil];
        }
 
    }
    else
    {
        [self showErrorWithCancelActionAndTitle:@"Pozor" subtitle:@"Tato sbírka není veřejně dostupná." withCompletion:nil];
    }
}

#pragma mark - Collection View Flow Layout Delegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    float desiredWidth = [self calculateCellWidthFromScreenWidth:collectionView.frame.size.width];
    
    CGSize sizeOfCell = CGSizeMake(desiredWidth, 140);
    
    return sizeOfCell;
    
}

-(float)calculateCellWidthFromScreenWidth:(float)width
{
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
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
    
    UICollectionViewFlowLayout *flowLayout = (id)self.collectionView.collectionViewLayout;
    float desiredWidth = [self calculateCellWidthFromScreenWidth:size.width];
    
    CGSize sizeOfCell = CGSizeMake(desiredWidth, 140);
    
    flowLayout.itemSize = sizeOfCell;
    
    [flowLayout invalidateLayout];
    
}


- (IBAction)onBack:(id)sender {
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - Datasource delegate methods
-(void)collectionItemsLoaded:(NSArray *)collectionItems
{
    // open colleciton detail from here
    
    
    if(![[NSThread currentThread] isMainThread])
    {
        __weak typeof(self) welf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf collectionItemsLoaded:collectionItems];
        });
        return;
    }
    
    if (!_loadedItems) {
        _loadedItems = [NSMutableArray new];
    }
    
    [_loadedItems addObjectsFromArray:[collectionItems copy]];
    [self.collectionView reloadData];
   
    MZKCollectionItemResource *firstItem = collectionItems.firstObject;
    if (firstItem.numFound != _loadedItems.count) {
        NSInteger start = _loadedItems.count;
        NSInteger count = firstItem.numFound - start;
        if (count >30) {
            count =30;
        }
        
        [_datasource getCollectionItems:_collectionPID withRangeFrom:start numberOfItems:count];
    }
    
    
    NSLog(@"Collection items count:%lu", (unsigned long)_loadedItems.count);

}

#pragma mark - segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"OpenReader"])
    {
        // Get reference to the destination view controller
        MZKDetailManagerViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        [vc setItemPID:_selectedItem.pid];
        _selectedItem = nil;
    }
    else if ([[segue identifier] isEqualToString:@"OpenSoundDetail"])
    {
        MZKMusicViewController *vc = [segue destinationViewController];
        [vc setItem:_selectedItem];
        _selectedItem = nil;
    }
    
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if (_selectedItem) {
        return YES;
    }
    return NO;
}
@end
