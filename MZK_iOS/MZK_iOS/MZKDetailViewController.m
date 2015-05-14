//
//  MZKDetailViewController.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 12/05/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKDetailViewController.h"
#import "MZKDatasource.h"

@interface MZKDetailViewController ()<DataLoadedDelegate, UIWebViewDelegate>
{
    MZKDatasource *detailDatasource;
    MZKItemResource *loadedItem;
}
@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)onClose:(id)sender;

@end

@implementation MZKDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    NSURLRequest *itemRequest = 
    //self.webView loadRequest:
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setItem:(MZKItemResource *)item
{
    _item = item;
    [self loadDataForItem:_item];
}

-(void)loadDataForItem:(MZKItemResource *)itemRes
{
    if (!detailDatasource) {
        detailDatasource = [MZKDatasource new];
        detailDatasource.delegate = self;
    }
    [detailDatasource getItem:itemRes.pid];
}

-(void)detailForItemLoaded:(MZKItemResource *)item
{
    loadedItem = item;
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
@end
