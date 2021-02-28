//
//  ViewController.swift
//  Kramerius
//
//  Created by Ondrej Vyhlidal on 12/10/2020.
//  Copyright © 2020 MZK. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!

    private var externalHosts = [
        "twitter.com",
        "pinterest.com",
        "facebook.com",
        "kramerius-edu.lib.cas.cz",
        "kramerius-vs.techlib.cz",
        "dnnt.mzk.cz",
        "ndk.cz"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupWebView()
    }

    private func setupWebView() {
        let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(webView)
        let constraints = [webView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        webView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        webView.topAnchor.constraint(equalTo: contentView.topAnchor),
        webView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)]

        NSLayoutConstraint.activate(constraints)

        guard let url = URL(string: "https://webview.digitalniknihovna.cz/") else { return }
        let request = URLRequest(url: url)

        webView.load(request)
    }
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, let host = url.host, externalHosts.contains(host),
           UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                // Fallback on earlier versions
                // for versions below iOS 10
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.openURL(url)
                }
            }
            print("Redirected to browser. No need to open it locally")
            decisionHandler(.cancel)
        } else {
            print("Open it locally")
            decisionHandler(.allow)
        }
    }
}

