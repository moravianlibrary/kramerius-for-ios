//
//  MZKDetailInformationViewController.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 04/01/16.
//  Copyright © 2016 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKDetailInformationViewController.h"
#import "MZKConstants.h"
#import "MZKDetailInformationDataSource.h"
#import "MZKDetailInformationTableViewCell.h"
#import "MZKDetailInformationStringModel.h"

@interface MZKDetailInformationViewController ()<DetailInformationDelegate, UITableViewDataSource, UITableViewDelegate>
{
    MZKDetailInformationDataSource *_datasource;
    MZKDetailInformationModel *_loadedInfo;
    NSArray *_detailInformation;
    
}
@property (weak, nonatomic) IBOutlet UILabel *itemTitle;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIStackView *verticalStackView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UIView *verticalStackViewContainer;
@property (strong, nonatomic) NSMutableArray *generatedViews;
@end

@implementation MZKDetailInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _detailInformation = [NSMutableArray new];
    // Do any additional setup after loading the view.
    if (_item) {
        
        if (_rootPID) {
             [self loadDataForItem:_rootPID];
        }
        else
        {
             [self loadDataForItem:_item];
        }
    }
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
  //  NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[left]-[right]-|" options:nil metrics:nil views:(nonnull NSDictionary<NSString *,id> *)
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setItem:(NSString *)item
{
    _item = item;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)loadDataForItem:(NSString *)pid
{
    [self setupDatasource];
    
    [_datasource getDetailInformationAboutDocument:pid];
    
}

-(void)setupDatasource
{
    if (!_datasource) {
        _datasource = [MZKDetailInformationDataSource new];
        _datasource.delegate = self;
    }
}

#pragma mark - UITableViewDatasource and Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (MZKDetailInformationTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MZKDetailInformationTableViewCell *cell = (MZKDetailInformationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"MZKDetailInformationTableViewCell"];
    
    MZKDetailInformationStringModel *modelInfo =[_detailInformation objectAtIndex:indexPath.row];
    cell.layoutMargins = UIEdgeInsetsZero;
    
    if (modelInfo.title && modelInfo.info) {
        [self setupCell:cell withTitle:modelInfo.title andInfo:modelInfo.info];
    }else if (modelInfo.title && !modelInfo.info)
    {
        [self setupCell:cell withTitle:modelInfo.title];
    }else if (!modelInfo.title && modelInfo.info)
    {
        [self setupCell:cell withInfo:modelInfo.info];
    }
    return cell;
}

-(void)setupCell:(MZKDetailInformationTableViewCell *)cell withTitle:(NSString *)title
{
    NSLog(@"Title");
    cell.titleInfoLabel.textColor = [UIColor blackColor];
    cell.titleInfoLabel.text = title;
    cell.contentInfoLabel.text = @"";
    
}

-(void)setupCell:(MZKDetailInformationTableViewCell *)cell withInfo:(NSString *)info
{
    NSLog(@"Info");
    cell.contentInfoLabel.text = info;
    cell.contentInfoLabel.textColor = [UIColor lightGrayColor];
    cell.titleInfoLabel.text = @"";
}

-(void)setupCell:(MZKDetailInformationTableViewCell *)cell withTitle:(NSString *)title andInfo:(NSString *)info
{
    NSLog(@"Title and Info");
    cell.contentInfoLabel.textColor = [UIColor lightGrayColor];
    cell.titleInfoLabel.textColor = [UIColor lightGrayColor];
    cell.titleInfoLabel.text = title;
    cell.contentInfoLabel.text = info;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _detailInformation.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


#pragma mark - Detail info delegate

-(void)detailInformationLoaded:(MZKDetailInformationModel *)info
{
    
    __weak typeof(self) welf = self;
    if(![[NSThread currentThread] isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf detailInformationLoaded:info];
        });
        return;
    }
    
    
    // information loaded
    _loadedInfo = info;
    
    _detailInformation = [self getStringRepresentationOfAvailableInformation:_loadedInfo];
    
    self.itemTitle.text = _loadedInfo.title;
    
    [_tableView reloadData];

}

-(void)downloadFailed
{
    __weak typeof(self) welf = self;
    if(![[NSThread currentThread] isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf downloadFailed];
        });
        return;
    }
    // nahradit lepsim errorem
   // [self showErrorWithCancelActionAndTitle:@"Problém v aplikaci" subtitle:@"Akci se nepodařilo dokončit."];
    
}


- (IBAction)onClose:(id)sender {
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(NSArray *)getStringRepresentationOfAvailableInformation:(MZKDetailInformationModel *)info
{
    NSMutableArray *infoArray = [NSMutableArray new];
    
    // title info
    
    if (_type) {
        MZKDetailInformationStringModel *model = [MZKDetailInformationStringModel new];
        [model setTitle:@"Typ:"];
        [model setInfo:_type];
        [infoArray addObject:model];
        

    }
    
    if (info.title) {
        
        MZKDetailInformationStringModel *modelTitle = [MZKDetailInformationStringModel new];
        [modelTitle setTitle:@"Hlavní název:"];
        [modelTitle setInfo: info.title];
        [infoArray addObject:modelTitle];
        
        if (info.subTitle) {
            MZKDetailInformationStringModel *modelTitle = [MZKDetailInformationStringModel new];
            [modelTitle setTitle:@"Podnázev:"];
            [modelTitle setInfo: info.subTitle];
            [infoArray addObject:modelTitle];
        }
    }

    //Authors
    if (info.authorsInfo.namesOfAllAuthors) {
        
        if (info.authorsInfo.namesOfAllAuthors.count > 1) {
            MZKDetailInformationStringModel *model = [MZKDetailInformationStringModel new];
            [model setTitle:@"Autoři"];
            [infoArray addObject:model];
        }else{
            MZKDetailInformationStringModel *model = [MZKDetailInformationStringModel new];
            [model setTitle:@"Autor"];
            [infoArray addObject:model];
             }
        
        for (NSString *name in info.authorsInfo.namesOfAllAuthors) {
            
            MZKDetailInformationStringModel *model = [MZKDetailInformationStringModel new];
            [model setInfo:name];
            
            [infoArray addObject:model];
        }
    }
    
    //information about location
    
    if (info.physicalLocation) {
        
        MZKDetailInformationStringModel *model = [MZKDetailInformationStringModel new];
        [model setTitle:@"Místo uložení"];
        [infoArray addObject:model];
        
    //    MZKDetailInformationStringModel *strModel = [MZKDetailInformationStringModel new];
      //  strModel.title = @"Místo uložení:";
        
        for (NSString *text in info.physicalLocation) {
             MZKDetailInformationStringModel *strModel = [MZKDetailInformationStringModel new];
            [strModel setInfo:text];
            [infoArray addObject:strModel];
        }
        
        //[strModel setInfo:info.physicalLocation];
        
        //[infoArray addObject:strModel];
        
        if (info.shelfLocation) {
             MZKDetailInformationStringModel *model = [MZKDetailInformationStringModel new];
            model.title = @"Signatura:";
            model.info = info.shelfLocation;
            [infoArray addObject:model];
        }
        
    }
    // language info
    
    if (info.languageNme) {
        MZKDetailInformationStringModel *model = [MZKDetailInformationStringModel new];
        model.title = @"Jazyk:";
        model.info = info.languageNme;
        [infoArray addObject:model];

    }
    
    
    if (info.identifiersInfo) {
        
      //  MZKDetailInformationStringModel *model = [MZKDetailInformationStringModel new];
        
        if (info.identifiersInfo.isbn) {
            
        }
        if (info.identifiersInfo.sysno) {
            
        }
        if (info.identifiersInfo.isbn) {
            
        }
        if (info.identifiersInfo.isbn) {
            
        }
        if (info.identifiersInfo.isbn) {
            
        }
        if (info.identifiersInfo.isbn) {
            
        }
        
    }
    
    return [infoArray copy];
    
}

@end
