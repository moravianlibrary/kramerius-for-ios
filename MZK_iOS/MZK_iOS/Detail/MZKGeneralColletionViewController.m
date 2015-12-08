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
#import "MZKSearchBarCollectionReusableView.h"
#import <Google/Analytics.h>

@interface MZKGeneralColletionViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, DataLoadedDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
{
    MZKDatasource *_datasource;
    MZKItemResource *parentItemResource;
    MZKSearchBarCollectionReusableView *_searchBarView;
    NSDictionary *_searchResults;
}
@property (weak, nonatomic) IBOutlet UICollectionView *_collectionView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIView *dimmingView;
@property (weak, nonatomic) IBOutlet UIView *activityIndicatorContainerView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITableView *searchResultsTableView;

@end

@implementation MZKGeneralColletionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.backButton.title = @"Zpět";
    
    if (_items) {
        [self._collectionView reloadData];
    }
    
    [self hideDimmingView];
    // Do any additional setup after loading the view.
    [self initGoogleAnalytics];
    _searchResults = [NSDictionary new];
    
}

-(void)initGoogleAnalytics
{
    NSString *name = [NSString stringWithFormat:@"Pattern~%@", @"MZKGeneralCollectionViewController"];
    
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

-(void)refreshTitle
{
    self.navigationItem.title = parentItemResource.title;
}

-(IBAction)onClose:(id)sender
{
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
    [self showLoadingIndicator];
    _parentObject = parentObject;
    if (!_datasource) {
        _datasource  = [MZKDatasource new];
        _datasource.delegate = self;
    }
    
    [_datasource getChildrenForItem:_parentObject.pid];
}

-(void)setParentPID:(NSString *)parentPID
{
    [self showLoadingIndicator];
    _parentPID = parentPID;
    if (!_datasource) {
        _datasource  = [MZKDatasource new];
        _datasource.delegate = self;
    }
    [_datasource getItem:_parentPID];
}

-(void)downloadFailedWithRequest:(NSString *)request
{
    [self hideLoadingIndicator];
    [self showErrorWithTitle:@"" subtitle:@""];
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
        cell.itemAuthors.text = item.getAuthorsStringRepresentation;
        cell.pObject = item;
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
    
    
    if ([po.model isEqualToString:@"periodicalitem"])
    {
        //[self performSegueWithIdentifier:@"OpenDetail" sender:cell.item];
        
        MZKDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MZKDetailViewController"];
        
        // Pass any objects to the view controller here, like...
        [vc setItemPID:po.pid];
        
        [self presentViewController:vc animated:YES completion:^{
            
        }];
        
    }
    
    if ([po.model isEqualToString:@"periodicalvolume"])
    {
        //[self performSegueWithIdentifier:@"OpenDetail" sender:cell.item];
        
        MZKGeneralColletionViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MZKGeneralColletionViewController"];
        
        // Pass any objects to the view controller here, like...
        [vc setParentPID:po.pid];
        vc.isFirst = NO;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        MZKSearchBarCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SearchHeader" forIndexPath:indexPath];
        headerView.searchBar.layer.borderWidth = 1.0;
        headerView.searchBar.layer.borderColor = [[UIColor groupTableViewBackgroundColor] CGColor];
        reusableview = headerView;
        _searchBarView = headerView;
        
    }
    
    return reusableview;
}

#pragma mark - Data Loaded delegate and Datasource methods
-(void)childrenForItemLoaded:(NSArray *)items
{
    _items = items;
    
    __weak typeof(self) wealf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [wealf._collectionView reloadData];
        [wealf hideLoadingIndicator];
        
    });
}

#pragma mark - Search bar delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length >3) {
        if (!_datasource) {
            _datasource = [MZKDatasource new];
            _datasource.delegate = self;
        }
        [self showLoadingIndicator];
        [_datasource getSearchResultsAsHints:searchText];
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
    self.activityIndicatorContainerView.hidden = self.activityIndicator.hidden = NO;
    [self.view bringSubviewToFront:self.activityIndicatorContainerView];
    [self.activityIndicator startAnimating];
    
}

-(void)hideLoadingIndicator
{
    [self.activityIndicator stopAnimating];
    self.activityIndicatorContainerView.hidden = self.activityIndicator.hidden = YES;
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
    
    [_datasource getItem:targetPid];
    
    [_searchResultsTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self resetSearch];
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
    
    parentItemResource = item;
    __weak typeof(self) wealf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [wealf refreshTitle];
        [_datasource getChildrenForItem:item.pid];
        [wealf hideLoadingIndicator];
    });
}

-(void)resetSearch
{
    [self hideDimmingView];
    [self hideLoadingIndicator];
    _searchResultsTableView.hidden = YES;
    _searchBarView.searchBar.text = @"";
}




@end
