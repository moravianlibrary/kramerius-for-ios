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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        guard let serverUrl = Bundle.main.object(forInfoDictionaryKey: "ServerURL") as? String else { return }

        if let baseUrl = URL(string: serverUrl) {
            setupWebView(url: baseUrl)
        }
    }

    private func setupWebView(url: URL) {
        let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(webView)
        let constraints = [webView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        webView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        webView.topAnchor.constraint(equalTo: contentView.topAnchor),
        webView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)]

        NSLayoutConstraint.activate(constraints)

        let request = URLRequest(url: url)

        webView.load(request)
    }
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let serverUrl = Bundle.main.object(forInfoDictionaryKey: "ServerURL") as? String, let baseUrl = URL(string: serverUrl) else { return }

        var requestTarget: String? = ""
        if let url = navigationAction.request.url, let host = url.host {
            if host.contains("www.") {
                let clean = host.replacingOccurrences(of: "www.", with: "")
                requestTarget = clean
            } else {
                requestTarget = host
            }
        }

        if let url = navigationAction.request.url, let host = requestTarget, baseUrl.host != host,
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

