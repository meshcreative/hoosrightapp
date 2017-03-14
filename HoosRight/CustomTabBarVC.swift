//
//  CustomTabBarVC.swift
//  HoosRight
//
//  Created by ios on 08/03/17.
//  Copyright © 2017 koios. All rights reserved.
//

import UIKit


class CustomTabBarVC: UITabBarController,UIViewControllerTransitioningDelegate {
    var button: UIButton = UIButton()
    //let customPresentAnimationController = CustomPresentAnimationController()
    let transition = BubbleTransition()
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.delegate = self
        if let items = tabBar.items  {
            if items.count > 0 {
                let itemToDisable = items[items.count - 3]
                itemToDisable.isEnabled = false
            }
        }
        let middleImage:UIImage = UIImage(named:"camera")!
        let frame = CGRect(x: 0.0, y: 0.0, width: middleImage.size.width, height: middleImage.size.height)
        button = UIButton(frame: frame)
        button.setBackgroundImage(middleImage, for: UIControlState())
        let heightDifference:CGFloat = middleImage.size.height - self.tabBar.frame.size.height
        if heightDifference < 0 {
            button.center = self.tabBar.center;
        }
        else
        {
            var center:CGPoint = self.tabBar.center;
            center.y = center.y - heightDifference/2.0;
            button.center = center;
        }
        
        button.addTarget(self, action: #selector(CustomTabBarVC.changeTabToMiddleTab(_:)), for: UIControlEvents.touchUpInside)
        
        self.view.addSubview(button)
    }
    /*
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // just return the custom TransitioningObject object that conforms to UIViewControllerAnimatedTransitioning protocol
        if self.tabBar.selectedItem?.tag == 6 {
            let animatedTransitioningObject = CustomPresentAnimationController()
            return animatedTransitioningObject
        }
        else {
            return nil
        }
    }
    
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print("the selected index is : \(tabBar.items?.index(of: item))")
    }
    */
    func changeTabToMiddleTab(_ sender:UIButton)
    {
        print("Center Button pressed")
        let vc:CameraVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "camera") as! CameraVC
        vc.transitioningDelegate = self
        //vc.transitioningDelegate = customPresentAnimationController
        self.present(vc, animated: true, completion: nil)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = button.center
        //transition.bubbleColor = button.backgroundColor!
        return transition
    }
    
//    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        transition.transitionMode = .dismiss
//        transition.startingPoint = button.center
//        //transition.bubbleColor = transitionButton.backgroundColor!
//        return transition
//    }
}




/*

class CustomPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 2.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let finalFrameForVC = transitionContext.finalFrame(for: toViewController)
        let containerView = transitionContext.containerView
        let bounds = UIScreen.main.bounds
        toViewController.view.frame = finalFrameForVC.offsetBy(dx: 0, dy: bounds.size.height)
        containerView.addSubview(toViewController.view)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: .curveLinear, animations: {
            fromViewController.view.alpha = 0.5
            toViewController.view.frame = finalFrameForVC
        }, completion: {
            finished in
            transitionContext.completeTransition(true)
            fromViewController.view.alpha = 1.0
        })
    }
    
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let presentationAnimator = CustomPresentAnimationController()
        return presentationAnimator
    }
    
}


class CustomDismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let finalFrameForVC = transitionContext.finalFrame(for: toViewController)
        let containerView = transitionContext.containerView
        toViewController.view.frame = finalFrameForVC
        toViewController.view.alpha = 0.5
        containerView.addSubview(toViewController.view)
        containerView.sendSubview(toBack: toViewController.view)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            fromViewController.view.frame = fromViewController.view.frame.insetBy(dx: fromViewController.view.frame.size.width / 2, dy: fromViewController.view.frame.size.height / 2)
            toViewController.view.alpha = 1.0
        }, completion: {
            finished in
            transitionContext.completeTransition(true)
        })
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}
*/
