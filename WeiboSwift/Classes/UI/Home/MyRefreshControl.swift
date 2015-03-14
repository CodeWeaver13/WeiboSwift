//
//  MyRefreshControl.swift
//  WeiboSwift
//
//  Created by wangshiyu13 on 15/3/10.
//  Copyright (c) 2015年 wangshiyu13. All rights reserved.
//

import UIKit

class MyRefreshControl: UIRefreshControl {

    lazy var refreshView: RefreshView = {
        return NSBundle.mainBundle().loadNibNamed("MyRefreshView", owner: nil, options: nil).last as! RefreshView
    }()
    override func willMoveToWindow(newWindow: UIWindow?) {
        refreshView.frame = self.bounds
    }
    
    override func awakeFromNib() {
        self.addSubview(refreshView)
        self.addObserver(self, forKeyPath: "frame", options: .New, context: nil)
    }
    
    deinit {
        self.removeObserver(self, forKeyPath: "frame")
    }
    // 动画效果状态
    var isLoading = false
    // 旋转提示状态
    var isRotateTip = false
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if self.frame.origin.y > 0 {
            return
        }
        if refreshing && isLoading {
            refreshView.showLoading()
            isLoading = true
            return
        }
        if self.frame.origin.y < -50 && !isRotateTip {
            isRotateTip = true
            refreshView.rotateIcon(isRotateTip)
        } else if self.frame.origin.y > -50 && isRotateTip {
            isRotateTip = false
            refreshView.rotateIcon(isRotateTip)
        }
    }
   override func endRefreshing() {
        super.endRefreshing()
        refreshView.stopLoading()
        isLoading = false
    }
}

class RefreshView: UIView {
    class func refreshView(isLoading: Bool = false) -> RefreshView {
        let v = NSBundle.mainBundle().loadNibNamed("MyRefreshView", owner: nil, options: nil).last as! RefreshView
        v.tipView.hidden = isLoading
        v.loadingView.hidden = !isLoading
        return v
    }
    
    ///  提示视图
    @IBOutlet weak var tipView: UIView!
    ///  提示图标
    @IBOutlet weak var tipIcon: UIImageView!
    ///  加载视图
    @IBOutlet weak var loadingView: UIView!
    ///  加载图标
    @IBOutlet weak var loadingIcon: UIImageView!
    
    func showLoading() {
        tipView.hidden = true
        loadingView.hidden = true
        
        loadingAni()
    }
    /// 开始动画
    func loadingAni() {
        let ani = CABasicAnimation(keyPath: "transform.rotation")
        ani.toValue = 2 * M_PI
        ani.repeatCount = MAXFLOAT
        ani.duration = 0.5
        loadingIcon.layer.addAnimation(ani, forKey: nil)
    }
    /// 停止动画
    func stopLoading() {
        loadingIcon.layer.removeAllAnimations()
        tipView.hidden = false
        loadingView.hidden = true
    }
    /// 旋转图标
    func rotateIcon(clockWise: Bool) {
        var angle = CGFloat(M_PI + 0.01)
        if clockWise {
            angle = CGFloat(M_PI - 0.01)
        }
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.tipIcon.transform = CGAffineTransformRotate(self.tipIcon.transform, angle)
        })
    }
    var parentView: UITableView?
    func addPullOberserver(parentView: UITableView, pullLoadData: ()->()) {
        self.parentView = parentView
        self.pullLoadData = pullLoadData
        self.parentView?.addObserver(self, forKeyPath: "contentOffset", options: .New, context: nil)
    }
    deinit {
        parentView!.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    var isPullLoading = false
    var pullLoadData: (()->())?
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if self.frame.origin.y == 0 {
            return
        }
        if (parentView!.bounds.size.height + parentView!.contentOffset.y) > CGRectGetMaxY(self.frame) {
            if !isPullLoading {
                isPullLoading = true
                showLoading()
                if pullLoadData != nil {
                    pullLoadData!()
                }
            }
        }
    }
    
    /// 上拉刷新完成
    func pullFinished() {
        // 重新设置刷新视图的属性
        isPullLoading = false
        
        // 停止动画
        stopLoading()
    }
}

