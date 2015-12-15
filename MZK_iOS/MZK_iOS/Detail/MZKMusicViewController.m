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
#import <Google/Analytics.h>

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
    
    __weak IBOutlet UIVisualEffectView *visualBlurEffectView;
    MZKDatasource *_datasource;
    NSString *_currentItemPID;
    MZKItemResource *_currentItem;
    NSArray *_availableTracks;
    AVPlayer *_musicPlayer;
    AVPlayerItem * _musicPlayerItem;
    AVURLAsset *_currentAsset;
    id mTimeObserver;
    float mRestoreAfterScrubbingRate;
    BOOL seekToZeroBeforePlay;
    BOOL isSeeking;
    
}

@end

static void *AVPlayerViewControllerRateObservationContext = &AVPlayerViewControllerRateObservationContext;
static void *AVPlayerViewControllerStatusObservationContext = &AVPlayerViewControllerStatusObservationContext;
static void *AVPlayerViewControllerCurrentItemObservationContext = &AVPlayerViewControllerCurrentItemObservationContext;

@interface MZKMusicViewController (Player)
- (void)removePlayerTimeObserver;
- (CMTime)playerItemDuration;
- (BOOL)isPlaying;
- (void)playerItemDidReachEnd:(NSNotification *)notification ;
- (void)observeValueForKeyPath:(NSString*) path ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys;
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
    _timeSlider.value = 0;
    if (_currentItemPID) {
        [self loadFullImageForItem:_currentItemPID];
        [self loadThumbnailImageForItem:_currentItemPID];
    }
    [self initGoogleAnalytics];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"playbackStarted" object:nil];
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

    _currentItem = item;
    
    [self updateViews];
    
    [_datasource getChildrenForItem:_currentItem.pid];
}

-(void)dataLoaded:(NSArray *)data withKey:(NSString *)key
{
    
}

-(void)childrenForItemLoaded:(NSArray *)items
{
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
    

    /*
     Create an asset for inspection of a resource referenced by a given URL.
     Load the values for the asset key "playable".
     */
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:strURL] options:nil];
    _currentAsset = asset;
    
    NSArray *requestedKeys = @[@"playable"];
    
    /* Tells the asset to load the values of any of the specified keys that are not already loaded. */
    [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:
     ^{
         dispatch_async( dispatch_get_main_queue(),
                        ^{
                            /* IMPORTANT: Must dispatch to main queue in order to operate on the AVPlayer and AVPlayerItem. */
                            [self prepareToPlayAsset:asset withKeys:requestedKeys];
                            [self saveLastPlayedMusic];
                        });
     }];
}

-(void)saveLastPlayedMusic
{
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    [delegate saveLastPlayedMusic:self.item.pid];
    
}

-(void)loadLastPlayerMusic
{
    
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

-(void)loadFullImageForItem:(NSString *)itemPID
{
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    NSString*url = [NSString stringWithFormat:@"%@://%@", delegate.defaultDatasourceItem.protocol, delegate.defaultDatasourceItem.stringURL];
    NSString*path = [NSString stringWithFormat:@"%@//search/api/v5.0/item/%@/full",url, itemPID ];
    
    [_blurryImage sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:nil];
    [self addBlurEffect];
    
}

-(void)loadThumbnailImageForItem:(NSString *)itemPID
{
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    NSString*url = [NSString stringWithFormat:@"%@://%@", delegate.defaultDatasourceItem.protocol, delegate.defaultDatasourceItem.stringURL];
    NSString*path = [NSString stringWithFormat:@"%@//search/api/v5.0/item/%@/full",url, itemPID ];
    
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_currentItem) {
            titleLabel.text = _currentItem.title;
        }
        
        float videoDurationSeconds = CMTimeGetSeconds( [wealf playerItemDuration]);
        if (videoDurationSeconds >0 ) {
            _timeSlider.minimumValue = 0;
            _timeSlider.maximumValue =videoDurationSeconds;
            
            _remainningTime.text = [self getTimeStringFromSeconds:videoDurationSeconds];
            _elapsedTime.text = [self getTimeStringFromSeconds:_timeSlider.value];
        }
    });
}

-(NSString *)getTimeStringFromSeconds:(int)seconds
{
    NSDateComponentsFormatter *dcFormatter = [[NSDateComponentsFormatter alloc] init];
    dcFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    dcFormatter.allowedUnits = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    dcFormatter.unitsStyle = NSDateComponentsFormatterUnitsStylePositional;
    return [dcFormatter stringFromTimeInterval:seconds];
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

/* Requests invocation of a given block during media playback to update the movie scrubber control. */
-(void)initScrubberTimer
{
    double interval = .1f;
    
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        return;
    }
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
        CGFloat width = CGRectGetWidth([_timeSlider bounds]);
        interval = 0.5f * duration / width;
    }
    
    /* Update the scrubber during normal playback. */
    __weak MZKMusicViewController *weakSelf = self;
    mTimeObserver = [_musicPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
                                                               queue:NULL /* If you pass NULL, the main queue is used. */
                                                          usingBlock:^(CMTime time)
                     {
                         [weakSelf syncScrubber];
                         [weakSelf updateViews];
                     }];
}

/* Set the scrubber based on the player current time. */
- (void)syncScrubber
{
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        _timeSlider.minimumValue = 0.0;
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
        float minValue = [_timeSlider minimumValue];
        float maxValue = [_timeSlider maximumValue];
        double time = CMTimeGetSeconds([_musicPlayer currentTime]);
        
        [_timeSlider setValue:(maxValue - minValue) * time / duration + minValue];
    }
}

/* If the media is playing, show the stop button; otherwise, show the play button. */
- (void)syncPlayPauseButtons
{
    if ([self isPlaying])
    {
       // [self showStopButton];
    }
    else
    {
       // [self showPlayButton];
    }
}


@end

@implementation MZKMusicViewController (Player)

#pragma mark Player Item

- (BOOL)isPlaying
{
    return mRestoreAfterScrubbingRate != 0.f || [_musicPlayer rate] != 0.f;
}

/* Called when the player item has played to its end time. */
- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    /* After the movie has played to its end time, seek back to time zero
     to play it again. */
    seekToZeroBeforePlay = YES;
}

/* ---------------------------------------------------------
 **  Get the duration for a AVPlayerItem.
 ** ------------------------------------------------------- */

- (CMTime)playerItemDuration
{
    AVPlayerItem *playerItem = [_musicPlayer currentItem];
    if (playerItem.status == AVPlayerItemStatusReadyToPlay)
    {
        return([playerItem duration]);
    }
    
    return(kCMTimeInvalid);
}


/* Cancels the previously registered time observer. */
-(void)removePlayerTimeObserver
{
    if (mTimeObserver)
    {
        [_musicPlayer removeTimeObserver:mTimeObserver];
        mTimeObserver = nil;
    }
}

#pragma mark -
#pragma mark Loading the Asset Keys Asynchronously

#pragma mark -
#pragma mark Error Handling - Preparing Assets for Playback Failed

/* --------------------------------------------------------------
 **  Called when an asset fails to prepare for playback for any of
 **  the following reasons:
 **
 **  1) values of asset keys did not load successfully,
 **  2) the asset keys did load successfully, but the asset is not
 **     playable
 **  3) the item did not become ready to play.
 ** ----------------------------------------------------------- */

-(void)assetFailedToPrepareForPlayback:(NSError *)error
{
    [self removePlayerTimeObserver];
    //[self syncScrubber];
    //[self disableScrubber];
    //[self disablePlayerButtons];
    
    /* Display the error. */
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                        message:[error localizedFailureReason]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}


#pragma mark Prepare to play asset, URL

/*
 Invoked at the completion of the loading of the values for all keys on the asset that we require.
 Checks whether loading was successfull and whether the asset is playable.
 If so, sets up an AVPlayerItem and an AVPlayer to play the asset.
 */
- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys
{
    /* Make sure that the value of each key has loaded successfully. */
    for (NSString *thisKey in requestedKeys)
    {
        NSError *error = nil;
        AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
        if (keyStatus == AVKeyValueStatusFailed)
        {
            [self assetFailedToPrepareForPlayback:error];
            return;
        }
        /* If you are also implementing -[AVAsset cancelLoading], add your code here to bail out properly in the case of cancellation. */
    }
    
    /* Use the AVAsset playable property to detect whether the asset can be played. */
    if (!asset.playable)
    {
        /* Generate an error describing the failure. */
        NSString *localizedDescription = NSLocalizedString(@"Item cannot be played", @"Item cannot be played description");
        NSString *localizedFailureReason = NSLocalizedString(@"The assets tracks were loaded, but could not be made playable.", @"Item cannot be played failure reason");
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   localizedDescription, NSLocalizedDescriptionKey,
                                   localizedFailureReason, NSLocalizedFailureReasonErrorKey,
                                   nil];
        NSError *assetCannotBePlayedError = [NSError errorWithDomain:@"StitchedStreamPlayer" code:0 userInfo:errorDict];
        
        /* Display the error to the user. */
        [self assetFailedToPrepareForPlayback:assetCannotBePlayedError];
        
        return;
    }
    
    /* At this point we're ready to set up for playback of the asset. */
    
    /* Stop observing our prior AVPlayerItem, if we have one. */
    if (_musicPlayerItem)
    {
        /* Remove existing player item key value observers and notifications. */
        
        [_musicPlayerItem removeObserver:self forKeyPath:@"status"];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:_musicPlayerItem];
    }
    
    /* Create a new instance of AVPlayerItem from the now successfully loaded AVAsset. */
    _musicPlayerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    /* Observe the player item "status" key to determine when it is ready to play. */
    [_musicPlayerItem addObserver:self
                       forKeyPath:@"status"
                          options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          context:AVPlayerViewControllerStatusObservationContext];
    
    /* When the player item has played to its end time we'll toggle
     the movie controller Pause button to be the Play button */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:_musicPlayerItem];
    
    seekToZeroBeforePlay = NO;
    
    /* Create new player, if we don't already have one. */
    if (!_musicPlayer)
    {
        /* Get a new AVPlayer initialized to play the specified player item. */
        _musicPlayer = [AVPlayer playerWithPlayerItem:_musicPlayerItem];
        
        /* Observe the AVPlayer "currentItem" property to find out when any
         AVPlayer replaceCurrentItemWithPlayerItem: replacement will/did
         occur.*/
        [_musicPlayer addObserver:self
                      forKeyPath:@"currentItem"
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:AVPlayerViewControllerCurrentItemObservationContext];
        
        /* Observe the AVPlayer "rate" property to update the scrubber control. */
        [_musicPlayer addObserver:self
                      forKeyPath:@"rate"
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:AVPlayerViewControllerRateObservationContext];
    }
    
    /* Make our new AVPlayerItem the AVPlayer's current item. */
    if (_musicPlayer.currentItem != _musicPlayerItem)
    {
        /* Replace the player item with a new player item. The item replacement occurs
         asynchronously; observe the currentItem property to find out when the
         replacement will/did occur
         
         If needed, configure player item here (example: adding outputs, setting text style rules,
         selecting media options) before associating it with a player
         */
        [_musicPlayer replaceCurrentItemWithPlayerItem:_musicPlayerItem];
        
        [self syncPlayPauseButtons];
    }
    
    [_timeSlider setValue:0.0];
}

#pragma mark -
#pragma mark Asset Key Value Observing
#pragma mark

#pragma mark Key Value Observer for player rate, currentItem, player item status

/* ---------------------------------------------------------
 **  Called when the value at the specified key path relative
 **  to the given object has changed.
 **  Adjust the movie play and pause button controls when the
 **  player item "status" value changes. Update the movie
 **  scrubber control when the player item is ready to play.
 **  Adjust the movie scrubber control when the player item
 **  "rate" value changes. For updates of the player
 **  "currentItem" property, set the AVPlayer for which the
 **  player layer displays visual output.
 **  NOTE: this method is invoked on the main queue.
 ** ------------------------------------------------------- */

- (void)observeValueForKeyPath:(NSString*) path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
    /* AVPlayerItem "status" property value observer. */
    if (context == AVPlayerViewControllerStatusObservationContext)
    {
        [self syncPlayPauseButtons];
        
        AVPlayerItemStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status)
        {
                /* Indicates that the status of the player is not yet known because
                 it has not tried to load new media resources for playback */
            case AVPlayerItemStatusUnknown:
            {
                [self removePlayerTimeObserver];
                [self syncScrubber];
                
               // [self disableScrubber];
               // [self disablePlayerButtons];
            }
                break;
                
            case AVPlayerItemStatusReadyToPlay:
            {
                /* Once the AVPlayerItem becomes ready to play, i.e.
                 [playerItem status] == AVPlayerItemStatusReadyToPlay,
                 its duration can be fetched from the item. */
                
                [self initScrubberTimer];
                
                [self updateViews];
                //[self enableScrubber];
               // [self enablePlayerButtons];
            }
                break;
                
            case AVPlayerItemStatusFailed:
            {
                AVPlayerItem *playerItem = (AVPlayerItem *)object;
                [self assetFailedToPrepareForPlayback:playerItem.error];
            }
                break;
        }
    }
    /* AVPlayer "rate" property value observer. */
    else if (context == AVPlayerViewControllerRateObservationContext)
    {
        [self syncPlayPauseButtons];
    }
    /* AVPlayer "currentItem" property observer.
     Called when the AVPlayer replaceCurrentItemWithPlayerItem:
     replacement will/did occur. */
    else if (context == AVPlayerViewControllerCurrentItemObservationContext)
    {
        AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
        
        /* Is the new player item null? */
        if (newPlayerItem == (id)[NSNull null])
        {
           // [self disablePlayerButtons];
           // [self disableScrubber];
        }
        else /* Replacement of player currentItem has occurred */
        {
            /* Set the AVPlayer for which the player layer displays visual output. */
            //[self.mPlaybackView setPlayer:mPlayer];
            
           // [self setViewDisplayName];
            
            /* Specifies that the player should preserve the video’s aspect ratio and 
             fit the video within the layer’s bounds. */
            //[self.mPlaybackView setVideoFillMode:AVLayerVideoGravityResizeAspect];
            
            [self syncPlayPauseButtons];
        }
    }
    else
    {
        [super observeValueForKeyPath:path ofObject:object change:change context:context];
    }
}


@end




