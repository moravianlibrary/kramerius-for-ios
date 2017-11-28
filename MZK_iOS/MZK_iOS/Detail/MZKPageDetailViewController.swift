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
import SWXMLHash

protocol MZKUserActivityDelegate :class {
    
    
    /**
     Method that notifies delegate about user activity - single tap gesture recognizer
     */
    
    func userDidSingleTapped()
    func nextPage()
    func previousPage()
}


class MZKPageDetailViewController: UIViewController, XMLParserDelegate, ITVScrollViewGestureDelegate {
    
    var pagePID : String!
    var xmlParser : XMLParser!
    var imageWidth : Int!
    var imageHeight : Int!
    var pageIndex : Int!
    var pdfURL : String!
    
    weak var userActivityDelegate : MZKUserActivityDelegate?
    
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
        // load page resolution for current PID
        self.imageReaderScrollView.delegate = self
        self.iTVReaderView.itvDelegate = self
        iTVReaderView.itvGestureDelegate = self
        iTVReaderView.canCancelContentTouches = false
        
        // self .loadImageProperties()
        self.imageSizeLoaded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if(!self.iTVReaderView.isHidden)
        {
            //self.zoomifyIIIFReaderScrollView.zoomToScale(1.0, animated: false)
            self.iTVReaderView.refreshTiles()
        }
    }
    
    
    func showPDFFile(item:MZKItemResource) -> Void {
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
    
    func loadImageProperties() {
        
        activityIndicator.startAnimating()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let libraryItem : MZKLibraryItem! = appDelegate.getDatasourceItem();
        
        let aStr = String(format: "%@/search/zoomify/%@/ImageProperties.xml", libraryItem.url , pagePID)
        
        getResponseFromURL(url: aStr)
    }
    
    /**
     * Func that makes request for specified URLs using Alamofire library
     */
    func getResponseFromURL(url : String) {
        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil)
            .response() { response in
                guard let statusCode = response.response?.statusCode else {
                    return
                }
                print("response code \(statusCode)")
                
                if (statusCode >= 200 && statusCode < 300) {
                    //   xml parser init
                    let xml = SWXMLHash.parse(response.data!)
                    let width = xml["IMAGE_PROPERTIES"].element?.attribute(by:"WIDTH")
                    let height = xml["IMAGE_PROPERTIES"].element?.attribute(by: "HEIGHT")
                    
                    self.imageWidth = Int((width?.text)!)
                    self.imageHeight = Int((height?.text)!)
                    
                    DispatchQueue.main.async { [weak self] in
                        self?.imageSizeLoaded()
                    }
                    
                } else if (statusCode > 400) {
                    DispatchQueue.main.async { [weak self] in
                        self?.imagePropertiesFailedToDownload()
                    }
                }
        }
    }
    
    /// Called only when image properties failed to donwload a we should display image as JPG
    func imagePropertiesFailedToDownload()
    {
        // try to load image thru sdwebimage
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let libraryItem : MZKLibraryItem! = appDelegate.getDatasourceItem();
        let heightScale = String(describing: Int(self.view.bounds.size.height*2))
        
        let imageStrUrl = String(format: "%@/search/img?pid=%@&stream=IMG_FULL&action=SCALE&scaledHeight=%@", libraryItem.url , pagePID, heightScale)
        
        let url = URL(string: imageStrUrl)
        
        imageReaderImageView.sd_setImage(with: url, placeholderImage: nil, options: []) { (image, error, cacheType, url) in
            DispatchQueue.main.async { [weak self] in
                self?.imageLoaded()
            }
        }
    }
    
    func imageLoaded() {
//        self.activityIndicator.stopAnimating()
//        self.imageReaderScrollView.maximumZoomScale = 2.0
//        self.imageReaderScrollView.zoomScale = 1.0
//        self.imageReaderScrollView.minimumZoomScale = 0.5
//
//        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.didTap(event:)))
//        tapGestureRecognizer.numberOfTapsRequired = 1
//        tapGestureRecognizer.cancelsTouchesInView = false
//
//        self.imageReaderScrollView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func imageSizeLoaded() {
        
        //  if ((self.imageWidth != nil) && (self.imageHeight != nil)) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let libraryItem : MZKLibraryItem! = appDelegate.getDatasourceItem();
        
        let imageURL = String(format: "%@/search/zoomify/%@/ImageProperties.xml", libraryItem.url , pagePID)
        
        iTVReaderView.loadImage(imageURL, api: ITVImageAPI.Raw)
        
        DispatchQueue.main.async (execute: { () -> Void in
            
            self.imageReaderContainerView.isHidden = true
            self.zoomifyIIFContainerView.isHidden = false
            self.activityIndicator.stopAnimating()
        })
        // }
    }
    
    
    func onShowHideBars(_ sender: UITapGestureRecognizer) -> Void {
        
        userActivityDelegate?.userDidSingleTapped()
    }
    
    // MARK : zooming methods
    private func updateMinZoomScaleForSize(size: CGSize) {
        let widthScale = size.width / imageReaderImageView.bounds.width //CGFloat(self.imageWidth)
        let heightScale = size.height / imageReaderImageView.bounds.height //CGFloat(self.imageHeight)
        let minScale = min(widthScale, heightScale)
        
        imageReaderScrollView.minimumZoomScale = minScale
        
        imageReaderScrollView.zoomScale = minScale
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateMinZoomScaleForSize(size: view.bounds.size)
    }
    
    func didTap(event: UITouch) {
        let location = event.location(in: self.iTVReaderView)
        let distanceLeft = self.iTVReaderView.frame.width / 5
        let distanceRight = self.iTVReaderView.frame.width - distanceLeft
        if location.x < distanceLeft {
            //previous page
            // userActivityDelegate?.previousPage()
        } else if location.x > distanceRight {
            
            // next page
            //   userActivityDelegate?.nextPage()
        }
        else
        {
            userActivityDelegate?.userDidSingleTapped()
        }
    }
    
    func didTap(type: ITVGestureEventType, location: CGPoint) {
        print(type.rawValue)
        if type == ITVGestureEventType.singleTap {
            
            print("Location: ", location)
            let approximatedX = location.x
            //            if(self.zoomifyIIIFReaderScrollView.zoomScale > 2)
            //            {
            //                approximatedX = approximatedX / (zoomifyIIIFReaderScrollView.zoomScale/2)
            //            }
            
            print( "width: ", self.view.bounds.width)
            
            let leftBandWidth  = self.view.bounds.width / 4
            let rightBandOffset = self.view.bounds.width - leftBandWidth
            
            print("Left: ", leftBandWidth, "Right: ", rightBandOffset, "ApproximatedX: ", approximatedX)
            
            if self.iTVReaderView.zoomScale > 2 {
                
                if approximatedX <= leftBandWidth {
                    print ("left, previous page")
                    //previous page
                    userActivityDelegate?.previousPage()
                } else if approximatedX >= rightBandOffset {
                    print("right, next page")
                    // next page
                    userActivityDelegate?.nextPage()
                }
                else
                {
                    print ("single tap, middle = show/hide bars")
                    userActivityDelegate?.userDidSingleTapped()
                }
            }
        }
        
    }
}

extension MZKPageDetailViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageReaderImageView
    }
}

extension MZKPageDetailViewController : UIWebViewDelegate
{
    func webViewDidFinishLoad(_ webView: UIWebView)
    {
        self.activityIndicator.stopAnimating()
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
    }
}

extension MZKPageDetailViewController : ITVScrollViewDelegate
{
    func didFinishLoading(error: NSError?)
    {
        self.activityIndicator.stopAnimating()
        if (error != nil) {
            DispatchQueue.main.async (execute: { () -> Void in
                
                print(error?.description)
                MZKSwiftErrorMessageHandler().showTSMessage(viewController: self, title: "Error".localizedWithComment(comment: "When error occures"), subtitle: "mzk.error.checkYourInternetConnection".localizedWithComment(comment: ""), completion: {(_) -> Void in
                })
            })
        }
    }
    
    func errorDidOccur(error: NSError)
    {
        DispatchQueue.main.async (execute: { () -> Void in
            MZKSwiftErrorMessageHandler().showTSMessageTest(viewController: self, error: error as NSError, completion: {(_) -> Void in
            })
        })
    }
}





