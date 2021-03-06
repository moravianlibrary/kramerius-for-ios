

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
#import "MZKSearchViewController.h"
#import "PresentMusicViewControllerProtocol.h"

#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad

@import RMessage;
@import SDWebImage;

const int kHeaderHeight = 95;

@interface MZKMainViewController ()<DataLoadedDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, MZKSearchDelegateProtocol, PresentMusicViewControllerProtocol> {
    MZKDatasource *datasource;
    NSArray *_recent;
    NSArray *_recommended;
    NSArray *_recentSearches;
    UIRefreshControl *refreshControl;
    NSDictionary *_searchResults;
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
@property (strong, nonatomic) UILabel *headerTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *navigationItemContainerView;
@end

@implementation MZKMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentMusic) name:@"presentMusicViewController" object:nil];

    self.navigationController.tabBarItem.title = NSLocalizedString(@"mzk.library", @"mzk title");
    //prepare header
    _headerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 3, _segmentControll.frame.origin.x - 6, 40)];
    _headerTitleLabel.backgroundColor = [UIColor clearColor];
    _headerTitleLabel.numberOfLines = 0;
    _headerTitleLabel.textAlignment = NSTextAlignmentCenter;

    // set bold font
    UIFontDescriptor * fontD = [_headerTitleLabel.font.fontDescriptor
                                fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    
    _headerTitleLabel.font = [UIFont fontWithDescriptor:fontD size:0];

    [_headerTitleLabel setMinimumScaleFactor:0.5];

    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = false;
    } else {
        // Fallback on earlier versions
        // there are some problems w
        _headerTitleLabel.frame = CGRectMake(3, 3, _headerTitleLabel.frame.size.width, _headerTitleLabel.frame.size.height);

        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributtes = @{ NSParagraphStyleAttributeName: paragraphStyle };
        [_segmentControll setTitleTextAttributes:attributtes forState:UIControlStateSelected];
        _segmentControll.translatesAutoresizingMaskIntoConstraints = NO;

        float fWidth = 150;

        _segmentControll.frame = CGRectMake(_headerTitleLabel.frame.size.width + 8, 3, fWidth , _segmentControll.frame.size.height);

        [NSLayoutConstraint constraintWithItem:_segmentControll
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:_segmentControll
                                     attribute:NSLayoutAttributeWidth
                                    multiplier:1.0
                                      constant:150.0].active = YES;
        _headerTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }

    self.navigationItem.titleView = _headerTitleLabel;
    _headerTitleLabel.adjustsFontSizeToFitWidth = YES;


    // segment controll
    [_segmentControll setTitle:NSLocalizedString(@"mzk.mainPage.latest", @"") forSegmentAtIndex:0];
    [_segmentControll setTitle:NSLocalizedString(@"mzk.mainPage.interesting", @"") forSegmentAtIndex:1];


    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultDatasourceChangedNotification:) name:kDatasourceItemChanged object:nil];

    AppDelegate *del = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    if (del.defaultDatasourceItem) {
        [self refreshAllValues];
        [self initGoogleAnalytics];
        [self refreshTitle];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // clean up search while leaving screen
    [self searchEnded];
    self.searchBar.text = @"";

    [_searchViewController searchCancelled];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.collectionView.contentInset = UIEdgeInsetsMake(8, self.collectionView.contentInset.left, self.collectionView.contentInset.bottom, self.collectionView.contentInset.right);
}

-(void)refreshTitle {
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

-(void)initGoogleAnalytics {
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

-(void)refreshAllValues {
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

-(void)reloadValuesFinished {
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
        [wealf reloadValuesFinished];
        
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
    // if error is saying anything with connection
    if ([error.domain isEqualToString:NSURLErrorDomain]) {
        [RMessage showNotificationWithTitle:NSLocalizedString(@"mzk.error", @"Obecna chyba") subtitle:@"mzk.error.checkYourInternetConnection" type:RMessageTypeWarning customTypeName:nil callback:^{
            [welf refreshAllValues];
        }];
    } else {
        [RMessage showNotificationWithTitle:NSLocalizedString(@"mzk.error", @"Obecna chyba")
                                   subtitle:NSLocalizedString(@"mzk.error.url.unknown", @"general error")
                                       type:RMessageTypeWarning
                             customTypeName:nil callback:^{
            [welf refreshAllValues];
        }];
    }

    [welf hideLoadingIndicator];
    [welf reloadValuesFinished];
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
        
        NSString*path = [NSString stringWithFormat:@"%@/search/api/v5.0/item/%@/thumb",delegate.defaultDatasourceItem.url, item.pid];
        // preview
        
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
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MZKItemCollectionViewCell *cell = (MZKItemCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    if (cell.item.policy) {
        if ([cell.item.policy isEqualToString:@"public"]) {
            if ([cell.item isModelMusic]) {
                NSString *itemPid = cell.item.pid;
                dispatch_async(dispatch_get_main_queue(), ^{
                    AppDelegate *appDelegate = (AppDelegate*)[UIApplication.sharedApplication delegate];
                    [self presentMusicViewController:appDelegate.musicViewController withItem:itemPid];

                });
            } else {
                [self prepareDataForSegue:cell.item];
            }
        } else {
            [RMessage showNotificationWithTitle:NSLocalizedString(@"mzk.warning", @"Obecna chyba") subtitle:@"Některé části dokumentu nemusí být veřejně dostupné." type:RMessageTypeWarning customTypeName:nil callback:nil];
        }
    } else {
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
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    float desiredWidth = [self calculateCellWidthFromScreenWidth:collectionView.frame.size.width];
    
    CGSize sizeOfCell = CGSizeMake(desiredWidth, 140);
    
    return sizeOfCell;
}

- (float)calculateCellWidthFromScreenWidth:(float)width {
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

- (MZKItemResource *)itemAtIndexPath:(NSIndexPath *)path {
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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"OpenReader"]) {
        // Get reference to the destination view controller
        MZKDetailManagerViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        [vc setItemPID:((MZKItemResource *)sender).pid];

    } else if ([[segue identifier] isEqualToString:@"OpenGeneralList"]) {
        UINavigationController *navVC =[segue destinationViewController];
        MZKGeneralColletionViewController *vc =(MZKGeneralColletionViewController *)navVC.topViewController;
        [vc setParentPID:((MZKItemResource *)sender).pid];
        vc.isFirst = YES;
    }

    [_searchViewController searchCancelled];
}

-(void)prepareDataForSegue:(MZKItemResource *)item {
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
            [self performSegueWithIdentifier:@"OpenReader" sender:item];
            break;
        case Sheetmusic:
        case SoundRecording:
        case SoundUnit:
             break;
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
- (IBAction)segmentControllValueChanged:(UISegmentedControl *)sender {
    [_searchViewController searchCancelled];

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

-(void)showLoadingIndicator {
    self.activityIndicatorContentView.hidden = self.activityIndicator.hidden = NO;
    [self.view bringSubviewToFront:self.activityIndicatorContentView];
    [self.activityIndicator startAnimating];
}

-(void)hideLoadingIndicator {
    [self.activityIndicator stopAnimating];
    self.activityIndicatorContentView.hidden = self.activityIndicator.hidden = YES;
}

-(void) detailForItemLoaded:(MZKItemResource *)item {
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
-(void)searchStarted {
    // shows dimming view and bring the focus to the search bar
    [self.view bringSubviewToFront:self.searchViewContainer];
    
    self.collectionView.scrollEnabled = NO;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0]; // indexPath of your header, item must be 0
    
    CGFloat offsetY = [_collectionView layoutAttributesForSupplementaryElementOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath].frame.origin.y;
    
    CGFloat contentInsetY = self.collectionView.contentInset.top;
    CGFloat sectionInsetY = ((UICollectionViewFlowLayout *)_collectionView.collectionViewLayout).sectionInset.top;
    
    [_collectionView setContentOffset:CGPointMake(_collectionView.contentOffset.x, offsetY - contentInsetY - sectionInsetY) animated:YES];
}

-(void)searchEnded {
    // search ended, enable scrolling and hide dimming view
    [self.view sendSubviewToBack:self.searchViewContainer];
    
    self.collectionView.scrollEnabled = YES;
}

-(void)setupSearchHeader {
    if (!_searchViewController) {
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        _searchViewController = (MZKSearchViewController *)[sb instantiateViewControllerWithIdentifier:@"MZKSearchViewController"];
        _searchViewController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        _searchViewController.view.frame = CGRectMake(0, 0, _searchViewContainer.frame.size.width, _searchViewContainer.frame.size.height);
        
        _searchViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _searchViewController.view.translatesAutoresizingMaskIntoConstraints = YES;
        _searchViewController.delegate = self;
        
        UIBarButtonItem *right =
        [[UIBarButtonItem alloc] initWithTitle:@"Right"
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(buttonPressed:)];
        [right setBackgroundImage:[UIImage imageNamed:@"ShowBars"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [_searchViewController.navigationItem setRightBarButtonItem:right];


        [self addChildViewController:_searchViewController];
        
        _searchBarContainerView.searchBar.delegate = _searchViewController;
        [_searchViewContainer addSubview:_searchViewController.view];
        
        [self.view sendSubviewToBack:_searchViewContainer];
    }
}

#pragma mark - rotation handling
-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    // will execute before rotation
    [self updateCollectionViewLayoutWithSize:size];
    
    [coordinator animateAlongsideTransition:^(id  _Nonnull context) {

    } completion:^(id  _Nonnull context) {
        
        // will execute after rotation
    }];
}

- (void)willTransitionToTraitCollection:(nonnull UITraitCollection *)newCollection withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {

}


-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)presentMusicViewController:(MusicViewController *)controller withItem:(NSString *)item {

    MusicViewController *musicViewController = nil;

    AppDelegate *del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    musicViewController = del.musicViewController;

    UIPopoverPresentationController *presentationController = musicViewController.popoverPresentationController;
    presentationController.sourceView = self.view;
    presentationController.sourceRect = CGRectMake(20, 20, 20, 20);
    presentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        musicViewController.preferredContentSize = CGSizeMake(375, 667);
    }

    // present
    [self presentViewController:musicViewController animated:YES completion:^{
        if (item) {
            [musicViewController playMusicWithPid:item];
        }
    }];
}

- (void)presentMusic {
    [self presentMusicViewController:nil withItem:nil];
}

@end
