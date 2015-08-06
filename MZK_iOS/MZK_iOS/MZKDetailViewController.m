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

@interface MZKDetailViewController ()<DataLoadedDelegate, UIWebViewDelegate, UIGestureRecognizerDelegate, PageResolutionLoadedDelegate>
{
    MZKDatasource *detailDatasource;
    MZKItemResource *loadedItem;
    NSArray *loadedPages;
    NSUInteger currentIndex;
    BOOL hidingBars;
    BOOL barsHidden;
}
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UISlider *pageSlider;
@property (weak, nonatomic) IBOutlet UILabel *pageCount;
@property (weak, nonatomic) IBOutlet UIButton *showGrid;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, strong) UISwipeGestureRecognizer *leftGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *rightGestureRecognizer;
@property (nonatomic, strong) IBOutlet UITapGestureRecognizer *tapGestureRecognizer;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UIView *bottomBar;

- (IBAction)onClose:(id)sender;
- (IBAction)onPageChanged:(id)sender;
- (IBAction)onShowGrid:(id)sender;

- (IBAction)onTap:(id)sender;



@end

@implementation MZKDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.webView.delegate = self;
    currentIndex = 0;

    if (self.item) {
         [self loadImageStreamsForItem:_item.pid];
        [detailDatasource getChildrenForItem:_item.pid];
        self.titleLabel.text = _item.title;
        
    }
    
    self.pageSlider.continuous = NO;
    self.pageCount.text = @"-/-";
    
    
    //setup gesture recognizers
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.delegate = self;
    self.tapGestureRecognizer = singleTap;
    [self.webView addGestureRecognizer:singleTap];
    
    [self.webView setBackgroundColor:[UIColor greenColor]];
    [self.webView.scrollView setBackgroundColor:[UIColor grayColor]];
    
    barsHidden = hidingBars = NO;
}

-(void)displayItemWithURL:(NSString *)url withWith:(double) width andHeight:(double)height
{
    NSString *path = [[NSBundle mainBundle]
                      pathForResource:@"index"
                      ofType:@"html"];
    
    NSURL *targetURL = [NSURL fileURLWithPath:path];
    
    
    
    NSString *theAbsoluteURLString = [targetURL absoluteString];
    
    NSString *queryString = [NSString stringWithFormat:@"?url=http://kramerius.mzk.cz/search/zoomify/%@/&width=%f&height=%f", url, width, height];
    
    NSString *absoluteURLwithQueryString = [theAbsoluteURLString stringByAppendingString: queryString];
    
    NSURL *finalURL = [NSURL URLWithString: absoluteURLwithQueryString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:finalURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:(NSTimeInterval)10.0 ];
    
    if (!_webView) {
        NSLog(@"NO WeB View");
    }
    [_webView setContentMode:UIViewContentModeScaleToFill];
    [_webView.scrollView setContentSize:CGSizeMake(_webView.frame.size.width, _webView.frame.size.height)];

    [_webView loadRequest:request];
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

-(void)loadDataForItem:(MZKItemResource *)item
{
    if (!detailDatasource) {
        detailDatasource = [MZKDatasource new];
        detailDatasource.delegate = self;
    }
   // [detailDatasource getItem:itemRes.pid];
    
    self.titleLabel.text = item.title;
    
}

-(void)loadImagePropertiesForItem:(NSString *)pid
{
    if (loadedPages) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pid ==%@", pid];
        NSArray *filtered = [loadedPages filteredArrayUsingPredicate:predicate];
        if (filtered.count > 0) {
            MZKPageObject *pageObj = (MZKPageObject *)[filtered objectAtIndex:0];
            [pageObj setDelegate:self];
            [pageObj loadPageResolution];
        }
    }
    
}

-(void)pageLoadedForItem:(MZKPageObject *)pageObject
{
    NSLog(@"Page Resolution LOADED");
    
    if (pageObject.pid == [[loadedPages objectAtIndex:currentIndex] pid]) {
        [self displayItemWithURL:pageObject.pid withWith:pageObject.width andHeight:pageObject.height];
    }
    
}
-(void)updateUserInterfaceAfterPageChange
{
    __weak MZKDetailViewController *weakSelf= self;
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateUserInterfaceAfterPageChange];
        });
        return;
    }

    self.pageCount.text = [NSString stringWithFormat:@"%lu/%lu", (unsigned long)currentIndex,(unsigned long)loadedPages.count];
    
    self.pageSlider.minimumValue =0;
    self.pageSlider.maximumValue = loadedPages.count-1;
    self.pageSlider.value = currentIndex;

}



-(void)loadImageStreamsForItem:(NSString *)pid
{
//    NSString*item = @"http://kramerius.mzk.cz";
//    NSString*finalURL = [NSString stringWithFormat:@"%@/search/api/v5.0/item/%@/full", item, pid ];
//    
//    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:finalURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:130];
//    [req setHTTPMethod: @"GET"];
//    
//    NSString *webString = [NSString stringWithFormat:@"<img  src=\"%@\" alt=\"strom\">", finalURL];
//    //[self.webView loadRequest:req];
//    
//  //  [self.webView loadHTMLString:webString baseURL:nil];
//    
//    CGSize contentSize = self.webView.scrollView.contentSize;
//    CGFloat d = contentSize.height/2 - self.webView.center.y;
//   // [self.webView.scrollView setContentOffset:CGPointMake(0, d) animated:NO];
//    
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

-(void)pagesLoadedForItem:(NSArray *)pages
{
    loadedPages = pages;
    [self updateUserInterfaceAfterPageChange];
    
    [self loadImagePropertiesForItem: [[pages objectAtIndex:currentIndex] pid]];

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
    
    [self loadImagePropertiesForItem:obj.pid];
    
    //[self loadImageStreamsForItem:obj.pid];
    
    [self updateUserInterfaceAfterPageChange];
    
    
}

- (IBAction)onShowGrid:(id)sender {
}

#pragma mark - tap gesture recognizer

-(IBAction)onTap:(id)sender
{
    NSLog(@"Tap detected!");
    
    if (!hidingBars) {
        
        barsHidden?[self showBars:YES]:[self hideBars:YES];
    }
    
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer ==self.tapGestureRecognizer) {
        return YES;
    }
    return NO;
}


#pragma mark - top bar hiding
-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)showBars:(BOOL)animated
{
    if (animated) {
        hidingBars = YES;
        [UIView animateWithDuration:.5 animations:^{
           self.topBar.alpha = self.bottomBar.alpha = 1.0;
            
            
        } completion:^(BOOL finished) {
            barsHidden = NO;
            hidingBars = NO;
        }];
    }
    else
    {
        self.topBar.alpha = self.bottomBar.alpha = 1.0;
        barsHidden = NO;
        
    }
    
}

-(void)hideBars:(BOOL)animated
{
    if (animated) {
        hidingBars = YES;
        [UIView animateWithDuration:.5 animations:^{
            self.topBar.alpha = self.bottomBar.alpha = 0.0;
            
        } completion:^(BOOL finished) {
            barsHidden = YES;
              hidingBars = NO;
        }];
    }
    else
    {
         self.topBar.alpha = self.bottomBar.alpha = 0.0;
         barsHidden = YES;

    }
  

}

@end
