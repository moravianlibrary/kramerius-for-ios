//
//  MZKMusicViewController.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 10/11/15.
//  Copyright © 2015 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKMusicViewController.h"
#import "MZKDatasource.h"
#import "MZKPageObject.h"

@interface MZKMusicViewController ()<DataLoadedDelegate>
{

    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UIImageView *_blurryImage;
    __weak IBOutlet UIImageView *_artWork;
    __weak IBOutlet UIView *_controlPanel;
    __weak IBOutlet UILabel *_elapsedTime;
    __weak IBOutlet UILabel *_remainningTime;
    __weak IBOutlet UILabel *_currentlyPlayed;
    __weak IBOutlet UIButton *_play;
    __weak IBOutlet UIButton *_ff;
    __weak IBOutlet UIButton *_rw;
    __weak IBOutlet UISlider *_timeSlider;
    
    MZKDatasource *_datasource;
}
@end

@implementation MZKMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
-(void)setItem:(MZKItemResource *)item
{
    _item = item;
    [self loadDataForItem:_item];
}

-(void)loadDataForItem:(MZKItemResource *)item
{
    if (!_datasource) {
        _datasource = [MZKDatasource new];
        _datasource.delegate = self;
    }
    [_datasource getChildrenForItem:item.pid];
    
    titleLabel.text = item.title;
}

-(void)detailForItemLoaded:(MZKItemResource *)item
{
    NSLog(@"Detail");
}
-(void)dataLoaded:(NSArray *)data withKey:(NSString *)key
{
    NSLog(@"Key %@", key);
    
}

-(void)pagesLoadedForItem:(NSArray *)pages
{
    NSLog(@"Pages");
    MZKPageObject *obj = [pages objectAtIndex:0];
    [_datasource getChildrenForItem:obj.pid];
}
- (IBAction)onMoreInformation:(id)sender {
    //use as a list of tracks?
}
- (IBAction)onSliderValueChanged:(id)sender {
}
- (IBAction)onPlayPause:(id)sender {
}
- (IBAction)onFF:(id)sender {
}
- (IBAction)onRW:(id)sender {
}


@end
