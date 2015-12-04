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
#import "MZKPageDetailCollectionViewCell.h"
#import "AppDelegate.h"
#import <UIImageView+WebCache.h>

NSString *const kCellIdentificator = @"MZKPageDetailCollectionViewCell";

@interface MZKDetailViewController ()<DataLoadedDelegate, UIWebViewDelegate, UIGestureRecognizerDelegate, PageResolutionLoadedDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
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
@property (weak, nonatomic) IBOutlet UIView *collectionViewContainer;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionPageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBarSpaceConstraint;

- (IBAction)onClose:(id)sender;
- (IBAction)onPageChanged:(id)sender;
- (IBAction)onShowGrid:(id)sender;

- (IBAction)onTap:(id)sender;

- (IBAction)onNextPage:(id)sender;
- (IBAction)onPreviousPage:(id)sender;
- (IBAction)onShowPages:(id)sender;



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
    
    [self.webView setBackgroundColor:[UIColor blackColor]];
    [self.webView.scrollView setBackgroundColor:[UIColor grayColor]];
    
    barsHidden = hidingBars = NO;
}

-(void)displayItem:(MZKPageObject*)page withURL:(NSString *)url withWith:(double) width andHeight:(double)height
{
    NSString *path = [[NSBundle mainBundle]
                      pathForResource:@"index"
                      ofType:@"html"];
    
    NSURL *targetURL = [NSURL fileURLWithPath:path];
    NSError *error;
    
    NSMutableString *indexString = [[NSString stringWithContentsOfURL:targetURL encoding:NSUTF8StringEncoding error:&error] mutableCopy];
    float scale = [self calculateInitialScaleForResource:page];
    NSLog(@"%.2f", scale);
    
    NSString *theAbsoluteURLString = [targetURL absoluteString];
    if (width ==0 ) {
        width = self.view.frame.size.width;
    }
    if (height ==0 ) {
        height = self.view.frame.size.height;
    }
    NSString *queryString = [NSString stringWithFormat:@"?url=http://kramerius.mzk.cz/search/zoomify/%@/&width=%f&height=%f", url, width, height];
    
    NSString *absoluteURLwithQueryString = [theAbsoluteURLString stringByAppendingString: queryString];
    
    NSURL *finalURL = [NSURL URLWithString: absoluteURLwithQueryString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:finalURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:(NSTimeInterval)10.0 ];
    
    NSLog(@"Request:%@", [request description]);
    
    if (!_webView) {
        NSLog(@"NO WeB View");
    }
    [_webView setContentMode:UIViewContentModeScaleToFill];
    [_webView.scrollView setContentSize:CGSizeMake(_webView.frame.size.width, _webView.frame.size.height)];

    [_webView loadRequest:request];
    
    NSLog(@"Width:%f  Height:%f", width, height);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setItemPID:(NSString *)pid
{
    if (!detailDatasource) {
        detailDatasource = [MZKDatasource new];
        detailDatasource.delegate = self;
    }
    [detailDatasource getItem:pid];

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
    [detailDatasource getItem:item.pid];
    
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
        [self displayItem:pageObject withURL:pageObject.pid withWith:pageObject.width andHeight:pageObject.height];
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
    if (loadedItem.title) {
         self.titleLabel.text = loadedItem.title;
    }
   

}

-(void)displayPage:(MZKPageObject *)pageObject
{
    NSUInteger targetIndex = [loadedPages indexOfObjectIdenticalTo:pageObject];
    
    [self displayItem:pageObject withURL:pageObject.pid withWith:pageObject.width andHeight:pageObject.height];
    currentIndex = targetIndex;
    self.pageSlider.value = currentIndex;
    [self updateUserInterfaceAfterPageChange];
    
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
    
    [self loadImagePropertiesForItem: [[loadedPages objectAtIndex:currentIndex] pid]];
    
}

-(void)detailForItemLoaded:(MZKItemResource *)item
{
    loadedItem = item;
    self.titleLabel.text = item.title;
    
    [detailDatasource getChildrenForItem:loadedItem.pid];
    __weak typeof(self) wealf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
          wealf.titleLabel.text = _item.title;
        
    });
  

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
    
    double value = self.pageSlider.value;
    int myInt = (int)(value + (value>0 ? 0.5 : -0.5));
    
    
    [self.pageSlider setValue:myInt animated:YES];
    currentIndex = myInt;
    [self switchPage];
    
    
}

- (IBAction)onShowGrid:(id)sender {
    
    _collectionViewContainer.hidden = !_collectionViewContainer.hidden;
    [self.collectionPageView reloadData];
}

#pragma mark - tap gesture recognizer

-(IBAction)onTap:(id)sender
{
    NSLog(@"Tap detected!");
    
    if (!hidingBars) {
        
        barsHidden?[self showBars:YES]:[self hideBars:YES];
    }
    
}

-(void)switchPage
{
    MZKPageObject *obj = [loadedPages objectAtIndex:currentIndex];
    
    [self loadImagePropertiesForItem:obj.pid];

    [self updateUserInterfaceAfterPageChange];
}

- (IBAction)onNextPage:(id)sender {
    if (++currentIndex <=loadedPages.count-1) {
       
        [self switchPage];
    }

}

- (IBAction)onPreviousPage:(id)sender {
    NSInteger tmpi = currentIndex;
    tmpi--;
    if (tmpi >=0) {
        currentIndex--;
       [self switchPage];
    }
}

- (IBAction)onShowPages:(id)sender {
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
        _bottomBarSpaceConstraint.constant = _bottomBar.frame.size.height;
        [UIView animateWithDuration:.5 animations:^{
           self.topBar.alpha = self.bottomBar.alpha = 1.0;
            [self.view layoutIfNeeded];
            
        } completion:^(BOOL finished) {
            barsHidden = NO;
            hidingBars = NO;
        }];
    }
    else
    {
        self.topBar.alpha = self.bottomBar.alpha = 1.0;
        barsHidden = NO;
        _bottomBarSpaceConstraint.constant = _bottomBar.frame.size.height;
        
    }
    
}

-(void)hideBars:(BOOL)animated
{
    if (animated) {
        hidingBars = YES;
        _bottomBarSpaceConstraint.constant = 0;
        [UIView animateWithDuration:.5 animations:^{
            self.topBar.alpha = self.bottomBar.alpha = 0.0;
             [self.view layoutIfNeeded];
            
        } completion:^(BOOL finished) {
            barsHidden = YES;
              hidingBars = NO;
        }];
    }
    else
    {
         self.topBar.alpha = self.bottomBar.alpha = 0.0;
         barsHidden = YES;
        _bottomBarSpaceConstraint.constant = 0;

    }
  

}
#pragma mark - collection view delegate and datasource
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {

    return loadedPages.count;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (MZKPageDetailCollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MZKPageDetailCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:kCellIdentificator forIndexPath:indexPath];
    
    MZKPageObject *page = [loadedPages objectAtIndex:indexPath.row];
    if (page) {
        
    
        AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        
        NSString*url = [NSString stringWithFormat:@"%@://%@", delegate.defaultDatasourceItem.protocol, delegate.defaultDatasourceItem.stringURL];
        NSString*path = [NSString stringWithFormat:@"%@//search/api/v5.0/item/%@/thumb",url, page.pid ];
        
        cell.pageNumber.text = [NSString stringWithFormat:@"%i", page.titleStringValue.intValue] ;
        [cell.pageThumbnail sd_setImageWithURL:[NSURL URLWithString:path]
                          placeholderImage:nil];
        cell.page = page;
    
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MZKPageObject *p = [loadedPages objectAtIndex:indexPath.row];
    [self displayPage:p];
    [self onShowGrid:nil];
}



#pragma mark - JS and HTML parameters

-(float)calculateInitialScaleForResource:(MZKPageObject *)pageObject
{
    float aspectRatio =(float)pageObject.width / (float)pageObject.height;
    float height = aspectRatio *_webView.frame.size.width;
    float finalRatio = _webView.frame.size.width/height;
    
    NSLog(@"Final ratio:%f", finalRatio);
    
    return finalRatio;
}


@end
