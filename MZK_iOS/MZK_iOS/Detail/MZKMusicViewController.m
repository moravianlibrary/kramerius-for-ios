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
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "MZKDetailInformationViewController.h"
#import <Google/Analytics.h>
#import <MobileCoreServices/MobileCoreServices.h>

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
    
    __weak IBOutlet UIVisualEffectView *visualBlurEffectView;
    MZKDatasource *_datasource;
    NSString *_currentItemPID;
    MZKItemResource *_currentItem;
    NSArray *_availableTracks;

    id mTimeObserver;
    float mRestoreAfterScrubbingRate;
    BOOL seekToZeroBeforePlay;
    BOOL isSeeking;
    NSTimer *tickTimer;
    
    MPMoviePlayerController *_audioPlayer;
    
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
    return sharedInstance;}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _timeSlider.value = 0;
    if (_currentItemPID) {
        [self loadFullImageForItem:_currentItemPID];
        [self loadThumbnailImageForItem:_currentItemPID];
    }
    [self initGoogleAnalytics];
    
    // NOTIFICATIONS
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(routeChange:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
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
    self.title = @"Hudební přehrávač";
}



-(void)playbackStateChanged:(NSNotification*)notification
{
    NSLog(@"Notification:%@", notification.description);
    //    switch (<#expression#>) {
    //        case <#constant#>:
    //            <#statements#>
    //            break;
    //
    //        default:
    //            break;
    //    }
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
    
}

-(void)loadDataForController
{
    [_datasource getItem:_currentItemPID];
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
    
    // [self hideLoadingIndicator];
    
    [self showErrorWithTitle:@"Problém při stahování" subtitle:@"Přejete si opakovat akci?" confirmAction:^{
        [welf loadDataForController];
        
    }];
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
    __weak typeof(self) welf = self;
    if(![[NSThread currentThread] isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf detailForItemLoaded:item];
        });
        return;
    }
    
    
    _currentItem = item;
    
    
    
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
    
    [self updateViews];
    
    
    if (_availableTracks.count ==1) {
        // [self playItemWithPID:((MZKPageObject *)_availableTracks.firstObject).pid];
        [self playeWithDifferentPlayer:((MZKPageObject *)_availableTracks.firstObject).pid];
    }
}

-(void)playeWithDifferentPlayer:(NSString *)pid
{
    [[AVAudioSession sharedInstance] setDelegate: self];
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    NSString*url = [NSString stringWithFormat:@"%@://%@", delegate.defaultDatasourceItem.protocol, delegate.defaultDatasourceItem.stringURL];
    NSString*path = [NSString stringWithFormat:@"%@/search/api/v5.0/item/%@/streams/MP3",url, pid];
    
    [self prepareNotificationsForPlayer];
    
    
    _audioPlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:path]];
    
    [_audioPlayer setShouldAutoplay:NO];
    [_audioPlayer setControlStyle: MPMovieControlStyleEmbedded];
    
    _audioPlayer.view.hidden = YES;
    
    [_audioPlayer prepareToPlay];
    
    [self scheduleTimer];
    
}

-(void)prepareNotificationsForPlayer
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoPlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:_audioPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackStateChanged:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
    
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
    NSLog(@"received event!");
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause: {
            
                if(_audioPlayer.currentPlaybackRate >0.0)
                {
                    [_audioPlayer pause];
                }
                else
                {
                    [_audioPlayer play];
                }
                break;
            }
            case UIEventSubtypeRemoteControlPlay: {
                // [_musicPlayer play];
                [_audioPlayer play];
                break;
            }
            case UIEventSubtypeRemoteControlPause: {
                // [_musicPlayer pause];
                [_audioPlayer pause];
                break;
            }
                
            case UIEventSubtypeRemoteControlBeginSeekingForward:
                [self onFF:nil];
                break;
            case UIEventSubtypeRemoteControlBeginSeekingBackward:
                [self onRW:nil];
                break;
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
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    [delegate saveLastPlayedMusic:self.item.pid];
    
}

-(void)loadLastPlayerMusic
{
    
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
     
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    
    if (playingInfoCenter) {
        
        
        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
        AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        
        NSString*url = [NSString stringWithFormat:@"%@://%@", delegate.defaultDatasourceItem.protocol, delegate.defaultDatasourceItem.stringURL];
        NSString*path = [NSString stringWithFormat:@"%@/search/api/v5.0/item/%@/full",url, _currentItem.pid ];
        
        
        [_artWork sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage:_artWork.image];
            
           
            [songInfo setObject:_currentItem.title forKey:MPMediaItemPropertyTitle];
            [songInfo setObject:_currentItem.authors forKey:MPMediaItemPropertyArtist];
           // [songInfo setObject:@"Audio Album" forKey:MPMediaItemPropertyAlbumTitle];
            [songInfo setObject:[NSNumber numberWithFloat:_audioPlayer.playableDuration] forKey:MPMediaItemPropertyPlaybackDuration];
            [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
        }];
        
        
        if (_audioPlayer.currentPlaybackRate == 0) {
            
            [[AVAudioSession sharedInstance] setActive:NO error:nil];
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
            [[AVAudioSession sharedInstance] setActive: YES error: nil];
            
            [_audioPlayer play];
            [_play setImage:[UIImage imageNamed:@"audioPause"] forState:UIControlStateNormal];
        }
        else{
            [_play setImage:[UIImage imageNamed:@"audioPlay"] forState:UIControlStateNormal];
            [_audioPlayer pause];
            
        }
        
    }
}
- (IBAction)onFF:(id)sender {
   
    NSTimeInterval timeInterval = _audioPlayer.playableDuration;
    long seconds = lroundf(timeInterval); // Since modulo operator (%) below needs int or long
    
    long currentTime = _audioPlayer.currentPlaybackTime;
    if (currentTime +10 <= seconds) {
        _audioPlayer.currentPlaybackTime+=10;
        [self scheduleTimer];
    }
}

-(void)updatePlayerViewsWithCurrentTime
{
    NSTimeInterval timeInterval = _audioPlayer.playableDuration;
    long seconds = lroundf(timeInterval); // Since modulo operator (%) below needs int or long
    
    int hour = seconds / 3600;
    int mins = (seconds % 3600) / 60;
    int secs = seconds % 60;
    
    long currentTime = _audioPlayer.currentPlaybackTime;
    
    int currentHour = currentTime/3600;
    int currenctMin =  (currentTime % 3600) / 60;
    int currentSecs = currentTime % 60;
    
    
    _elapsedTime.text =[NSString stringWithFormat:@"%d:%d:%d", currentHour, currenctMin, currentSecs];
    _remainningTime.text = [NSString stringWithFormat:@"%d:%d:%d", hour, mins, secs];
}

- (IBAction)onRW:(id)sender {
    
    long currentTime = _audioPlayer.currentPlaybackTime;
    if (currentTime -10 <= 0) {
        _audioPlayer.currentPlaybackTime-=10;
        [self scheduleTimer];

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
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    NSString*url = [NSString stringWithFormat:@"%@://%@", delegate.defaultDatasourceItem.protocol, delegate.defaultDatasourceItem.stringURL];
    NSString*path = [NSString stringWithFormat:@"%@/search/api/v5.0/item/%@/full",url, itemPID ];
    
    [_blurryImage sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:nil];
    [self addBlurEffect];
    
}

-(void)loadThumbnailImageForItem:(NSString *)itemPID
{
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    NSString*url = [NSString stringWithFormat:@"%@://%@", delegate.defaultDatasourceItem.protocol, delegate.defaultDatasourceItem.stringURL];
    NSString*path = [NSString stringWithFormat:@"%@/search/api/v5.0/item/%@/full",url, itemPID ];
    
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

-(void)updateViews
{
    __weak typeof(self) wealf = self;
    
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        if (_currentItem) {
    //            titleLabel.text = _currentItem.title;
    //        }
    //
    //        float videoDurationSeconds = CMTimeGetSeconds( [wealf playerItemDuration]);
    //        if (videoDurationSeconds >0 ) {
    //            _timeSlider.minimumValue = 0;
    //            _timeSlider.maximumValue =videoDurationSeconds;
    //
    //            _remainningTime.text = [self getTimeStringFromSeconds:videoDurationSeconds];
    //            _elapsedTime.text = [self getTimeStringFromSeconds:_timeSlider.value];
    //        }
    //    });
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
            [vc setType:[_item getAuthorsStringRepresentation]];
        }
        
        // Pass any objects to the view controller here, like...
        [vc setItem:targetPid];
        
    }
}

@end
