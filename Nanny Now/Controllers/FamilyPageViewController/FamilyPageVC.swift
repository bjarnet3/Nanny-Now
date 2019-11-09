//
//  FamilyPageVC.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 24.09.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

class FamilyPageVC: UIPageViewController {
    
    private var currentIndex: Int?
    private var pendingIndex: Int?
    
    var pages = [UIViewController]()
    var pageToLoadFirst = 0
    
    private var pageControl = UIPageControl(frame: .zero)
    private func setupPageControl() {
        
        pageControl.numberOfPages = pages.count
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = UIColor.white.withAlphaComponent(0.5)
        pageControl.pageIndicatorTintColor = UIColor.lightGray.withAlphaComponent(0.6)
        
        let leading = NSLayoutConstraint(item: pageControl, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint(item: pageControl, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: pageControl, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        
        view.insertSubview(pageControl, at: 0)
        view.bringSubviewToFront(pageControl)
        view.addConstraints([leading, trailing, bottom])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let page0 = storyboard!.instantiateViewController(withIdentifier: "FamilyPageZero") as? FamilyPageZero
        let page1 = storyboard!.instantiateViewController(withIdentifier: "FamilyPageOne") as? FamilyPageOne
        let page2 = storyboard!.instantiateViewController(withIdentifier: "FamilyPageTwo") as? FamilyPageTwo
        
        pages.append(page0!)
        pages.append(page1!)
        pages.append(page2!)
        
        switch self.pageToLoadFirst {
        case 0:
            setViewControllers([page0!], direction: .forward, animated: false, completion: nil)
        case 1:
            setViewControllers([page1!], direction: .forward, animated: false, completion: nil)
        case 2:
            setViewControllers([page2!], direction: .forward, animated: false, completion: nil)
        default:
            setViewControllers([page0!], direction: .forward, animated: false, completion: nil)
        }
        
        setupPageControl()
        dataSource = self
        delegate = self
        
    }

}

extension FamilyPageVC : UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex = pages.index(of: viewController)!
        if currentIndex == 0 {
            return nil
        }
        let previousIndex = abs((currentIndex - 1) % pages.count)
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentIndex = pages.index(of: viewController)!
        if currentIndex == pages.count-1 {
            return nil
        }
        let nextIndex = abs((currentIndex + 1) % pages.count)
        return pages[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        pendingIndex = pages.index(of: pendingViewControllers.first!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            currentIndex = pendingIndex
            if let index = currentIndex {
                pageControl.currentPage = index
            }
        }
    }
    
}
