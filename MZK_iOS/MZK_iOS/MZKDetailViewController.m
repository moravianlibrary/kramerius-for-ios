//
//  MZKDetailViewController.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 12/05/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKDetailViewController.h"
#import "MZKDatasource.h"
#import "MZKPageObject.h"

@interface MZKDetailViewController ()<DataLoadedDelegate, UIWebViewDelegate, UIGestureRecognizerDelegate>
{
    MZKDatasource *detailDatasource;
    MZKItemResource *loadedItem;
    NSArray *loadedPages;
    NSUInteger currentIndex;
}
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UISlider *pageSlider;
@property (weak, nonatomic) IBOutlet UILabel *pageCount;
@property (weak, nonatomic) IBOutlet UIButton *showGrid;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, strong) UISwipeGestureRecognizer *leftGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *rightGestureRecognizer;

- (IBAction)onClose:(id)sender;
- (IBAction)onPageChanged:(id)sender;
- (IBAction)onShowGrid:(id)sender;



@end

@implementation MZKDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.webView.delegate = self;
    currentIndex = 0;

   // NSURLRequest *itemRequest =
    //self.webView loadRequest:
    
    if (self.item) {
         [self loadImageStreamsForItem:_item.pid];
        [detailDatasource getChildrenForItem:_item.pid];
        self.titleLabel.text = _item.title;
    }
    
    self.pageSlider.continuous = NO;
    self.pageCount.text = @"-/-";
    
    
    //setup gesture recognizers
    
    self.leftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeLeft)];
    self.leftGestureRecognizer.numberOfTouchesRequired=1;
    self.leftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    self.leftGestureRecognizer.delegate = self;
    
    [self.view addGestureRecognizer:self.leftGestureRecognizer];
    
    self.rightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeRight)];
    self.rightGestureRecognizer.numberOfTouchesRequired=1;
    self.rightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    self.rightGestureRecognizer.delegate = self;
    
     [self.view addGestureRecognizer:self.rightGestureRecognizer];
    
}

-(void)onSwipeLeft
{
    MZKPageObject *obj = [loadedPages objectAtIndex:++currentIndex];
    [self loadImageStreamsForItem:obj.pid];
    NSLog(@"left swipe");
    
}


-(void)onSwipeRight
{
    MZKPageObject *obj = [loadedPages objectAtIndex:--currentIndex];
    [self loadImageStreamsForItem:obj.pid];
    NSLog(@"right swipe");

    
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
   // [detailDatasource getItem:itemRes.pid];
    
    self.titleLabel.text = itemRes.title;
    
}

-(void)updateUserInterfaceAfterPageChange
{
    self.pageCount.text = [NSString stringWithFormat:@"%lu/%lu", (unsigned long)currentIndex,(unsigned long)loadedPages.count];
    
    self.pageSlider.minimumValue =0;
    self.pageSlider.maximumValue = loadedPages.count-1;
    self.pageSlider.value = currentIndex;

}

-(void)pagesLoadedForItem:(NSArray *)pages
{
    loadedPages = pages;
    [self updateUserInterfaceAfterPageChange];
}

-(void)loadImageStreamsForItem:(NSString *)pid
{
    
    
    NSString*item = @"http://kramerius.mzk.cz";
    NSString*finalURL = [NSString stringWithFormat:@"%@/search/api/v5.0/item/%@/full", item, pid ];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:finalURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:130];
    [req setHTTPMethod: @"GET"];
    
    NSString *webString = [NSString stringWithFormat:@"<img  src=\"%@\" alt=\"strom\">", finalURL];
    //[self.webView loadRequest:req];
    
    [self.webView loadHTMLString:webString baseURL:nil];
    
    CGSize contentSize = self.webView.scrollView.contentSize;
    CGFloat d = contentSize.height/2 - self.webView.center.y;
    [self.webView.scrollView setContentOffset:CGPointMake(0, d) animated:NO];
    
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"did Start loading");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"did finish loading");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Failed to load with error :%@",[error debugDescription]);
    
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

- (IBAction)onPageChanged:(id)sender {
    
    
    NSLog(@"slider value:%f", self.pageSlider.value);
    double value = self.pageSlider.value;
    int myInt = (int)(value + (value>0 ? 0.5 : -0.5));
    
    
    [self.pageSlider setValue:myInt animated:YES];
    currentIndex = myInt;
    
    MZKPageObject *obj = [loadedPages objectAtIndex:myInt];
    [self loadImageStreamsForItem:obj.pid];
    
    [self updateUserInterfaceAfterPageChange];
    
    
}

- (IBAction)onShowGrid:(id)sender {
}
@end
