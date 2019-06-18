//
//  MZKPageViewController.swift
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 26/10/2016.
//  Copyright © 2016 Ondrej Vyhlidal. All rights reserved.
//

import UIKit

protocol MZKPagesProtocolDelegate: class  {
    // var pageObjects: [MZKPageObject] { get set }
    func pagesLoaded(_ pages:[MZKPageObject])
}

protocol PageIndexDelegate: class {
    /**
     Called when the current index is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter index: the index of the currently visible page.
     */
    func pageIndexDelegate(pageIndexDelegate: PageIndexDelegate, didUpdatePageIndex index: Int)
}


@objc class MZKPageViewController: UIPageViewController, DataLoadedDelegate {
    // close can be used for initialize with params ...
    lazy fileprivate var mzkDatasource : MZKDatasource = {
        return MZKDatasource()
    }()
    
    // public properties
    var itemPID: String!
    var item: MZKItemResource!
    var pages: [MZKPageObject]!
    var currentIndex: Int!
    var currentPagePID: String!
    
    weak var pageIndexDelegate: PageIndexDelegate?
    var pendingIndex: Int?
    
    fileprivate(set) lazy var orderedViewControllers: [UIViewController] = {
        return []
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        currentIndex = nextIndex
        
        return orderedViewControllers[nextIndex]
    }

    // MARK: - DataLoaded Delegate methods
    
    func dataLoaded(_ data: [Any]!, withKey key: String!) {
       
    }

    public func displaySinglePage(pagePID: String) {
        self.pages = [MZKPageObject]()
        orderedViewControllers = [UIViewController]()
        orderedViewControllers.append(newPageViewController(pagePID, index: 0))
        DispatchQueue.main.async (execute: { [weak self] in
            guard let strongSelf = self else { return }

            if let firstViewController = strongSelf.orderedViewControllers.first as? MZKPageDetailViewController {
                strongSelf.setViewControllers([firstViewController],
                                        direction: .forward,
                                        animated: true,
                                        completion: { [weak self] _ in
                                            guard let strongSelf = self else { return }

                                            strongSelf.currentIndex = firstViewController.pageIndex
                                            strongSelf.currentPagePID = firstViewController.pagePID
                                            
                                            if (strongSelf.item != nil) {
                                                firstViewController.showPDFFile(item: strongSelf.item)
                                            }
                })
            }
        })
    }
    
    func pagesLoaded(_ pages: [MZKPageObject]) {
        self.pages = pages
               
        orderedViewControllers = []
        
        for i in 1...pages.count {
           orderedViewControllers.append(newPageViewController(pages[i-1].pid, index: i))
        }
        
        DispatchQueue.main.async (execute: { () -> Void in
            
            if let firstViewController = self.orderedViewControllers.first as? MZKPageDetailViewController {
                self.setViewControllers([firstViewController],
                                        direction: .forward,
                                        animated: true,
                                        completion: {(_) -> Void in
                                            
                                            self.currentIndex = firstViewController.pageIndex
                                            self.currentPagePID = firstViewController.pagePID
                                            
                                            if (self.item != nil)
                                            {
                                                firstViewController.showPDFFile(item: self.item)
                                                
                                            }
                })
            }
        })
    }

    fileprivate func newPageViewController(_ itemPID: String, index: Int) -> UIViewController {
        let pageVC : MZKPageDetailViewController = UIStoryboard(name: "MZKDetail", bundle: nil) .
            instantiateViewController(withIdentifier: "MZKPageDetailViewController") as! MZKPageDetailViewController

        pageVC.pagePID = itemPID
        pageVC.pageIndex = index
        pageVC.userActivityDelegate = self.pageIndexDelegate as! MZKUserActivityDelegate?
        
        return pageVC
    }
    
    open func goToPage(_ index: Int) {
        if index <= orderedViewControllers.count {
            
            var direction = UIPageViewController.NavigationDirection.forward
          
            if (index < self.currentIndex) {
                direction = UIPageViewController.NavigationDirection.reverse
                
            }

            self.setViewControllers([orderedViewControllers[index]], direction: direction, animated: true, completion: { _ in
                if let firstViewController = self.viewControllers?.first,
                    let vcIndex = self.orderedViewControllers.index(of: firstViewController) {
                
                    let tmpVC = firstViewController as! MZKPageDetailViewController
                    self.currentIndex = tmpVC.pageIndex
                    self.currentPagePID = tmpVC.pagePID
                    
                    self.pageIndexDelegate?.pageIndexDelegate(pageIndexDelegate: self.pageIndexDelegate!, didUpdatePageIndex: vcIndex+1)
                }
            })
        }
    }
    
    func nextPage() {
        guard let targetIndex = currentIndex else { return }
        if (currentIndex.advanced(by: 1) <= pages.count) {
            self.setViewControllers([orderedViewControllers[targetIndex]], direction: .forward, animated: true, completion: { [weak self] _ in
                guard let strongSelf = self else { return }

                if let firstViewController = strongSelf.viewControllers?.first,
                    let vcIndex = strongSelf.orderedViewControllers.index(of: firstViewController) {
                    
                    let tmpVC = firstViewController as! MZKPageDetailViewController
                    strongSelf.currentIndex = tmpVC.pageIndex
                    strongSelf.currentPagePID = tmpVC.pagePID
                    strongSelf.pageIndexDelegate?.pageIndexDelegate(pageIndexDelegate: strongSelf.pageIndexDelegate!, didUpdatePageIndex: vcIndex+1)
                }
            })
        }
    }
    
    func previousPage() {
        guard let firstVc = self.viewControllers?.first, let tmpVc = firstVc as? MZKPageDetailViewController else { return }

        currentIndex = tmpVc.pageIndex

        var targetIndex = currentIndex.advanced(by: -1)
        targetIndex = targetIndex.advanced(by: -1)

        if (targetIndex >= 0) {
            // goToPage(targetIndex)
            self.setViewControllers([orderedViewControllers[targetIndex]], direction: .reverse, animated: true, completion: { _ in
                if let firstViewController = self.viewControllers?.first,
                    let vcIndex = self.orderedViewControllers.index(of: firstViewController) {
            
                    let tmpVC = firstViewController as! MZKPageDetailViewController
                    self.currentIndex = tmpVC.pageIndex
                    self.currentPagePID = tmpVC.pagePID
                    
                    self.pageIndexDelegate?.pageIndexDelegate(pageIndexDelegate: self.pageIndexDelegate!, didUpdatePageIndex: vcIndex+1)
                    
                }
            })

        }
    }
    
    func setUpForPDF(item:MZKItemResource) {
        print("📖 Setup for PDF")
        guard let firstViewController = self.orderedViewControllers.first, let tmpVC = firstViewController as? MZKPageDetailViewController else { return }
        tmpVC.pdfURL = item.pdfUrl
        tmpVC.showPDFFile(item: item)
    }
}

extension MZKPageViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {

        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }

        let previousIndex = viewControllerIndex - 1

        guard previousIndex >= 0 else {
            return nil
        }

        guard orderedViewControllers.count > previousIndex else {
            return nil
        }

        currentIndex = previousIndex

        return orderedViewControllers[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        pendingIndex = orderedViewControllers.index(of: orderedViewControllers.first!)
        print("Will transition to VC, pendingIndex: \(String(describing: pendingIndex))")
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

        if finished {
            if let firstViewController = viewControllers?.first,
                let index = orderedViewControllers.index(of: firstViewController) {
                pageIndexDelegate?.pageIndexDelegate(pageIndexDelegate: self.pageIndexDelegate!, didUpdatePageIndex: index+1)

                let tmpVC = firstViewController as! MZKPageDetailViewController
                self.currentPagePID = tmpVC.pagePID

                self.currentIndex = tmpVC.pageIndex
            }
        }
    }

}
