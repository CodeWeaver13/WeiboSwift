//
//  WeiboData.swift
//  WeiboSwift
//
//  Created by wangshiyu13 on 15/3/7.
//  Copyright (c) 2015年 wangshiyu13. All rights reserved.
//

import UIKit

///  微博数据URL
private let WB_Home_Timeline_URL = "https://api.weibo.com/2/statuses/home_timeline.json"

class WeiboPicURL: NSObject {
    ///  缩略图
    var thumbnail_pic: String?
}

///  微博Cell模型
class WeiboModel: NSObject, Dict2ModelProtocol {
    ///  微博创建时间
    var created_at: String?
    ///  微博ID
    var id: Int = 0
    ///  微博信息内容
    var text: String?
    ///  微博来源
    var source: String?
    ///  转发数
    var reposts_count: Int = 0
    ///  评论数
    var comments_count: Int = 0
    ///  表态数
    var attitudes_count: Int = 0
    ///  用户信息
    var user: UserInfo?
    ///  转发微博
    var retweeted_status: WeiboModel?
    ///  图片数组
    var pic_urls: [WeiboPicURL]?
    ///  外部调用的图片数组，如果是原创微博，使用pic_urls，如果是转发的用retweeted_status?.pic_urls
    var picUrls: [WeiboPicURL]? {
        if retweeted_status != nil {
            return retweeted_status?.pic_urls
        } else {
            return pic_urls
        }
    }
    
    static func customClassMapping() -> [String : String]? {
        return ["pic_urls": "\(WeiboPicURL.self)",
            "user": "\(UserInfo.self)",
            "retweeted_status": "\(WeiboModel.self)"]
    }
}

///  微博数据列表模型
class WeiboData: NSObject, Dict2ModelProtocol {
    ///  微博数组
    var statuses: [WeiboModel]?
    ///  微博总数
    var total_number: Int = 0
    ///  未读数量
    var has_unread: Int = 0
    
    static func customClassMapping() -> [String : String]? {
        return ["statuses": "\(WeiboModel.self)"]
    }
    
    ///  加载微博数据
    ///  当加载成功时，进行字典转模型，并回调转换后的模型
    ///  :param: completion 回调
    class func loadData(completion: (data: WeiboData?, error: NSError?)-> ()) {
        let net = NetManager.sharedManager
        if let token = AccessToken.loadAccessToken()?.access_token {
            let params = ["access_token": token]
            
            net.requestJSON(.GET, WB_Home_Timeline_URL, params) { (result, error) -> () in
                if error != nil {
                    completion(data: nil, error: error!)
                    return
                }
                
                var modelTools = Dict2ModelManager.sharedManager
                var model = modelTools.objectWithDictionary(result as! NSDictionary, cls: WeiboData.self) as? WeiboData
                
                if let urls = WeiboData.pictureURLs(model?.statuses) {
                    net.downloadImgs(urls) {
                        (_, _) -> () in
                        completion(data: model, error: nil)
                    }
                } else {
                    println(model)
                    completion(data: model, error: nil)
                }
            }
        }
    }
    
    ///  取出微博模型数组中的图片URL数组
    ///
    ///  :param: statuses 微博模型数组
    ///
    ///  :returns: 图片URL数组
    class func pictureURLs(statuses: [WeiboModel]?) -> [String]? {
        if statuses == nil {
            return nil
        }
        
        var list = [String]()
        for data in statuses! {
            if let urls = data.picUrls {
                for pic in urls {
                    list.append(pic.thumbnail_pic!)
                }
            }
        }
        
        if list.count > 0 {
            return list
        } else {
            return nil
        }
    }
}