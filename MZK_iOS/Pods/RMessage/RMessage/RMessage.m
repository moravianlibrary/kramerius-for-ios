//
//  RMessage.m
//  RMessage
//
//  Created by Adonis Peralta on 12/7/15.
//  Copyright © 2015 Adonis Peralta. All rights reserved.
//

#import "RMessage.h"
#import "RMessageView.h"

static UIViewController *_defaultViewController;
static NSLock *mLock, *nLock;

@interface RMessage () <RMessageViewProtocol>

/** The queued messages (RMessageView objects) */
@property (nonatomic, strong) NSMutableArray *messages;

@property (nonatomic, assign) BOOL notificationActive;

@end

@implementation RMessage

#pragma mark - Class Methods

+ (instancetype)sharedMessage
{
  static RMessage *sharedMessage;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedMessage = [RMessage new];
    mLock = [NSLock new];
    nLock = [NSLock new];
  });
  return sharedMessage;
}

+ (void)showNotificationWithTitle:(NSString *)title
                             type:(RMessageType)type
                   customTypeName:(NSString *)customTypeName
                         callback:(void (^)(void))callback
{
  [self showNotificationWithTitle:title subtitle:nil type:type customTypeName:customTypeName callback:callback];
}

+ (void)showNotificationWithTitle:(NSString *)title
                         subtitle:(NSString *)subtitle
                             type:(RMessageType)type
                   customTypeName:(NSString *)customTypeName
                         callback:(void (^)(void))callback
{
  [self showNotificationInViewController:_defaultViewController
                                   title:title
                                subtitle:subtitle
                                    type:type
                          customTypeName:customTypeName
                                callback:callback];
}

+ (void)showNotificationWithTitle:(NSString *)title
                         subtitle:(NSString *)subtitle
                             type:(RMessageType)type
                   customTypeName:(NSString *)customTypeName
                         duration:(NSTimeInterval)duration
                         callback:(void (^)(void))callback
{
  [self showNotificationInViewController:_defaultViewController
                                   title:title
                                subtitle:subtitle
                                    type:type
                          customTypeName:customTypeName
                                duration:duration
                                callback:callback];
}

+ (void)showNotificationWithTitle:(NSString *)title
                         subtitle:(NSString *)subtitle
                             type:(RMessageType)type
                   customTypeName:(NSString *)customTypeName
                         duration:(NSTimeInterval)duration
                         callback:(void (^)(void))callback
             canBeDismissedByUser:(BOOL)dismissingEnabled
{
  [self showNotificationInViewController:_defaultViewController
                                   title:title
                                subtitle:subtitle
                                    type:type
                          customTypeName:customTypeName
                                duration:duration
                                callback:callback
                    canBeDismissedByUser:dismissingEnabled];
}

+ (void)showNotificationWithTitle:(NSString *)title
                         subtitle:(NSString *)subtitle
                        iconImage:(UIImage *)iconImage
                             type:(RMessageType)type
                   customTypeName:(NSString *)customTypeName
                         duration:(NSTimeInterval)duration
                         callback:(void (^)(void))callback
                      buttonTitle:(NSString *)buttonTitle
                   buttonCallback:(void (^)(void))buttonCallback
                       atPosition:(RMessagePosition)messagePosition
             canBeDismissedByUser:(BOOL)dismissingEnabled
{
  [self showNotificationInViewController:_defaultViewController
                                   title:title
                                subtitle:subtitle
                               iconImage:iconImage
                                    type:type
                          customTypeName:customTypeName
                                duration:duration
                                callback:callback
                             buttonTitle:buttonTitle
                          buttonCallback:buttonCallback
                              atPosition:messagePosition
                    canBeDismissedByUser:dismissingEnabled];
}

+ (void)showNotificationInViewController:(UIViewController *)viewController
                                   title:(NSString *)title
                                subtitle:(NSString *)subtitle
                                    type:(RMessageType)type
                          customTypeName:(NSString *)customTypeName
                                duration:(NSTimeInterval)duration
                                callback:(void (^)(void))callback
{
  [self showNotificationInViewController:viewController
                                   title:title
                                subtitle:subtitle
                               iconImage:nil
                                    type:type
                          customTypeName:customTypeName
                                duration:duration
                                callback:callback
                             buttonTitle:nil
                          buttonCallback:nil
                              atPosition:RMessagePositionTop
                    canBeDismissedByUser:YES];
}

+ (void)showNotificationInViewController:(UIViewController *)viewController
                                   title:(NSString *)title
                                subtitle:(NSString *)subtitle
                                    type:(RMessageType)type
                          customTypeName:(NSString *)customTypeName
                                duration:(NSTimeInterval)duration
                                callback:(void (^)(void))callback
                    canBeDismissedByUser:(BOOL)dismissingEnabled
{
  [self showNotificationInViewController:viewController
                                   title:title
                                subtitle:subtitle
                               iconImage:nil
                                    type:type
                          customTypeName:customTypeName
                                duration:duration
                                callback:callback
                             buttonTitle:nil
                          buttonCallback:nil
                              atPosition:RMessagePositionTop
                    canBeDismissedByUser:dismissingEnabled];
}

+ (void)showNotificationInViewController:(UIViewController *)viewController
                                   title:(NSString *)title
                                subtitle:(NSString *)subtitle
                                    type:(RMessageType)type
                          customTypeName:(NSString *)customTypeName
                                callback:(void (^)(void))callback
{
  [self showNotificationInViewController:viewController
                                   title:title
                                subtitle:subtitle
                               iconImage:nil
                                    type:type
                          customTypeName:customTypeName
                                duration:RMessageDurationAutomatic
                                callback:callback
                             buttonTitle:nil
                          buttonCallback:nil
                              atPosition:RMessagePositionTop
                    canBeDismissedByUser:YES];
}

+ (void)showNotificationInViewController:(UIViewController *)viewController
                                   title:(NSString *)title
                                subtitle:(NSString *)subtitle
                               iconImage:(UIImage *)iconImage
                                    type:(RMessageType)type
                          customTypeName:(NSString *)customTypeName
                                duration:(NSTimeInterval)duration
                                callback:(void (^)(void))callback
                             buttonTitle:(NSString *)buttonTitle
                          buttonCallback:(void (^)(void))buttonCallback
                              atPosition:(RMessagePosition)messagePosition
                    canBeDismissedByUser:(BOOL)dismissingEnabled
{
  [self showNotificationInViewController:viewController
                                   title:title
                                subtitle:subtitle
                               iconImage:iconImage
                                    type:type
                          customTypeName:customTypeName
                                duration:duration
                                callback:callback
                    presentingCompletion:nil
                       dismissCompletion:nil
                             buttonTitle:buttonTitle
                          buttonCallback:buttonCallback
                              atPosition:messagePosition
                    canBeDismissedByUser:dismissingEnabled];
}

+ (void)showNotificationInViewController:(UIViewController *)viewController
                                   title:(NSString *)title
                                subtitle:(NSString *)subtitle
                               iconImage:(UIImage *)iconImage
                                    type:(RMessageType)type
                          customTypeName:(NSString *)customTypeName
                                duration:(NSTimeInterval)duration
                                callback:(void (^)(void))callback
                    presentingCompletion:(void (^)(void))presentingCompletionCallback
                       dismissCompletion:(void (^)(void))dismissCompletionCallback
                             buttonTitle:(NSString *)buttonTitle
                          buttonCallback:(void (^)(void))buttonCallback
                              atPosition:(RMessagePosition)messagePosition
                    canBeDismissedByUser:(BOOL)dismissingEnabled
{
  RMessageView *messageView = [[RMessageView alloc] initWithDelegate:[RMessage sharedMessage]
                                                               title:title
                                                            subtitle:subtitle
                                                           iconImage:iconImage
                                                                type:type
                                                      customTypeName:customTypeName
                                                            duration:duration
                                                    inViewController:viewController
                                                            callback:callback
                                                presentingCompletion:presentingCompletionCallback
                                                   dismissCompletion:dismissCompletionCallback
                                                         buttonTitle:buttonTitle
                                                      buttonCallback:buttonCallback
                                                          atPosition:messagePosition
                                                canBeDismissedByUser:dismissingEnabled];
  [self prepareNotificationForPresentation:messageView];
}

+ (void)prepareNotificationForPresentation:(RMessageView *)messageView
{
  [mLock lock];
  [[RMessage sharedMessage].messages addObject:messageView];
  [mLock unlock];

  [nLock lock];
  if (![RMessage sharedMessage].notificationActive) {
    [nLock unlock];
    [[RMessage sharedMessage] presentMessageView];
    return;
  }
  [nLock unlock];
}

+ (BOOL)dismissActiveNotification
{
  return [self dismissActiveNotificationWithCompletion:nil];
}

+ (BOOL)dismissActiveNotificationWithCompletion:(void (^)(void))completionBlock
{
  [mLock lock];
  if ([RMessage sharedMessage].messages.count == 0 || ![RMessage sharedMessage].messages) {
    [mLock unlock];
    return NO;
  }

  RMessageView *currentMessage = [RMessage sharedMessage].messages[0];

  if (currentMessage && currentMessage.messageIsFullyDisplayed) {
    [currentMessage dismissWithCompletion:completionBlock];
  }

  [mLock unlock];
  return YES;
}

#pragma mark Customizing RMessage

+ (void)setDefaultViewController:(UIViewController *)defaultViewController
{
  _defaultViewController = defaultViewController;
}

+ (void)setDelegate:(id<RMessageProtocol>)delegate
{
  [RMessage sharedMessage].delegate = delegate;
}

+ (void)addDesignsFromFileWithName:(NSString *)filename inBundle:(NSBundle *)bundle
{
  [RMessageView addDesignsFromFileWithName:filename inBundle:bundle];
}

#pragma mark - Misc Methods

+ (BOOL)isNotificationActive
{
  [nLock lock];
  BOOL notificationActive = [RMessage sharedMessage].notificationActive;
  [nLock unlock];
  return notificationActive;
}

+ (NSArray *)queuedMessages
{
  [mLock lock];
  NSArray *messagesCopy = [[RMessage sharedMessage].messages copy];
  [mLock unlock];
  return messagesCopy;
}

#pragma mark - Instance Methods

- (instancetype)init
{
  self = [super init];
  if (self) {
    [mLock lock];
    _messages = [NSMutableArray new];
    [mLock unlock];
  }
  return self;
}

- (void)presentMessageView
{
  [mLock lock];
  if (self.messages.count == 0) {
    [mLock unlock];
    return;
  }

  RMessageView *messageView = self.messages[0];
  [mLock unlock];

  if (self.delegate && [self.delegate respondsToSelector:@selector(customizeMessageView:)]) {
    [self.delegate customizeMessageView:messageView];
  }
  [messageView present];
}

#pragma mark - RMessageView Delegate Methods

- (void)messageViewIsPresenting:(RMessageView *)messageView
{
  [nLock lock];
  self.notificationActive = YES;
  [nLock unlock];
}

- (void)messageViewDidDismiss:(RMessageView *)messageView
{
  [mLock lock];
  if (self.messages.count > 0) {
    [self.messages removeObjectAtIndex:0];
  }
  [mLock unlock];

  [nLock lock];
  self.notificationActive = NO;
  [nLock unlock];

  [mLock lock];
  if (self.messages.count > 0) {
    [mLock unlock];
    [self presentMessageView];
    return;
  }
  [mLock unlock];
}

- (CGFloat)customVerticalOffsetForMessageView:(RMessageView *)messageView
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(customVerticalOffsetForMessageView:)]) {
    return [self.delegate customVerticalOffsetForMessageView:messageView];
  }
  return 0.f;
}

+ (void)interfaceDidRotate
{
  [mLock lock];
  if ([RMessage sharedMessage].messages.count == 0) {
    [mLock unlock];
    return;
  }
  [[RMessage sharedMessage].messages[0] interfaceDidRotate];
  [mLock unlock];
}

@end
