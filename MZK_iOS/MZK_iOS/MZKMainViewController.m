//
//  MZKMainViewController.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 05/05/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKMainViewController.h"
#import "MZKDatasource.h"
#import "MZKItemTableViewCell.h"
#import "MZKDetailViewController.h"
#import "MZKConstants.h"
#import "AppDelegate.h"
#import "MZKItemCollectionViewCell.h"
#import "MZKMusicViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MZKGeneralColletionViewController.h"
#import "MZKSearchBarCollectionReusableView.h"
#import <Google/Analytics.h>

@interface MZKMainViewController ()<DataLoadedDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate>
{
    MZKDatasource *datasource;
    NSArray *_recent;
    NSArray *_recommended;
    UIRefreshControl *refreshControl;
    NSDictionary *_searchResults;
}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *activityIndicatorContentView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControll;
@property (weak, nonatomic) IBOutlet UIView *dimmingView;
@property (weak, nonatomic) IBOutlet UITableView *searchResultsTableView;

@end

@implementation MZKMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    datasource = [MZKDatasource new];
    datasource.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultDatasourceChangedNotification:) name:kDatasourceItemChanged object:nil];
    // [self.collectionView registerClass:[MZKItemCollectionViewCell class] forCellWithReuseIdentifier:@"MZKItemCollectionViewCell"];
    
    [self refreshAllValues];
    [self hideDimmingView];
    [self initGoogleAnalytics];
    
}

-(void)initGoogleAnalytics
{
    NSString *name = [NSString stringWithFormat:@"Pattern~%@", @"MZKMainViewController"];
    
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

-(void)refreshAllValues
{
    [datasource getRecommended];
    [datasource getMostRecent];
    [self showLoadingIndicator];
    
}

-(void)reloadValues
{
    [refreshControl endRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dataLoaded:(NSArray *)data withKey:(NSString *)key
{
    if ([key isEqualToString:kRecent]) {
        _recent = data;
    }
    
    if ([key isEqualToString:kRecommended]) {
        _recommended = data;
    }
    
    __weak typeof(self) wealf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [wealf.collectionView reloadData];
        [wealf hideLoadingIndicator];
        
    });
    
    if (![NSThread mainThread]) {
        [self performSelectorOnMainThread:@selector(reloadData) withObject:self.collectionView waitUntilDone:NO];
        NSLog(@"Not main thread ======");
    }
    
}

-(void)downloadFailedWithRequest:(NSString *)request
{
    if(![[NSThread currentThread] isMainThread])
    {
        __weak typeof(self) welf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf downloadFailedWithRequest:request];
        });
        return;
    }
    [self hideLoadingIndicator];
    [self showErrorWithTitle:@"Problem při stahování" subtitle:@"Opakovat akci?"];
}


#pragma mark - Collection View Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    
    switch (_segmentControll.selectedSegmentIndex) {
        case 0:
            return  _recent.count;
            break;
        case 1:
            return _recommended.count;
            
        default:
            break;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (MZKItemCollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MZKItemCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"MZKItemCollectionViewCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    
    MZKItemResource *item = [self itemAtIndexPath:indexPath];
    if (item) {
        cell.itemName.text = item.title;
        cell.itemAuthors.text = item.getAuthorsStringRepresentation;
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

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        MZKSearchBarCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SearchHeader" forIndexPath:indexPath];
        
        headerView.searchBar.layer.borderWidth = 1.0;
        headerView.searchBar.layer.borderColor =  [[UIColor groupTableViewBackgroundColor] CGColor];
        
        reusableview = headerView;
    }
    return reusableview;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MZKItemCollectionViewCell *cell = (MZKItemCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    NSLog(@"Model:%@",  cell.item.model);
    
    [self prepareDataForSegue:cell.item];
    
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
}

-(void)prepareDataForSegue:(MZKItemResource *)item
{
    if ([item.model isEqualToString:@"soundrecording"] || [item.model isEqualToString:@"periodical"] || [item.model isEqualToString:@"sheetmusic"]) {
        [self performSegueWithIdentifier:@"OpenGeneralList" sender:item];
    }else if([item.model isEqualToString:@"manuscript"] || [item.model isEqualToString:@"monograph"] ||[item.model isEqualToString:@"map"] ||[item.model isEqualToString:@"graphic"])
    {
        [self performSegueWithIdentifier:@"OpenDetail" sender:item];
    }
}

-(MZKItemResource *)itemAtIndexPath:(NSIndexPath *)path
{
    switch (_segmentControll.selectedSegmentIndex) {
        case 0:
            return [_recent objectAtIndex:path.row];
            break;
        case 1:
            return [_recommended objectAtIndex:path.row];
            break;
            
        default:
            break;
    }
    
    return nil;
}


#pragma mark - segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"OpenDetail"])
    {
        // Get reference to the destination view controller
        MZKDetailViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        [vc setItem:sender];
    }
    else if ([[segue identifier] isEqualToString:@"OpenSoundDetail"])
    {
        MZKMusicViewController *vc = [segue destinationViewController];
        [vc setItem:sender];
        //set item
    }
    else if ([[segue identifier] isEqualToString:@"OpenGeneralList"])
    {
        UINavigationController *navVC =[segue destinationViewController];
        MZKGeneralColletionViewController *vc =(MZKGeneralColletionViewController *)navVC.topViewController;
        [vc setParentPID:((MZKItemResource *)sender).pid];
        vc.isFirst = YES;
        NSLog(@"%@", [navVC description]);
        // MZKGeneralColletionViewController *rootViewController = [self.navigationController.viewControllers firstObject];
        // [rootViewController setParentObject:sender];
        
        //set item
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


#pragma mark - notification handling
-(void)defaultDatasourceChangedNotification:(NSNotification *)notf
{
    NSLog(@"Notification received:%@", [notf description]);
    if ( ![[NSThread currentThread] isEqual:[NSThread mainThread]] )
    {
        [self performSelectorOnMainThread:@selector(refreshAllValues) withObject:self waitUntilDone:NO];
    }
    else
    {
        [self refreshAllValues];
    }
}

#pragma mark - segment controll
- (IBAction)segmentControllValueChanged:(UISegmentedControl *)sender
{
    switch (_segmentControll.selectedSegmentIndex) {
        case 0:
            NSLog(@"0 segmet");
            [_collectionView reloadData];
            break;
            
        case 1:
            NSLog(@"1 segmet");
            [_collectionView reloadData];
            break;
            
        default:
            break;
    }
    [self hideDimmingView];
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - SearchBar Delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length >=3) {
        if (!datasource) {
            datasource = [MZKDatasource new];
            datasource.delegate = self;
        }
        [self showLoadingIndicator];
        [datasource getSearchResultsAsHints:searchText];
    }
    else
    {
        [self showDimmingView];
        _searchResults = [NSDictionary new];
        [_searchResultsTableView reloadData];
    }
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self showDimmingView];
}

-(void)showDimmingView
{
    [UIView animateWithDuration:0.4 animations:^{
        _dimmingView.alpha = 0.4;
    }];
}

-(void)hideDimmingView
{
    _searchResultsTableView.hidden = YES;
    [UIView animateWithDuration:0.4 animations:^{
        _dimmingView.alpha = 0.0;
    }];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    searchBar.text = @"";
    [self hideDimmingView];
}

-(void)showLoadingIndicator
{
    self.activityIndicatorContentView.hidden = self.activityIndicator.hidden = NO;
    [self.view bringSubviewToFront:self.activityIndicatorContentView];
    [self.activityIndicator startAnimating];
    
}

-(void)hideLoadingIndicator
{
    [self.activityIndicator stopAnimating];
    self.activityIndicatorContentView.hidden = self.activityIndicator.hidden = YES;
}

-(void)searchHintsLoaded:(NSDictionary *)results
{
    if(![[NSThread currentThread] isMainThread])
    {
        __weak typeof(self) welf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf searchHintsLoaded:results];
        });
        return;
    }
    
    [self hideDimmingView];
    [self hideLoadingIndicator];
    
    _searchResults = results;
    _searchResultsTableView.hidden = NO;
    [_searchResultsTableView reloadData];
}

#pragma mark - search table view delegate and datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  _searchResults.allKeys.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchHintCell"];
    
    
    cell.textLabel.text = [_searchResults.allKeys objectAtIndex:indexPath.row];
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [_searchResults.allKeys objectAtIndex:indexPath.row];
    NSString *targetPid = [_searchResults objectForKey:key];
    
    [datasource getItem:targetPid];
    
    [_searchResultsTableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void) detailForItemLoaded:(MZKItemResource *)item
{
    if(![[NSThread currentThread] isMainThread])
    {
        __weak typeof(self) welf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf detailForItemLoaded:item];
        });
        return;
    }
    
    [self prepareDataForSegue:item];
}


@end
