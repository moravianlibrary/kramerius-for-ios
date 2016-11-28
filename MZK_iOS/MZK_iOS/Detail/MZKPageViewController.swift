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
    
    
//    /**
//     Called when the number of pages is updated.
//     
//     - parameter tutorialPageViewController: the TutorialPageViewController instance
//     - parameter count: the total number of pages.
//     */
//    func pageIndexDelegate(pageIndexDelegate: PageIndexDelegate, didUpdatePageCount count: Int)
    

    
}


@objc class MZKPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, DataLoadedDelegate {
    
    // close can be used for initialize with params ...
    lazy fileprivate var mzkDatasource : MZKDatasource = {
        return MZKDatasource()
    }()
    
    // public properties
    var itemPID:String!
    var pages:[MZKPageObject]!
    open var currentIndex:Int!
    open var currentPagePID:String!
    
    weak var pageIndexDelegate: PageIndexDelegate?
    
    
    fileprivate(set) lazy var orderedViewControllers: [UIViewController] = {
        return []
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        // dataSource = self set up from SB?
         delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    
    // MARK UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
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
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
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
    
    fileprivate var pendingIndex: Int?
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        pendingIndex = orderedViewControllers.index(of: orderedViewControllers.first!)
        print("Pending index:\(pendingIndex)")
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if finished {
            print( "Finished animating")
            if let firstViewController = viewControllers?.first,
                let index = orderedViewControllers.index(of: firstViewController) {
                pageIndexDelegate?.pageIndexDelegate(pageIndexDelegate: self.pageIndexDelegate!, didUpdatePageIndex: index+1)
               
                let tmpVC = firstViewController as! MZKPageDetailViewController
                self.currentPagePID = tmpVC.pagePID
                
                self.currentIndex = tmpVC.pageIndex
            }
        }
    }
    
    // MARK: - DataLoaded Delegate methods
    
    func dataLoaded(_ data: [Any]!, withKey key: String!) {
        print("Data Loaded");
    }
    
    open func pagesLoaded(_ pages: [MZKPageObject]) {
        self.pages = pages
               
        orderedViewControllers = []
        
        for i in 1...pages.count
        {
           orderedViewControllers .append(newPageViewController(pages[i-1].pid, index: i))
        }
        
        DispatchQueue.main.async (execute: { () -> Void in
            
            if let firstViewController = self.orderedViewControllers.first as? MZKPageDetailViewController {
                self.setViewControllers([firstViewController],
                                        direction: .forward,
                                        animated: true,
                                        completion: {(_) -> Void in
                                            self.currentIndex = firstViewController.pageIndex
                                            self.currentPagePID = firstViewController.pagePID
                                            
                })

            }
            
        })
    }
    
    internal func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    internal func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = orderedViewControllers.index(of: firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }
    
    fileprivate func newPageViewController(_ itemPID: String, index: Int) -> UIViewController {
        
        let pageVC : MZKPageDetailViewController = UIStoryboard(name: "MZKDetail", bundle: nil) .
            instantiateViewController(withIdentifier: "MZKPageDetailViewController") as! MZKPageDetailViewController
        
        pageVC.pagePID = itemPID
        pageVC.pageIndex = index
        
        return pageVC
    }
    
    open func goToPage(_ index: Int) {
        if index <= orderedViewControllers.count {
            
            var direction = UIPageViewControllerNavigationDirection.forward
          
            if (index < self.currentIndex) {
                direction = UIPageViewControllerNavigationDirection.reverse
                
            }

            self.setViewControllers([orderedViewControllers[index]], direction: direction, animated: true, completion: {(_)->Void in
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
    
    func nextPage() -> Void {
        let targetIndex = currentIndex!
        if (currentIndex.advanced(by: 1) <= pages.count) {
            self.setViewControllers([orderedViewControllers[targetIndex]], direction: .forward, animated: true, completion: {(_)->Void in
                if let firstViewController = self.viewControllers?.first,
                    let vcIndex = self.orderedViewControllers.index(of: firstViewController) {
                    
                    //print(" ===== Index Changed: \(index)")
                    
                    let tmpVC = firstViewController as! MZKPageDetailViewController
                    self.currentIndex = tmpVC.pageIndex
                    self.currentPagePID = tmpVC.pagePID
                    self.pageIndexDelegate?.pageIndexDelegate(pageIndexDelegate: self.pageIndexDelegate!, didUpdatePageIndex: vcIndex+1)
                    
                }
            })

            
            
        }
    }
    
    func previousPage() -> Void {
        let targetIndex = currentIndex.advanced(by: -1)
        
        if (targetIndex > 0) {
            // goToPage(targetIndex)
            self.setViewControllers([orderedViewControllers[targetIndex-1]], direction: .reverse, animated: true, completion: {(_)->Void in
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

    
        
}


