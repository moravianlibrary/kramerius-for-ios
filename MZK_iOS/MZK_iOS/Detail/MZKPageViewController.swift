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
    func pagesLoaded(pages:[MZKPageObject])
}

protocol PageIndexDelegate: class {
    
    /**
     Called when the number of pages is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter count: the total number of pages.
     */
    func pageIndexDelegate(pageIndexDelegate: PageIndexDelegate,
                                    didUpdatePageCount count: Int)
    
    /**
     Called when the current index is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter index: the index of the currently visible page.
     */
    func pageIndexDelegate(pageIndexDelegate: PageIndexDelegate,
                                    didUpdatePageIndex index: Int)
    
}


@objc class MZKPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, DataLoadedDelegate {
    
    // close can be used for initialize with params ...
    lazy private var mzkDatasource : MZKDatasource = {
        return MZKDatasource()
    }()
    
    // public properties
    var itemPID:String!
    var pages:[MZKPageObject]!
    public var currentIndex:Int!
    
    weak var pageIndexDelegate: PageIndexDelegate?
    
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
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
    
    private var pendingIndex: Int?
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        pendingIndex = orderedViewControllers.index(of: orderedViewControllers.first!)
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            currentIndex = pendingIndex
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if finished {
            
            if let firstViewController = viewControllers?.first,
                let index = orderedViewControllers.index(of: firstViewController) {
                pageIndexDelegate?.pageIndexDelegate(pageIndexDelegate: self.pageIndexDelegate!, didUpdatePageIndex: index+1)
                currentIndex = pendingIndex
            }
        }
    }
    
    // MARK: - DataLoaded Delegate methods
    
    func dataLoaded(_ data: [Any]!, withKey key: String!) {
        print("Data Loaded");
    }
    
    public func pagesLoaded(pages: [MZKPageObject]) {
        self.pages = pages
        
        
        print(pages.count)
        
        orderedViewControllers = []
        
        for i in 1...pages.count
        {
           orderedViewControllers .append(newPageViewController(itemPID: pages[i-1].pid, index: i))
        }
        
        DispatchQueue.main.async (execute: { () -> Void in
            
            if let firstViewController = self.orderedViewControllers.first {
                self.setViewControllers([firstViewController],
                                        direction: .forward,
                                        animated: true,
                                        completion: nil)
            }
            
        })
    }
    
    private func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    private func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = orderedViewControllers.index(of: firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }
    
    
    
    private func newPageViewController(itemPID: String, index: Int) -> UIViewController {
        
        let pageVC : MZKPageDetailViewController = UIStoryboard(name: "MZKDetail", bundle: nil) .
            instantiateViewController(withIdentifier: "MZKPageDetailViewController") as! MZKPageDetailViewController
        
        pageVC.pagePID = itemPID
        pageVC.pageIndex = index
        
        return pageVC
    }
    
    public func goToPage(index: Int) {
        if index < orderedViewControllers.count {
            self.setViewControllers([orderedViewControllers[index]], direction: .forward, animated: true, completion: nil)
            
            if let firstViewController = viewControllers?.first,
                let index = orderedViewControllers.index(of: firstViewController) {
                pageIndexDelegate?.pageIndexDelegate(pageIndexDelegate: self.pageIndexDelegate!, didUpdatePageIndex: index+1)
                currentIndex = pendingIndex
            }

        }
    }

    
        
}


