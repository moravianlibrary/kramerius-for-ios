//
//  MZKBaseViewController.m
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 28/11/15.
//  Copyright © 2015 Ondrej Vyhlidal. All rights reserved.
//

#import "MZKBaseViewController.h"


@interface MZKBaseViewController ()

@end

@implementation MZKBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showErrorWithCancelActionAndTitle:(NSString *)title subtitle:(NSString *)subtitle withCompletion:(void (^)())actionBlock
{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:title
                                  message:subtitle
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Ok"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:actionBlock];
    
}




-(void)showErrorWithCancelActionAndTitle:(NSString *)title subtitle:(NSString *)subtitle
{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:title
                                  message:subtitle
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Ok"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(void)showErrorWithTitle:(NSString *)title subtitle:(NSString *)subtitle confirmAction:(void (^)())actionBlock
{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:title
                                  message:subtitle
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"Ano"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             actionBlock();
                             NSLog(@"Action Block");
                             
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Zrušit"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(void)showErrorWithTitle:(NSString *)title subtitle:(NSString *)subtitle
{
    NSString *t = title ? title : @"Nastala chyba";
    NSString *st = subtitle ? subtitle : @"Nastal problem pri stahovani dat, chcete akci opakovat?";
    
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:t
                                  message:st
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"Ano"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Zrušit"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}



-(void)showTSMessageWithTitle:(NSString *)title subtitle:(NSString *)subtitle type:(TSMessageNotificationType)type
{
    // Add a button inside the message
    
    [TSMessage showNotificationWithTitle:title subtitle:subtitle type:type];
    
}

-(void)showTSMessageWithTitle:(NSString *)title subtitle:(NSString *)subtitle type:(TSMessageNotificationType)type buttonTitle:(NSString *)buttonTitle confirmAction:(void (^)())actionBlock
{
    // Add a button inside the message
    [TSMessage showNotificationInViewController:[TSMessage defaultViewController]
                                          title:title
                                       subtitle:subtitle
                                          image:nil
                                           type:type
                                       duration:TSMessageNotificationDurationAutomatic
                                       callback:nil
                                    buttonTitle:buttonTitle
                                 buttonCallback:^{
                                     NSLog(@"User tapped the button");
                                     actionBlock();
                                 }
                                     atPosition:TSMessageNotificationPositionTop
                           canBeDismissedByUser:YES];
    
}

-(void)showTSErrorWithCancelActionAndTitle:(NSString *)title subtitle:(NSString *)subtitle withCompletion:(void (^)())actionBlock
{
    
}

-(void)showTsErrorWithNSError:(NSError *)error andConfirmAction:(void (^)())actionBlock
{
    NSString *title;
    NSString *subtitle;
    NSString *buttonTitle;
    TSMessageNotificationDuration duration = TSMessageNotificationDurationAutomatic;
    
    // NSURLErrorDomain
    
    switch (error.code) {
        case NSURLErrorUnknown:
        case NSURLErrorBadURL:
            title = NSLocalizedString(@"mzk.error", @"Error title of message box");
            subtitle = NSLocalizedString(@"mzk.error.url.unknown", @"Unknown error");
            duration = TSMessageNotificationDurationEndless;
            buttonTitle = NSLocalizedString(@"mzk.error.retry", @"Retry");
            
            break;

        case NSURLErrorTimedOut:
            title = NSLocalizedString(@"mzk.error", @"Error title of message box");
            subtitle = NSLocalizedString(@"mzk.error.connectionTimeout", @"Pouzito v okamziku, kdy vyprsi timeout");
            duration = TSMessageNotificationDurationEndless;
            buttonTitle = NSLocalizedString(@"mzk.error.retry", @"Retry");
            
            break;
        case NSURLErrorUnsupportedURL:
            
            break;
        case NSURLErrorCannotFindHost:
            title = NSLocalizedString(@"mzk.error", @"Error title of message box");
            subtitle = NSLocalizedString(@"mzk.error.unableToConnect", @"");
            duration = TSMessageNotificationDurationEndless;
            buttonTitle = NSLocalizedString(@"mzk.error.retry", @"Retry");
            break;
            
        case NSURLErrorCannotConnectToHost:
            title = NSLocalizedString(@"mzk.error", @"Error title of message box");
            subtitle = NSLocalizedString(@"mzk.error.unableToConnect", @"Cannot connect to host");
            duration = TSMessageNotificationDurationEndless;
            buttonTitle = NSLocalizedString(@"mzk.error.retry", @"Retry");
            break;
            
        case NSURLErrorNetworkConnectionLost:
            title = NSLocalizedString(@"mzk.error", @"Error title of message box");
            subtitle = NSLocalizedString(@"mzk.error.networkConnectionLost", @"Conection Lost");
            duration = TSMessageNotificationDurationEndless;
            buttonTitle = NSLocalizedString(@"mzk.error.retry", @"Retry");
            break;

        case NSURLErrorDNSLookupFailed:
            
            break;
        case NSURLErrorHTTPTooManyRedirects:
            
            break;
        case NSURLErrorResourceUnavailable:
            
            break;
        case NSURLErrorNotConnectedToInternet:
            title = NSLocalizedString(@"mzk.error", @"Error title of message box");
            subtitle = NSLocalizedString(@"mzk.error.checkYourInternetConnection", @"Conection Lost");
            duration = TSMessageNotificationDurationEndless;
            buttonTitle = NSLocalizedString(@"mzk.error.retry", @"Retry");
            break;
            
        case NSURLErrorRedirectToNonExistentLocation:
            
            break;
        case NSURLErrorBadServerResponse:
            
            break;
        case NSURLErrorUserCancelledAuthentication:
            
            break;
        case NSURLErrorUserAuthenticationRequired:
            
            break;
        case NSURLErrorZeroByteResource:
            
            break;
        case NSURLErrorCannotDecodeRawData:
            
            break;
        case NSURLErrorCannotDecodeContentData:
            
            break;
        case NSURLErrorCannotParseResponse:
            
            break;
            
        default:
            break;
    }
    
    [TSMessage showNotificationInViewController:[TSMessage defaultViewController]
                                          title:title
                                       subtitle:subtitle
                                          image:nil
                                           type:TSMessageNotificationTypeError
                                       duration:duration
                                       callback:nil
                                    buttonTitle:buttonTitle
                                 buttonCallback:^{
                                     NSLog(@"User tapped the button");
                                     actionBlock();
                                 }
                                     atPosition:TSMessageNotificationPositionTop
                           canBeDismissedByUser:YES];
    
}







@end
