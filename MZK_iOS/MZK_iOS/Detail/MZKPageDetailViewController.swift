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


class MZKPageDetailViewController: UIViewController, XMLParserDelegate {
    
    var pagePID : String!
    var xmlParser : XMLParser!
    var imageWidth : Int!
    var imageHeight : Int!
    var pageIndex : Int!
    
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        // load page resolution for current PID
        
       print(pagePID)
        self .loadImageProperties()
        
       // self.zoomifyIIIFReaderScrollView.errorDelegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadImageProperties() {
        
        activityIndicator.startAnimating()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let libraryItem : MZKLibraryItem! = appDelegate.getDatasourceItem();
        
        let aStr = String(format: "%@://%@/search/zoomify/%@/ImageProperties.xml", libraryItem.protocol, libraryItem.stringURL , pagePID)
        
        
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
        
        let imageStrUrl = String(format: "%@://%@/search/img?pid=%@&stream=IMG_FULL&action=SCALE&scaledHeight=%@", libraryItem.protocol, libraryItem.stringURL , pagePID, heightScale)
        
        print(imageStrUrl)

        let url = NSURL(string: imageStrUrl)
    
        imageReaderImageView.sd_setImage(with: url as URL!, placeholderImage: nil, options: [.continueInBackground, .progressiveDownload], progress:{[weak self](receivedSize, expectedSize) -> Void in}, completed:{[weak self] (image, data, error, finished)-> Void in
        // body of completion block
            
            self!.activityIndicator.stopAnimating()
        })
        
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
            print("Parsing Finished")
            
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        
        if ((self.imageWidth != nil) && (self.imageHeight != nil)) {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let libraryItem : MZKLibraryItem! = appDelegate.getDatasourceItem();
            
            let imageURL = String(format: "%@://%@/search/zoomify/%@/ImageProperties.xml", libraryItem.protocol, libraryItem.stringURL , pagePID)

            
            self.zoomifyIIIFReaderScrollView.loadImage(imageURL)
            
            DispatchQueue.main.async (execute: { () -> Void in
                
               self.imageReaderContainerView.isHidden = true
               self.zoomifyIIFContainerView.isHidden = false
                self.activityIndicator.stopAnimating()
            })
        }
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
    @nonobjc func viewForZoomingInScrollView(_ scrollView: UIScrollView) -> UIView? {
        return imageReaderImageView
    }
}





