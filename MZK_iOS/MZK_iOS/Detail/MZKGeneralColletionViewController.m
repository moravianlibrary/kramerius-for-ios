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

#import "MZKSearchBarCollectionReusableView.h"
#import <Google/Analytics.h>
#import "MZKConstants.h"
#import "MZK_iOS-Swift.h"


@interface MZKGeneralColletionViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, DataLoadedDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, MZKDataLoadedDelegateObjc>
{
    MZKDatasource *_datasource;
    MZKDatasourceS *s_datasource;
    MZKItemResource *parentItemResource;
    MZKSearchBarCollectionReusableView *_searchBarView;
    MZKFilterQuery *filterQuery;
    NSDictionary *_searchResults;
    MZKFiltersViewController *_filtersVC;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIView *dimmingView;
@property (weak, nonatomic) IBOutlet UIView *activityIndicatorContainerView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITableView *searchResultsTableView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *filterButton;
@property (weak, nonatomic) IBOutlet UIView *activeFiltersContainerView;
@property (weak, nonatomic) IBOutlet UIStackView *activeFiltersStackView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *activeFiltersHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *filtersViewControllerContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filtersContainerViewTopConstraint;

@end

@implementation MZKGeneralColletionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.backButton.title = @"❮";
    
    if (_items) {
        [self.collectionView reloadData];
    }
    
    [self hideDimmingView];
    // Do any additional setup after loading the view.
    [self initGoogleAnalytics];
    _searchResults = [NSDictionary new];
    
    // should display search icon in header bar
    if (_shouldDisplayFilters) {
        [self showBarButtonItem:self.filterButton];
    }
    else{
        [self hideBarButtonItem:self.filterButton];
    }
    
    _filtersContainerViewTopConstraint.constant = self.view.frame.size.height;
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
    
    if (parentItemResource.model == Periodical) {
        
        NSLog(@"Periodical:%@", parentItemResource.debugDescription);
        
        if (parentItemResource.rootTitle) {
            [title appendString:parentItemResource.rootTitle];
        }
    }
    
    if (parentItemResource.model == PeriodicalVolume) {
        
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
    
    
    if (parentItemResource.model == PeriodicalItem) {
        
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
    
    // should display search icon in header bar
    if (_shouldDisplayFilters) {
        [self showBarButtonItem:self.filterButton];
    }
    else{
        [self hideBarButtonItem:self.filterButton];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.collectionView setContentOffset:CGPointMake(0, -50) animated:false];
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
    
    if ([error.domain isEqualToString:NSURLErrorDomain]) {
        //NSError Domain Code
        [self showTsErrorWithNSError:error andConfirmAction:^{
            
            [welf showLoadingIndicator];
            [welf loadDataForController];
        }];
    }else if([error.domain isEqualToString:@"MZK"])
    {
        [self showErrorWithTitle:NSLocalizedString(@"mzk.error", @"Obecna chyba") subtitle:[error.userInfo objectForKey:@"details"]  confirmAction:^{
            [welf showLoadingIndicator];
            [welf loadDataForController];
            
        }];
        
    }
    else
    {
        [self showErrorWithTitle:NSLocalizedString(@"mzk.error", @"Obecna chyba") subtitle:NSLocalizedString(@"mzk.error.kramerius", "generic error") confirmAction:^{
            [welf showLoadingIndicator];
            [welf loadDataForController];
            
        }];
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
        
        if (item.model == PeriodicalVolume) {
            
            
            if (item.year) {
                cell.itemName.text = item.year;
            }
            
            if (item.volumeNumber) {
                cell.itemAuthors.text = [NSString stringWithFormat:@"Ročník %@", item.volumeNumber];
            }
        }
        
        
        if (item.model == PeriodicalItem) {
            
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
        
        NSString*path = [NSString stringWithFormat:@"%@/search/api/v5.0/item/%@/thumb",delegate.defaultDatasourceItem.url, item.pid ];
        
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
    
    if (po.model == SoundUnit) {
        
        [self onClose:nil];
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        [delegate transitionToMusicViewControllerWithSelectedMusic:po.pid];
        
    }
    else if (po.datanode) {
        //should dive deeper
        MZKGeneralColletionViewController *nextViewController = [storyboard instantiateViewControllerWithIdentifier:@"MZKGeneralColletionViewController"];
        [nextViewController setParentPID:po.pid];
        nextViewController.isFirst = NO;
        
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
    
    if ([po.policy isEqualToString:@"public"]) {
        
        if (po.model == PeriodicalItem || po.model == Manuscript || po.model == Monograph || po.model == Map || po.model == Graphic || po.model == Page || po.model == Article || po.model == Archive || po.model == InternalPart || po.model == Sheetmusic || po.model == Supplement) {
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MZKDetail" bundle: nil];
            MZKDetailManagerViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MZKDetailManagerViewController"];
            
            // Pass any objects to the view controller here, like...
            [vc setItemPID:po.pid];
            
            [self presentViewController:vc animated:YES completion:^{
                
            }];
            
        }
        
        if (po.model== PeriodicalVolume || po.model ==Periodical)
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
    
    [self.collectionView reloadData];
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

#pragma MARK - Filters
- (IBAction)onFilterButton:(id)sender {

  _filtersContainerViewTopConstraint.constant = (_filtersContainerViewTopConstraint.constant == 0) ? self.view.frame.size.height : 0;
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}

-(void) refreshFiltersWithQuery:(MZKFilterQuery *)query {
    if  (!s_datasource) {
        s_datasource = [[MZKDatasourceS alloc] init];
    }
    
    // set delegate
    [s_datasource setDelegate:self];
    
    // refresh Search Results with selected filter facet
    [s_datasource getSearchResultsFrom:_searchTerm WithQuery:query facet:@""];
    
    //save query
    filterQuery = query;
    
    // refresh filter facets
    [self setupActiveFilters: [filterQuery getAllActiveFilters]];
}

-(void) hideBarButtonItem :(UIBarButtonItem *)myButton {
    // Get the reference to the current toolbar buttons
    NSMutableArray *navBarBtns = [self.navigationItem.rightBarButtonItems mutableCopy];
    
    // This is how you remove the button from the toolbar and animate it
    [navBarBtns removeObject:myButton];
    [self.navigationItem setRightBarButtonItems:navBarBtns animated:YES];
}


-(void) showBarButtonItem :(UIBarButtonItem *)myButton {
    // Get the reference to the current toolbar buttons
    NSMutableArray *navBarBtns = [self.navigationItem.rightBarButtonItems mutableCopy];
    
    // This is how you add the button to the toolbar and animate it
    if (![navBarBtns containsObject:myButton]) {
        [navBarBtns addObject:myButton];
        [self.navigationItem setRightBarButtonItems:navBarBtns animated:YES];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier  isEqual: @"FiltersSegue"]) {
        // filter segue
        if (!_filtersVC) {
            _filtersVC = [segue destinationViewController] ;
        }
        
        if(!filterQuery) {
            filterQuery = [[MZKFilterQuery alloc] initWithQuery:_searchTerm publicOnly:YES];
        }
        
        _filtersVC.currentQuery = filterQuery;
        [_filtersVC setSearchTerm: _searchTerm];
        __weak typeof(self) welf = self;
        _filtersVC.onFilterChanged = ^(MZKFilterQuery * _Nonnull query) {
            if (query) {
                //  _datasource
                [welf refreshFiltersWithQuery:query];
            }
        };
    }
}

/**
 Data loaded swift version
 */
- (void)searchFilterDataLoadedWithResults:(NSArray * _Nonnull)results {
    // set new items
    self.items = results;
    
    // reload table views, move this to view will appear - on smaller devices there is no need to refresh data - collection view is not visible ...
    [self.collectionView reloadData];
    
    // refresh filters -
}

/**
 * method that setup views representing active filters
 */

-(void)setupActiveFilters:(NSArray *)filters {
    
    // check if array contains any values?
    if (filters.count > 0) {
        
        // clean views
        for (UIView * filterView in _activeFiltersStackView.subviews) {
            [_activeFiltersStackView removeArrangedSubview:filterView];
        }
        // for each filter create UIView ...
        for (NSString *filter in filters) {
            MZKPillLabel * filterLabel = [[MZKPillLabel alloc] init];
            filterLabel.textColor = [UIColor whiteColor];
            filterLabel.numberOfLines = 0;
            filterLabel.text = filter;
            
            filterLabel.backgroundColor = [UIColor colorWithRed:0.0f green:0.22f blue:122.0/255.0 alpha:1.0f];
            filterLabel.font = [UIFont fontWithName:filterLabel.font.fontName size:15.0];
            filterLabel.translatesAutoresizingMaskIntoConstraints = false;
            
            //[UIColor colorWithRed:70.0 green:122.0 blue:21.0 alpha:1.0];
            [_activeFiltersStackView addArrangedSubview:filterLabel];
        }
    } else {
        // if not -> hide filters view
        // change height of filter container to 0, constraint for height defined -> change to 0
        _activeFiltersHeightConstraint.constant = 0.0;
        
    }
}

@end
