//
//  OAuthViewControllerTests.swift
//  WeiboSwift
//
//  Created by wangshiyu13 on 15/3/6.
//  Copyright (c) 2015年 wangshiyu13. All rights reserved.
//

import UIKit
import XCTest

class OAuthViewControllerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testRandomCode() {
        for i in 0...20 {
            let democode = "7b54cde6155f23bc189fad24c150c6a7\(i)"
            let url = NSURL(string: "http://www.itheima.com/?code=\(democode)")!
            let result = oauthVC!.continueWithCode(url)
            XCTAssertFalse(result.load, "不应该加载")
            XCTAssert(result.code == democode, "code 不正确")
        }
    }

    func testContiuneWithCode() {
        // 登录界面的 URL
        // 应该加载，没有 code
        var url = NSURL(string: "https://api.weibo.com/oauth2/authorize?client_id=1931646285&redirect_uri=http://www.itheima.com")!
        var result = oauthVC!.continueWithCode(url)
        
        XCTAssertTrue(result.load, "应该加载")
        XCTAssertNil(result.code, "不应该有code")
        
        // 点击注册按钮
        // 不加载，没有code
        url = NSURL(string: "http://weibo.cn/dpool/ttt/h5/reg.php?wm=4406&appsrc=4o1TqS&backURL=https%3A%2F%2Fapi.weibo.com%2F2%2Foauth2%2Fauthorize%3Fclient_id%3D1931646285%26response_type%3Dcode%26display%3Dmobile%26redirect_uri%3Dhttp%253A%252F%252Fwww.itheima.com%26from%3D%26with_cookie%3D")!
        result = oauthVC!.continueWithCode(url)
        XCTAssertFalse(result.load, "不应该加载")
        XCTAssertNil(result.code, "不应该有code")
        
        // 登录成功
        url = NSURL(string: "https://api.weibo.com/oauth2/authorize")!
        result = oauthVC!.continueWithCode(url)
        XCTAssertTrue(result.load, "应该加载")
        XCTAssertNil(result.code, "不应该有code")
        
        // 授权回调 － 测试用例
        let democode = "7b54cde6155f23bc189fad24c150c6a7"
        
        url = NSURL(string: "http://www.itheima.com/?code=\(democode)")!
        result = oauthVC!.continueWithCode(url)
        XCTAssertFalse(result.load, "不应该加载")
        XCTAssert(result.code == democode, "code 不正确")
        
        // 取消授权
        url = NSURL(string: "http://www.itheima.com/?error_uri=%2Foauth2%2Fauthorize&error=access_denied&error_description=user%20denied%20your%20request.&error_code=21330")!
        result = oauthVC!.continueWithCode(url)
        XCTAssertFalse(result.load, "不应该加载")
        XCTAssertNil(result.code, "不应该有code")
        
        // 切换账号
        url = NSURL(string: "http://login.sina.com.cn/sso/logout.php?entry=openapi&r=https%3A%2F%2Fapi.weibo.com%2Foauth2%2Fauthorize%3Fclient_id%3D1931646285%26redirect_uri%3Dhttp%3A%2F%2Fwww.itheima.com")!
        result = oauthVC!.continueWithCode(url)
        XCTAssertFalse(result.load, "不应该加载")
        XCTAssertNil(result.code, "不应该有code")
    }
    
    /// MARK:测试OA控制器
    func testRootView() {
        let view = oauthVC!.view as! UIWebView
        XCTAssert(view.isKindOfClass(UIWebView.self), "根视图类型不是UIWebView")
    }
    
    func testRootViewDelegate() {
        let webView = oauthVC!.view as! UIWebView
        XCTAssert(webView.delegate === oauthVC!, "oauthVC没设置代理")
    }
    
    // 切记要给sb添加tests
    lazy var oauthVC: OAuthViewController? = {
        let bundle = NSBundle(forClass: OAuthViewControllerTests.self)
        let sb = UIStoryboard(name: "OAuth", bundle: bundle)
        return sb.instantiateInitialViewController() as? OAuthViewController
    }()
}
