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
#import "UIImageView+WebCache.h"
#import <Google/Analytics.h>
#import "MZKDetailInformationViewController.h"
#import "MyURLProtocol.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageView+ProgressView.h"


NSString *const kCellIdentificator = @"MZKPageDetailCollectionViewCell";

@interface MZKDetailViewController ()<DataLoadedDelegate, UIWebViewDelegate, UIGestureRecognizerDelegate, PageResolutionLoadedDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>
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
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageZoomView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTopConstraint;


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
        // [detailDatasource getChildrenForItem:_item.pid];
        self.titleLabel.text = _item.title;
        
    }
    
    self.pageSlider.continuous = NO;
    self.pageCount.text = @"-/-";
    self.pageSlider.minimumValue = 1;
    
    
    //setup gesture recognizers
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.delegate = self;
    self.tapGestureRecognizer = singleTap;
    [self.webView addGestureRecognizer:singleTap];
    
    [_webView setBackgroundColor:[UIColor blackColor]];
    [_webView.scrollView setBackgroundColor:[UIColor grayColor]];
    
    barsHidden = hidingBars = NO;
    
    [self initGoogleAnalytics];
}

-(void)initGoogleAnalytics
{
    NSString *name = [NSString stringWithFormat:@"Pattern~%@", @"MZKDetailViewController"];
    
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

-(void)displayItem:(MZKPageObject*)page withURL:(NSString *)url withWith:(double) width andHeight:(double)height
{
    NSString *path = [[NSBundle mainBundle]
                      pathForResource:@"index"
                      ofType:@"html"];
    
    NSURL *targetURL = [NSURL fileURLWithPath:path];
    NSError *error;
    
    NSMutableString *indexString = [[NSString stringWithContentsOfURL:targetURL encoding:NSUTF8StringEncoding error:&error] mutableCopy];
    float scale = [self calculateInitialScaleForResource:page];
    
    
    NSString *theAbsoluteURLString = [targetURL absoluteString];
    if (width ==0 ) {
        width = self.view.frame.size.width;
    }
    if (height ==0 ) {
        height = self.view.frame.size.height;
    }
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    NSString *queryString = [NSString stringWithFormat:@"?url=%@://%@/search/zoomify/%@/&width=%f&height=%f",delegate.defaultDatasourceItem.protocol, delegate.defaultDatasourceItem.stringURL, url, width, height];
    
    NSString *absoluteURLwithQueryString = [theAbsoluteURLString stringByAppendingString: queryString];
    
    NSURL *finalURL = [NSURL URLWithString: absoluteURLwithQueryString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:finalURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:(NSTimeInterval)10.0 ];
    
    // NSLog(@"Request:%@", [request description]);
    
    if (!_webView) {
        NSLog(@"NO WeB View");
    }
    [_webView setBackgroundColor:[UIColor blackColor]];
    [_webView setContentMode:UIViewContentModeScaleToFill];
    [_webView.scrollView setContentSize:CGSizeMake(_webView.frame.size.width, _webView.frame.size.height)];
    
    [_webView loadRequest:request];
}

-(void)displayItemWithJPGResource:(MZKPageObject *)page
{
    // image server let
    // http://kramerius.mzk.cz/search/img?pid=uuid:1c0e5c47-435f-11dd-b505-00145e5790ea&stream=IMG_FULL&action=SCALE&scaledHeight=1000
    
    // use scrollview instead of UIWebView, use SDWebImage
    
    self.webView.hidden = YES;
    self.scrollView.hidden = NO;
        
    NSLog(@"Page resolution Not Loaded");
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    // /search/api/v5.0/item/uuid:a2b0851b-aa48-11e1-b7f6-0050569d679d/streams/IMG_FULL
    // tady schazi dodelat test na url response...
    NSString *load = [NSString stringWithFormat:@"%@://%@/search/img?pid=%@&stream=IMG_FULL&action=SCALE&scaledHeight=%@", delegate.defaultDatasourceItem.protocol, delegate.defaultDatasourceItem.stringURL, page.pid, [NSString stringWithFormat:@"%d", 1000]];
    
    NSURL *finalURL = [NSURL URLWithString:load];
   // NSURLRequest *request = [NSURLRequest requestWithURL:finalURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:(NSTimeInterval)50 ];
    
    
    [_imageZoomView sd_setImageWithURL:finalURL placeholderImage:nil options:SDWebImageHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)  {
        
    } usingProgressView:nil];

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

-(void)downloadFailedWithError:(NSError *)error
{
    __weak typeof(self) welf = self;
    if(![[NSThread currentThread] isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf downloadFailedWithError:error];
        });
        return;
    }
    
    [self showErrorWithTitle:@"Problém při stahování" subtitle:@"Přejete si opakovat akci?" confirmAction:^{
        if (_item) {
            [welf loadDataForItem:_item];
        }
        
    }];
}

-(void)loadDataForItem:(MZKItemResource *)item
{
    if(![[NSThread currentThread] isMainThread])
    {
        __weak typeof(self) welf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf loadDataForItem:item];
        });
        return;
    }
    
    
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
        
        
        self.pageSlider.userInteractionEnabled = loadedPages.count>1?YES:NO;
        
        }
    
}

-(void)loadImagePropertiesForPageItem:(NSString *)page
{
    MZKPageObject *tmpPageObject = [MZKPageObject new];
    tmpPageObject.pid = page;
    loadedPages = [NSArray arrayWithObject:tmpPageObject];
    
    [tmpPageObject setDelegate:self];
    [tmpPageObject loadPageResolution];
}

-(void)pageLoadedForItem:(MZKPageObject *)pageObject
{
    if(![[NSThread currentThread] isMainThread])
    {
        __weak typeof(self) welf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf pageLoadedForItem:pageObject];
        });
        return;
    }
    
    if (pageObject.pid == [[loadedPages objectAtIndex:currentIndex] pid]) {
        [self displayItem:pageObject withURL:pageObject.pid withWith:pageObject.width andHeight:pageObject.height];
    }
    
}

-(void)displayPageAsJPG
{
    if(![[NSThread currentThread] isMainThread])
    {
        __weak typeof(self) welf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf displayPageAsJPG];
        });
        return;
    }
    
    MZKPageObject *page =[loadedPages objectAtIndex:currentIndex];
    
    [self displayItemWithJPGResource:page];
    
}

-(void)pageResolutionDownloadFailed
{
    __weak typeof(self) welf = self;
    if(![[NSThread currentThread] isMainThread])
    {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf pageResolutionDownloadFailed];
        });
        return;
    }
    
    [self showErrorWithTitle:@"Chyba" subtitle:@"Nepodařilo se načíst informace o stránce." confirmAction:^{
        
    }];
}

//called when getImageProperties returns err 404 or 500 etc

-(void)pageResolutionDownloadFailedWithError:(NSError *)error
{
    __weak typeof(self) welf = self;
    if(![[NSThread currentThread] isMainThread])
    {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf pageResolutionDownloadFailedWithError:error];
        });
        return;
    }
    
    [self displayPageAsJPG];
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
    
    if (loadedPages.count > 1) {
        self.pageSlider.enabled = YES;
        NSUInteger num = currentIndex+1;
        self.pageCount.text = [NSString stringWithFormat:@"%lu/%lu", (unsigned long)num,(unsigned long)loadedPages.count];
        
        self.pageSlider.minimumValue =1;
        self.pageSlider.maximumValue = loadedPages.count;
        self.pageSlider.value = num;
        
    }
    else{
        self.pageSlider.enabled = NO;
    }
    
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

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    // NSLog(@"did Start loading");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSCachedURLResponse *urlResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:webView.request];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) urlResponse.response;
    NSInteger statusCode = httpResponse.statusCode;
    if (statusCode > 399) {
        NSError *error = [NSError errorWithDomain:@"HTTP Error" code:httpResponse.statusCode userInfo:@{@"response":httpResponse}];
        // Forward the error to webView:didFailLoadWithError: or other
    }
    else {
        // No HTTP error
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Failed to load with error :%@",[error debugDescription]);
}

-(void)pagesLoadedForItem:(NSArray *)pages
{
    if(![[NSThread currentThread] isMainThread])
    {
        __weak typeof(self) welf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf pagesLoadedForItem:pages];
        });
        return;
    }
    
    loadedPages = pages;
    [self updateUserInterfaceAfterPageChange];
    
    [self loadImagePropertiesForItem: [[loadedPages objectAtIndex:currentIndex] pid]];
    
}

-(void)detailForItemLoaded:(MZKItemResource *)item
{
    if(![[NSThread currentThread] isMainThread])
    {
        __weak typeof(self) welf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf detailForItemLoaded:item];
        });
        return;
    }
    
    loadedItem = item;
    self.titleLabel.text = item.title;
    
    
    if ([loadedItem.model isEqualToString:@"page"]) {
        [self loadImagePropertiesForPageItem: loadedItem.pid];
    }
    else{
        [detailDatasource getChildrenForItem:loadedItem.pid];
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

- (IBAction)onClose:(id)sender {
    
    if (_item) {
        [self saveDocumentToRecentlyOpened:_item];
    }
    else if (loadedItem)
    {
        [self saveDocumentToRecentlyOpened:loadedItem];
    }
    
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        
    }];

}

- (IBAction)onPageChanged:(id)sender {
    double value = self.pageSlider.value;
    int myInt = (int)(value + (value>0 ? 0.5 : -0.5));
    
    [self.pageSlider setValue:myInt animated:YES];
    currentIndex = myInt-1;
    [self switchPage];
}

- (IBAction)onShowGrid:(id)sender {
    
    _collectionViewContainer.hidden = !_collectionViewContainer.hidden;
    [self.collectionPageView reloadData];
}

#pragma mark - tap gesture recognizer

-(IBAction)onTap:(id)sender
{
    if (!hidingBars) {
        
        barsHidden?[self showBars:YES]:[self hideBars:YES];
    }
}

-(void)switchPage
{
    MZKPageObject *obj = [loadedPages objectAtIndex:currentIndex];
    
    if ([obj.policy isEqualToString:@"public"]) {
        [self loadImagePropertiesForItem:obj.pid];
        
        [self updateUserInterfaceAfterPageChange];
    }
    else
    {
         [self showErrorWithCancelActionAndTitle:@"Pozor" subtitle:@"Tato stránka není veřejně dostupná." withCompletion:nil];
    }
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
        NSString*path = [NSString stringWithFormat:@"%@/search/api/v5.0/item/%@/thumb",url, page.pid ];
        
        cell.pageNumber.text = page.title;
        
        [cell.pageThumbnail sd_setImageWithURL:[NSURL URLWithString:path]
                              placeholderImage:nil];
        cell.page = page;
        
    }
    
    return cell;
}



-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MZKPageObject *p = [loadedPages objectAtIndex:indexPath.row];
    
    if ([p.policy isEqualToString:@"public"]) {
        currentIndex = indexPath.row;
        [self switchPage];
    }
    else
    {
        [self showErrorWithCancelActionAndTitle:@"Pozor" subtitle:@"Tato stránka není veřejně dostupná." withCompletion:nil];
    }
        
    [self onShowGrid:nil];
}
#pragma mark - recently opened documents

-(void)saveDocumentToRecentlyOpened:(MZKItemResource *)item
{
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
    [dateformat setDateFormat:@"dd.MM.yyyy"];
    item.lastOpened = [dateformat stringFromDate:[NSDate date]];
    item.indexLastOpenedPage = [NSNumber numberWithInteger:currentIndex];
    
    [appDelegate addRecentlyOpenedDocument:item];
    
}

#pragma mark - JS and HTML parameters

-(float)calculateInitialScaleForResource:(MZKPageObject *)pageObject
{
    float aspectRatio =(float)pageObject.width / (float)pageObject.height;
    float height = aspectRatio *_webView.frame.size.width;
    float finalRatio = _webView.frame.size.width/height;
    
    return finalRatio;
}

#pragma mark - segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"OpenInfoDetail"])
    {
        // Get reference to the destination view controller
        MZKDetailInformationViewController *vc = [segue destinationViewController];
        
        NSString *targetPid;
        
        if (_item) {
            targetPid = _item.pid;
            [vc setType:[_item getAuthorsStringRepresentation]];
        }
        else if (loadedItem)
        {
            targetPid = loadedItem.pid;
        }
        
        // Pass any objects to the view controller here, like...
        [vc setItem:targetPid];
        
    }
}

-(void)viewDidLayoutSubviews
{
    if (!_scrollView.hidden) {
        [self updateMinZoomScaleForSize:self.view.bounds.size];
    }
    
}

#pragma mark - UIScrollViewDelegate

-(UIImageView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageZoomView;
}

-(void)updateMinZoomScaleForSize:(CGSize)size
{
    float widthScale = size.width / _imageZoomView.bounds.size.width;
    float heightScale = size.height / _imageZoomView.bounds.size.height;
    float minScale = MIN(widthScale, heightScale);
    
    _scrollView.minimumZoomScale = minScale;
    
    _scrollView.zoomScale = minScale;

}

-(void)updateConstraintsForSize:(CGSize)size
{
    float yOffset = MAX(0, (size.height - _imageZoomView.frame.size.height) / 2);
    _imageViewTopConstraint.constant = yOffset;
    _imageViewBottomConstraint.constant = yOffset;
    
    float xOffset = MAX(0, (size.width - _imageZoomView.frame.size.width) / 2);
    _imageViewLeadingConstraint.constant = xOffset;
    _imageViewTrailingConstraint.constant = xOffset;
    
    [self.view layoutIfNeeded];
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self updateConstraintsForSize:self.view.bounds.size];
}

#pragma mark -



//private func updateConstraintsForSize(size: CGSize) {
//    
//    let yOffset = max(0, (size.height - imageView.frame.height) / 2)
//    imageViewTopConstraint.constant = yOffset
//    imageViewBottomConstraint.constant = yOffset
//    
//    let xOffset = max(0, (size.width - imageView.frame.width) / 2)
//    imageViewLeadingConstraint.constant = xOffset
//    imageViewTrailingConstraint.constant = xOffset
//    
//    view.layoutIfNeeded()
//}

@end
