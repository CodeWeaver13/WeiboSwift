//
//  NetManagerTests.swift
//  WeiboSwift
//
//  Created by wangshiyu13 on 15/3/6.
//  Copyright (c) 2015年 wangshiyu13. All rights reserved.
//

import UIKit
import XCTest

class NetManagerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        let manager1 = NetManager.sharedManager
        let manager2 = NetManager.sharedManager
        XCTAssert(manager1 === manager2, "网络单例创建失败")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
