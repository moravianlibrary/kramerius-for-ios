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

NSString * const MZKMenuCellIdentifier = @"MZKMenuCell";
@interface MZKMenuViewController ()<MenuClickableHeaderDelegate>
{
    MZKMenuClickableHeader *headerView;
}

// menu properties
@property (nonatomic, strong) NSDictionary *paneViewControllerIdentifiers;
@property (nonatomic, strong) NSDictionary *paneViewControllerTitles;
@property (nonatomic, strong) NSDictionary *paneViewControllersIcons;

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
#pragma mark - menu view controller methods

-(void)initializeMenuHeader
{
    // Load menu header
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"MZKMenuClickableHeader" owner:nil options:nil];
    
    // Find the view among nib contents (not too hard assuming there is only one view in it).
    headerView = [nibContents lastObject];
    headerView.translatesAutoresizingMaskIntoConstraints = YES;
    headerView.frame = CGRectMake(0, 0, self.tableView.bounds.size.width, 100);
    headerView.delegate = self;
    self.tableView.tableHeaderView = headerView;
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
     headerView.frame = CGRectMake(0, 0, self.tableView.bounds.size.width, 100);
    
}

-(void)initializeMenu
{
    self.paneViewControllerType = NSUIntegerMax;
    self.paneViewControllerTitles = @{
                                      @(MZKMainViewController) : @"Hlavní strana",
                                      @(MZKCollectionsViewController) : @"Kolekce",
                                      @(MSPaneViewControllerTypeBounce) : @"Hledání",
                                      @(MSPaneViewControllerTypeGestures) : @"Nejnovější"
                                      };
    
    self.paneViewControllerIdentifiers = @{
                                           @(MZKMainViewController) : @"MainViewController",
                                           @(MZKCollectionsViewController) : @"Collections",
                                           @(MSPaneViewControllerTypeBounce) : @"Bounce",
                                           @(MSPaneViewControllerTypeGestures) : @"Gestures"
                                           };
    
    self.paneViewControllersIcons = @{
                                      @(MZKMainViewController) : @"ic_home_grey",
                                      @(MZKCollectionsViewController) : @"ic_group_grey",
                                      @(MSPaneViewControllerTypeBounce) : @"ic_search_grey",
                                      @(MSPaneViewControllerTypeGestures) : @"ic_recent_grey"
                                      };


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
    
    
    self.paneRevealLeftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(dynamicsDrawerRevealLeftBarButtonItemTapped:)];
   
    paneViewController.navigationItem.leftBarButtonItem = self.paneRevealLeftBarButtonItem;
    
    
    UINavigationController *paneNavigationViewController = [[UINavigationController alloc] initWithRootViewController:paneViewController];
    [self.dynamicsDrawerViewController setPaneViewController:paneNavigationViewController animated:animateTransition completion:nil];
    
    self.paneViewControllerType = paneViewControllerType;
}


-(void)onMenuHeader
{
    NSLog(@"Menu header touched");
    MZKDataSourceViewController *dsVc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MZKDataSourceViewController"];
    [self presentViewController:dsVc animated:YES completion:^{
        
    }];
    
}


#pragma mark - orientation changes
- (NSUInteger)supportedInterfaceOrientations
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
    return 6; //array count
}

/*
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //UITableViewHeaderFooterView *headerView = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:MSDrawerHeaderReuseIdentifier];
   // headerView.textLabel.text = [self.sectionTitles[@(section)] uppercaseString];
    return headerView;
}
 


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return FLT_EPSILON;
}
 
  */

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
    [self transitionToViewController:paneViewControllerType];
    
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
    
    //
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end
