//
//  MZKSwiftErrorMessageHandler.swift
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 04/12/2016.
//  Copyright © 2016 Ondrej Vyhlidal. All rights reserved.
//

import UIKit
import TSMessages


class MZKSwiftErrorMessageHandler: NSObject {
    
    
    public func showTSMessageTest(viewController:UIViewController, error: NSError, completion:(() -> Void)?) -> Void {
        
      //  let code = (error as NSError).code
        
//        mzk.error" = "Error";
//        "mzk.error.url.unknown" = "Unknown error occured";
//        "mzk.error.requestCancelled" = "Request canceled";
//        "mzk.error.connectionTimeout" = "Connection timeout";
//        "mzk.error.unableToConnect" = "Unable to connect check you internet connection";
//        "mzk.error.unsupportedURL" = "Unsupported URL";
//        "mzk.error.networkConnectionLost" = "Network connection lost";
//        "mzk.error.checkYourInternetConnection" = "Check your internet connection";
//        "mzk.error.retry" = "Retry";
//        "mzk.error.cancel" = "Cancel";
//        
//        "mzk.error.coulNotFind" = "Could not find";
//        "mzk.error.noRecordsFound" = "No search results found";
//
//        
        var title:String!
        var subtitle:String!
        var duration:TSMessageNotificationDuration!
        var buttonTitle:String!
        
        switch (error.code) {
        case NSURLErrorUnknown:
            title = "Error".localizedWithComment(comment: "Error title of message box")
            subtitle = "Unknown error occured".localizedWithComment(comment:"Unknown error")
            duration = TSMessageNotificationDuration.endless
            buttonTitle = "Retry".localizedWithComment(comment: "Retry")
            break
        case NSURLErrorBadURL:
            title = "Error".localizedWithComment(comment: "Error title of message box")
            subtitle = "Unknown error occured".localizedWithComment(comment:"Unknown error")
            duration = TSMessageNotificationDuration.endless
            buttonTitle = "Retry".localizedWithComment(comment: "Retry")
            break
            
        case NSURLErrorTimedOut:
           title = "Error".localizedWithComment(comment: "Error title of message box")
           subtitle = "Connection timeout".localizedWithComment(comment: "Pouzito v okamziku, kdy vyprsi timeout")
            duration = TSMessageNotificationDuration.endless
             buttonTitle = "Retry".localizedWithComment(comment: "Retry")
            
            break
        case NSURLErrorUnsupportedURL:
            
            break
        case NSURLErrorCannotFindHost:
            title = "Error".localizedWithComment(comment: "Error title of message box")
            subtitle = "Unable to connect check you internet connection".localizedWithComment(comment: "")
            duration = TSMessageNotificationDuration.endless
             buttonTitle = "Retry".localizedWithComment(comment: "Retry")
            break
            
        case NSURLErrorCannotConnectToHost:
            title = "Error".localizedWithComment(comment: "Error title of message box")
            subtitle = "Unable to connect check you internet connection".localizedWithComment(comment: "")
            duration = TSMessageNotificationDuration.endless
            buttonTitle = "Retry".localizedWithComment(comment: "Retry")
            break
            
        case NSURLErrorNetworkConnectionLost:
            title = "Error".localizedWithComment(comment: "Error title of message box")
            subtitle = "Network connection lost".localizedWithComment(comment:"Conection Lost")
            duration = TSMessageNotificationDuration.endless
            buttonTitle = "Retry".localizedWithComment(comment: "Retry")
            break
            
        case NSURLErrorDNSLookupFailed:
            
            break
        case NSURLErrorHTTPTooManyRedirects:
            
            break
        case NSURLErrorResourceUnavailable:
            
            break
        case NSURLErrorNotConnectedToInternet:
            title = "Error".localizedWithComment(comment: "Error title of message box")
            subtitle = "Check your internet connection".localizedWithComment(comment: "Conection Lost")
            duration = TSMessageNotificationDuration.endless
            buttonTitle = "Retry".localizedWithComment(comment: "Retry")
            break
            
        case NSURLErrorRedirectToNonExistentLocation:
            
            break
        case NSURLErrorBadServerResponse:
            
            break
        case NSURLErrorUserCancelledAuthentication:
            
            break
        case NSURLErrorUserAuthenticationRequired:
            
            break
        case NSURLErrorZeroByteResource:
            
            break
        case NSURLErrorCannotDecodeRawData:
            
            break
        case NSURLErrorCannotDecodeContentData:
            
            break
        case NSURLErrorCannotParseResponse:
            
            break
            
        default:
            break
        }
    
        
        if (title == nil) {
            title = "Error".localizedWithComment(comment: "Error title of message box")
        }
        
        if subtitle == nil {
            subtitle = "Unknown error occured".localizedWithComment(comment:"Unknown error")
        }
        
        if buttonTitle == nil {
             buttonTitle = "Retry".localizedWithComment(comment: "Retry")
        }
    
        duration = TSMessageNotificationDuration.endless
   

    
        TSMessage.showNotification(in: viewController,
                                   title: title,
                                   subtitle: subtitle,
                                   image: nil,
                                   type: TSMessageNotificationType.error,
                                   duration: 150, //TimeInterval(TSMessageNotificationDuration.endless.rawValue),
                                   callback: nil,
                                   buttonTitle: buttonTitle,
                                   buttonCallback:completion,
                                   at: TSMessageNotificationPosition.top,
                                   canBeDismissedByUser: true)
    }
    
    public func showTSMessage(viewController:UIViewController, title: String, subtitle: String, completion:(() -> Void)?) -> Void {
        
        var buttonTitle:String!
        
        buttonTitle = "Retry".localizedWithComment(comment: "Retry")
        
        
        TSMessage.showNotification(in: viewController,
                                   title: title,
                                   subtitle: subtitle,
                                   image: nil,
                                   type: TSMessageNotificationType.error,
                                   duration: 150, //TimeInterval(TSMessageNotificationDuration.endless.rawValue),
            callback: nil,
            buttonTitle: buttonTitle,
            buttonCallback:completion,
            at: TSMessageNotificationPosition.top,
            canBeDismissedByUser: true)
    }


}

extension String {
    func localizedWithComment(comment:String) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: comment)
    }
}
