//
//  MZKDataSourceViewController.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 06/08/15.
//  Copyright (c) 2015 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKDataSourceViewController.h"
#import "MZKResourceItem.h"
#import "MZKDataSourceTableViewCell.h"
#import "MZKConstants.h"

@interface MZKDataSourceViewController (){
    
    NSArray *_libraries;
    

}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)onBack:(id)sender;

@end

@implementation MZKDataSourceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _libraries = [self createDataForLibraries];
    
   
    
    // Do any additional setup after loading the view.
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

-(NSArray *)createDataForLibraries
{
    MZKResourceItem *item1 = [MZKResourceItem new];
    item1.name = @"Moravská zemská knihovna";
    item1.protocol = @"http";
    item1.stringURL = @"kramerius.mzk.cz";
    item1.imageName = @"logo_mzk";
    
    MZKResourceItem *item2 = [MZKResourceItem new];
    item2.name = @"Národní digitální knihovna";
    item2.protocol = @"http";
    item2.stringURL = @"krameriusndktest.mzk.cz";
    item2.imageName = @"logo_ndk";
    
    
    MZKResourceItem *item3 = [MZKResourceItem new];
    item3.name = @"Jihočeská vědecká knihovna v Českých Budějovicích";
    item3.protocol = @"http";
    item3.stringURL = @"kramerius.kr-olomoucky.cz";
    item3.imageName = @"logo_cbvk";
    
    MZKResourceItem *item4 = [MZKResourceItem new];
    item4.name = @"Vědecká knihovna v Olomouci";
    item4.protocol = @"http";
    item4.stringURL = @"kramerius.mzk.cz";
    item4.imageName = @"logo_vkol";
    
    MZKResourceItem *item5 = [MZKResourceItem new];
    item5.name = @"Studijní a vědecká knihovna v Hradci Králové";
    item5.protocol = @"http";
    item5.stringURL = @"kramerius4.svkhk.cz";
    item5.imageName = @"logo_svkhk";
    
    MZKResourceItem *item6 = [MZKResourceItem new];
    item6.name = @"Krajská knihovna Karlovy Vary";
    item6.protocol = @"http";
    item6.stringURL = @"k4.kr-karlovarsky.cz";
    item6.imageName = @"logo_kkkv";
    
    MZKResourceItem *item7 = [MZKResourceItem new];
    item1.name = @"Knihovna Akademie věd ČR";
    item1.protocol = @"http";
    item1.stringURL = @"kramerius.lib.cas.cz";
    item1.imageName = @"logo_knav";
    
    return [NSArray arrayWithObjects:item1, item2, item3, item4, item5, item6, item7, nil];
    
   
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
    
    MZKResourceItem *tmpItem = [_libraries objectAtIndex:indexPath.row];
    
    cell.libraryName.text = tmpItem.name;
    cell.libraryURL.text = tmpItem.stringURL;
    cell.libraryIcon.image = [UIImage imageNamed:tmpItem.imageName];
    
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
    
    MZKResourceItem *item = [_libraries objectAtIndex:indexPath.row];
    [self saveToUserDefaults:item];
    
    [self onBack:nil];
}

-(void)saveToUserDefaults:(MZKResourceItem *)item
{
    [[NSUserDefaults standardUserDefaults] setObject:item.name forKey:kDefaultDatasourceName];
    [[NSUserDefaults standardUserDefaults] setObject:item.stringURL forKey:kDefaultDatasourceStringURL];
    [[NSUserDefaults standardUserDefaults] setObject:item.imageName forKey:kDefaultImageName];
    [[NSUserDefaults standardUserDefaults] setObject:item.protocol forKey:kDefaultDatasourceProtocol];

}


- (IBAction)onBack:(id)sender {
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}
@end
