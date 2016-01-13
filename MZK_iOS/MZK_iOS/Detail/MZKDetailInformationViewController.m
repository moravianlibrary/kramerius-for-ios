//
//  MZKDetailInformationViewController.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 04/01/16.
//  Copyright © 2016 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKDetailInformationViewController.h"
#import "MZKConstants.h"
#import "MZKDetailInformationDataSource.h"

@interface MZKDetailInformationViewController ()<DetailInformationDelegate>
{
    MZKDetailInformationDataSource *datasource;
    
}

@end

@implementation MZKDetailInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (_item) {
        [self loadDataForItem:_item];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setItem:(NSString *)item
{
    _item = item;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)loadDataForItem:(NSString *)pid
{
    [self setupDatasource];
    
    [datasource getDetailInformationAboutDocument:pid];
    
}

-(void)setupDatasource
{
    if (!datasource) {
        datasource = [MZKDetailInformationDataSource new];
        datasource.delegate = self;
    }
}

#pragma mark - Detail info delegate

-(void)detailInformationLoaded:(MZKDetailInformationModel *)info
{
    // information loaded
    
}

-(void)downloadFailed
{
    
}

@end
