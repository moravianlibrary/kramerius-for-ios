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
#import <SDWebImage/UIImageView+WebCache.h>
#import "MZKItemCollectionViewCell.h"
#import <Google/Analytics.h>


@interface MZKCollectionDetailViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, DataLoadedDelegate>
{
    MZKDatasource *_datasource;
    NSArray *_loadedItems;
    MZKCollectionItemResource *_selectedItem;
}
@property (weak, nonatomic) IBOutlet UILabel *collectionName;
- (IBAction)onBack:(id)sender;

@end

@implementation MZKCollectionDetailViewController

- (void)viewDidLoad {
    // Do any additional setup after loading the view.
    [super viewDidLoad];
    self.collectionName.text = _selectedCollectionName;
    
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

- (MZKItemCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MZKItemCollectionViewCell* newCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"MZKItemCollectionViewCell"
                                                                                          forIndexPath:indexPath];
    MZKCollectionItemResource *item = [_items objectAtIndex:indexPath.row];
    
    newCell.itemName.text =item.title;
    newCell.itemAuthors.text = item.authors;
    newCell.itemType.text = item.documentType;
    //newCell.itemTypeIcon
    
    NSString*url = @"http://kramerius.mzk.cz";
    NSString*path = [NSString stringWithFormat:@"%@/search/api/v5.0/item/%@/thumb",url, item.pid ];
    
    
    [newCell.itemImage sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:nil];
    
    
    // newCell.cellLabel.text = [NSString stringWithFormat:@"Section:%d, Item:%d", indexPath.section, indexPath.item];
    return newCell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MZKCollectionItemResource *item = [_items objectAtIndex:indexPath.row];
    _selectedItem = item;
    
    [self performSegueWithIdentifier:@"OpenCollectionDetail" sender:nil];
}

- (IBAction)onBack:(id)sender {
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"OpenCollectionDetail"])
    {
        // Get reference to the destination view controller
        MZKDetailViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        [vc setItem:_selectedItem];
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
