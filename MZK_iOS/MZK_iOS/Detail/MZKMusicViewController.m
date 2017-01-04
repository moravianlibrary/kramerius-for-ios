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
#import <AVKit/AVKit.h>
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "MZKDetailInformationViewController.h"
#import <Google/Analytics.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "MZKConstants.h"
#import "AFNetworking.h"
static void *AVPlayerDemoPlaybackViewControllerRateObservationContext = &AVPlayerDemoPlaybackViewControllerRateObservationContext;
static void *AVPlayerDemoPlaybackViewControllerStatusObservationContext = &AVPlayerDemoPlaybackViewControllerStatusObservationContext;
static void *AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext = &AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext;
static MZKMusicViewController *sharedInstance;
@interface MZKMusicViewController ()<DataLoadedDelegate, AVAudioPlayerDelegate, AVAudioSessionDelegate>
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
    __weak IBOutlet UIView *loadingContainerVIew;
    __weak IBOutlet UIActivityIndicatorView *activityIndicator;
    __weak IBOutlet UILabel *musicTitleLabel;
    
    __weak IBOutlet UIVisualEffectView *visualBlurEffectView;
    MZKDatasource *_datasource;
    NSString *_currentItemPID;
    MZKItemResource *_currentItem;
    NSArray *_availableTracks;
    
    id mTimeObserver;
    float mRestoreAfterScrubbingRate;
    BOOL seekToZeroBeforePlay;
    BOOL isSeeking;
    BOOL isFinished;
    NSTimer *tickTimer;
    
    AVPlayer *_player;
    AVPlayerItem *_playerItem;
    
}
@end

@implementation MZKMusicViewController

+(instancetype)sharedInstance
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        sharedInstance = [storyboard instantiateViewControllerWithIdentifier:@"MZKMusicViewController"];
        
        [sharedInstance view];
        
    });
    return sharedInstance;
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    self = [super initWithCoder:decoder];
    if (self) {
        self.navigationController.tabBarItem.title = NSLocalizedString(@"mzk.musicPlayer", @"Player title");
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self prepareSlider];
    _timeSlider.value = 0;
    if (_currentItemPID) {
        [self loadFullImageForItem:_currentItemPID];
        [self loadThumbnailImageForItem:_currentItemPID];
    }
    [self initGoogleAnalytics];
    isFinished = NO;
    
    // NOTIFICATIONS
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(routeChange:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDatasourceChanged:) name:kDatasourceItemChanged object:nil];
    
    NSError *myErr;
    // Initialize the AVAudioSession here.
    if (![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&myErr]) {
        // Handle the error here.
        NSLog(@"Audio Session error %@, %@", myErr, [myErr userInfo]);
    }
    else{
        // Since there were no errors initializing the session, we'll allow begin receiving remote control events
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    }
    self.title =  self.navigationController.tabBarItem.title;
    
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    
}

-(void)initGoogleAnalytics
{
    NSString *name = [NSString stringWithFormat:@"Pattern~%@", @"MZKMusicViewController"];
    
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

-(void)setItemPID:(NSString *)itemPid
{
    if (!_datasource) {
        _datasource = [MZKDatasource new];
        _datasource.delegate = self;
    }
    _currentItemPID = itemPid;
    [_datasource getItem:itemPid];
    
    [self startAnimating];
    
}

-(void)loadDataForController
{
    if (!_datasource) {
        _datasource = [MZKDatasource new];
        _datasource.delegate = self;
    }
    
    if (_currentItem) {
        [_datasource getChildrenForItem:_currentItem.pid];
    }
    else if (_currentItemPID)
    {
        [_datasource getItem:_currentItemPID];
    }
    
    
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
    
    if ([error.domain isEqualToString:NSURLErrorDomain]) {
        //NSError Domain Code
        [self showTsErrorWithNSError:error andConfirmAction:^{
            [welf loadDataForController];
        }];
    }
    else
    {
        
        [self showErrorWithTitle:@"Problém při stahování" subtitle:@"Přejete si opakovat akci?" confirmAction:^{
            [welf loadDataForController];
            
        }];
    }
}


-(void)setItem:(MZKItemResource *)item
{
    __weak typeof(self) welf = self;
    if(![[NSThread currentThread] isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf setItem:item];
        });
        return;
    }
    
    _item = item;
    [self loadDataForItem:_item];
}

-(void)startAnimating
{
    __weak typeof(self) welf = self;
    if(![[NSThread currentThread] isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf startAnimating];
        });
        return;
    }
    
    loadingContainerVIew.hidden =NO;
    [activityIndicator startAnimating];
}

-(void)stopAnimating
{
    __weak typeof(self) welf = self;
    if(![[NSThread currentThread] isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf stopAnimating];
        });
        return;
    }
    
    loadingContainerVIew.hidden =YES;
    [activityIndicator stopAnimating];
}

-(void)loadDataForItem:(MZKItemResource *)item
{
    if (!_datasource) {
        _datasource = [MZKDatasource new];
        _datasource.delegate = self;
    }
    
    _currentItem = item;
    
    [_datasource getChildrenForItem:item.pid];
}

-(void)detailForItemLoaded:(MZKItemResource *)item
{
    __weak typeof(self) welf = self;
    if(![[NSThread currentThread] isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf detailForItemLoaded:item];
        });
        return;
    }
    
    _currentItem = item;
    musicTitleLabel.text = item.title;
    
    [_datasource getChildrenForItem:_currentItem.pid];
}

-(void)dataLoaded:(NSArray *)data withKey:(NSString *)key
{
    
}

-(void)childrenForItemLoaded:(NSArray *)items
{
    __weak typeof(self) welf = self;
    if(![[NSThread currentThread] isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf childrenForItemLoaded:items];
        });
        return;
    }
    _availableTracks = items;
    
    _timeSlider.value = 0;
    if (_currentItemPID) {
        [self loadFullImageForItem:_currentItemPID];
        [self loadThumbnailImageForItem:_currentItemPID];
    }
    
    if (_availableTracks.count ==1) {
        
        [self playWithAVPlayer:((MZKPageObject *)_availableTracks.firstObject).pid];
    }
}

-(void)playWithAVPlayer:(NSString *)pid
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString*path = [NSString stringWithFormat:@"%@/search/api/v5.0/item/%@/streams/MP3",delegate.defaultDatasourceItem.url, pid];
    
    if (_player) {
        // stop playback
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:[_player currentItem]];
        
        [_player removeObserver:self forKeyPath:@"status"];
        
        _player = nil;
        _playerItem = nil;
        [self prepareSlider];
    }
    
    AVPlayer *player = [[AVPlayer alloc]initWithURL:[NSURL URLWithString:path]];
    _player = player;
    _playerItem = _player.currentItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[_player currentItem]];
    
    [_player addObserver:self forKeyPath:@"status" options:0 context:nil];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object == _player && [keyPath isEqualToString:@"status"]) {
        if (_player.status == AVPlayerStatusFailed) {
            NSLog(@"AVPlayer Failed");
            
        } else if (_player.status == AVPlayerStatusReadyToPlay) {
            NSLog(@"AVPlayerStatusReadyToPlay");
            // perform selector on main thread
            
            [self performSelectorOnMainThread:@selector(stopAnimating) withObject:self waitUntilDone:NO];
            [self performSelectorOnMainThread:@selector(playAfterLoad) withObject:self waitUntilDone:NO];
            [self performSelectorOnMainThread:@selector(setCurrentTrackToInfoCenter) withObject:self waitUntilDone:NO];
            
            // time slider init?
            
        } else if (_player.status == AVPlayerItemStatusUnknown) {
            NSLog(@"AVPlayer Unknown");
            
        }
    }
}

-(void)playAfterLoad
{
    isSeeking = NO;
    
    [self prepareSlider];
    
    [_player play];
    
    if ([self playerPlaying]) {
        
        
        if (_timeSlider.value > 0) {
            //scrubbed before play
            [_player seekToTime:CMTimeMakeWithSeconds(_timeSlider.value, NSEC_PER_SEC)];
        }
        
        
        [_play setImage:[UIImage imageNamed:@"audioPause"] forState:UIControlStateNormal];
    }
    else{
        [_play setImage:[UIImage imageNamed:@"audioPlay"] forState:UIControlStateNormal];
        
        
    }
    
    
    [self scheduleTimer];
    
}

-(void)setCurrentTrackToInfoCenter
{
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    if (playingInfoCenter) {
        
        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        NSString*path = [NSString stringWithFormat:@"%@/search/api/v5.0/item/%@/full",delegate.defaultDatasourceItem.url, _currentItem.pid ];
        
        
        [_artWork sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage:_artWork.image];
            
            
            [songInfo setObject:_currentItem.title forKey:MPMediaItemPropertyTitle];
            [songInfo setObject:[NSNumber numberWithFloat:[self playbackDuration]] forKey:MPMediaItemPropertyPlaybackDuration];
            [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
        }];
    }
    
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker|AVAudioSessionCategoryOptionMixWithOthers error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    
    
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    
    //  code here to play next sound file
    NSLog(@"Played to end");
    
    [self resetPlayer];
    [_player seekToTime:CMTimeMakeWithSeconds(0, NSEC_PER_SEC)];
    
    [self setCurrentTrackToInfoCenter];
    
    _timeSlider.maximumValue = [self playbackDuration];
    
}


-(BOOL)playerPlaying
{
    if (_player) {
        if(_player.rate >0)
        {
            return YES;
        }
    }
    return NO;
}

-(float)playbackDuration
{
    float duration = -1;
    if (_player.currentItem) {
        duration = CMTimeGetSeconds(_playerItem.duration);
    }
    
    return duration;
}

-(void)prepareNotificationsForPlayer
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackStateChanged:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDatasourceChanged:) name:kDatasourceItemChanged object:nil];
    
}

-(void)playbackDidFinish:(NSNotification *)notf
{
    [self resetPlayer];
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    
}

-(void)onDatasourceChanged:(NSNotification *)notf
{
    if (_player) {
        [self resetPlayer];
        _currentItem = nil;
        _currentItemPID = nil;
        _remainningTime.text = @"00:00:00";
        _artWork.image = nil;
        _blurryImage.image = nil;
        musicTitleLabel.text = @"";
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:[_player currentItem]];
        
        [_player removeObserver:self forKeyPath:@"status"];
        
        _player = nil;
        _playerItem = nil;
    }
    
}

-(void)resetPlayer
{
    [_player pause];
    [self prepareSlider];
    [tickTimer invalidate];
    tickTimer = nil;
    [_play setImage:[UIImage imageNamed:@"audioPlay"] forState:UIControlStateNormal];
    _elapsedTime.text = @"00:00:00";
}

-(void)prepareSlider
{
    _timeSlider.minimumValue = 0;
    _timeSlider.maximumValue = 0;
    _timeSlider.value = 0;
}


#pragma mark - audio route changed
- (void)routeChange:(NSNotification*)notification {
    
    NSDictionary *interuptionDict = notification.userInfo;
    
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonUnknown:
            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonUnknown");
            break;
            
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            // a headset was added or removed
            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonNewDeviceAvailable");
            break;
            
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            // a headset was added or removed
            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonOldDeviceUnavailable");
            break;
            
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonCategoryChange");
            //AVAudioSessionRouteChangeReasonCategoryChange
            break;
            
        case AVAudioSessionRouteChangeReasonOverride:
            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonOverride");
            break;
            
        case AVAudioSessionRouteChangeReasonWakeFromSleep:
            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonWakeFromSleep");
            break;
            
        case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory:
            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory");
            break;
            
        default:
            break;
    }
}

- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause: {
                
                if(_player.rate >0.0)
                {
                    [_player pause];
                }
                else
                {
                    [_player play];
                }
                break;
            }
            case UIEventSubtypeRemoteControlPlay: {
                [_player play];
                break;
            }
            case UIEventSubtypeRemoteControlPause: {
                [_player pause];
                break;
            }
                
                // case UIEventSubtypeRemoteControlNextTrack:
            case UIEventSubtypeRemoteControlNextTrack:  {
                // [self performSelectorOnMainThread:@selector(onFF:) withObject:self waitUntilDone:NO];
                [self onFF:nil];
                break;
            }
                //case UIEventSubtypeRemoteControlBeginSeekingBackward:
            case UIEventSubtypeRemoteControlPreviousTrack:{
                //  [self performSelectorOnMainThread:@selector(onRW:) withObject:self waitUntilDone:NO];
                
                [self onRW:nil];
                break;
            }
            default:
                break;
        }
    }
}


-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder]; [super viewWillDisappear:animated];
}

- (BOOL) canBecomeFirstResponder {
    return YES;
}


#pragma mark - Playback handling
-(void)saveLastPlayedMusic
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [delegate saveLastPlayedMusic:self.item.pid];
    
}

-(void)loadLastPlayerMusic
{
    
}

- (IBAction)onMoreInformation:(id)sender {
    //use as a list of tracks?
}

- (IBAction)onSliderValueChanged:(id)sender {
    
    
}

- (IBAction)beginScrubbing:(id)sender
{
    isSeeking = YES;
    if (tickTimer) {
        
        [tickTimer invalidate];
    }
}

- (IBAction)endScrubbing:(id)sender
{
    isSeeking = NO;
    
    [_player pause];
    [_player seekToTime:CMTimeMakeWithSeconds(_timeSlider.value, NSEC_PER_SEC)];
    [_player play];
    [self scheduleTimer];
}

- (IBAction)scrub:(id)sender
{
    isSeeking = YES;
    
    long currentTime = _timeSlider.value;
    
    int currentHour = currentTime/3600;
    int currenctMin =  (currentTime % 3600) / 60;
    int currentSecs = currentTime % 60;
    
    
    _elapsedTime.text =[NSString stringWithFormat:@"%02d:%02d:%02d", currentHour, currenctMin, currentSecs];
}

- (IBAction)onPlayPause:(id)sender {
    
    if(![[NSThread currentThread] isMainThread])
    {
        __weak typeof(self)welf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf onPlayPause:sender];
        });
        return;
    }
    
    if (_currentItemPID) {
        
        [self setCurrentTrackToInfoCenter];
        isSeeking = NO;
        
        _timeSlider.maximumValue = [self playbackDuration];
        
        if (![self playerPlaying]) {
            
            [_player play];
            [_play setImage:[UIImage imageNamed:@"audioPause"] forState:UIControlStateNormal];
        }
        else{
            [_play setImage:[UIImage imageNamed:@"audioPlay"] forState:UIControlStateNormal];
            [_player pause];
            
            
        }
        [self scheduleTimer];
        
    }
    
}
- (IBAction)onFF:(id)sender {
    
    if(![[NSThread currentThread] isMainThread])
    {
        __weak typeof(self)welf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf onFF:sender];
        });
        return;
    }
    
    
    NSTimeInterval timeInterval = [self playbackDuration];
    long seconds = lroundf(timeInterval); // Since modulo operator (%) below needs int or long
    
    long currentTime = CMTimeGetSeconds(_player.currentItem.currentTime);
    if (currentTime +10 <= seconds) {
        [_player pause];
        [_player seekToTime:CMTimeMakeWithSeconds(currentTime +10 , NSEC_PER_SEC)];
        [_player play];
        [self scheduleTimer];
    }
}

- (IBAction)onRW:(id)sender {
    
    if(![[NSThread currentThread] isMainThread])
    {
        __weak typeof(self)welf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf onRW:sender];
        });
        return;
    }
    
    
    long currentTime = CMTimeGetSeconds(_player.currentItem.currentTime);
    if (currentTime -10 >= 0) {
        [_player seekToTime:CMTimeMakeWithSeconds(currentTime -10 , NSEC_PER_SEC)];
        [self scheduleTimer];
        
    }
}

-(void)updatePlayerViewsWithCurrentTime
{
    __weak typeof(self) welf = self;
    if(![[NSThread currentThread] isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf updatePlayerViewsWithCurrentTime];
        });
        return;
    }
    
    float timeInterval = [self playbackDuration];
    long seconds = lroundf(timeInterval); // Since modulo operator (%) below needs int or long
    
    int hour = seconds / 3600;
    int mins = (seconds % 3600) / 60;
    int secs = seconds % 60;
    
    long currentTime = CMTimeGetSeconds(_player.currentItem.currentTime);
    
    int currentHour = currentTime/3600;
    int currenctMin =  (currentTime % 3600) / 60;
    int currentSecs = currentTime % 60;
    
    //  NSLog(@"%@", [NSString stringWithFormat:@"%02d:%02d:%02d", currentHour, currenctMin, currentSecs]);
    
    _elapsedTime.text =[NSString stringWithFormat:@"%02d:%02d:%02d", currentHour, currenctMin, currentSecs];
    _remainningTime.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, mins, secs];
    _timeSlider.maximumValue = timeInterval;
    
    if (!_timeSlider.maximumValue) {
        _timeSlider.maximumValue = 0;
    }
    
    _timeSlider.minimumValue = 0;
    if (!isSeeking) {
        _timeSlider.value = currentTime;
        
    }
    
}

-(void)scheduleTimer
{
    if (tickTimer) {
        [tickTimer invalidate];
    }
    
    tickTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updatePlayerViewsWithCurrentTime) userInfo:nil repeats:YES];
}

-(void)loadFullImageForItem:(NSString *)itemPID
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString*path = [NSString stringWithFormat:@"%@/search/api/v5.0/item/%@/full",delegate.defaultDatasourceItem.url, itemPID ];
    
    [_blurryImage sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:nil];
    [self addBlurEffect];
    
}

-(void)loadThumbnailImageForItem:(NSString *)itemPID
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    NSString*path = [NSString stringWithFormat:@"%@/search/api/v5.0/item/%@/full",delegate.defaultDatasourceItem.url, itemPID ];
    
    [_artWork sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:nil];
}
-(void)viewDidLayoutSubviews
{
    [self addBlurEffect];
}


-(void)addBlurEffect
{
    visualBlurEffectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
}

-(NSString *)getTimeStringFromSeconds:(int)seconds
{
    NSDateComponentsFormatter *dcFormatter = [[NSDateComponentsFormatter alloc] init];
    dcFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    dcFormatter.allowedUnits = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    dcFormatter.unitsStyle = NSDateComponentsFormatterUnitsStylePositional;
    return [dcFormatter stringFromTimeInterval:seconds];
}

- (BOOL)isScrubbing
{
    return mRestoreAfterScrubbingRate != 0.f;
}

-(void)enableScrubber
{
    _timeSlider.enabled = YES;
}

-(void)disableScrubber
{
    _timeSlider.enabled = NO;
}



/* If the media is playing, show the stop button; otherwise, show the play button. */

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"OpenInfoDetail"])
    {
        // Get reference to the destination view controller
        MZKDetailInformationViewController *vc = [segue destinationViewController];
        
        NSString *targetPid;
        
        if (_currentItem.rootPid) {
            targetPid = _currentItem.rootPid;
            [vc setType:[_item getLocalizedItemType]];
        }
        
        // Pass any objects to the view controller here, like...
        [vc setItem:targetPid];
        
    }
}

@end

