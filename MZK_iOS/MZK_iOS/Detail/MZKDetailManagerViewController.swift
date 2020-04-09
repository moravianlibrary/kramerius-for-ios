 //
 //  MZKDetailManagerViewController.swift
 //  MZK_iOS
 //
 //  Created by OndrejVyhlidal on 02/11/2016.
 //  Copyright © 2016 Ondrej Vyhlidal. All rights reserved.
 //
 
 import UIKit

@objc
public class MZKDetailManagerViewController: UIViewController, DataLoadedDelegate {
    
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

    // UIPage view controller
    private var currentIndex: Int = 0
    private var pageController: UIPageViewController!
    var viewControllers = [UIViewController]()

    private lazy var mzkDatasource: MZKDatasource = {
        return MZKDatasource()
    }()
    
    private lazy var bookmarkDatasource: MZKBookmarkDatasource = {
        return MZKBookmarkDatasource()
    }()

    @objc
    public var item: MZKItemResource!

    var statusBarHidden = false {
        didSet {
            UIView.animate(withDuration: 0.5) { () -> Void in
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }

    @objc
    public var itemPID:String!

    var pages: [MZKPageObject]!
    var bookmarks: [MZKBookmark]!
    var barsVisible:Bool = true

    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        pageSlider.minimumValue = 0
        pageSlider.value = 0
        loadItem("test")
        bookmarkTableView.delegate = self
        showBookmarks.isEnabled = false
        
        barsVisible = true
        bookmarkContainerLeadingConstraint.constant = -bookmarkContainer.frame.size.width
        
        let shouldDimmDisplay = UserDefaults.standard.object(forKey: kShouldDimmDisplay) as! NSNumber
        
        let shouldDimm = shouldDimmDisplay.boolValue

        UIApplication.shared.isIdleTimerDisabled = shouldDimm
        
        enableUserInteraction(enable: false)

        pageController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: [UIPageViewController.OptionsKey.interPageSpacing: 10]
        )
        
        pageController.dataSource = self
        pageController.delegate = self

        addChild(pageController)
        containerView.addSubviewWithConstraintsToEdges(pageController.view)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "MZKDetailViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker!.send(builder!.build() as [NSObject : AnyObject])
    }

    override public var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }

    override public var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    // MARK : actions
    @IBAction func onShowInformation(_ sender: Any) {
        
        // MZKDetailInformationViewController
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "MZKDetailInformationViewController") as! MZKDetailInformationViewController

        if((self.item.rootPid) != nil) {
            controller.rootPID = self.item.rootPid
        }
        
        controller.item = self.itemPID
        
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func onShowThumbnails(_ sender: Any) {
        pageThumbnailView.isHidden = !pageThumbnailView.isHidden
        self.showThumbnailButton.isSelected = !pageThumbnailView.isHidden
    }
    
    @IBAction func onClose(_ sender: Any) {
        if item != nil {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            
            item.lastOpened = formatter.string(from: date)
//            if childVC != nil {
//                item.indexLastOpenedPage = currentIndex as NSNumber
//            }
            
            print("Date recently opened:\(formatter.string(from: date))")
            
            appDelegate.addRecentlyOpenedDocument(item)
            
            UIApplication.shared.isIdleTimerDisabled = false
        }
        
        self.presentingViewController?.dismiss(animated: true, completion:nil)
    }
    
    @IBAction func onSliderValueChanged(_ sender: Any) {
        let currentValue = Int((sender as! UISlider).value)
        show(page: currentValue)
    }
    
    @IBAction func pageSliderValueChanged(_ sender: Any) {

    }

    @IBAction func onShowHideBars(_ sender: Any) {
        if (barsVisible) {
            //hide bars
            topBarTopConstant.constant = -100
            bottomBarBottomConstant.constant = -100
            statusBarHidden = false
        } else {
            //show bars
            self.topBarTopConstant.constant = 0
            self.bottomBarBottomConstant.constant = 0
            statusBarHidden = true
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
      //  bookmark.pagePID = childVC.currentPagePID
        // TODO: FIXME!
       // bookmark.pageIndex = "\(childVC.currentIndex!)"
        
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
        
        if (bookmarkContainerLeadingConstraint.constant == 0) {
            self.bookmarkContainerLeadingConstraint.constant = -bookmarkContainer.frame.size.width
            self.showBookmarks.isSelected = false
        } else {
            bookmarkContainerLeadingConstraint.constant = 0
            self.showBookmarks.isSelected = true
            self.bookmarkContainer.isHidden = false
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        }, completion:  {(_) -> Void in
            
            if(self.bookmarkContainerLeadingConstraint.constant == 0) {
                self.bookmarkContainer.isHidden = false
            } else {
                self.bookmarkContainer.isHidden = true
            }
        })
    }
    
    @IBAction func onNextPage(_ sender: Any) {
        print("Button - NEXT")
    }

    @IBAction func onPreviousPage(_ sender: Any) {
        print("Button - PREVIOUS")
    }

    @IBAction func onMusicTapped(_ sender: UIButton) {
        print("Button - Music")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        guard let musicViewController = appDelegate.musicViewController else { return }
        guard let _ = musicViewController.itemPID else { return}
        // 1. request an UITraitCollection instance
        let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom

        // 2. check the idiom
        switch (deviceIdiom) {
        case .unspecified:
            musicViewController.preferredContentSize = CGSize(width: 375, height: 667)
        case .phone:
            break
        case .pad:
            musicViewController.preferredContentSize = CGSize(width: 375, height: 667)
        case .tv:
            break
        case .carPlay:
            break
        }

        let popoverPresentationController = musicViewController.presentationController as! UIPopoverPresentationController
        popoverPresentationController.sourceView = sender
        popoverPresentationController.sourceRect = sender.frame

        present(musicViewController, animated: true)
    }
    
    // MARK: - Loading of pages

    func loadItem(_ pid: String) {
        mzkDatasource.delegate = self
        mzkDatasource.getItem(itemPID)
    }
    
    func loadPages(_ pid: String) {
        mzkDatasource.delegate = self
        mzkDatasource.getChildrenForItem(itemPID)
    }

    @objc
    public func children(forItemLoaded items: [Any]!) {
        pages = items as? [MZKPageObject]

        DispatchQueue.main.async {[weak self] in

            guard let self = self else { return }

            var viewControllers = [MZKPageDetailViewController]()
            for (_, page) in self.pages.enumerated() {
                let viewController: MZKPageDetailViewController = UIStoryboard(name: "MZKDetail", bundle: nil) .
                       instantiateViewController(withIdentifier: "MZKPageDetailViewController") as! MZKPageDetailViewController

                viewController.pagePID = page.pid
                viewController.userActivityDelegate = self

                viewControllers.append(viewController)
            }

            self.viewControllers = viewControllers

            self.pageController.setViewControllers([viewControllers[0]], direction: .forward, animated: false, completion: nil)

            self.pageSlider.minimumValue = 1
            self.pageSlider.maximumValue = Float(self.pages.count)
            self.pageSlider.value = 1

            if self.pages.count == 1 {
                self.pageSlider.isHidden = true
            }
            
            let startIndex = 1
            
            self.currentPageNumber.text = "\(startIndex as Int)/\(self.pages.count)"
            self.pageThumbnailsCollectionView.reloadData()
            self.setupSlider()
            self.bookmarks = self.bookmarkDatasource.getBookmarks(self.itemPID)
            self.setupBookmarkViews()
            self.bookmarkTableView.reloadData()
        }
    }
    
    @objc
    public func detail(forItemLoaded item: MZKItemResource) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.itemTitle.text = item.title

            strongSelf.item = item

            // enable user interaction
            strongSelf.enableUserInteraction(enable: true)

            if item.model != MZKModel.Page {
                strongSelf.loadPages(strongSelf.itemPID)
            } else {
                strongSelf.setupForPage()
            }

            if (item.pdfUrl != nil) {
               // strongSelf.childVC.item = item
               // strongSelf.childVC.setUpForPDF(item: item)
                strongSelf.bottomBarView.isHidden = true
            }
        }
    }
    
    func setupSlider() {
        pageSlider.popUpViewCornerRadius = 6.0;
        pageSlider.setMaxFractionDigitsDisplayed(0)
        pageSlider.popUpViewColor = UIColor(red: 0, green: 118/255, blue: 255/255, alpha: 0.8)
        pageSlider.font = UIFont.systemFont(ofSize: 22)
        pageSlider.textColor = UIColor.black
        pageSlider.tintColor = pageSlider.popUpViewColor
        pageSlider.minimumTrackTintColor = pageSlider.popUpViewColor
    }

    func setupForPage() {
        pageSlider.isHidden = true

      //  childVC.displaySinglePage(pagePID: item.pid)

        let pageVC: MZKPageDetailViewController = UIStoryboard(name: "MZKDetail", bundle: nil) .
        instantiateViewController(withIdentifier: "MZKPageDetailViewController") as! MZKPageDetailViewController

        pageVC.pagePID = itemPID
        pageVC.userActivityDelegate = self
        self.viewControllers = [pageVC]
        self.pageController.setViewControllers([viewControllers[0]], direction: .forward, animated: false, completion: nil)
    }
    
    func setupBookmarkViews() {
        if(bookmarks != nil) {
            if (bookmarks.count > 0) {
                showBookmarks.isEnabled = true
            }
        }
    }
    
    // MARK other methods

    func show(page: Int) {
        guard page < viewControllers.count else {
            return
        }
        pageController.setViewControllers([viewControllers[page]], direction: .forward, animated: false, completion: nil)
        currentIndex = page

        updateSliderValue(value: currentIndex)
    }

    func goToPage(_ index: Int) {
        if index < pages.count {

        }
    }
    
    func enableUserInteraction(enable: Bool) {
        // back button should be always enabled, everything else should be disabled until content is loaded
        createBookmark.isEnabled = enable
        
        if(bookmarks != nil) {
            if (bookmarks.count > 0) {
                showBookmarks.isEnabled = enable
            }
        }
        
        infoButton.isEnabled = enable
        showThumbnailButton.isEnabled = enable
        pageSlider.isEnabled = enable
        
        nextPageButton.isEnabled = enable
        previousPageButton.isEnabled = enable
    }

    func updateSliderValue(value: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.pageSlider.setValue(Float(value), animated: true)
            self.currentPageNumber.text = "\(value)/\(self.pages.count)"
        }
    }
    
    func reloadData () {
        if(self.item == nil) {
            self.loadItem(self.itemPID)
        }
        
        if(self.pages == nil) {
            self.loadPages(self.itemPID)
        }
    }
    
    /**
     MZKDataLoaded method
     * argument view controller for presentaion of messages
     * argument error  - NSError or Error
     * argument completion - completion block that is invoked when user taps button inside message
     
     */
    @objc
    public func downloadFailedWithError(_ error: Error!) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            if let error = error as NSError? {
                if(error.domain == "MZK") {
                    // TODO: messages
                    //                MZKSwiftErrorMessageHandler().showTSMessage(viewController: self, title: "Error".localizedWithComment(comment: "Error title of message box"), subtitle: "Something went wrong".localizedWithComment(comment: "Generic kramerius error"), completion: {
                    //                    self.reloadData()
                    //                })
                }
        } else {
            MZKSwiftErrorMessageHandler().showTSMessageTest(viewController: strongSelf, error: error! as NSError, completion: { [weak self] in
                guard let strongSelf = self else { return }
                print("Reloading values")
                strongSelf.reloadData()
            })
        }
        }
    }
 }
 
 extension MZKDetailManagerViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        goToPage(indexPath.row)
        onShowThumbnails(Any.self)
    }
 }
 
 extension MZKDetailManagerViewController : UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if (pages != nil) {
            return pages.count
        }
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MZKPageDetailCollectionViewCell",
                                                      for: indexPath) as! MZKPageDetailCollectionViewCell
        // Configure the cell
        
        let pageObject = pages[indexPath.row]
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let libraryItem : MZKLibraryItem! = appDelegate.getDatasourceItem();
        
        let thumbURL = String(format:"%@/search/api/v5.0/item/%@/thumb", libraryItem.url, pageObject.pid)
        
        cell.pageNumber.text = pageObject.title
        cell.pageThumbnail.sd_setImage(with: NSURL(string: thumbURL) as URL?)
        cell.page = pageObject
        
        return cell
    }
 }
 
 extension MZKDetailManagerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let bookmarkToDelete = bookmarks[indexPath.row]
            
            self.bookmarkDatasource.deleteBookmark(bookmarkToDelete.pagePID!, bookmarkParentPID: bookmarkToDelete.parentPID!)
            self.bookmarks = bookmarkDatasource.getBookmarks(itemPID)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.reloadData()
            tableView.endUpdates()
        }
    }
    
    private func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
    }
    
    @nonobjc func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bookmark = bookmarks[indexPath.row]
        
        if let _ = Int(bookmark.pageIndex!) {
            onShowBookmarks(self)
        }
    }
 }
 
 extension MZKDetailManagerViewController : UITableViewDataSource {
    @nonobjc func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (bookmarks != nil) {
            return bookmarks.count
        }
        
        return 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MZKBookmarkTableViewCell", for: indexPath) as! MZKBookmarkTableViewCell
        let bookmark = bookmarks[indexPath.row]
        
        if let a = bookmark.pageIndex {
            // a is an Int
            cell.bookmarkLabel.text = "● Záložka na straně: \(a)"
            
        }
        return cell
    }
 }
 
 extension MZKDetailManagerViewController: MZKUserActivityDelegate {
    func userDidSingleTapped() {
        onShowHideBars(self)
    }
    
    func nextPage() {
        onNextPage(self)
    }
    
    func previousPage() {
        onPreviousPage(self)
    }
 }

 extension MZKDetailManagerViewController: UIPageViewControllerDelegate {
    private func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let viewController = pendingViewControllers.first else {
            return
        }

        currentIndex = viewControllers.firstIndex(of: viewController) ?? 0
      //  didManuallyScroll(to: currentIndex)
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

        guard let viewController = previousViewControllers.last else {
            return
        }

        if !completed {
            
        }
        currentIndex = viewControllers.firstIndex(of: viewController) ?? 0
        updateSliderValue(value:(currentIndex + 1))
    }
 }

 extension MZKDetailManagerViewController: UIPageViewControllerDataSource {
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let range = viewControllers.startIndex..<viewControllers.endIndex
        let index = viewControllers.firstIndex(of: viewController) ?? 0
        let newIndex = index - 1

        return range.contains(newIndex) ? viewControllers[newIndex] : nil
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let range = viewControllers.startIndex..<viewControllers.endIndex
        let index = viewControllers.firstIndex(of: viewController) ?? 0
        let newIndex = index + 1

        return range.contains(newIndex) ? viewControllers[newIndex] : nil
    }
 }
