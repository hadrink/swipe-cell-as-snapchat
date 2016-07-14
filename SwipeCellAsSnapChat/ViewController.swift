//
//  ViewController.swift
//  SwipeCellAsSnapChat
//
//  Created by Rplay on 13/07/16.
//  Copyright © 2016 rplay. All rights reserved.
//

import UIKit

//-- HandlePan protocol
weak var panDelegate: HandlePanDelegate?

protocol HandlePanDelegate: class {
    func handlePan(isDragging translation: CGPoint, locationInView location: CGPoint)
    func handlePan(visibleView visible: UIView)
    func handlePan(viewWillAppear view: UIView)
    func handlePan(didEndDragging didEnd: Bool)
}

//-- First View Controller
class ViewController: UIViewController {
    
    //-- Outlets
    @IBOutlet var scrollView: UIScrollView!
    
    //-- Load viewControllers
    let firstViewController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("first_view_controller")
    let secondViewController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("second_view_controller")
    
    //-- Var
    var viewControllers: Array<UIViewController> = []
    var cellIsDragging = false
    var cellDidSwipe = false
    
    //-- View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //-- Put viewControllers in scrollView
        initViewControllers()
        initScrollView()
        addPanGesture()
        
        //-- Active delegates
        scrollView.delegate = self
        swipeCellDelegate = self
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //-- Init View Controllers method
    func initViewControllers() {
        
        //-- Append viewControllers in view viewControllers Array
        viewControllers.append(firstViewController)
        viewControllers.append(secondViewController)
        
        //-- Loop on viewControllers Array to append View Controllers in scrollView at the right position
        var originPositionX: CGFloat = 0
        for viewController in viewControllers {
            let originPositionY = viewController.view.frame.origin.y
            let width = viewController.view.frame.width
            let height = viewController.view.frame.height
            
            viewController.view.frame = CGRect(x: originPositionX, y: originPositionY, width: width, height: height)
            scrollView.addSubview(viewController.view)
            
            originPositionX += width
        }
    }
    
    //-- Init scrollView method
    func initScrollView() {
        scrollView.pagingEnabled = true
        scrollView.contentSize = self.view.frame.size
        scrollView.autoresizesSubviews = false
    }
    
    //-- Add pan gesture method
    func addPanGesture() {
        let pan: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
        pan.delegate = self
        self.view.addGestureRecognizer(pan)
    }
    
    //-- Pan target
    func handlePan(panGestureReconizer: UIPanGestureRecognizer) {
        
        //-- Get location and translation in view
        let translation = panGestureReconizer.translationInView(self.view)
        let location = panGestureReconizer.locationInView(self.view)
        
        //-- Send translation and location from pan gesture to panDelegate to be be receive in firstViewController
        panDelegate?.handlePan(isDragging: translation, locationInView: location)
        
        //-- Statetement if cell did Swipe the scrollView content size will increase
        if cellDidSwipe {
            scrollView.contentSize.width = self.view.frame.size.width * CGFloat(viewControllers.count)
        }
        
        //-- reset cell frame when the user take off his finger
        if panGestureReconizer.numberOfTouches() == 0 {
            panDelegate?.handlePan(didEndDragging: true)
            cellDidSwipe = false
        }
    }
}

//-- Extensions ViewController
extension ViewController: UIScrollViewDelegate {
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        //-- Check what view is visible
        let firstView = CGRectIntersectsRect(scrollView.bounds, firstViewController.view.frame)
        let secondView = CGRectIntersectsRect(scrollView.bounds, secondViewController.view.frame)
        
        //-- First view is fully displayed
        if firstView && !secondView {
            //scrollView.contentSize.width = self.view.frame.size.width
            //-- Tell to pan delegate firstView is displayed
            panDelegate?.handlePan(visibleView: firstViewController.view)
            
            //-- Reset scrollView content size
            scrollView.contentSize = self.view.frame.size
        }
        
        //-- Second view is fully displayed
        if secondView && !firstView {
            //-- Tell to pan delegate secondView is displayed
            panDelegate?.handlePan(visibleView: secondViewController.view)
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        let firstView = CGRectIntersectsRect(scrollView.bounds, firstViewController.view.frame)
        let secondView = CGRectIntersectsRect(scrollView.bounds, secondViewController.view.frame)
        let translation = scrollView.panGestureRecognizer.translationInView(self.view)
        
        //-- Statement: If firstView is fully displayed and the translation come left to right
        if firstView && !secondView && translation.x < 0 {
            panDelegate?.handlePan(viewWillAppear: secondViewController.view)
        }
        
        //-- Avoid scrollView translation gap
        scrollView.panGestureRecognizer.setTranslation(CGPointZero, inView: self.view)
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension ViewController: SwipeCellDelegate {
    func swipeCell(cellDidSwipe didSwipe: Bool) {
        //-- Get cellDidSpwipe value
        cellDidSwipe = didSwipe
    }
}

