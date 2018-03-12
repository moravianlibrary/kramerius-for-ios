//
//  MZKGeneralViewController.swift
//  MZK_iOS
//  This class is Swift replacement of MZKBaseViewController.
//
//  Created by Ondrej Vyhlidal on 03/01/2018.
//  Copyright © 2018 Ondrej Vyhlidal. All rights reserved.
//

import UIKit
import SwiftMessages

class MZKGeneralViewController: UIViewController {
    /** Original objc methods
     -(void)showErrorWithCancelActionAndTitle:(NSString *)title subtitle:(NSString *)subtitle;
     -(void)showErrorWithTitle:(NSString *)title subtitle:(NSString *)subtitle confirmAction:(void (^)())actionBlock;
     -(void)showErrorWithCancelActionAndTitle:(NSString *)title subtitle:(NSString *)subtitle withCompletion:(void (^)())actionBlock;
     -(void)showTSMessageWithTitle:(NSString *)title subtitle:(NSString *)subtitle type:(TSMessageNotificationType)type;
     -(void)showTsErrorWithNSError:(NSError *)error andConfirmAction:(void (^)())actionBlock;
    */

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /// Show error - shows simple message to user
    ///
    /// - Parameters:
    ///   - title: optinal title
    ///   - subtitle: optional subtitle
    /// Replacement of  -(void)showErrorWithTitle:(NSString *)title subtitle:(NSString *)subtitle;
    func showError(title: String?, subtitle: String?) {

        if let t = title, let st = subtitle {

            let alert = UIAlertController.init(title: t, message: st, preferredStyle: .alert)

            let alertActionOk = UIAlertAction.init(title: "Ano", style: .default, handler: { (action) in
                alert .dismiss(animated: true, completion: nil)

            })

            alert.addAction(alertActionOk)

            let alertActionCancel = UIAlertAction.init(title: "Zrušit", style: .default, handler: { (action) in
                alert .dismiss(animated: true, completion: nil)
            })

            alert.addAction(alertActionCancel)

            self.present(alert, animated: true, completion: nil)
        }
    }

    /// Simple message for
    ///
    /// - Parameters:
    ///   - title: title
    ///   - subtitle: subtitle
    ///   - completion: completion
    func showErrorWithCancelActionAndTitle(title: String?, subtitle: String?, completion: @escaping () -> Void) {

        let alert = UIAlertController.init(title: title, message: subtitle, preferredStyle: .alert)

        let alertActionOk = UIAlertAction.init(title: "Ano", style: .default, handler: { (action) in
            alert .dismiss(animated: true, completion:nil)

        })

        alert.addAction(alertActionOk)

        self.present(alert, animated: true, completion: completion)
    }

    func showErrorWithCancelActionAndTitle(title: String, subtitle: String) {
        let alert = UIAlertController.init(title: title, message: subtitle, preferredStyle: .alert)

        let alertActionOk = UIAlertAction.init(title: "Ano", style: .default, handler: { (action) in
            alert .dismiss(animated: true, completion:nil)

        })

        alert.addAction(alertActionOk)

        self.present(alert, animated: true, completion: nil)
    }


    /// show error
    ///
    /// - Parameters:
    ///   - title: <#title description#>
    ///   - subtitle: <#subtitle description#>
    ///   - completion: <#completion description#>
    /// Replacement of: showErrorWithTitle:(NSString *)title subtitle:(NSString *)subtitle confirmAction:(void (^)())actionBlock
    func showErrorWithTitle(title: String?, subtitle: String?, completion: @escaping () -> Void) {

        let alert = UIAlertController.init(title: title, message: subtitle, preferredStyle: .alert)

        let alertActionOk = UIAlertAction.init(title: "Ano", style: .default, handler: { (action) in
            alert .dismiss(animated: true, completion: nil)
            completion()
        })

        alert.addAction(alertActionOk)

        let alertActionCancel = UIAlertAction.init(title: "Zrušit", style: .default, handler: { (action) in
            alert .dismiss(animated: true, completion: nil)
        })

        alert.addAction(alertActionCancel)

        self.present(alert, animated: true, completion: nil)

    }

    /// Ensures that SwiftMessages are congfigured properly.
    fileprivate func configureMessages() {
        // for now this method is fileprivate - we don't need any more configurations.
        SwiftMessages.defaultConfig.presentationStyle = .top
        SwiftMessages.defaultConfig.presentationContext = .viewController(self)
    }

    /// Basic method for show message. It uses our default style for presenting messages
    ///
    /// - Parameter text: Text of message
    func showMessage(title: String, subtitle: String) {
        // base configuration of SwiftMessages. This is just basic config. It can be extended when needed.
        configureMessages()

        // basic message style
        let messageView = MessageView.viewFromNib(layout: .messageView)
        messageView.configureTheme(backgroundColor: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), foregroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), iconImage: nil, iconText: nil)

        // hide button
        messageView.button?.isHidden = true
        // no title just text
        messageView.configureContent(title: title, body: subtitle)

        SwiftMessages.show(view:messageView)
    }


    func showMessage(error: NSError) {

        configureMessages()

        let title = NSLocalizedString("mzk.error", comment: "Error title of message box")
        var subtitle = ""
        var buttonTitle = ""

        switch (error.code) {
        case NSURLErrorUnknown:
            break
        case NSURLErrorBadURL:
            subtitle = NSLocalizedString("mzk.error.url.unknown", comment:"Unknown error")
            buttonTitle = NSLocalizedString("mzk.error.retry", comment:"Retry")
            break

        case NSURLErrorTimedOut:

            subtitle = NSLocalizedString("mzk.error.connectionTimeout", comment:"Pouzito v okamziku, kdy vyprsi timeout")

            buttonTitle = NSLocalizedString("mzk.error.retry", comment:"Retry")

            break
        case NSURLErrorUnsupportedURL:
            break
        case NSURLErrorCannotFindHost:

            subtitle = NSLocalizedString("mzk.error.unableToConnect", comment:"")

            buttonTitle = NSLocalizedString("mzk.error.retry", comment: "Retry")
            break

        case NSURLErrorCannotConnectToHost:

            subtitle = NSLocalizedString("mzk.error.unableToConnect", comment: "Cannot connect to host")

            buttonTitle = NSLocalizedString("mzk.error.retry", comment: "Retry")
            break

        case NSURLErrorNetworkConnectionLost:

            subtitle = NSLocalizedString("mzk.error.networkConnectionLost", comment: "Conection Lost")

            buttonTitle = NSLocalizedString("mzk.error.retry", comment: "Retry")
            break

        case NSURLErrorDNSLookupFailed:

            break
        case NSURLErrorHTTPTooManyRedirects:

            break
        case NSURLErrorResourceUnavailable:

            break
        case NSURLErrorNotConnectedToInternet:

            subtitle = NSLocalizedString("mzk.error.checkYourInternetConnection",comment: "Conection Lost")

            buttonTitle = NSLocalizedString("mzk.error.retry",comment: "Retry")
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

        let messageView = MessageView.viewFromNib(layout: .messageView)
        messageView.configureTheme(backgroundColor: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), foregroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), iconImage: nil, iconText: nil)

        // hide button
        messageView.button?.isHidden = true
        // no title just text
        messageView.configureContent(title: title, body: subtitle)

        SwiftMessages.show(view:messageView)

    }

}
