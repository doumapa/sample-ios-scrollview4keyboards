//
//  MainView.swift
//  KeyboardPos
//
//  Created by makoto kaneko on 2018/02/24.
//  Copyright © 2018年 makoto kaneko. All rights reserved.
//

import UIKit
import ReactiveCocoa

class MainView: UIView {

  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var scrollContentView: UIView!
  
  // MARK: -

  override func awakeFromNib() {
    super.awakeFromNib()
    configureForControllers()
    bindSignal()
  }

  // MARK: -

  private func configureForControllers() {
    guard let scrollView = scrollView, let scrollContentView = scrollContentView else {
      return
    }
    scrollView.keyboardDismissMode = .interactive
    scrollContentView.addGestureRecognizer({ (gesture: UIGestureRecognizer) -> UIGestureRecognizer in
      gesture.reactive.stateChanged.observeValues { [unowned self] _ in
        self.endEditing(true)
      }
      return gesture
    } (UITapGestureRecognizer()))
  }
  
  private func bindSignal() {
    func keyboardWillShowOrHide(notification: Notification) {
      guard let scrollView = scrollView, let userInfo = notification.userInfo,
        let endValue = userInfo[UIKeyboardFrameEndUserInfoKey],
        let durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey],
        let curveValule = userInfo[UIKeyboardAnimationCurveUserInfoKey] else {
          return
      }
      let endRect = convert(endValue as! CGRect, to: self.window)
      let keyboardOverlap = scrollView.frame.maxY - endRect.origin.y
      scrollView.contentInset.bottom = keyboardOverlap
      scrollView.scrollIndicatorInsets.bottom = keyboardOverlap
      UIView.animate(withDuration: durationValue as! TimeInterval,
                     delay: 0,
                     options: UIViewAnimationOptions(rawValue: UInt((curveValule as! Int) << 16)),
                     animations: { [unowned self] in
                      self.layoutIfNeeded()
        },
                     completion: nil)
    }
    
    NotificationCenter.default.reactive.notifications(forName: NSNotification.Name.UIKeyboardWillShow)
      .take(duringLifetimeOf: self)
      .observeValues { (notification: Notification) in
        keyboardWillShowOrHide(notification: notification)
    }
    NotificationCenter.default.reactive.notifications(forName: NSNotification.Name.UIKeyboardWillHide)
      .take(duringLifetimeOf: self)
      .observeValues { (notification: Notification) in
        keyboardWillShowOrHide(notification: notification)
    }
  }
  
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

