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

protocol MZKUserActivityDelegate :class {
    
    
    /**
     Method that notifies delegate about user activity - single tap gesture recognizer
     */
    
    func userDidSingleTapped()
    func nextPage()
    func previousPage()
}


class MZKPageDetailViewController: UIViewController, XMLParserDelegate {
    
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
    @IBOutlet weak var zoomifyIIIFReaderScrollView: ITVScrollView!
    
    @IBOutlet weak var pdfReaderViewContainer: UIView!
    @IBOutlet weak var pdfWebView: UIWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // load page resolution for current PID
        
        self .loadImageProperties()
        self.imageReaderScrollView.delegate = self
        
       // self.zoomifyIIIFReaderScrollView.ITVScrollViewDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if(!self.zoomifyIIIFReaderScrollView.isHidden)
        {
            //self.zoomifyIIIFReaderScrollView.zoomToScale(1.0, animated: false)
            self.zoomifyIIIFReaderScrollView.refreshTiles()
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
        
        
        guard let url = URL(string: aStr) else {
            print("Error: cannot create URL")
            return
        }
        
        
        let urlRequest = URLRequest(url: url as URL)
        
        let config = URLSessionConfiguration.default
        let session = Foundation.URLSession(configuration: config)
        
        let task = session.dataTask(with: urlRequest as URLRequest, completionHandler: { (data, response, error) in
            // ...
            
            if let httpResponse = response as? HTTPURLResponse {
                print("error \(httpResponse.statusCode)")
                
                let errorCode:HTTPStatusCode = HTTPStatusCode(rawValue: httpResponse.statusCode)!
                
                switch errorCode {
                // ugly hack as hell!!!!
                // status 500 means that we should display resource as JPG instead of ZOOMify or IIIF protocol ... WTF?!
                case HTTPStatusCode.internalServerError:
                    self.imagePropertiesFailedToDownload()
                    break
                    
                default: break
                    
                }
                
                if error != nil {
                    print(error!.localizedDescription)
                    self.imagePropertiesFailedToDownload()
                }
                else
                {
                    
                    if data == nil {
                        
                        return
                    }
                    
                    //xml parser init
                    self.xmlParser = XMLParser(data: data!)
                    self.xmlParser.delegate = self
                    self.xmlParser.parse()
                    
                }
                
            }
        })
        
        task.resume()
        
    }
    
    func imagePropertiesFailedToDownload()
    {
        print("image properties failed to download")
        
        // try to load image thru sdwebimage
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let libraryItem : MZKLibraryItem! = appDelegate.getDatasourceItem();
        let heightScale = String(describing: Int(self.view.bounds.size.height*2))
        
        let imageStrUrl = String(format: "%@/search/img?pid=%@&stream=IMG_FULL&action=SCALE&scaledHeight=%@", libraryItem.url , pagePID, heightScale)
        
        let url = NSURL(string: imageStrUrl)
        
//        imageReaderImageView.sd_setImage(with: url as URL!, placeholderImage: nil, options: [.continueInBackground, .progressiveDownload]) { (image, error, , <#URL?#>) in
//            
//        }
//        
//        imageReaderImageView.sd_setImage(with: url as URL!) { (nil, error, , url) in
//            // IF there is no IMAGE! -> PDF file
//            
//           
//        }
        
        
        SDWebImageManager.shared().imageDownloader?.downloadImage(with: url as URL!, options: SDWebImageDownloaderOptions.allowInvalidSSLCertificates, progress: { (min, max, url) in
            print("loading……")
        }, completed: { (image, data, error, finished) in
            if image != nil {
                self.activityIndicator.stopAnimating()
                self.imageReaderScrollView.maximumZoomScale = 2.0
                self.imageReaderScrollView.zoomScale = 1.0
                self.imageReaderScrollView.minimumZoomScale = 0.5
                
                
                let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.didTap(event:)))
                tapGestureRecognizer.numberOfTapsRequired = 1
                tapGestureRecognizer.cancelsTouchesInView = false
                
                self.imageReaderScrollView.addGestureRecognizer(tapGestureRecognizer)

            } else {
                print("wrong")
            }
        })
        
        
//        imageReaderImageView.sd_setImage(with: url as URL!, placeholderImage: nil, options: [.continueInBackground, .progressiveDownload], progress:{[weak self](receivedSize, expectedSize) -> Void in}, completed:{[(image, data, error, finished)-> Void in
//            // body of completion block
//            
//            // IF there is no IMAGE! -> PDF file
//            
//            self!.activityIndicator.stopAnimating()
//            self!.imageReaderScrollView.maximumZoomScale = 2.0
//            self!.imageReaderScrollView.zoomScale = 1.0
//            self!.imageReaderScrollView.minimumZoomScale = 0.5
//            
//            
//            let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self!.didTap(event:)))
//            tapGestureRecognizer.numberOfTapsRequired = 1
//            tapGestureRecognizer.cancelsTouchesInView = false
//            
//            self!.imageReaderScrollView.addGestureRecognizer(tapGestureRecognizer)
//        })
        
    }
    
    // MARK: xml parser delegate methods
    
    func parserDidStartDocument(_ parser: XMLParser)
    {
        
    }
    
    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String : String] = [:])
    {
        
        if (elementName as NSString).isEqual(to: "IMAGE_PROPERTIES")
        {
            print(attributeDict)
            self.imageWidth =  Int(attributeDict["WIDTH"]!)
            self.imageHeight =   Int(attributeDict["HEIGHT"]!)
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        
        if ((self.imageWidth != nil) && (self.imageHeight != nil)) {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let libraryItem : MZKLibraryItem! = appDelegate.getDatasourceItem();
            
            let imageURL = String(format: "%@/search/zoomify/%@/ImageProperties.xml", libraryItem.url , pagePID)
            
            
            self.zoomifyIIIFReaderScrollView.loadImage(imageURL, api: ITVImageAPI.Unknown)
            
            let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.didTap(event:)))
            tapGestureRecognizer.numberOfTapsRequired = 1
            tapGestureRecognizer.cancelsTouchesInView = false
            
            self.zoomifyIIIFReaderScrollView.addGestureRecognizer(tapGestureRecognizer)
            
            DispatchQueue.main.async (execute: { () -> Void in
                
                self.imageReaderContainerView.isHidden = true
                self.zoomifyIIFContainerView.isHidden = false
                self.activityIndicator.stopAnimating()
            })
        }
    }
    
    func didTap(event: UITouch) {
        let location = event.location(in: self.zoomifyIIIFReaderScrollView)
        let distanceLeft = self.zoomifyIIIFReaderScrollView.frame.width / 5
        let distanceRight = self.zoomifyIIIFReaderScrollView.frame.width - distanceLeft
        if location.x < distanceLeft {
            
            //previous page
            userActivityDelegate?.previousPage()
        } else if location.x > distanceRight {
            
            // next page
            userActivityDelegate?.nextPage()
        }
        else
        {
            userActivityDelegate?.userDidSingleTapped()
        }
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





