//
//  MainTabBar.swift
//  WeiboSwift
//
//  Created by wangshiyu13 on 15/3/7.
//  Copyright (c) 2015年 wangshiyu13. All rights reserved.
//

import UIKit

class MainTabBar: UITabBar {

    /// 点击微博按钮的回调
    var composedButtonClicked: (()->())?
    
    /// 按钮综述
    let buttonCount = 5
    
    /// 创建写微博的按钮
    lazy var composedBtn: UIButton? = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "tabbar_compose_icon_add"), forState: .Normal)
        btn.setBackgroundImage(UIImage(named: "tabbar_compose_icon_add_highlighted"), forState: .Highlighted)
        btn.setBackgroundImage(UIImage(named: "tabbar_compose_button"), forState: UIControlState.Normal)
        btn.setBackgroundImage(UIImage(named: "tabbar_compose_button_highlighted"), forState: UIControlState.Highlighted)
        btn.addTarget(self, action: "clickCompose", forControlEvents: .TouchUpInside)
        return btn
    }()
    
    /// 写微博的点击事件
    func clickCompose() {
        if composedButtonClicked != nil {
            composedButtonClicked!()
        }
    }
    
    /// MARK:生命周期方法
    override func awakeFromNib() {
        self.addSubview(composedBtn!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setButtonsFrame()
    }
    
    /// 设置按钮的frame
    func setButtonsFrame() {
        let w = self.bounds.size.width / CGFloat(buttonCount)
        let h = self.bounds.size.height
        
        var idx = 0
        for view in self.subviews as! [UIView] {
            if view is UIControl && !(view is UIButton) {
                let r = CGRectMake(CGFloat(idx) * w, 0, w, h)
                view.frame = r
                idx = idx + 1
                
                if idx == 2 {
                    idx = idx + 1
                }
            }
        }
        composedBtn!.frame = CGRectMake(0, 0, w, h)
        composedBtn!.center = CGPointMake(self.center.x, h * 0.5)
    }
}
