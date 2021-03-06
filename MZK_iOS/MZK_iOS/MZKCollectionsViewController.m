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
#import "AppDelegate.h"

@import SDWebImage;
@import RMessage;

@interface MZKCollectionsViewController ()<DataLoadedDelegate,UITableViewDataSource, UITableViewDelegate> {
    MZKDatasource * _datasource;
    NSArray *_collections;
    NSArray *_collectionItems;
    NSString *_selectedCollectionName;
    NSString *_selectedCollectionPID;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MZKCollectionsViewController
- (id)initWithCoder:(NSCoder *)decoder {
    
    self = [super initWithCoder:decoder];
    if (self) {
        self.navigationController.tabBarItem.title = NSLocalizedString(@"mzk.collections", @"Collections title");
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadDataForController];
    self.title = self.navigationController.tabBarItem.title;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultDatasourceChangedNotification:) name:kDatasourceItemChanged object:nil];
    [self initGoogleAnalytics];
}

- (void)loadDataForController {
    _datasource = [[MZKDatasource alloc] init];
    [_datasource setDelegate:self];
    [_datasource getInfoAboutCollections];
    _selectedCollectionName = nil;
    
}

- (void)initGoogleAnalytics {
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

#pragma mark - Datasource Delegate
- (void)collectionListLoaded:(NSArray *)collections {
    if(![[NSThread currentThread] isMainThread]) {
        __weak typeof(self) welf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf collectionListLoaded:collections];
        });
        return;
    }
    
    _collections = collections;
    [self.tableView reloadData];
}

- (void)downloadFailedWithError:(NSError *)error {
    __weak typeof(self) welf = self;
    if(![[NSThread currentThread] isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf downloadFailedWithError:error];
        });
        return;
    }
    
    //[self hideLoadingIndicator];
    if ([error.domain isEqualToString:NSURLErrorDomain]) {
        //NSError Domain Code
        [RMessage showNotificationWithTitle:NSLocalizedString(@"mzk.error.networkConnectionLost", @"Obecna chyba")
                                   subtitle:NSLocalizedString(@"mzk.error.checkYourInternetConnection", "generic error")
                                       type:RMessageTypeWarning
                             customTypeName:nil callback:^{
                                 [welf loadDataForController];
                             }];
    }else if([error.domain isEqualToString:@"MZK"]) {
        [RMessage showNotificationWithTitle:NSLocalizedString(@"mzk.error", @"Obecna chyba")
                                   subtitle:[error.userInfo objectForKey:@"details"]
                                       type:RMessageTypeWarning
                             customTypeName:nil callback:^{
                                 [welf loadDataForController];
                             }];
    } else {
        [RMessage showNotificationWithTitle:NSLocalizedString(@"mzk.error", @"Obecna chyba")
                                   subtitle:NSLocalizedString(@"mzk.error.kramerius", "generic error")
                                       type:RMessageTypeWarning
                             customTypeName:nil callback:^{
                                 [welf loadDataForController];
                             }];
    }
}

#pragma mark - UITableView Delegate and Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _collections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MZKCollectionTableViewCell *cell = (MZKCollectionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"MZKCollectionTableViewCell"];
    
    MZKCollectionItem  *item = [_collections objectAtIndex:indexPath.row];
    
    cell.collectionTitleLabel.text = item.nameCZ;
    cell.collectionItem = item;

    if (item.longDescriptionCZ) {
        [cell.longDescription setHidden:NO];
        [cell.longDescription setText:item.longDescriptionCZ];
    } else {
        [cell.numberOfDocuments setHidden:YES];
    }

    if (item.numberOfDocuments > 0) {
        [cell.numberOfDocuments setHidden:NO];
        [cell.numberOfDocuments setText:[NSString stringWithFormat:@"%ld dokumentů", (long)item.numberOfDocuments]];
    } else {
        [cell.numberOfDocuments setHidden:YES];
    }

    __weak AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    NSString *path = [NSString stringWithFormat:@"%@/search/api/v5.0/item/%@/thumb",delegate.defaultDatasourceItem.url, item.pid ];

    [cell.collectionImageView sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:nil];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MZKCollectionItem  *item = [_collections objectAtIndex:indexPath.row];
    [_datasource getCollectionItems:item.pid];
    _selectedCollectionName = item.nameCZ;
    _selectedCollectionPID= item.pid;
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        
    [self performSegueWithIdentifier:@"OpenCollection" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"OpenCollection"]) {
        // Get reference to the destination view controller
        MZKCollectionDetailViewController *vc = [segue destinationViewController];

        [vc setCollectionPID:_selectedCollectionPID];
        [vc setSelectedCollectionName:_selectedCollectionName];
    }
}

#pragma mark - notification handling
- (void)defaultDatasourceChangedNotification:(NSNotification *)notf {
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    _datasource = [[MZKDatasource alloc] init];
    [_datasource setDelegate:self];
    [_datasource getInfoAboutCollections];
    _selectedCollectionName = nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
