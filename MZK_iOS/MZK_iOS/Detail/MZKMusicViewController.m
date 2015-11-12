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
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

static MZKMusicViewController *sharedInstance;
@interface MZKMusicViewController ()<DataLoadedDelegate, AVAudioPlayerDelegate>
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
    NSString *_currentItemPID;
    MZKItemResource *_currentItem;
    NSArray *_availableTracks;
    AVPlayer *_musicPlayer;
    
}

@end

@implementation MZKMusicViewController

+(instancetype)sharedInstance
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        sharedInstance = [storyboard instantiateViewControllerWithIdentifier:@"MZKMusicViewController"];
        
    });
    return sharedInstance;}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"Music controller:%@", [self description]);
    _timeSlider.value = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setItemPID:(NSString *)itemPid
{
    if (!_datasource) {
        _datasource = [MZKDatasource new];
        _datasource.delegate = self;
    }
    _currentItemPID = itemPid;
    [_datasource getItem:itemPid];
}

-(void)loadDetailForItem:(NSString *)itemPID
{
    if (!_datasource) {
        _datasource = [MZKDatasource new];
        _datasource.delegate = self;
    }
  
}


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
    _currentItem = item;
    
    [self updateViews];
    
    [_datasource getChildrenForItem:_currentItem.pid];
}

-(void)dataLoaded:(NSArray *)data withKey:(NSString *)key
{
    NSLog(@"Key %@", key);
    
}

-(void)childrenForItemLoaded:(NSArray *)items
{
    NSLog(@"items: %@", [items description]);
    
    _availableTracks = items;
    
    if (_availableTracks.count ==1) {
        [self playItemWithPID:((MZKPageObject *)_availableTracks.firstObject).pid];
    }
}

#pragma mark - Playback handling

//-(void)playItemWithPID:(NSString *)itemPID
//{
//
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:strURL, itemPID]];
//    
//    
//    
//    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
//    
//    NSArray *requestedKeys = @[@"playable"];
//    
//    /* Tells the asset to load the values of any of the specified keys that are not already loaded. */
//    [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:
//     ^{
//         dispatch_async( dispatch_get_main_queue(),
//                        ^{
//                            /* IMPORTANT: Must dispatch to main queue in order to operate on the AVPlayer and AVPlayerItem. */
//                           // [self prepareToPlayAsset:asset withKeys:requestedKeys];
//                        });
//     }];
//}


-(void)playItemWithPID:(NSString *)itemPID
{
    NSString *strURL = [NSString stringWithFormat:@"http://kramerius.mzk.cz/search/api/v5.0/item/%@/streams/MP3", itemPID];
    
    AVPlayer *player = [[AVPlayer alloc]initWithURL:[NSURL URLWithString:strURL]];
    _musicPlayer = player;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[_musicPlayer currentItem]];
    [_musicPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
    
    [self updateViews];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object == _musicPlayer && [keyPath isEqualToString:@"status"]) {
        if (_musicPlayer.status == AVPlayerStatusFailed) {
            NSLog(@"AVPlayer Failed");
            
        } else if (_musicPlayer.status == AVPlayerStatusReadyToPlay) {
            NSLog(@"AVPlayerStatusReadyToPlay");
            [_musicPlayer play];
             [_play setImage:[UIImage imageNamed:@"audioPause"] forState:UIControlStateNormal];
            
        } else if (_musicPlayer.status == AVPlayerItemStatusUnknown) {
            NSLog(@"AVPlayer Unknown");
            
        }
    }
}

-(void)updateProgress:(NSTimer *)timer
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_currentItem) {
            titleLabel.text = _currentItem.title;
        }
        
        _timeSlider.value += 0.1;
        
    });

    
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    
    //  code here to play next sound file
    
}



- (IBAction)onMoreInformation:(id)sender {
    //use as a list of tracks?
}
- (IBAction)onSliderValueChanged:(id)sender {
}
- (IBAction)onPlayPause:(id)sender {
    
    if (_musicPlayer.rate == 0) {
        [_musicPlayer play];
        [_play setImage:[UIImage imageNamed:@"audioPause"] forState:UIControlStateNormal];
    }
    else{
         [_play setImage:[UIImage imageNamed:@"audioPlay"] forState:UIControlStateNormal];
        [_musicPlayer pause];
        
    }
    
}
- (IBAction)onFF:(id)sender {
}
- (IBAction)onRW:(id)sender {
}
- (IBAction)onClose:(id)sender {
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)updateViews
{
    
    __weak typeof(self) wealf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_currentItem) {
            titleLabel.text = _currentItem.title;
        }
        
        float videoDurationSeconds = CMTimeGetSeconds( [self playerItemDuration]);
        if (videoDurationSeconds >0 ) {
            _timeSlider.minimumValue = 0;
            _timeSlider.maximumValue =videoDurationSeconds;
            
            NSDate* d = [[NSDate alloc] initWithTimeIntervalSinceNow:videoDurationSeconds];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"HH:mm:ss"];
            NSString* result = [dateFormatter stringFromDate:d];
            _remainningTime.text = [NSString stringWithFormat:@"-%@", result];
        }

    });
    
   
    
}



- (CMTime)playerItemDuration
{
    AVPlayerItem *playerItem = [_musicPlayer currentItem];
    if (playerItem.status == AVPlayerItemStatusReadyToPlay)
    {
        return([playerItem duration]);
    }
    
    return(kCMTimeInvalid);
}


@end
