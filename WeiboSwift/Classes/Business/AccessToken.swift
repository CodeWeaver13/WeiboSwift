//
//  AccessToken.swift
//  WeiboSwift
//
//  Created by wangshiyu13 on 15/3/6.
//  Copyright (c) 2015年 wangshiyu13. All rights reserved.
//

import UIKit

class AccessToken: NSObject, NSCoding {
    /// 用于调用access_token, 接口获取授权后的access token
    var access_token: String?
    
    /// access_token的生命周期，单位是秒数
    var expires_in: NSNumber? {
        didSet {
            expiresDate = NSDate(timeIntervalSinceNow: expires_in!.doubleValue)
            println("过期日期 \(expiresDate)")
        }
    }
    /// 过期日期
    var expiresDate: NSDate?
    
    /// 是否过期，用于过期时期和当前时间进行判断
    var isExpired: Bool {
        return expiresDate?.compare(NSDate()) == NSComparisonResult.OrderedAscending
    }
    
    /// access_token 的生命周期，即将废弃的参数，请使用expriess_in
    var remind_in: NSNumber?
    
    /// 当前用户的UID
    /// 目前版本的Swift归档整数类型使用NSNumber会不正常，只能使用Int
    var uid: Int = 0
    
    /// 构造函数，会覆盖系统的init方法
    init(dict: NSDictionary) {
        super.init()
        self.setValuesForKeysWithDictionary(dict as [NSObject: AnyObject])
    }
    
    /// 沙盒路径
    static var tokenPath: String {
        return NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, .UserDomainMask, true).last!.stringByAppendingPathComponent("token.plist") as String
    }
    
    /// 将数据保存到沙盒
    func saveAccessToken() {
        NSKeyedArchiver.archiveRootObject(self, toFile: AccessToken.tokenPath)
    }
    
    /// 从沙盒读取本地数据
    class func loadAccessToken() -> AccessToken? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(tokenPath) as? AccessToken
    }
    
    /// 归档方法
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(access_token)
        aCoder.encodeObject(expiresDate)
        // 基本数据需要将NSNumber改为Int
        aCoder.encodeInteger(uid, forKey: "uid")
    }
    
    /// 解档方法
    required init(coder aDecoder: NSCoder) {
        access_token = aDecoder.decodeObject() as? String
        expiresDate = aDecoder.decodeObject() as? NSDate
        uid = aDecoder.decodeIntegerForKey("uid")
    }
}

/// extension是分类，跟OC一样，不能存储属性
/// 如果要答应对象信息，即OC的description,在swift中需要遵守协议DebugPrintable
extension AccessToken: DebugPrintable {
    override var debugDescription: String {
        let dict = self.dictionaryWithValuesForKeys(["access_token", "expriesDate", "uid"])
        return "\(dict)"
    }
}