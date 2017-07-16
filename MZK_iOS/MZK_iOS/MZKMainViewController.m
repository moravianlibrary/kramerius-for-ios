//
//  MZKMainViewController.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 05/05/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKMainViewController.h"
#import "MZKDatasource.h"
#import "MZKConstants.h"
#import "AppDelegate.h"
#import "MZKItemCollectionViewCell.h"
#import "MZKMusicViewController.h"
#import "MZKGeneralColletionViewController.h"
#import "MZKSearchBarCollectionReusableView.h"
#import <Google/Analytics.h>
#import "MZKLibraryItem.h"
#import "UINavigationBar+CustomHeight.h"
#import "MZK_iOS-Swift.h"
@import CocoaLumberjack;
@import SDWebImage;

const int kHeaderHeight = 95;


#import "MZKSearchViewController.h"

@interface MZKMainViewController ()<DataLoadedDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, MZKSearchDelegateProtocol> //, UIViewControllerPreviewingDelegate
{
    MZKDatasource *datasource;
    NSArray *_recent;
    NSArray *_recommended;
    NSArray *_recentSearches;
    UIRefreshControl *refreshControl;
    NSDictionary *_searchResults;
    BOOL dialogVisible;
    
    MZKSearchViewController *_searchViewController;
    
}
@property (weak, nonatomic) IBOutlet MZKSearchBarCollectionReusableView *searchBarContainerView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *activityIndicatorContentView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControll;
@property (weak, nonatomic) IBOutlet UIView *dimmingView;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIView *searchBarContainer;
@property (weak, nonatomic) IBOutlet UIView *searchViewContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchViewContainerTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *headerTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *navigationItemContainerView;

@end

@implementation MZKMainViewController
- (id)initWithCoder:(NSCoder *)decoder {
    
    self = [super initWithCoder:decoder];
    if (self) {
        self.navigationController.tabBarItem.title = NSLocalizedString(@"mzk.home", @"Home button title");
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    dialogVisible = NO;
    
    [_segmentControll setTitle:NSLocalizedString(@"mzk.mainPage.latest", @"") forSegmentAtIndex:0];
    [_segmentControll setTitle:NSLocalizedString(@"mzk.mainPage.interesting", @"") forSegmentAtIndex:1];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultDatasourceChangedNotification:) name:kDatasourceItemChanged object:nil];
    
    AppDelegate *del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (del.defaultDatasourceItem)
    {
        [self refreshAllValues];
        [self initGoogleAnalytics];
        [self refreshTitle];
    }
    // DDLogInfo(@"There is no default library, wait for DL")
        
    //    DDLogInfo(@"Info");
    //    DDLogInfo(@"top = %f, bounds top %f", self.collectionView.frame.origin.y, self.collectionView.bounds.origin.y);
    //    DDLogInfo(@"offset y = %f", self.collectionView.contentOffset.y);
    //    DDLogInfo(@"height = %f", self.collectionView.contentSize.height);
    //    DDLogInfo(@"inset top = %f", self.collectionView.contentInset.top);
    //    DDLogInfo(@"inset bottom = %f", self.collectionView.contentInset.bottom);
    //    DDLogInfo(@"inset left = %f", self.collectionView.contentInset.left);
    //    DDLogInfo(@"inset right = %f", self.collectionView.contentInset.right);
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHeight:kHeaderHeight];
    
    _navigationItemContainerView.frame = CGRectMake(0, 0, self.view.frame.size.width, kHeaderHeight);
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar setHeight:kHeaderHeight];
    _navigationItemContainerView.frame = CGRectMake(0, 0, self.view.frame.size.width, kHeaderHeight);
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.collectionView.contentInset = UIEdgeInsetsMake(8, self.collectionView.contentInset.left, self.collectionView.contentInset.bottom, self.collectionView.contentInset.right);
}

-(void)refreshTitle
{
    //get name of selected library
    AppDelegate *del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *libName;
    
    NSArray *supportedLanguages = [NSLocale preferredLanguages];
    if(supportedLanguages.count >0)
    {
        NSString *selectedLang = supportedLanguages[0];
        if ([selectedLang containsString:@"cs"]) {
             libName = [[del getDatasourceItem] name];
        }
        else
        {
            libName = [[del getDatasourceItem] nameEN];
        }
    }
    
    _headerTitleLabel.text = libName;
}

-(void)initGoogleAnalytics
{
    NSString *name = [NSString stringWithFormat:@"Pattern~%@", @"MAIN"];
    
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
    if (!datasource) {
        datasource = [MZKDatasource new];
        datasource.delegate = self;
    }
    
    // clean old values
    _recent = [NSArray new];
    _recommended = [NSArray new];
    
    [self.collectionView reloadData];
    
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
#pragma mark - Datasource methods
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
        
    }
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
    
    if ([error.domain isEqualToString:NSURLErrorDomain]) {
        //NSError Domain Code
        [self showTsErrorWithNSError:error andConfirmAction:^{
            
            [welf refreshAllValues];
            
        }];
        
    }
    else if([error.domain isEqualToString:@"MZK"])
    {
        [self showErrorWithTitle:NSLocalizedString(@"mzk.error", @"Obecna chyba") subtitle:[error.userInfo objectForKey:@"details"]  confirmAction:^{
             [welf refreshAllValues];
            
        }];
        
    }
    else
    {
        [self showErrorWithTitle:NSLocalizedString(@"mzk.error", @"Obecna chyba") subtitle:NSLocalizedString(@"mzk.error.kramerius", "generic error") confirmAction:^{
             [welf refreshAllValues];
            
        }];
    }
    
    
    [self hideLoadingIndicator];
    
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
        cell.itemType.text = [item getLocalizedItemType];
        
        cell.publicOnlyIcon.hidden = [item.policy isEqualToString:@"public"]? YES:NO;
        
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        NSString*path = [NSString stringWithFormat:@"%@/search/api/v5.0/item/%@/thumb",delegate.defaultDatasourceItem.url, item.pid ];
        
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
        headerView.backgroundColor = [UIColor clearColor];
        headerView.searchBar.backgroundColor= [UIColor clearColor];
        headerView.searchBar.layer.borderWidth = 1.0;
        headerView.searchBar.layer.borderColor =  [[UIColor groupTableViewBackgroundColor] CGColor];
        [headerView removeSearchBarBorder];
        reusableview = headerView;
        _searchBarContainerView = headerView;
        
        UICollectionViewLayoutAttributes *cv = [self.collectionView layoutAttributesForSupplementaryElementOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
        
        [self setupSearchHeader];
    }
    return reusableview;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MZKItemCollectionViewCell *cell = (MZKItemCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    if (cell.item.policy ) {
        if ([cell.item.policy isEqualToString:@"public"]) {
            [self prepareDataForSegue:cell.item];
        }
        else
        {
            [self showErrorWithCancelActionAndTitle:@"Pozor" subtitle:@"Tento dokument není veřejně dostupný"];
        }
    }
    else
    {
        [self prepareDataForSegue:cell.item];
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

- (void)updateCollectionViewLayoutWithSize:(CGSize)size {
    
    UICollectionViewFlowLayout *flowLayout = (id)self.collectionView.collectionViewLayout;
    float desiredWidth = [self calculateCellWidthFromScreenWidth:size.width];
    
    CGSize sizeOfCell = CGSizeMake(desiredWidth, 140);
    
    flowLayout.itemSize = sizeOfCell;
    
    [flowLayout invalidateLayout];
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
    if ([[segue identifier] isEqualToString:@"OpenReader"])
    {
        // Get reference to the destination view controller
        MZKDetailManagerViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        [vc setItemPID:((MZKItemResource *)sender).pid];
        
    }else if ([[segue identifier] isEqualToString:@"OpenSoundDetail"])
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
    }
}

-(void)prepareDataForSegue:(MZKItemResource *)item
{
    
    switch (item.model) {
        case Map :
        case Monograph:
        case Manuscript:
        case Graphic:
        case Page:
        case PeriodicalItem:
        case Article:
        case Archive:
        case InternalPart:
        case Supplement:
        case Sheetmusic:
            [self performSegueWithIdentifier:@"OpenReader" sender:item];
            break;
            
        case SoundRecording:
        case Periodical:
            [self performSegueWithIdentifier:@"OpenGeneralList" sender:item];
            
        default:
            break;
    }
}

#pragma mark - notification handling
-(void)defaultDatasourceChangedNotification:(NSNotification *)notf
{
    if(![[NSThread currentThread] isMainThread])
    {
        __weak typeof(self) welf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf defaultDatasourceChangedNotification:notf];
        });
        return;
    }
    
    _recent = [NSArray new];
    _recommended = [NSArray new];
    [self.collectionView reloadData];
    
    [self refreshAllValues];
    [self refreshTitle];
    
    [self searchEnded];
    self.searchBar.text = @"";
}

#pragma mark - segment controll
- (IBAction)segmentControllValueChanged:(UISegmentedControl *)sender
{
    switch (_segmentControll.selectedSegmentIndex) {
        case 0:
            [_collectionView reloadData];
            break;
            
        case 1:
            [_collectionView reloadData];
            break;
            
        default:
            break;
    }
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

#pragma mark - Search
-(void)searchStarted
{
    // shows dimming view and bring the focus to the search bar
    [self.view bringSubviewToFront:self.searchViewContainer];
    
    self.collectionView.scrollEnabled = NO;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0]; // indexPath of your header, item must be 0
    
    CGFloat offsetY = [_collectionView layoutAttributesForSupplementaryElementOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath].frame.origin.y;
    
    CGFloat contentInsetY = self.collectionView.contentInset.top;
    CGFloat sectionInsetY = ((UICollectionViewFlowLayout *)_collectionView.collectionViewLayout).sectionInset.top;
    
    [_collectionView setContentOffset:CGPointMake(_collectionView.contentOffset.x, offsetY - contentInsetY - sectionInsetY) animated:YES];
    
}

-(void)searchEnded
{
    // search ended, enable scrolling and hide dimming view
    [self.view sendSubviewToBack:self.searchViewContainer];
    
    self.collectionView.scrollEnabled = YES;
}

-(void)setupSearchHeader
{
    if (!_searchViewController) {
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        _searchViewController = (MZKSearchViewController *)[sb instantiateViewControllerWithIdentifier:@"MZKSearchViewController"];
        _searchViewController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        _searchViewController.view.frame = CGRectMake(0, 0, _searchViewContainer.frame.size.width, _searchViewContainer.frame.size.height);
        
        _searchViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _searchViewController.view.translatesAutoresizingMaskIntoConstraints = YES;
        _searchViewController.delegate = self;
        [self addChildViewController:_searchViewController];
        
        _searchBarContainerView.searchBar.delegate = _searchViewController;
        [_searchViewContainer addSubview:_searchViewController.view];
        
        [self.view sendSubviewToBack:_searchViewContainer];
    }
}

#pragma mark - rotation handling
-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    // rotation handling
    // best call super just in case
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    // will execute before rotation
    [self updateCollectionViewLayoutWithSize:size];
    
    [coordinator animateAlongsideTransition:^(id  _Nonnull context) {
        
        // will execute during rotation
        _navigationItemContainerView.frame = CGRectMake(0, 0, self.view.frame.size.width, kHeaderHeight);
        
    } completion:^(id  _Nonnull context) {
        
        // will execute after rotation
    }];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
