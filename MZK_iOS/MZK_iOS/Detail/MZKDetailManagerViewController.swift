//
//  MZKDetailManagerViewController.swift
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 02/11/2016.
//  Copyright © 2016 Ondrej Vyhlidal. All rights reserved.
//

import UIKit



class MZKDetailManagerViewController: UIViewController, DataLoadedDelegate, PageIndexDelegate {
    
    @IBOutlet weak var topBarTopConstant: NSLayoutConstraint!
    @IBOutlet weak var bottomBarBottomConstant: NSLayoutConstraint!
    @IBOutlet weak var onHideShow: UIButton!
    @IBOutlet weak var currentPageNumber: UILabel!
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var pageThumbnails: UIButton!
    @IBOutlet weak var pageSlider: UISlider!
    @IBOutlet weak var pageThumbnailView: UIView!
    
    @IBOutlet weak var pageThumbnailsCollectionView: UICollectionView!
    // close can be used for initialize with params ...
    lazy private var mzkDatasource : MZKDatasource = {
        return MZKDatasource()
    }()
    
    var itemPID:String!
    var pages:[MZKPageObject]!
    var childVC:MZKPageViewController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.loadPages(pid: itemPID)
        self.pageSlider.minimumValue = 0
        self.pageSlider.value = 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "ShowPageViewController"
        {
            if let destinationVC = segue.destination as? MZKPageViewController {
                destinationVC.itemPID = self.itemPID
                // destinationVC.pagesLoadedDelegate = self
                childVC = destinationVC
                childVC.pageIndexDelegate = self
                
                self.addChildViewController(destinationVC)
            }
        }
    }
    
    // MARK : actions
    @IBAction func onAction(_ sender: Any) {
        self.topBarTopConstant.constant = -50
        self.bottomBarBottomConstant.constant = -50
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        
    }
    @IBAction func onShowInformation(_ sender: Any) {
        
        // MZKDetailInformationViewController
        
//        let storyboard = UIStoryboard(name: "MZKDetail", bundle: nil)
//        let controller = storyboard.instantiateViewController(withIdentifier: "MZKDetailInformationViewController") as! MZKDetailInformationViewController
//        
//        
//        self.present(controller, animated: true, completion: nil)
        
        
    }
    
    @IBAction func onShowThumbnails(_ sender: Any) {
        pageThumbnailView.isHidden = !pageThumbnailView.isHidden
        
    }
    @IBAction func onClose(_ sender: Any) {
        
        self.presentingViewController?.dismiss(animated: true, completion:nil)
    }
    // MARK: - Loading of pages
    
    func loadPages(pid:String) -> () {
        mzkDatasource.delegate = self
        mzkDatasource .getChildrenForItem(pid)
    }
    
    
    func children(forItemLoaded items: [Any]!) {
        pages = items as! [MZKPageObject]!
        childVC .pagesLoaded(pages: pages)
        
        
        DispatchQueue.main.async (execute: { () -> Void in
            self.currentPageNumber.text = "\(self.childVC.currentIndex)/\(self.pages.count)"
            self.pageThumbnailsCollectionView.reloadData()
            
        })
    }
    
    // MARK other methods
    
    
    /**
     Called when the number of pages is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter count: the total number of pages.
     */
    func pageIndexDelegate(pageIndexDelegate: PageIndexDelegate,
                           didUpdatePageCount count: Int)
    {
        
    }
    
    /**
     Called when the current index is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter index: the index of the currently visible page.
     */
    func pageIndexDelegate(pageIndexDelegate: PageIndexDelegate,
                           didUpdatePageIndex index: Int)
    {
        DispatchQueue.main.async (execute: { () -> Void in
            self.currentPageNumber.text = "\(index)/\(self.pages.count)"
            
        })
        
    }
    
    public func goToPage(index: Int) {
        if index < pages.count {
            childVC.goToPage(index: index)
        }
    }
    
}

extension MZKDetailManagerViewController : UICollectionViewDelegate
{
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.goToPage(index: indexPath.row)
        self .onShowThumbnails(Any.self)
    }
    
    
}

extension MZKDetailManagerViewController : UICollectionViewDataSource
{
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if (pages != nil) {
            return pages.count
        }
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MZKPageDetailCollectionViewCell",
                                                      for: indexPath) as! MZKPageDetailCollectionViewCell
        // Configure the cell
        
        let pageObject = pages[indexPath.row]
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let libraryItem : MZKLibraryItem! = appDelegate.getDatasourceItem();
        
        let thumbURL = String(format:"%@://%@/search/api/v5.0/item/%@/thumb", libraryItem.protocol, libraryItem.stringURL, pageObject.pid)
        
        
        cell.pageNumber.text = pageObject.title
        
        cell.pageThumbnail .sd_setImage(with: NSURL(string: thumbURL) as URL!)
        
        cell.page = pageObject
        
        return cell
    }
    
   

    
}

