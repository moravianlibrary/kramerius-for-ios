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

@interface MZKSearchViewController ()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, DataLoadedDelegate>
{
    NSDictionary *_searchResults;
    MZKDatasource *_datasource;
    MZKItemResource *_item;
   
}
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *searchResultsTableView;
@property (weak, nonatomic) IBOutlet UIView *dimmingView;
@property (weak, nonatomic) IBOutlet UIView *activityIndicatorContainerView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSString *stringItem;

@end

@implementation MZKSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
}

#pragma mark - datasource delegate
-(void)detailForItemLoaded:(MZKItemResource *)item
{
    _item = item;
    
    if ([_item.model caseInsensitiveCompare:@"manuscript"] ==NSOrderedSame) {
         [self performSegueWithIdentifier:@"OpenDetail" sender:_item];
    }
}

-(void)searchResultsLoaded:(NSArray *)results
{
    [self hideDimmingView];
    NSLog(@"Loaded");
    
}

#pragma mark segues for general view controller



@end
