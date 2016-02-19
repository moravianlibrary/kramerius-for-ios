//
//  MZKMenuViewController.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 04/05/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKMenuViewController.h"
#import "MZKMenuClickableHeader.h"
#import "MZKDataSourceViewController.h"
#import "MZKConstants.h"
#import "AppDelegate.h"
#import "MZKAboutViewController.h"

NSString *const MZKMenuCellIdentifier = @"MZKMenuCell";
NSString *const kMZKMusicViewController = @"MZKMusicViewController";
NSInteger const MZKMenuWidth = 270;
@interface MZKMenuViewController ()<MenuClickableHeaderDelegate>
{
    MZKMenuClickableHeader *headerView;
}

// menu properties
@property (nonatomic, strong) NSMutableDictionary *paneViewControllerIdentifiers;
@property (nonatomic, strong) NSMutableDictionary *paneViewControllerTitles;
@property (nonatomic, strong) NSMutableDictionary *paneViewControllersIcons;

@property (nonatomic, strong) UIBarButtonItem *paneStateBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *paneRevealLeftBarButtonItem;

@end

@implementation MZKMenuViewController
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeMenu];
    }
    return self;
}

#pragma mark - UIViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initializeMenu];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //setu table view for
    //[self initializeMenu];
   // [self.tableView registerClass:[MZKMenuTableViewCell class] forCellReuseIdentifier:MZKMenuCellIdentifier];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultDatasourceChangedNotification:) name:kDatasourceItemChanged object:nil];
    [self initializeMenuHeader];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStarted:) name:@"playbackStarted" object:nil];
    
     self.dynamicsDrawerViewController.shouldAlignStatusBarToPaneView = NO;
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
#pragma mark - playback started notification
-(void)playbackStarted:(NSNotification *)notf
{
    if (![self playerVisibleInMenu]) {
        [self addPlayerToMenu];
    }
}

-(BOOL)playerVisibleInMenu
{
    if ([[_paneViewControllerIdentifiers allKeys] containsObject:@(MZKMusicVC)]) {
        return YES;
    }
    
    return NO;
}

-(void)addPlayerToMenu
{
    [_paneViewControllerTitles addEntriesFromDictionary:@{ @(MZKMusicVC) : @"Přehrávač"}];
    [_paneViewControllerIdentifiers addEntriesFromDictionary:@{@(MZKMusicVC) : @"MZKMusicViewController"}];
    [_paneViewControllersIcons addEntriesFromDictionary:@{@(MZKMusicVC): @"audioPlay"}];
    
    [self.tableView reloadData];
}

#pragma mark - menu view controller methods

-(void)initializeMenuHeader
{
    // Load menu header
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"MZKMenuClickableHeader" owner:nil options:nil];
    
    // Find the view among nib contents (not too hard assuming there is only one view in it).
    headerView = [nibContents lastObject];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    headerView.translatesAutoresizingMaskIntoConstraints = YES;
    headerView.frame = CGRectMake(0, 0, MZKMenuWidth, 100);
    
    headerView.delegate = self;
    self.tableView.tableHeaderView = headerView;
    
    
    [self defaultDatasourceChangedNotification:nil];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    headerView.frame = CGRectMake(0, 0, MZKMenuWidth, 100);
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, MZKMenuWidth, self.view.frame.size.height);
}

-(void)initializeMenu
{
    self.paneViewControllerType = NSUIntegerMax;
    self.paneViewControllerTitles = [NSMutableDictionary new];
    [_paneViewControllerTitles addEntriesFromDictionary:@{
                                      @(MZKMainViewController) : @"Hlavní strana",
                                      @(MZKCollectionsViewController) : @"Kolekce" }];
    
    self.paneViewControllerIdentifiers =[NSMutableDictionary new];
    [_paneViewControllerIdentifiers addEntriesFromDictionary:@{
                                           @(MZKMainViewController) : @"MainViewController",
                                           @(MZKCollectionsViewController) : @"Collections" }];
    
    self.paneViewControllersIcons = [NSMutableDictionary new];
    [_paneViewControllersIcons addEntriesFromDictionary:@{
                                      @(MZKMainViewController) : @"ic_home_grey",
                                      @(MZKCollectionsViewController) : @"ic_group_grey" }];

    self.musicController = [MZKMusicViewController sharedInstance];
    
   
}

- (MSPaneViewControllerType)paneViewControllerTypeForIndexPath:(NSIndexPath *)indexPath
{
    MSPaneViewControllerType paneViewControllerType;
    paneViewControllerType = indexPath.row;
   
    NSAssert(paneViewControllerType < MSPaneViewControllerTypeCount, @"Invalid Index Path");
    return paneViewControllerType;
}

- (void)transitionToViewController:(MSPaneViewControllerType)paneViewControllerType
{
    // Close pane if already displaying the pane view controller
    if (paneViewControllerType == self.paneViewControllerType) {
        [self.dynamicsDrawerViewController setPaneState:MSDynamicsDrawerPaneStateClosed animated:YES allowUserInterruption:YES completion:nil];
        return;
    }
    
    BOOL animateTransition = self.dynamicsDrawerViewController.paneViewController != nil;
    
    UIViewController *paneViewController = [self.storyboard instantiateViewControllerWithIdentifier:self.paneViewControllerIdentifiers[@(paneViewControllerType)]];

    
    paneViewController.navigationItem.title = self.paneViewControllerTitles[@(paneViewControllerType)];
    
    self.paneRevealLeftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStylePlain target:self action:@selector(dynamicsDrawerRevealLeftBarButtonItemTapped:)];
    
    paneViewController.navigationItem.leftBarButtonItem = self.paneRevealLeftBarButtonItem;
    
    UINavigationController *paneNavigationViewController = [[UINavigationController alloc] initWithRootViewController:paneViewController];
    [self.dynamicsDrawerViewController setPaneViewController:paneNavigationViewController animated:animateTransition completion:nil];
    
    self.paneViewControllerType = paneViewControllerType;
}


-(void)onMenuHeader
{
    MZKDataSourceViewController *dsVc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MZKDataSourceViewController"];
    
    __weak typeof(self) wealf;
    [self presentViewController:dsVc animated:YES completion:^{
        [wealf.dynamicsDrawerViewController setPaneState:MSDynamicsDrawerPaneStateClosed];
    }];
}

#pragma mark - orientation changes
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _paneViewControllerTitles.count; //array count
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MZKMenuTableViewCell *cell = (MZKMenuTableViewCell*)[tableView dequeueReusableCellWithIdentifier:MZKMenuCellIdentifier];
    cell.menuItemTitle.text = self.paneViewControllerTitles[@([self paneViewControllerTypeForIndexPath:indexPath])];
    cell.menuItemIcon.image = [UIImage imageNamed:self.paneViewControllersIcons[@([self paneViewControllerTypeForIndexPath:indexPath])]];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSPaneViewControllerType paneViewControllerType = [self paneViewControllerTypeForIndexPath:indexPath];
    if(paneViewControllerType == MZKMusicVC)
    {
        if (!self.musicController) {
            self.musicController =[self.storyboard instantiateViewControllerWithIdentifier:kMZKMusicViewController];
        }
       
        [self presentViewController:self.musicController animated:YES completion:^{
             [self.dynamicsDrawerViewController setPaneState:MSDynamicsDrawerPaneStateClosed animated:NO allowUserInterruption:NO completion:nil];
            
        }];
    }
    else
    {
        [self transitionToViewController:paneViewControllerType];
    }
    
    // Prevent visual display bug with cell dividers
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.tableView reloadData];
    });
}

#pragma mark - menu handling

- (void)dynamicsDrawerRevealLeftBarButtonItemTapped:(id)sender
{
    [self.dynamicsDrawerViewController setPaneState:MSDynamicsDrawerPaneStateOpen inDirection:MSDynamicsDrawerDirectionLeft animated:YES allowUserInterruption:YES completion:nil];
}

#pragma mark - notification handling
-(void)defaultDatasourceChangedNotification:(NSNotification *)notf
{
    //change heade of table view...

    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    MZKResourceItem *item = appDelegate.getDatasourceItem;
    
    headerView.libraryName.text = item.name;
    headerView.libraryIcon.image = [UIImage imageNamed:item.imageName];
    headerView.libraryInfo.text = item.stringURL;
}
- (IBAction)onFeedback:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];

    MZKAboutViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MZKAboutViewController"];
    
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end
