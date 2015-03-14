//
//  AppDelegate.swift
//  WeiboSwift
//
//  Created by wangshiyu13 on 15/2/28.
//  Copyright (c) 2015年 wangshiyu13. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        
        let abc = "abc"
        println("\(abc.md5)")
        
        if let token = AccessToken.loadAccessToken() {
            showMainInterface()
        } else {
            // 添加通知监听，监听用户登录成功
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "showMainInterface", name: WB_Login_Successed_Notification, object: nil)
        }
        return true
    }

    ///  显示主界面
    func showMainInterface() {
        // 通知在不需要的时候，要及时销毁
        NSNotificationCenter.defaultCenter().removeObserver(self, name: WB_Login_Successed_Notification, object: nil)
        
        window!.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as? UIViewController
        
        // 设置 nav 按钮的外观
        setNavAppearance()
    }
    
    ///  设置按钮的 tintColor
    func setNavAppearance() {
        UINavigationBar.appearance().tintColor = UIColor.orangeColor()
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

