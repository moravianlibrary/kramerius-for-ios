//
//  MZKSearchViewController.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 06/08/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKSearchViewController.h"
#import "MZKDatasource.h"
#import <Google/Analytics.h>
#import "MZKItemResource.h"

#import "MZKMusicViewController.h"
#import "MZKGeneralColletionViewController.h"
#import "MZKConstants.h"
#import "MZKSearchTableViewCell.h"
#import "MZK_iOS-Swift.h"
@import RMessage;

@interface MZKSearchViewController ()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, DataLoadedDelegate>
{
    NSArray *_searchHints;
    NSArray *_searchResults;
    MZKDatasource *_datasource;
    MZKItemResource *_item;
    BOOL _isRemovingTextWithBackspace;
    NSArray *_filteredRecentSearches;
    NSMutableSet *_recentMutableSearches;
}

@property (weak, nonatomic) IBOutlet UITableView *searchResultsTableView;
@property (weak, nonatomic) IBOutlet UIView *dimmingView;
@property (weak, nonatomic) IBOutlet UIView *activityIndicatorContainerView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSString *stringItem;

@end

@implementation MZKSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
  //  self.title = NSLocalizedString(@"mzk.searchResults", @"Search VC title");
    
    [_searchResultsTableView registerClass:[MZKSearchTableViewCell class] forCellReuseIdentifier:@"MZKSearchTableViewCell"];
    
    // Do any additional setup after loading the view.
    [self hideDimmingView];
    // Do any additional setup after loading the view.
    [self initGoogleAnalytics];
    _searchHints= [NSArray new];
    _recentMutableSearches = [self loadRecentSearches];
    
    self.searchResultsTableView.tableFooterView = [[UIView alloc] init];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.searchResultsTableView setContentOffset:CGPointMake(0, -50) animated:false];
}

-(void)onDatasourceChanged:(NSNotification *)notf {
    
    __weak typeof(self) welf = self;
    if(![[NSThread currentThread] isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf onDatasourceChanged:notf];
        });
        return;
    }    
    _searchHints = [NSArray new];
    _searchResults = [NSArray new];
    _filteredRecentSearches = [NSArray new];
    _searchBar.text = @"";
}

-(void)initGoogleAnalytics {
    NSString *name = [NSString stringWithFormat:@"Pattern~%@", @"MZKSearchViewController"];
    
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

-(void)setStringItem:(NSString *)stringItem {
    _stringItem = stringItem;
    
    //should load details for string item
    
    if (!_datasource) {
        _datasource = [MZKDatasource new];
        _datasource.delegate = self;
    }
}

-(void)downloadFailedWithError:(NSError *)error {
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
        if (error.code != -999) {
            //NSError Domain Code
            [RMessage showNotificationWithTitle:NSLocalizedString(@"mzk.error.networkConnectionLost", @"Obecna chyba")
                                       subtitle:NSLocalizedString(@"mzk.error.checkYourInternetConnection", "generic error")
                                           type:RMessageTypeWarning
                                 customTypeName:nil callback:^{
                                    
                                 }];
        }
        else { NSLog(@"Canceled request"); }
    } else if([error.domain isEqualToString:@"MZK"]) {
        [RMessage showNotificationWithTitle:NSLocalizedString(@"mzk.warning", @"Obecna chyba") subtitle:@"Některé části dokumentu nemusí být veřejně dostupné." type:RMessageTypeWarning customTypeName:nil callback:nil];
        
    } else {
        [RMessage showNotificationWithTitle:NSLocalizedString(@"mzk.error", @"Obecna chyba")
                                   subtitle:NSLocalizedString(@"mzk.error.url.unknown", @"general error")
                                       type:RMessageTypeWarning
                             customTypeName:nil callback:^{
                               //  [welf loadDataForController];
                             }];
    }

}

#pragma mark - SearchBar Delegate

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    _isRemovingTextWithBackspace = ([searchBar.text stringByReplacingCharactersInRange:range withString:text].length == 0);
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // Do the search...
    [self performSearchWithItem:searchBar.text];
    
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.searchBar = searchBar;
    _searchResultsTableView.hidden = NO;
    
    _filteredRecentSearches = [self getSearchHintsFromRecentWithString:searchText];
    
    if (searchText.length == 0 && !_isRemovingTextWithBackspace)
    {
        [self searchBarCancelButtonClicked:searchBar];
        
        // show recent
        
        if ([self.delegate respondsToSelector:@selector(searchStarted)]) {
            [self.delegate searchStarted];
        }
        
    }else if (searchText.length >=1) {
        [self performHintSearchWithText:searchText];
    }
    else
    {
        [self showDimmingView];
        _searchHints= [NSArray new];
        _searchResultsTableView.hidden = NO;
    }
    
    [_searchResultsTableView reloadData];
}

-(void)performHintSearchWithText:(NSString *)searchText
{
    if (!_datasource) {
        _datasource = [MZKDatasource new];
        _datasource.delegate = self;
    }
    [_datasource getSearchResultsAsHints:searchText];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self showDimmingView];
    if([self.delegate respondsToSelector:@selector(searchStarted)])
    {
        [self.delegate searchStarted];
    }
    
    [self.searchResultsTableView reloadData];
}

-(void)showDimmingView
{
    if (_dimmingView.hidden) {
        _dimmingView.hidden = NO;
    }
    
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
    [self searchCancelled];
    
    if ([self.delegate respondsToSelector:@selector(searchEnded)]) {
        [self.delegate searchEnded];
    }
}

-(void)searchCancelled {
    [self.view endEditing:YES];
    [_searchBar resignFirstResponder];
    _searchBar.text = @"";
    [self hideDimmingView];

}

#pragma mark - search table view delegate and datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  _searchHints.count + _filteredRecentSearches.count;
}

-(MZKSearchTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MZKSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MZKSearchTableViewCell2" forIndexPath:indexPath];
    
    if (_filteredRecentSearches.count > 0 && indexPath.row <= _filteredRecentSearches.count-1 ) {
        
        NSString *itemTitle = [_filteredRecentSearches objectAtIndex:indexPath.row];
        cell.searchHintLabel.text = itemTitle;
        cell.searchTypeIcon.image = [UIImage imageNamed:@"recentSearch"];
        
        return cell;
    }
    
    if (_searchHints.count !=0 ) {
        // no recent searches
        cell.searchHintLabel.text = [_searchHints objectAtIndex:indexPath.row-_filteredRecentSearches.count];
        cell.searchTypeIcon.image = [UIImage imageNamed:@"zoomSearchIcon"];

    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key;
    if (_filteredRecentSearches.count > 0 && indexPath.row <= _filteredRecentSearches.count-1 ) {
        key = [_filteredRecentSearches objectAtIndex:indexPath.row];
    }
    else
    {
        key = [_searchHints objectAtIndex:indexPath.row - _filteredRecentSearches.count];
    }
    
    _searchBar.text = key;
    [self performSearchWithItem:key];
    [_searchResultsTableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - regular search

-(void)performSearchWithItem:(NSString *)title
{
    if (!_datasource) {
        _datasource = [MZKDatasource new];
        _datasource.delegate = self;
    }
    
    [_datasource getSearchResults:title];
    
    
    if (![_recentMutableSearches containsObject:title]) {
        [_recentMutableSearches addObject:title];
        [self saveRecentSearches];
    }
}

#pragma mark - datasource delegate

-(void)searchHintsLoaded:(NSArray *)results
{
    if(![[NSThread currentThread] isMainThread])
    {
        __weak typeof(self) welf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf searchHintsLoaded:results];
        });
        return;
    }
    
    if (results.count == 0) {
        NSLog(@"0 HINTS results");
    }
    else{
        _searchHints= results;
        _searchResultsTableView.hidden = NO;
        [_searchResultsTableView reloadData];
    }
}

-(void)searchResultsLoaded:(NSArray *)results
{
    if(![[NSThread currentThread] isMainThread])
    {
        __weak typeof(self) welf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf searchResultsLoaded:results];
        });
        return;
    }
    
    [self hideDimmingView];
    
    if (results.count == 0) {
        [RMessage showNotificationWithTitle:NSLocalizedString(@"mzk.error.noRecordsFound", @"Obecna chyba")
                                   subtitle:NSLocalizedString(@"mzk.error.changeSearchTerm", @"general error")
                                       type:RMessageTypeWarning
                             customTypeName:nil callback:^{
                                 //  [welf loadDataForController];
                             }];
    } else {
        _searchResults = results;
        [self performSegueWithIdentifier:@"OpenGeneralList" sender:nil];
    }
    
    if ([self.delegate respondsToSelector:@selector(searchEnded)]) {
        [self.delegate searchEnded];
    }
}

#pragma mark segues for general view controller

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"OpenReader"])
    {
        // Get reference to the destination view controller
        MZKDetailManagerViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        [vc setItemPID:sender];
        
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
     
        vc.title = NSLocalizedString(@"mzk.searchResults", @"Search results title for VC");
        vc.isFirst = YES;
        vc.shouldShowSearchBar = NO;
        vc.items = _searchResults;
        vc.shouldDisplayFilters = YES;
        vc.searchTerm = _searchBar.text;
    
        _searchBar.text = @"";
        [self hideDimmingView];
    }
}

#pragma mark - recent searches
-(NSArray *)getSearchHintsFromRecentWithString:(NSString *)key
{
    
    NSMutableSet *results = [NSMutableSet new];
    // create NSPredicate with correct format
    
    results = [self loadRecentSearches];
    NSString *keywordWithBackslashedApostrophes = [key stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"SELF beginswith[c] '%@'", [keywordWithBackslashedApostrophes lowercaseString]]];
    
    [results filterUsingPredicate:pred];
    
    NSMutableArray *filteredResults = [NSMutableArray new];
    
    if (results.count >3) {
        
        for (int i = 0; i<3; i++) {
            [filteredResults addObject:results.allObjects[i]];
        }
    }
    else
    {
        filteredResults = [results.allObjects copy];
    }
    
    return [filteredResults copy];
}

-(void)saveRecentSearches {
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_recentMutableSearches] forKey:kRecentSearches];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSMutableSet *)loadRecentSearches {
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *dataRepresentingSavedArray = [currentDefaults objectForKey:kRecentSearches];
    NSMutableSet *savedData;
    if (dataRepresentingSavedArray)
    {
        savedData = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedArray];
        if (!savedData) {
            savedData = [NSMutableSet new];
        }
    }else
    {
        return [NSMutableSet new];
        
    }
    
    return savedData;
}

#pragma mark - search bar
-(void)removeSearchBarBorder {
    if ([self.searchBar respondsToSelector:@selector(setBarTintColor:)]) {
        self.searchBar.barTintColor = [UIColor clearColor];
    }
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
