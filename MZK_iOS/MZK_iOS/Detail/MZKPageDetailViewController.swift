//
//  MZKPageDetailViewController.swift
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 26/10/2016.
//  Copyright © 2016 Ondrej Vyhlidal. All rights reserved.
//

import UIKit
import SDWebImage
import iOSTiledViewer
import Alamofire

protocol MZKUserActivityDelegate: class {
    /**
     Method that notifies delegate about user activity - single tap gesture recognizer
     */
    func userDidSingleTapped()
    func nextPage()
    func previousPage()
}


class MZKPageDetailViewController: UIViewController, XMLParserDelegate, ITVScrollViewGestureDelegate {
    
    var pagePID: String?

    var pageIndex: Int!
    var pdfURL: String!
    
    weak var userActivityDelegate: MZKUserActivityDelegate?
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var imageReaderContainerView: UIView!
    @IBOutlet weak var zoomifyIIFContainerView: UIView!
    
    @IBOutlet weak var imageReaderScrollView: UIScrollView!
    @IBOutlet weak var imageReaderImageView: UIImageView!
    
    @IBOutlet weak var imageReaderViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageReaderViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageReaderViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageReaderViewTrailingConstraint: NSLayoutConstraint!
    // this should be refactored with xcode 9 - lower versions cannot do swift refactors
    @IBOutlet weak var iTVReaderView: ITVScrollView!
    
    @IBOutlet weak var pdfReaderViewContainer: UIView!
    @IBOutlet weak var pdfWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // hide others
        imageReaderContainerView.isHidden = true
        pdfReaderViewContainer.isHidden = true

        // load page resolution for current PID
        imageReaderScrollView.delegate = self
        iTVReaderView.itvDelegate = self
        iTVReaderView.itvGestureDelegate = self
        iTVReaderView.canCancelContentTouches = false

        loadImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(!self.iTVReaderView.isHidden) {
            iTVReaderView.zoomToScale(1.0, animated: false)
            iTVReaderView.refreshTiles()
        }
    }

    func showPDFFile(item: MZKItemResource) -> Void {
        self.pdfURL = item.pdfUrl
        self.zoomifyIIFContainerView.isHidden = true
        self.imageReaderContainerView.isHidden = true
        self.pdfReaderViewContainer.isHidden = false
        
        let targetURL = URL(string:self.pdfURL )
        let request = URLRequest(url:targetURL!)
        self.pdfWebView.delegate = self
        self.pdfWebView.loadRequest(request)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Load image to ITVReaderScrollView
    func loadImage() {
        guard let pagePid = pagePID else { return }

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let libraryItem: MZKLibraryItem! = appDelegate.getDatasourceItem()
        
        let imageURL = String(format: "%@/search/zoomify/%@/ImageProperties.xml", libraryItem.url , pagePid)
        
        iTVReaderView.loadImage(imageURL, api: .Unknown)
        DispatchQueue.main.async (execute: {[weak self] () -> Void in
            guard let strongSelf = self else { return }
            strongSelf.imageReaderContainerView.isHidden = true
            strongSelf.zoomifyIIFContainerView.isHidden = false
            strongSelf.showLoading()
        })
    }

    private func showLoading() {
        view.bringSubviewToFront(activityIndicator)
        activityIndicator.startAnimating()
    }

    private func hideLoading() {
        activityIndicator.stopAnimating()
        view.sendSubviewToBack(activityIndicator)
    }
    
    func onShowHideBars(_ sender: UITapGestureRecognizer) {
        userActivityDelegate?.userDidSingleTapped()
    }
    
    // MARK : zooming methods
    private func updateMinZoomScaleForSize(size: CGSize) {
        let widthScale = size.width / imageReaderImageView.bounds.width
        let heightScale = size.height / imageReaderImageView.bounds.height
        let minScale = min(widthScale, heightScale)
        
        imageReaderScrollView.minimumZoomScale = minScale
        
        imageReaderScrollView.zoomScale = minScale
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateMinZoomScaleForSize(size: view.bounds.size)
    }

    func didTap(type: ITVGestureEventType, location: CGPoint) {
        switch type {
        case .singleTap:
            let left = CGFloat(50)
            let right = self.view.frame.size.width - 50
            if location.x <= left {
                userActivityDelegate?.previousPage()
            } else if location.x >= left && location.x <= right {
                userActivityDelegate?.userDidSingleTapped()
            } else {
                userActivityDelegate?.nextPage()
            }
        case .doubleTap:
            break
        }
    }
}

extension MZKPageDetailViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageReaderImageView
    }
}

extension MZKPageDetailViewController : UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.activityIndicator.stopAnimating()
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
    }
}

/// Extension - error messages
extension MZKPageDetailViewController: ITVScrollViewDelegate {
    func didFinishLoading(error: NSError?) {
        hideLoading()

        if let _ = error {
            // not able to load image - SDWebImageLoad?
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let libraryItem : MZKLibraryItem! = appDelegate.getDatasourceItem();

            guard let pagePID = self.pagePID else { return }
            let height = String(describing: Int(self.view.bounds.size.height*2))

            let imageStrUrl = String(format: "%@/search/img?pid=%@&stream=IMG_FULL&action=SCALE&scaledHeight=%@", libraryItem.url , pagePID, height)

            iTVReaderView.loadImage(imageStrUrl, api: .Raw)
        } else {
            if error != nil {
                // TODO: messages
                print(error?.description)
            }
        }
    }

    func errorDidOccur(error: NSError) {
        DispatchQueue.main.async (execute: { () -> Void in
            MZKSwiftErrorMessageHandler().showTSMessageTest(viewController: self, error: error as NSError, completion: nil)
        })
    }
}
