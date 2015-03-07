//
//  OAuthViewController.swift
//  WeiboSwift
//
//  Created by wangshiyu13 on 15/2/28.
//  Copyright (c) 2015年 wangshiyu13. All rights reserved.
//

import UIKit

let WB_Login_Successed_Notification = "WB_Login_Successed_Notification"
class OAuthViewController: UIViewController {
    let WB_API_URL_String       = "https://api.weibo.com"
    let WB_Redirect_URL_String  = "http://www.itheima.com"
    let WB_Client_ID            = "1931646285"
    let WB_Client_Secret        = "c1cdb3d0d665be60bc7e70312da184e8"
    let WB_Grant_Type           = "authorization_code"
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadAuthPage()
        webView?.delegate = self
    }
    
    func loadAuthPage() {
        let urlStr = "https://api.weibo.com/oauth2/authorize?client_id=\(WB_Client_ID)&redirect_uri=\(WB_Redirect_URL_String)"
        let url = NSURL(string: urlStr)
        webView!.loadRequest(NSURLRequest(URL: url!))
    }
}

extension OAuthViewController: UIWebViewDelegate {
    func continueWithCode(url: NSURL) -> (load: Bool, code: String?, reloadPage: Bool) {
        let urlString = url.absoluteString!
        
        if !urlString.hasPrefix(WB_API_URL_String) {
            if urlString.hasPrefix(WB_Redirect_URL_String) {
                if let query = url.query {
                    let codestr: NSString = "code="
                    
                    if query.hasPrefix(codestr as String) {
                        var q = query as NSString!
                        return (false, q.substringFromIndex(codestr.length), false)
                    } else {
                        return (false, nil, true)
                    }
                }
            }
            return (false, nil, false)
        }
        return (true, nil, false)
    }
    
    // 页面重定向
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
//        println(request.URL)
        
        let result = continueWithCode(request.URL!)
        if let code = result.code {
            println("需要换token\(code)")
            
            let params = ["client_id": WB_Client_ID,
                "client_secret": WB_Client_Secret,
                "grant_type": WB_Grant_Type,
                "redirect_uri": WB_Redirect_URL_String,
                "code": code]
            let net = NetManager.sharedManager
            net.requestJSON(.POST, "https://api.weibo.com/oauth2/access_token", params) { (result, error) -> () in
                let token = AccessToken(dict: result as! NSDictionary)
                token.saveAccessToken()
                NSNotificationCenter.defaultCenter().postNotificationName(WB_Login_Successed_Notification, object: nil)
            }
        }
        if !result.load {
            if result.reloadPage {
                SVProgressHUD.showInfoWithStatus("求放过", maskType: .Gradient)
                loadAuthPage()
            }
        }
        return result.load
    }
}