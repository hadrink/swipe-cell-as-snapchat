//
//  FirstViewController.swift
//  SwipeCellAsSnapChat
//
//  Created by Rplay on 13/07/16.
//  Copyright © 2016 rplay. All rights reserved.
//

import Foundation
import UIKit

//-- SwipeCellDelegate protocol
weak var swipeCellDelegate: SwipeCellDelegate?

protocol SwipeCellDelegate: class {
    func swipeCell(cellDidSwipe didSwipe: Bool)
}

//-- FirstViewController
class FirstViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    
    var indexPath: NSIndexPath?
    var swipeViewOriginY: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        panDelegate = self
    }
}

//-- Extensions FirstViewController
extension FirstViewController: UITableViewDataSource {
    
    //-- Return nb of rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    //-- Display cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //-- Get cell
        let cell: CustomCell = tableView.dequeueReusableCellWithIdentifier("custom_cell") as! CustomCell
        cell.testLabel.text = "test"
        
        //-- Create swipe background view
        let swipeView: UIView = UIView(frame: cell.frame)
        swipeView.frame = cell.frame
        swipeView.frame.size.width = tableView.frame.width
        swipeView.frame.origin.y = swipeViewOriginY
        swipeView.backgroundColor = UIColor.redColor()
        tableView.insertSubview(swipeView, atIndex: 0)
        
        //-- Inc Y position
        swipeViewOriginY += cell.frame.height
        
        //-- Return cell to display
        return cell
    }
}

extension FirstViewController: HandlePanDelegate {
    
    //-- Get the scrollView handlePan
    func handlePan(isDragging translation: CGPoint, locationInView location: CGPoint) {
        
        //-- Get indexPath for the cell touched or return if nil
        guard let indexPathForSwipeCell = tableView.indexPathForRowAtPoint(location) else {
            print("IndexPath \(tableView.indexPathForSelectedRow)")
            swipeCellDelegate?.swipeCell(cellDidSwipe: false)
            return
        }
        
        //-- Set indexPath to be use in an other method
        indexPath = indexPathForSwipeCell
        let cell: CustomCell = tableView.cellForRowAtIndexPath(indexPathForSwipeCell) as! CustomCell
        
        //-- Statemment : if cell position < 0 : active swipe
        if cell.frame.origin.x < -50 {
            swipeCellDelegate?.swipeCell(cellDidSwipe: true)
        } else {
            swipeCellDelegate?.swipeCell(cellDidSwipe: false)
            cell.transform = CGAffineTransformMakeTranslation(translation.x, 0)
        }
    }
    
    func handlePan(visibleView visible: UIView) {
        if visible == self.view {
            print("First view is fully displayed")
        }
    }
    
    //-- Method called to replace viewDidAppear
    func handlePan(viewWillAppear view: UIView) {
        if view != self.view {
            print("Second view will appear")
        }
    }
    
    //-- Method called when the user touch up the screen
    func handlePan(didEndDragging didEnd: Bool) {
        
        //-- Reset cell frame
        let cells = tableView.visibleCells
        for cell in cells {
            UIView.animateWithDuration(0.2, animations: {
                cell.transform = CGAffineTransformIdentity
            })
        }
    }
}
