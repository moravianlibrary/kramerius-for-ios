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

    @IBOutlet weak var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadWebView()
    }

    func loadWebView() {
        guard let url = URL(string: "http://www.digitalniknihovna.cz/") else { return }
        let request = URLRequest(url: url)

        webView.load(request)
    }
}

