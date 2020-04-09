//
//  MZKPageViewController.swift
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 26/10/2016.
//  Copyright © 2016 Ondrej Vyhlidal. All rights reserved.
//

import UIKit

@objc
class MZKPageViewController: UIViewController {
    
    // public properties
    var itemPID: String!
    var item: MZKItemResource!
    var page: MZKPageObject!
    var currentPagePID: String!

    var childViewController: MZKPageDetailViewController?

    var userActivityDelegate: MZKUserActivityDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Page view controller view did load")

        let pageVC: MZKPageDetailViewController = UIStoryboard(name: "MZKDetail", bundle: nil) .
            instantiateViewController(withIdentifier: "MZKPageDetailViewController") as! MZKPageDetailViewController

        pageVC.pagePID = itemPID
        pageVC.userActivityDelegate = userActivityDelegate
        addChild(pageVC)
        view.addSubviewWithConstraintsToEdges(pageVC.view)

        childViewController = pageVC
    }

    // MARK: -

    public func displaySinglePage(pagePID: String) {
        let child = newPageViewController(pagePID)
        childViewController = child
    }

    private func newPageViewController(_ itemPID: String) -> MZKPageDetailViewController {
        let pageVC: MZKPageDetailViewController = UIStoryboard(name: "MZKDetail", bundle: nil) .
            instantiateViewController(withIdentifier: "MZKPageDetailViewController") as! MZKPageDetailViewController

        pageVC.pagePID = itemPID

        pageVC.userActivityDelegate = nil
        
        return pageVC
    }

    func setUpForPDF(item:MZKItemResource) {
        print("📖 Setup for PDF")
        guard let tmpVC = childViewController else { return }
        tmpVC.pdfURL = item.pdfUrl
        tmpVC.showPDFFile(item: item)
    }
}
