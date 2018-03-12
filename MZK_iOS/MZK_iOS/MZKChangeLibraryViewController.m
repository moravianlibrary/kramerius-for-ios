//
//  MZKDataSourceViewController.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 06/08/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKChangeLibraryViewController.h"
#import "MZKLibraryItem.h"
#import "MZKDataSourceTableViewCell.h"
#import "MZKConstants.h"
#import "AppDelegate.h"
#import <Google/Analytics.h>
#import "MZKDatasource.h"
#import "NSString+MD5.h"
@import SDWebImage;

@interface MZKChangeLibraryViewController ()<UITableViewDataSource, UITableViewDelegate, DataLoadedDelegate>{
    MZKLibraryItem *_selectedLibrary;
    MZKDatasource *_datasource;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MZKChangeLibraryViewController

- (id)initWithCoder:(NSCoder *)decoder {
    
    self = [super initWithCoder:decoder];
    if (self) {
        self.navigationController.tabBarItem.title = NSLocalizedString(@"mzk.chooseLibrary", @"choose library title");
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!_libraries) {
        [self downloadJsonFromServer];
      //   _libraries = [self createDataForLibraries];
    }
    
    self.title = self.navigationController.tabBarItem.title;
    
    [self initGoogleAnalytics];
    
    // highlight default library
    NSIndexPath* selectedCellIndexPath= [self getSelectedIndexPath];
    
    [self.tableView selectRowAtIndexPath:selectedCellIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];

}

-(void)viewWillAppear:(BOOL)animated
{
    
}

-(void)initGoogleAnalytics
{
    NSString *name = @"ChangeLibrary";
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSIndexPath *)getSelectedIndexPath
{
    NSUInteger index;
    if (!_selectedLibrary) {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        _selectedLibrary = appDelegate.defaultDatasourceItem;
    }
    
    
    for (int i =0; i <_libraries.count; i++) {
        if ([((MZKLibraryItem *)_libraries[i]).name caseInsensitiveCompare:_selectedLibrary.name] == NSOrderedSame) {
            index = i;
            break;
        }
    }
    
    if (index != NSNotFound) {
         return [NSIndexPath indexPathForRow:index inSection:0];
    }else{
      return [NSIndexPath indexPathForRow:0 inSection:0];
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

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MZKDataSourceTableViewCell *cell = (MZKDataSourceTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"MZKDataSourceTableViewCell"];
    
    MZKLibraryItem *tmpItem = [_libraries objectAtIndex:indexPath.row];
    
    
    NSString *libName;
    
    NSArray *supportedLanguages = [NSLocale preferredLanguages];
    if(supportedLanguages.count >0)
    {
        NSString *selectedLang = supportedLanguages[0];
        if ([selectedLang containsString:@"cs"]) {
            libName = [tmpItem name];
        }
        else
        {
            libName = [tmpItem nameEN];
        }
    }

    cell.libraryName.text = libName;
    cell.libraryURL.text = tmpItem.url;
    
    [cell.libraryIcon sd_setImageWithURL:[NSURL URLWithString:tmpItem.logoURL]
                      placeholderImage:nil];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_libraries) {
        return _libraries.count;
    }
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //set the default datasource...
    
    MZKLibraryItem *item = [_libraries objectAtIndex:indexPath.row];
    [self saveToUserDefaults:item];
}

-(void)saveToUserDefaults:(MZKLibraryItem *)item
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [appDelegate saveToUserDefaults:item];
    _selectedLibrary = item;
}

-(NSArray *)loadJSONFileFromLocal
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"libraries" ofType:@"json"];
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    NSError* error = nil;
    NSArray *result = [NSJSONSerialization JSONObjectWithData:data
                                                options:kNilOptions error:&error];
    
    NSMutableArray *librariesArray = [NSMutableArray new];
    if (!error && result) {
        for (NSDictionary *lib in result) {
            if ([[lib objectForKey:@"ios"] integerValue] >=2) {
                MZKLibraryItem *item = [MZKLibraryItem new];
                item.libID = [[lib objectForKey:@"id"] integerValue];
                item.name = [lib objectForKey:@"name"];
                item.code = [lib objectForKey:@"code"];
                item.version = [lib objectForKey:@"version"];
                item.libraryURL = [lib objectForKey:@"library_url"];
                item.logoURL = [lib objectForKey:@"logo"];
                [librariesArray addObject:item];
            }
        }

    }
    
    return [librariesArray copy];
}

-(void)downloadJsonFromServer
{
    // download json from server
    // save json
    
    _datasource = [MZKDatasource new];
    _datasource.delegate = self;
    [_datasource getLibraries];
 
}

#pragma mark - data loaded delegate methods
-(void)librariesLoaded:(NSArray *)results
{
     [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
    _libraries = results;
    [self.tableView reloadData];
}

// error states
-(void)downloadFailedWithError:(NSError *)error
{
    __weak typeof(self) welf = self;

    if(![[NSThread currentThread] isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf downloadFailedWithError:error];
        });
        return;
    } else {
        if([error.domain isEqualToString:NSURLErrorDomain])
        {
            // load from cache;
            // inform user that there is problem with connection
            _libraries = [self loadJSONFileFromLocal];
            [self.tableView reloadData];
        }
    }
}
    
@end
