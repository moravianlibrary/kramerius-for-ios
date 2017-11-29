 //
 //  MZKDetailManagerViewController.swift
 //  MZK_iOS
 //
 //  Created by OndrejVyhlidal on 02/11/2016.
 //  Copyright © 2016 Ondrej Vyhlidal. All rights reserved.
 //
 
 import UIKit
 import iOSTiledViewer
 import TSMessages
 
 
 class MZKDetailManagerViewController:UIViewController, DataLoadedDelegate, PageIndexDelegate, UIPageViewControllerDelegate {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tapGestureRecognizerView: UIView!
    @IBOutlet weak var topBarTopConstant: NSLayoutConstraint!
    @IBOutlet weak var bottomBarBottomConstant: NSLayoutConstraint!
    @IBOutlet weak var onHideShow: UIButton!
    @IBOutlet weak var currentPageNumber: UILabel!
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var pageThumbnails: UIButton!
    @IBOutlet weak var pageSlider: ASValueTrackingSlider!
    @IBOutlet weak var pageThumbnailView: UIView!
    
    @IBOutlet weak var previousPageButton: UIButton!
    @IBOutlet weak var nextPageButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var showThumbnailButton: UIButton!
    @IBOutlet weak var pageThumbnailsCollectionView: UICollectionView!
    
    @IBOutlet weak var createBookmark: UIButton!
    @IBOutlet weak var showBookmarks: UIButton!
    @IBOutlet weak var bookmarkContainer: UIView!
    @IBOutlet weak var bookmarkTableView: UITableView!
    @IBOutlet weak var bookmarkContainerLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomBarView: UIView!
    lazy fileprivate var mzkDatasource : MZKDatasource = {
        return MZKDatasource()
    }()
    
    lazy fileprivate var bookmarkDatasource : MZKBookmarkDatasource = {
        return MZKBookmarkDatasource()
    }()
    
    var item:MZKItemResource!
    var itemPID:String!
    var pages:[MZKPageObject]!
    var bookmarks:[MZKBookmark]!
    var childVC:MZKPageViewController!
    var barsVisible:Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.pageSlider.minimumValue = 0
        self.pageSlider.value = 0
        self.loadItem("asadasdas")
        self.bookmarkTableView.delegate = self
        showBookmarks.isEnabled = false
        
        barsVisible = true
        bookmarkContainerLeadingConstraint.constant = -bookmarkContainer.frame.size.width
        
        let shouldDimmDisplay = UserDefaults.standard.object(forKey: kShouldDimmDisplay) as! NSNumber
        
        let shouldDimm = shouldDimmDisplay.boolValue
        
        //print("Should DIMM:\(shouldDimm)")
        UIApplication.shared.isIdleTimerDisabled = shouldDimm
        
        self.enableUserInteraction(enable: false)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "MZKDetailViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker!.send(builder!.build() as [NSObject : AnyObject])
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
                destinationVC.item = self.item
                childVC = destinationVC
                childVC.pageIndexDelegate = self
                self.addChildViewController(destinationVC)
            }
        }
    }
    
    // MARK : actions
    @IBAction func onShowInformation(_ sender: Any) {
        
        // MZKDetailInformationViewController
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "MZKDetailInformationViewController") as! MZKDetailInformationViewController
        
        
        if((self.item.rootPid) != nil)
        {
            controller.rootPID = self.item.rootPid
        }
            controller.item = self.itemPID
       // controller.type = MZKConstants.modelType(toString: self.item.model)
        
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func onShowThumbnails(_ sender: Any) {
        pageThumbnailView.isHidden = !pageThumbnailView.isHidden
        self.showThumbnailButton.isSelected = !pageThumbnailView.isHidden
    }
    
    @IBAction func onClose(_ sender: Any) {
        
        if item != nil {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let date = Date()
            
            let formatter = DateFormatter()
            
            formatter.dateFormat = "dd.MM.yyyy"
            
            item.lastOpened = formatter.string(from: date)
            item.indexLastOpenedPage = childVC.currentIndex as NSNumber!
            
            print("Date recently opened:\(formatter.string(from: date))")
            
            appDelegate.addRecentlyOpenedDocument(item)
            
            UIApplication.shared.isIdleTimerDisabled = false
        }
        
        self.presentingViewController?.dismiss(animated: true, completion:nil)
    }
    
    @IBAction func onSliderValueChanged(_ sender: Any) {
        let currentValue = Int((sender as! UISlider).value)
        childVC.goToPage(currentValue-1)
        
    }
    
    @IBAction func pageSliderValueChanged(_ sender: Any) {
    }
    
    @IBAction func onShowHideBars(_ sender: Any) {
        
        if (barsVisible) {
            //hide bars
            self.topBarTopConstant.constant = -70
            self.bottomBarBottomConstant.constant = -50
            UIApplication.shared.setStatusBarHidden(true, with: UIStatusBarAnimation.slide)
        }
        else
        {
            //show bars
            
            self.topBarTopConstant.constant = 0
            self.bottomBarBottomConstant.constant = 0
            UIApplication.shared.setStatusBarHidden(false, with: UIStatusBarAnimation.slide)
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        }, completion:  {(_) -> Void in
            self.barsVisible = !self.barsVisible
        })
    }
    
    @IBAction func onCreateBookmark(_ sender: Any) {
        
        // MARK: - Creates new bookmark for current page
        let bookmark:MZKBookmark = MZKBookmark()
        bookmark.parentPID = itemPID
        bookmark.pagePID = childVC.currentPagePID
        bookmark.pageIndex = "\(childVC.currentIndex!)"
        
        // current date
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        
        bookmark.dateCreated = formatter.string(from: date)
        
        bookmarkDatasource.addBookmark(bookmark)
        
        bookmarks = bookmarkDatasource.getBookmarks(bookmark.parentPID!)
        
        print("Bookmarks count: \(bookmarks.count)")
        
        // rreload bookmarks
        self.bookmarkTableView.reloadData()
        setupBookmarkViews()
        
    }
    
    @IBAction func onShowBookmarks(_ sender: Any) {
        self.bookmarkTableView.reloadData()
        
        if (bookmarkContainerLeadingConstraint.constant == 0)
        {
            self.bookmarkContainerLeadingConstraint.constant = -bookmarkContainer.frame.size.width
            self.showBookmarks.isSelected = false
        }
        else
        {
            bookmarkContainerLeadingConstraint.constant = 0
            self.showBookmarks.isSelected = true
            self.bookmarkContainer.isHidden = false
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        }, completion:  {(_) -> Void in
            
            if(self.bookmarkContainerLeadingConstraint.constant == 0)
            {
                self.bookmarkContainer.isHidden = false
            }
            else
            {
                self.bookmarkContainer.isHidden = true
            }
            
        })
    }
    
    @IBAction func onNextPage(_ sender: Any) {
        
        self.childVC.nextPage()
    }
    @IBAction func onPreviousPage(_ sender: Any) {
        self.childVC.previousPage()
    }
    
    // MARK: - Loading of pages
    
    func loadItem(_ pid:String) ->()
    {
        mzkDatasource.delegate = self
        mzkDatasource.getItem(self.itemPID)
    }
    
    func loadPages(_ pid:String) -> () {
        mzkDatasource.delegate = self
        mzkDatasource .getChildrenForItem(self.itemPID)
    }
    
    func children(forItemLoaded items: [Any]!) {
        pages = items as! [MZKPageObject]!
        childVC .pagesLoaded(pages)
        
        DispatchQueue.main.async (execute: { () -> Void in
            self.pageSlider.minimumValue=1
            self.pageSlider.maximumValue = Float(self.pages.count)
            self.pageSlider.value = 1
            
            let startIndex = 1
            
            self.currentPageNumber.text = "\(startIndex as Int)/\(self.pages.count)"
            self.pageThumbnailsCollectionView.reloadData()
            self.setupSlider()
            self.bookmarks = self.bookmarkDatasource.getBookmarks(self.itemPID)
            self.setupBookmarkViews()
            self.bookmarkTableView.reloadData()
            
        })
    }
    
    func detail(forItemLoaded item: MZKItemResource!) {
        DispatchQueue.main.async (execute: { () -> Void in
            self.itemTitle.text = item.title
            
            self.item = item
            
            // enable user interaction
            self.enableUserInteraction(enable: true)
            
            self.loadPages(self.itemPID)
            
            if (item.pdfUrl != nil)
            {
                self.childVC.item = item
                self.childVC.setUpForPDF(item: item)
                self.bottomBarView.isHidden = true
            }
        })
    }
    
    func setupSlider() -> ()
    {
        self.pageSlider.popUpViewCornerRadius = 6.0;
        self.pageSlider .setMaxFractionDigitsDisplayed(0)
        self.pageSlider.popUpViewColor = UIColor.init(colorLiteralRed: 0, green: 118/255, blue: 255/255, alpha: 0.8)
        self.pageSlider.font = UIFont.systemFont(ofSize: 22)
        self.pageSlider.textColor = UIColor.black
        self.pageSlider.tintColor = self.pageSlider.popUpViewColor
        self.pageSlider.minimumTrackTintColor = self.pageSlider.popUpViewColor
        
    }
    
    func setupBookmarkViews() -> Void
    {
        if(bookmarks != nil)
        {
            if (bookmarks.count > 0)
            {
                showBookmarks.isEnabled = true
            }
        }
    }
    
    // MARK other methods
    
    /**
     Called when the current index is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter index: the index of the currently visible page.
     */
    func pageIndexDelegate(pageIndexDelegate: PageIndexDelegate, didUpdatePageIndex index: Int)
    {
        DispatchQueue.main.async (execute: { () -> Void in
            self.currentPageNumber.text = "\(index)/\(self.pages.count)"
            self.pageSlider.minimumValue=1
            self.pageSlider.maximumValue = Float(self.pages.count)
            self.pageSlider.value = Float(index)
        })
        
    }
    
    open func goToPage(_ index: Int) {
        if index < pages.count {
            childVC.goToPage(index)
        }
    }
    
    func enableUserInteraction(enable:Bool) -> Void {
        // back button should be always enabled, everything else should be disabled until content is loaded
        
        self.createBookmark.isEnabled = enable
        
        if(bookmarks != nil)
        {
            if (bookmarks.count > 0)
            {
                showBookmarks.isEnabled = enable
            }
        }
        
        self.infoButton.isEnabled = enable
        self.showThumbnailButton.isEnabled = enable
        self.pageSlider.isEnabled = enable
        
      self.nextPageButton.isEnabled = enable
       self.previousPageButton.isEnabled = enable
    }
    
    func reloadData () -> Void
    {
        if(self.item == nil)
        {
            self.loadItem(self.itemPID)
        }
        
        if(self.pages == nil)
        {
            self.loadPages(self.itemPID)
        }
    }
    
    /**
     MZKDataLoaded method
     * argument view controller for presentaion of messages
     * argument error  - NSError or Error
     * argument completion - completion block that is invoked when user taps button inside message
     
     */
    
    func downloadFailedWithError(_ error: Error!) {
        
        
        let error = error as NSError!
        
        DispatchQueue.main.async (execute: { () -> Void in
            
            if(error?.domain == "MZK")
            {
                MZKSwiftErrorMessageHandler().showTSMessage(viewController: self, title: "Error".localizedWithComment(comment: "Error title of message box"), subtitle: "Something went wrong".localizedWithComment(comment: "Generic kramerius error"), completion: {
                    self.reloadData()
                })
            }
            else
            {
                MZKSwiftErrorMessageHandler().showTSMessageTest(viewController: self, error: error! as NSError, completion: {(_) -> Void in
                    print("Reloading values")
                    self.reloadData()
                })
                
            }
        })
    }
 }
 
 extension MZKDetailManagerViewController : UICollectionViewDelegate
 {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.goToPage(indexPath.row)
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
        
        let thumbURL = String(format:"%@/search/api/v5.0/item/%@/thumb", libraryItem.url, pageObject.pid)
        
        
        cell.pageNumber.text = pageObject.title
        
        cell.pageThumbnail .sd_setImage(with: NSURL(string: thumbURL) as URL!)
        
        cell.page = pageObject
        
        return cell
    }
 }
 
 extension MZKDetailManagerViewController : UITableViewDelegate
 {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let bookmarkToDelete = bookmarks[indexPath.row]
            
            self.bookmarkDatasource.deleteBookmark(bookmarkToDelete.pagePID!, bookmarkParentPID: bookmarkToDelete.parentPID!)
            self.bookmarks = self.bookmarkDatasource.getBookmarks(itemPID)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.reloadData()
            tableView.endUpdates()
            
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bookmark = bookmarks[indexPath.row]
        
        if let pageIndex = Int(bookmark.pageIndex!) {
            self.childVC.goToPage(pageIndex-1)
            
            self .onShowBookmarks(self)
        }
    }
 }
 
 extension MZKDetailManagerViewController : UITableViewDataSource
 {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (bookmarks != nil)
        {
            return bookmarks.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MZKBookmarkTableViewCell", for: indexPath) as! MZKBookmarkTableViewCell
        let bookmark = bookmarks[indexPath.row]
        
        if let a = bookmark.pageIndex {
            // a is an Int
            cell.bookmarkLabel.text = "● Záložka na straně: \(a)"
            
        }
        return cell
    }
 }
 
 extension MZKDetailManagerViewController : MZKUserActivityDelegate
 {
    func userDidSingleTapped() {
        self.onShowHideBars(self)
    }
    
    func nextPage() {
        self.onNextPage(self)
    }
    
    func previousPage() {
        self.onPreviousPage(self)
    }
 }
