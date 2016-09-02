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
#import "UIImageView+WebCache.h"
#import "MZKDatasource.h"
#import "MZKPageObject.h"
#import "MZKMusicViewController.h"
#import "MZKDetailViewController.h"
#import "MZKSearchBarCollectionReusableView.h"
#import <Google/Analytics.h>
#import "MZKConstants.h"

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
    // title has to be different based on type of parent resource!!!
    NSMutableString *title = [NSMutableString new];
    
    if ([parentItemResource.model caseInsensitiveCompare:kPeriodical] == NSOrderedSame) {
        
        NSLog(@"Periodical:%@", parentItemResource.debugDescription);
        
        if (parentItemResource.rootTitle) {
            [title appendString:parentItemResource.rootTitle];
        }
    }
    
    if ([parentItemResource.model caseInsensitiveCompare:kPeriodicalVolume] == NSOrderedSame) {
        
        NSLog(@"Periodical Volume:%@", parentItemResource.debugDescription);
        
        if (parentItemResource.rootTitle) {
           [title appendString:parentItemResource.rootTitle];
        }
        
        if (parentItemResource.year) {
            [title appendString:@" "];
            [title appendString:parentItemResource.year];
            NSLog(@"Year:%@", parentItemResource.year);
        }
    }
    
    
    if ([parentItemResource.model caseInsensitiveCompare:kPeriodicalItem] == NSOrderedSame) {
        
        // do we have a root title?
        if (parentItemResource.rootTitle) {
            [title appendString:parentItemResource.rootTitle];
        }
        
        // do we have a date of release?
        if (parentItemResource.issueNumber) {
            [title appendString:@" "];
            NSLog(@"IssueNumber:%@", parentItemResource.issueNumber);
            [title appendString:parentItemResource.issueNumber];
        }
        else if (parentItemResource.year) {
            [title appendString:@" "];
            [title appendString:parentItemResource.year];
            NSLog(@"Year:%@", parentItemResource.year);
        }
    }
    
    if (title) {
        self.navigationItem.title = title;
    }
    else
    {
        NSLog(@"There is no usable title! Using default instead!");
        self.navigationItem.title = parentItemResource.title;
    }
    
    
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
    [self loadDataForController];
    
}

-(void)loadDataForController
{
    if (!_datasource) {
        _datasource  = [MZKDatasource new];
        _datasource.delegate = self;
    }
    
    if (parentItemResource ) {
        
        [_datasource getChildrenForItem:parentItemResource.pid];
    }
    else if(_parentPID){
        [_datasource getItem:_parentPID];
    }
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
    
    [self hideLoadingIndicator];
    
    [self showErrorWithTitle:@"Problém při stahování" subtitle:@"Přejete si opakovat akci?" confirmAction:^{
        [welf showLoadingIndicator];
        [welf loadDataForController];
        
    }];
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

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (MZKItemCollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MZKItemCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"MZKItemCollectionViewCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    
    MZKPageObject *item = [_items objectAtIndex:indexPath.row];
    if (item) {
        cell.itemName.text = item.title;
        cell.itemAuthors.text = item.getAuthorsStringRepresentation;
        cell.pObject = item;
        cell.itemType.text = [item getLocalizedItemType];
        cell.publicOnlyIcon.hidden = [item.policy isEqualToString:@"public"]? YES:NO;
        
        if ([item.model caseInsensitiveCompare:kPeriodicalVolume] == NSOrderedSame) {
            
            
            if (item.year) {
                cell.itemName.text = item.year;
            }
            
            if (item.volumeNumber) {
                cell.itemAuthors.text = [NSString stringWithFormat:@"Ročník %@", item.volumeNumber];
            }
        }
        
        
        if ([item.model caseInsensitiveCompare:kPeriodicalItem] == NSOrderedSame) {
            
            if (item.year) {
                cell.itemName.text = item.year;
            }
            
            cell.itemName.text = item.date;
            
            
            if ([cell.itemName.text caseInsensitiveCompare:@""] ==NSOrderedSame) {
                // we dont have a title
                cell.itemName.text = [NSString stringWithFormat:@"Číslo %@", item.issueNumber];
            }
            else
            {
                 cell.itemAuthors.text = [NSString stringWithFormat:@"Číslo %@", item.issueNumber];
                
            }
 
            if (!item.title) {
                cell.itemName.text = item.rootTitle;
            }
        }
        
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        NSString*url = [NSString stringWithFormat:@"%@://%@", delegate.defaultDatasourceItem.protocol, delegate.defaultDatasourceItem.stringURL];
        NSString*path = [NSString stringWithFormat:@"%@/search/api/v5.0/item/%@/thumb",url, item.pid ];
        
        
        [cell.itemImage sd_setImageWithURL:[NSURL URLWithString:path]
                          placeholderImage:nil];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    MZKPageObject *po =[_items objectAtIndex:indexPath.row];
    
    if ([po.model isEqualToString:@"soundunit"]) {
        
        [self onClose:nil];
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        [delegate transitionToMusicViewControllerWithSelectedMusic:po.pid];
        
    }
    else if (po.datanode) {
        //should dive deeper
        //  MZKGeneralColletionViewController *nextViewController = [[MZKGeneralColletionViewController alloc] init];
        MZKGeneralColletionViewController *nextViewController = [storyboard instantiateViewControllerWithIdentifier:@"MZKGeneralColletionViewController"];
        [nextViewController setParentPID:po.pid];
        nextViewController.isFirst = NO;
        
        [self.navigationController pushViewController:nextViewController animated:YES];
    }

   if ([po.policy isEqualToString:@"public"]) {
        
        if ([po.model isEqualToString:@"periodicalitem"] || [po.model isEqualToString:@"manuscript"] || [po.model isEqualToString:@"monograph"] ||[po.model isEqualToString:@"map"] ||[po.model isEqualToString:@"graphic"] || [po.model isEqualToString:@"page"])
        {
            //[self performSegueWithIdentifier:@"OpenDetail" sender:cell.item];
            
            MZKDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MZKDetailViewController"];
            
            // Pass any objects to the view controller here, like...
            [vc setItemPID:po.pid];
            
            [self presentViewController:vc animated:YES completion:^{
                
            }];
            
        }
        
        if ([po.model isEqualToString:@"periodicalvolume"] ||[po.model isEqualToString:@"periodical"])
        {
            //[self performSegueWithIdentifier:@"OpenDetail" sender:cell.item];
            
            MZKGeneralColletionViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MZKGeneralColletionViewController"];
            
            // Pass any objects to the view controller here, like...
            [vc setParentPID:po.pid];
            vc.isFirst = NO;
            
            [self.navigationController pushViewController:vc animated:YES];
        }
        
    }
    else
    {
        [self showErrorWithCancelActionAndTitle:@"Pozor" subtitle:@"Tento dokument není veřejně přístupný." withCompletion:nil];
    }
    
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
}

- (void)collectionView:(UICollectionView *)colView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* cell = [colView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor lightGrayColor];
}

- (void)collectionView:(UICollectionView *)colView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* cell = [colView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor whiteColor];
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
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self._collectionView.collectionViewLayout;
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
    
    UICollectionViewFlowLayout *flowLayout = (id)self._collectionView.collectionViewLayout;
    float desiredWidth = [self calculateCellWidthFromScreenWidth:size.width];
    
    CGSize sizeOfCell = CGSizeMake(desiredWidth, 140);
    
    flowLayout.itemSize = sizeOfCell;
    
    [flowLayout invalidateLayout];
    
}



#pragma mark - Data Loaded delegate and Datasource methods
-(void)childrenForItemLoaded:(NSArray *)items
{
    if(![[NSThread currentThread] isMainThread])
    {
        __weak typeof(self) welf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf childrenForItemLoaded:items];
        });
        return;
    }
    
    _items = items;
    
    [self._collectionView reloadData];
    [self hideLoadingIndicator];
    
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

//-(void)searchHintsLoaded:(NSDictionary *)results
//{
//    if(![[NSThread currentThread] isMainThread])
//    {
//        __weak typeof(self) welf = self;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [welf searchHintsLoaded:results];
//        });
//        return;
//    }
//
//    [self hideDimmingView];
//    [self hideLoadingIndicator];
//    NSLog(@"Results:%@", [results description]);
//    _searchResults = results;
//    _searchResultsTableView.hidden = NO;
//    [_searchResultsTableView reloadData];
//}

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
    
    [self refreshTitle];
    [_datasource getChildrenForItem:parentItemResource.pid];
}

-(void)resetSearch
{
    [self hideDimmingView];
    [self hideLoadingIndicator];
    _searchResultsTableView.hidden = YES;
    _searchBarView.searchBar.text = @"";
}
@end
