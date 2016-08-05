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
#import "MZKDetailViewController.h"
#import "MZKMusicViewController.h"
#import "MZKGeneralColletionViewController.h"
#import "MZKConstants.h"
#import "MZKSearchTableViewCell.h"
#import "MZKSearchHistoryItem.h"
#import "MZKQueue.h"
#import "TSMessage.h"

@interface MZKSearchViewController ()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, DataLoadedDelegate>
{
    NSArray *_searchHints;
    NSArray *_recentSearches;
    NSArray *_searchResults;
    MZKDatasource *_datasource;
    MZKItemResource *_item;
    BOOL _isRemovingTextWithBackspace;
    
    MZKQueue *_hist;
   
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
    
    self.title = NSLocalizedString(@"mzk.searchResults", @"Search VC title");
    
    [_searchResultsTableView registerClass:[MZKSearchTableViewCell class] forCellReuseIdentifier:@"MZKSearchTableViewCell"];
    
  //  _searchResultsTableView.registerClass(UITableViewCell.classForKeyedArchiver(), forCellReuseIdentifier: "your_reuse_identifier")
    
    // Do any additional setup after loading the view.
    [self hideDimmingView];
    // Do any additional setup after loading the view.
    [self initGoogleAnalytics];
    _searchHints= [NSArray new];
    _recentSearches = [self loadRecentSearches];

    self.searchResultsTableView.tableFooterView = [[UIView alloc] init];
    _hist = [[MZKQueue alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultDatasourceChangedNotification:) name:kDatasourceItemChanged object:nil];
}

-(void)initGoogleAnalytics
{
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

-(void)setStringItem:(NSString *)stringItem
{
    _stringItem = stringItem;
    
    //should load details for string item
    
    if (!_datasource) {
        _datasource = [MZKDatasource new];
        _datasource.delegate = self;
    }
    
    //[_datasource getFullSearchResults:_stringItem];

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
    
    [self showErrorWithCancelActionAndTitle:@"Problém při stahování" subtitle:@"Opakujte zadání"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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

    if (searchText.length == 0 && !_isRemovingTextWithBackspace)
    {
        NSLog(@"Has clicked on clear !");
        [self searchBarCancelButtonClicked:searchBar];
        
        // show recent
        _searchResultsTableView.hidden = NO;
        [_searchResultsTableView reloadData];
        
        if ([self.delegate respondsToSelector:@selector(searchStarted)]) {
            [self.delegate searchStarted];
        }
        
    }else if (searchText.length >=3) {
        [self performHintSearchWithText:searchText];
    }
    else
    {
        [self showDimmingView];
        _searchHints= [NSArray new];
        _searchResultsTableView.hidden = NO;
        [_searchResultsTableView reloadData];
    }
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
    [self.view endEditing:YES];
    [searchBar resignFirstResponder];
    searchBar.text = @"";
    [self hideDimmingView];
    
    if ([self.delegate respondsToSelector:@selector(searchEnded)]) {
        [self.delegate searchEnded];
    }
}


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
    
    //t[self hideDimmingView];
   //DELEGATE? [self hideLoadingIndicator];
    
    _searchHints= results;
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
    NSLog(@"Number of rows:%lu", (_searchHints.count + _recentSearches.count));
    NSLog(@"NUmber of recent searches:%lu", (unsigned long)_recentSearches.count);
    return  _searchHints.count + _recentSearches.count;
}

-(MZKSearchTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MZKSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MZKSearchTableViewCell2" forIndexPath:indexPath];
    
    if (_recentSearches.count > 0) {
        
        if (indexPath.row <=_recentSearches.count-1) {
            
            MZKSearchHistoryItem *tmpItem = [_recentSearches objectAtIndex:indexPath.row];
            cell.searchHintLabel.text = tmpItem.title;
            cell.searchTypeIcon.image = [UIImage imageNamed:@"recentSearch"];
            
            return cell;
        }
    }
    
    // no recent searches
    cell.searchHintLabel.text = [_searchHints objectAtIndex:indexPath.row-_recentSearches.count];
    cell.searchTypeIcon.image = [UIImage imageNamed:@"zoomSearchIcon"];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [_searchHints objectAtIndex:indexPath.row];

    MZKSearchHistoryItem *item = [[MZKSearchHistoryItem alloc] init];
    item.timestamp = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];

    item.title = key;
    
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
    
    [_hist enqueue:title];
    
}



#pragma mark - datasource delegate

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
    
    
    _searchResults = results;
    
    [self performSegueWithIdentifier:@"OpenGeneralList" sender:nil];
    
    if ([self.delegate respondsToSelector:@selector(searchEnded)]) {
        [self.delegate searchEnded];
    }

}

#pragma mark segues for general view controller

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
        //[vc setParentPID:((MZKItemResource *)sender).pid];
        vc.title = NSLocalizedString(@"mzk.searchResults", @"Search results title for VC");
        vc.isFirst = YES;
        vc.shouldShowSearchBar = NO;
        vc.items = _searchResults;
    }
}

#pragma mark - recent searches
-(void)addRecentSearch:(NSString *)recentSearch
{
    if (_hist.count<3) {
        [_hist enqueue:recentSearch];
        NSLog(@"Adding, hist count:%lu", (unsigned long)_hist.count);
    }
    else
    {
        NSLog(@"Removing, hist count:%lu", (unsigned long)_hist.count);
        [_hist dequeue];
        [_hist enqueue:recentSearch];
    }
}

-(void)saveRecentSearches
{
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_hist] forKey:kRecentSearches];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

-(MZKQueue *)loadRecentSearches
{
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *dataRepresentingSavedArray = [currentDefaults objectForKey:kRecentSearches];
    MZKQueue *savedData;
    if (dataRepresentingSavedArray)
    {
        savedData = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedArray];
        if (!savedData) {
            savedData = [MZKQueue new];
        }
    }else
    {
        return [MZKQueue new];
        
    }
    
    NSLog(@"Loading recent searches:%lu", (unsigned long)savedData.count);
    
    return savedData;
    
    [TSMessage showNotificationWithTitle:@"Your Title"
                                subtitle:@"A description"
                                    type:TSMessageNotificationTypeError];
    
    
    // Add a button inside the message
    [TSMessage showNotificationInViewController:self
                                          title:@"Update available"
                                       subtitle:@"Please update the app"
                                          image:nil
                                           type:TSMessageNotificationTypeMessage
                                       duration:TSMessageNotificationDurationAutomatic
                                       callback:nil
                                    buttonTitle:@"Update"
                                 buttonCallback:^{
                                     NSLog(@"User tapped the button");
                                 }
                                     atPosition:TSMessageNotificationPositionTop
                           canBeDismissedByUser:YES];

}

-(void)datasourceChanged:(NSNotification *)notf
{
    // when datasource is changed we need to drop all recent changes
    
    //remove all recent searches
    
    _hist = [[MZKQueue alloc] init];
    NSLog(@"Removing history searches");
}

#pragma mark - search bar 

-(void)removeSearchBarBorder
{
    if ([self.searchBar respondsToSelector:@selector(setBarTintColor:)]) {
        self.searchBar.barTintColor = [UIColor clearColor];
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
