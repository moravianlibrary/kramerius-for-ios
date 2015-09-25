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

@interface MZKCollectionsViewController ()<DataLoadedDelegate,UITableViewDataSource, UITableViewDelegate>
{
    MZKDatasource * _datasource;
    NSArray *_collections;
    NSArray *_collectionItems;
    NSString *_selectedCollectionName;
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

-(void)collectionItemsLoaded:(NSArray *)collectionItems
{
    // open colleciton detail from here
    
    if(![[NSThread currentThread] isMainThread])
    {
        __weak typeof(self) welf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf collectionItemsLoaded:collectionItems];
        });
        return;
    }
    _collectionItems = collectionItems;
    //open detail
    
    [self performSegueWithIdentifier:@"OpenCollection" sender:self];
    
   

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
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"OpenCollection"])
    {
        // Get reference to the destination view controller
        MZKCollectionDetailViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        [vc setItems:_collectionItems];
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
