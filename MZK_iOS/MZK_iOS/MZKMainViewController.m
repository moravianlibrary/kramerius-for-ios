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

#import <SDWebImage/UIImageView+WebCache.h>

@interface MZKMainViewController ()<DataLoadedDelegate, UITableViewDataSource, UITableViewDelegate>
{
    MZKDatasource *datasource;
    NSMutableDictionary *items;
    UIRefreshControl *refreshControl;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MZKMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    datasource = [MZKDatasource new];
    datasource.delegate = self;
    
    [datasource getRecommended];
    [datasource getMostRecent];
    
    refreshControl = [[UIRefreshControl alloc] init];
   
    refreshControl.tintColor = [UIColor blueColor];
    [refreshControl addTarget:self
                            action:@selector(reloadValues)
                  forControlEvents:UIControlEventValueChanged];
    
    [self.tableView addSubview:refreshControl];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultDatasourceChangedNotification:) name:kDatasourceItemChanged object:nil];
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
        
    
    if (!items) {
        items = [NSMutableDictionary new];
    }
    if (![[items allKeys] containsObject:key]) {
        [items setObject:data forKey:key];
    }else{
        [items setObject:data forKey:key];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
        
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
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberof = 0;
        if ([[items allKeys] objectAtIndex:section]) {
        numberof = [[items objectForKey:[[items allKeys] objectAtIndex:section]] count];
    }
    
    NSLog(@"Number of rows: %ld", (long)numberof);
    
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
        NSString*url = @"http://kramerius.mzk.cz";
        NSString*path = [NSString stringWithFormat:@"%@//search/api/v5.0/item/%@/thumb",url, item.pid ];
        
     
        [cell.itemImage sd_setImageWithURL:[NSURL URLWithString:path]
                                  placeholderImage:nil];
    }
       
    
    return cell;
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numberOfsections = [[items allKeys] count];
    NSLog(@"Number of sections %li", (long)numberOfsections);
    return numberOfsections;
    
}

-(MZKItemResource *)itemAtIndexPath:(NSIndexPath *)path
{
    MZKItemResource *item;
    if (items) {
        NSString *key = [[items allKeys] objectAtIndex:path.section];
        NSArray *itemsForKey =[items objectForKey:key];
        
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
    [self.tableView reloadData];
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
