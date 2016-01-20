//
//  MZKCollectionsViewController.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 13/05/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKCollectionsViewController.h"
#import "MZKDatasource.h"
#import "MZKCollectionTableViewCell.h"
#import "MZKCollectionItem.h"
#import "MZKCollectionDetailViewController.h"
#import "MZKConstants.h"
#import <Google/Analytics.h>

@interface MZKCollectionsViewController ()<DataLoadedDelegate,UITableViewDataSource, UITableViewDelegate>
{
    MZKDatasource * _datasource;
    NSArray *_collections;
    NSArray *_collectionItems;
    NSString *_selectedCollectionName;
    NSString *_selectedCollectionPID;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MZKCollectionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _datasource = [[MZKDatasource alloc] init];
    [_datasource setDelegate:self];
    [_datasource getInfoAboutCollections];
    _selectedCollectionName = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultDatasourceChangedNotification:) name:kDatasourceItemChanged object:nil];
    [self initGoogleAnalytics];
}

-(void)initGoogleAnalytics
{
    NSString *name = [NSString stringWithFormat:@"Pattern~%@", @"MZKVirtualCollectionsViewController"];
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - Datasource Delegate
-(void)collectionListLoaded:(NSArray *)collections
{
    if(![[NSThread currentThread] isMainThread])
    {
        __weak typeof(self) welf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf collectionListLoaded:collections];
        });
        return;
    }

    _collections = collections;
    [self.tableView reloadData];
}

#pragma mark - UITableView Delegate and Datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _collections.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MZKCollectionTableViewCell *cell = (MZKCollectionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"MZKCollectionTableViewCell"];
    
    MZKCollectionItem  *item = [_collections objectAtIndex:indexPath.row];
    
    cell.collectionTitleLabel.text = item.nameCZ;
    cell.collectionItem = item;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MZKCollectionItem  *item = [_collections objectAtIndex:indexPath.row];
    [_datasource getCollectionItems:item.pid];
    _selectedCollectionName = item.nameCZ;
    _selectedCollectionPID= item.pid;
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    [self performSegueWithIdentifier:@"OpenCollection" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"OpenCollection"])
    {
        // Get reference to the destination view controller
        MZKCollectionDetailViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
     
        [vc setCollectionPID:_selectedCollectionPID];
        [vc setSelectedCollectionName:_selectedCollectionName];
        
    }
}


#pragma mark - notification handling
-(void)defaultDatasourceChangedNotification:(NSNotification *)notf
{
    [self.tableView reloadData];
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
