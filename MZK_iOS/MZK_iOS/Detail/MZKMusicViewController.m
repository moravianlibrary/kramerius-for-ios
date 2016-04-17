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
#import "MZKConstants.h"

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
    
   // [self startAnimating];
}



-(void)playbackStateChanged:(NSNotification*)notification
{
    NSLog(@"State changed to: %lu\n", (unsigned long)_audioPlayer.loadState);
    MPMovieLoadState state = [_audioPlayer loadState];
    
    if (state & MPMovieLoadStateUnknown) {
        NSLog(@"Unknown");
        
    }
    
    if( state & MPMovieLoadStatePlaythroughOK ) {
        NSLog(@"NodeViewController: Playthrough OK Load State");
        [self stopAnimating];
       
    }
    
    if( state & MPMovieLoadStateStalled ) {
        NSLog(@"NodeViewController: Stalled Load State");
    }
    
    if (state & MPMovieLoadStatePlayable)
    {
        NSLog(@"Playable");
        _timeSlider.userInteractionEnabled = YES;
        _timeSlider.maximumValue = _audioPlayer.playableDuration;
        
    }

  [self updatePlayerViewsWithCurrentTime];
    
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

        [self playItemWithPID:((MZKPageObject *)_availableTracks.firstObject).pid];
    }
}

-(void)playItemWithPID:(NSString *)pid
{
   
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    NSString*url = [NSString stringWithFormat:@"%@://%@", delegate.defaultDatasourceItem.protocol, delegate.defaultDatasourceItem.stringURL];
    NSString*path = [NSString stringWithFormat:@"%@/search/api/v5.0/item/%@/streams/MP3",url, pid];
    
    [self prepareNotificationsForPlayer];
    
    
    _audioPlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:path]];
    
    [_audioPlayer setMovieSourceType:MPMovieSourceTypeStreaming];
    [_audioPlayer setShouldAutoplay:NO];
    [_audioPlayer setControlStyle: MPMovieControlStyleEmbedded];
    
    _audioPlayer.view.hidden = YES;
    
    [_audioPlayer prepareToPlay];
    
}

-(void)prepareNotificationsForPlayer
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:_audioPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackStateChanged:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDatasourceChanged:) name:kDatasourceItemChanged object:nil];
    
}

-(void)playbackDidFinish:(NSNotification *)notf
{
    NSLog(@"Playback did finish");
    
    [self resetPlayer];
    
}

-(void)onDatasourceChanged:(NSNotification *)notf
{
    if (_audioPlayer) {
        [_audioPlayer stop];
    }
    
}

-(void)resetPlayer
{
    [_audioPlayer stop];
    [self prepareSlider];
    [tickTimer invalidate];
    tickTimer = nil;
    
    if (_audioPlayer.currentPlaybackRate == 0) {
        
        [_play setImage:[UIImage imageNamed:@"audioPlay"] forState:UIControlStateNormal];
    }
}

-(void)prepareSlider
{
    _timeSlider.minimumValue = 0;
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
                [_audioPlayer play];
                break;
            }
            case UIEventSubtypeRemoteControlPause: {
                [_audioPlayer pause];
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
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    [delegate saveLastPlayedMusic:self.item.pid];
    
}

-(void)loadLastPlayerMusic
{
    
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    
    //  code here to play next sound file
    
}



- (IBAction)onMoreInformation:(id)sender {
    //use as a list of tracks?
}

- (IBAction)onSliderValueChanged:(id)sender {
    
    
}

- (IBAction)beginScrubbing:(id)sender
{
    NSLog(@"Begin scrubbing");
    isSeeking = YES;
}

- (IBAction)endScrubbing:(id)sender
{
    isSeeking = NO;
    NSLog(@"end Scrubbing");
    [self scheduleTimer];
}

- (IBAction)scrub:(id)sender
{
    isSeeking = YES;
    _audioPlayer.currentPlaybackTime = _timeSlider.value;
    NSLog(@"on scrub");
    
    [self updatePlayerViewsWithCurrentTime];
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
            [songInfo setObject:[NSNumber numberWithFloat:_audioPlayer.playableDuration] forKey:MPMediaItemPropertyPlaybackDuration];
            [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
        }];
        
        isSeeking = NO;
       
        _timeSlider.maximumValue = _audioPlayer.playableDuration;
        
        if (_audioPlayer.currentPlaybackRate == 0) {
            
            [[AVAudioSession sharedInstance] setActive:NO error:nil];
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
            [[AVAudioSession sharedInstance] setActive: YES error: nil];
            
            if (_timeSlider.value > 0 && _audioPlayer.currentPlaybackRate ==0) {
                //scrubbed before play
                _audioPlayer.currentPlaybackTime = _timeSlider.value;
            }
            
            [_audioPlayer play];
            [_play setImage:[UIImage imageNamed:@"audioPause"] forState:UIControlStateNormal];
        }
        else{
            [_play setImage:[UIImage imageNamed:@"audioPlay"] forState:UIControlStateNormal];
            [_audioPlayer pause];
            
            
        }
        [self scheduleTimer];
        
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

- (IBAction)onRW:(id)sender {
    
    long currentTime = _audioPlayer.currentPlaybackTime;
    if (currentTime -10 >= 0) {
        _audioPlayer.currentPlaybackTime-=10;
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
    
    NSTimeInterval timeInterval = _audioPlayer.playableDuration;
    long seconds = lroundf(timeInterval); // Since modulo operator (%) below needs int or long
    
    int hour = seconds / 3600;
    int mins = (seconds % 3600) / 60;
    int secs = seconds % 60;
    
    long currentTime = _audioPlayer.currentPlaybackTime;
    
    int currentHour = currentTime/3600;
    int currenctMin =  (currentTime % 3600) / 60;
    int currentSecs = currentTime % 60;
    
    
    _elapsedTime.text =[NSString stringWithFormat:@"%02d:%02d:%02d", currentHour, currenctMin, currentSecs];
    _remainningTime.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, mins, secs];
    
    if (!isSeeking) {
        _timeSlider.value = _audioPlayer.currentPlaybackTime;

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
