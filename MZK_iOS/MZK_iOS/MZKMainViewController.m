//
//  MZKMainViewController.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 05/05/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKMainViewController.h"
#import "MZKDatasource.h"
#import "MZKItemTableViewCell.h"
#import "MZKDetailViewController.h"
#import "MZKConstants.h"
#import "AppDelegate.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface MZKMainViewController ()<DataLoadedDelegate, UITableViewDataSource, UITableViewDelegate>
{
    MZKDatasource *datasource;
    NSMutableDictionary *items;
    UIRefreshControl *refreshControl;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *activityIndicatorContentView;

@end

@implementation MZKMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    datasource = [MZKDatasource new];
    datasource.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultDatasourceChangedNotification:) name:kDatasourceItemChanged object:nil];
    
    [self refreshAllValues];
}

-(void)refreshAllValues
{
    items = nil;
    [datasource getRecommended];
    [datasource getMostRecent];
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    
}

-(void)reloadValues
{
    [refreshControl endRefreshing];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dataLoaded:(NSArray *)data withKey:(NSString *)key
{
    if (data.count>0) {
        
        [self.activityIndicator stopAnimating];
        
        
        if (!items) {
            items = [NSMutableDictionary new];
        }
        if (![[items allKeys] containsObject:key]) {
            [items setObject:data forKey:key];
        }else{
            [items setObject:data forKey:key];
        }
        
        __weak typeof(self) wealf = self;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wealf.tableView reloadData];
            wealf.activityIndicator.hidden= YES;
            [wealf.activityIndicator stopAnimating];
        });
        
        if (![NSThread mainThread]) {
            [self performSelectorOnMainThread:@selector(reloadData) withObject:self.tableView waitUntilDone:NO];
            NSLog(@"Not main thread ======");
        }
        
    }
}

#pragma mark - UITableViewDatasource and Delegate
// Section header & footer information. Views are preferred over title should you decide to provide both

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//
//}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[items allKeys] objectAtIndex:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MZKItemTableViewCell *cell = (MZKItemTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"OpenDetail" sender:cell];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberof = 0;
    if ([[items allKeys] objectAtIndex:section]) {
        numberof = [[items objectForKey:[[items allKeys] objectAtIndex:section]] count];
    }
    
    //   NSLog(@"Number of rows: %ld", (long)numberof);
    
    return numberof;
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MZKItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MZKItemTableViewCell"];
    
    cell.itemImage.image = nil;
    MZKItemResource *item = [self itemAtIndexPath:indexPath];
    if (item) {
        cell.itemName.text = item.title;
        cell.itemInfo.text = item.issn;
        cell.item = item;
        cell.itemKind.text = item.model;
        
        
        AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        
        NSString*url = [NSString stringWithFormat:@"%@://%@", delegate.defaultDatasourceItem.protocol, delegate.defaultDatasourceItem.stringURL];
        NSString*path = [NSString stringWithFormat:@"%@//search/api/v5.0/item/%@/thumb",url, item.pid ];
        
        
        [cell.itemImage sd_setImageWithURL:[NSURL URLWithString:path]
                          placeholderImage:nil];
    }
    
    
    return cell;
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numberOfsections = [[items allKeys] count];
    //   NSLog(@"Number of sections %li", (long)numberOfsections);
    return numberOfsections;
    
}

-(MZKItemResource *)itemAtIndexPath:(NSIndexPath *)path
{
    MZKItemResource *item;
    if (items) {
        NSString *key = [[items allKeys] objectAtIndex:path.section];
        
        item =  [[items objectForKey:key] objectAtIndex:path.row];
        
    }
    return item;
}

#pragma mark - segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"OpenDetail"])
    {
        // Get reference to the destination view controller
        MZKDetailViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        [vc setItem:((MZKItemTableViewCell*)sender).item];
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


#pragma mark - notification handling
-(void)defaultDatasourceChangedNotification:(NSNotification *)notf
{
    if ( ![[NSThread currentThread] isEqual:[NSThread mainThread]] )
    {
        [self performSelectorOnMainThread:@selector(refreshAllValues) withObject:self waitUntilDone:NO];
    }
    else
    {
        [self refreshAllValues];
    }
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
