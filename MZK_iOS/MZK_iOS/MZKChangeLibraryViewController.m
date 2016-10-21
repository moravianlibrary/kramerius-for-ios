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

@interface MZKChangeLibraryViewController ()<UITableViewDataSource, UITableViewDelegate, DataLoadedDelegate>{
    
    NSArray *_libraries;
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
    _libraries = [self createDataForLibraries];
    
   // [self downloadJsonFromServer];
   // [self loadJSONFileFromLocal];

    
    self.title = self.navigationController.tabBarItem.title;
    
    [self initGoogleAnalytics];
    
    
    // highlight default library
    NSIndexPath* selectedCellIndexPath= [self getSelectedIndexPath];
    
    [self.tableView selectRowAtIndexPath:selectedCellIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];

}

-(void)initGoogleAnalytics
{
    NSString *name = [NSString stringWithFormat:@"Pattern~%@", self.title];
    
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
    
    
    for (int i =0; i<_libraries.count; i++) {
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

-(NSArray *)createDataForLibraries
{
    MZKLibraryItem *item1 = [MZKLibraryItem new];
    item1.name = @"Moravská zemská knihovna";
    item1.protocol = @"http";
    item1.stringURL = @"kramerius.mzk.cz";
    item1.imageName = @"logo_mzk";
   
    
    MZKLibraryItem *item3 = [MZKLibraryItem new];
    item3.name = @"Jihočeská vědecká knihovna v Českých Budějovicích";
    item3.protocol = @"http";
    item3.stringURL = @"kramerius.cbvk.cz";
    item3.imageName = @"logo_cbvk";
    
    MZKLibraryItem *item4 = [MZKLibraryItem new];
    item4.name = @"Vědecká knihovna v Olomouci";
    item4.protocol = @"http";
    item4.stringURL = @"kramerius.kr-olomoucky.cz";
    item4.imageName = @"logo_vkol";
    
    MZKLibraryItem *item5 = [MZKLibraryItem new];
    item5.name = @"Studijní a vědecká knihovna v Hradci Králové";
    item5.protocol = @"http";
    item5.stringURL = @"kramerius4.svkhk.cz";
    item5.imageName = @"logo_svkhk";
    
    MZKLibraryItem *item6 = [MZKLibraryItem new];
    item6.name = @"Krajská knihovna Karlovy Vary";
    item6.protocol = @"http";
    item6.stringURL = @"k4.kr-karlovarsky.cz";
    item6.imageName = @"logo_kkkv";
    
    MZKLibraryItem *item7 = [MZKLibraryItem new];
    item7.name = @"Knihovna Akademie věd ČR";
    item7.protocol = @"http";
    item7.stringURL = @"kramerius.lib.cas.cz";
    item7.imageName = @"logo_knav";
        
    MZKLibraryItem *item8 = [MZKLibraryItem new];
    item8.name = @"Severočeská vědecká knihovna v Ústí nad Labem";
    item8.protocol = @"http";
    item8.stringURL = @"kramerius.svkul.cz";
    item8.imageName = @"logo_svkul";
   
    MZKLibraryItem *item9 = [MZKLibraryItem new];
    item9.name = @"Mendelova univerzita v Brně";
    item9.protocol = @"http";
    item9.stringURL = @"kramerius4.mendelu.cz";
    item9.imageName = @"logo_mendelu";
    
    MZKLibraryItem *item10 = [MZKLibraryItem new];
    item10.name = @"Městská knihovna Česká Třebová";
    item10.protocol = @"http";
    item10.stringURL = @"k5.digiknihovna.cz";
    item10.imageName = @"logo_mkct";
    
    MZKLibraryItem *item11 = [MZKLibraryItem new];
    item11.name = @"Městská knihovna v Praze";
    item11.protocol = @"http";
    item11.stringURL = @"kramerius4.mlp.cz";
    item11.imageName = @"logo_mlp";
    
    MZKLibraryItem *item12 = [MZKLibraryItem new];
    item12.name = @"Národní technická knihovna";
    item12.protocol = @"http";
    item12.stringURL = @"kramerius.techlib.cz";
    item12.imageName = @"logo_ntk";
    
    return [NSArray arrayWithObjects:item1, item12, item3, item4, item5, item6, item7, item8, item9, item10, item11, nil];
    
   
//    add(new Domain(false, "Krajská knihovna Karlovy Vary", "http", "k4.kr-karlovarsky.cz", R.drawable.logo_kkkv));
//    add(new Domain(false, "Knihovna Akademie věd ČR", "http", "kramerius.lib.cas.cz", R.drawable.logo_knav));
//    add(new Domain(false, "Knihovna Západočeského muzea v Plzni", "http", "kramerius.zcm.cz",
//                   R.drawable.logo_zcm));
//    add(new Domain(false, "Univerzita Karlova v Praze - Fakulta sociálních věd", "http",
//                   "kramerius.fsv.cuni.cz", R.drawable.logo_cuni_fsv));
//    add(new Domain(false, "Městská knihovna v Praze", "http", "kramerius4.mlp.cz", R.drawable.logo_mlp));
//    add(new Domain(false, "Krajská vědecká knihovna v Liberci", "http", "kramerius.kvkli.cz",
//                   R.drawable.ic_launcher));
//    
//    add(new Domain(false, "Národní knihovna", "http", "kramerius4.nkp.cz", R.drawable.logo_nkp));
//    add(new Domain(false, "Národní technická knihovna", "http", "kramerius.techlib.cz", R.drawable.logo_ntk));
//    add(new Domain(false, "Severočeská vědecká knihovna v Ústí nad Labem", "http", "kramerius4.svkul.cz",
//                   R.drawable.logo_svkul));
//    add(new Domain(false, "Středočeská vědecká knihovna v Kladně", "http", "kramerius.svkkl.cz",
//                   R.drawable.logo_svkkl));
//    add(new Domain(false, "Krajská knihovna Františka Bartoše ve Zlíně", "http", "dlib.kfbz.cz",
//                   R.drawable.logo_kfbz));
//    
//    add(new Domain(false, "Česká digitální knihovna", "http", "cdk-test.lib.cas.cz", R.drawable.logo_cdk));
//    // add(new Domain("INCAD", "Test INCAD", "http", "sluzby.incad.cz/vmkramerius", R.drawable.logo_incad));
//    add(new Domain(false, "Moravská zemská knihovna - Docker", "http", "docker.mzk.cz", R.drawable.logo_mzk));
//    add(new Domain(false, "Moravská zemská knihovna - Demo", "http", "krameriusdemo.mzk.cz",
//                   R.drawable.logo_mzk));
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MZKDataSourceTableViewCell *cell = (MZKDataSourceTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"MZKDataSourceTableViewCell"];
    
    MZKLibraryItem *tmpItem = [_libraries objectAtIndex:indexPath.row];
    
    cell.libraryName.text = tmpItem.name;
    cell.libraryURL.text = tmpItem.stringURL;
    cell.libraryIcon.image = [UIImage imageNamed:tmpItem.imageName];
    
//    NSString *hash = [tmpItem.code MD5];
//    NSMutableString *s = [tmpItem.libraryURL mutableCopy];
//    [s appendFormat:@"/assets/logo_%@-%@.png", tmpItem.code, hash];
//    
//    NSURL *finalUrl = [NSURL URLWithString:s];
//    
//    NSLog(@"final URL:%@", [finalUrl absoluteString]);
    
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
                [librariesArray addObject:item];
                NSLog(@"Library added");
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
    
    _libraries = results;
    [self.tableView reloadData];
    
}

// error states
-(void)downloadFailedWithError:(NSError *)error
{
    if([error.domain isEqualToString:NSURLErrorDomain])
    {
        // load from cache;
        // inform user that there is problem with connection
        _libraries = [self loadJSONFileFromLocal];
        [self.tableView reloadData];
    }
}



@end
