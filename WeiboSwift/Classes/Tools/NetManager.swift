//
//  NetManager.swift
//  WeiboSwift
//
//  Created by wangshiyu13 on 15/3/6.
//  Copyright (c) 2015年 wangshiyu13. All rights reserved.
//

import Foundation

///  网络访问接口
///  用于隔离app和第三方框架之间的网络访问
private let instance = NetManager()
class NetManager {
    class var sharedManager: NetManager {
        return instance
    }
    
    // 尾随闭包
    typealias Completion = (result: AnyObject?, error: NSError?) -> ()
    
    // 全局的一个网络框架实例
    private let net = NetFramework()
    
    /// 传参给NetManager
    func requestJSON(method: HTTPMethod, _ urlStr: String, _ params: [String: String]?, _ completion: Completion) {
        net.requestJSON(method, urlStr, params, completion)
    }
    
    ///  异步下载图像
    ///
    ///  :param: urlStr     url
    ///  :param: completion 回调
    func requestImage(urlStr: String, _ completion: Completion) {
        net.requestImage(urlStr, completion)
    }
    
    ///  下载多张图片
    ///
    ///  :param: urls       图片URL数据
    ///  :param: completion 所有图片下载完成后的回调
    func downloadImgs(urls: [String], _ completion: Completion) {
        net.downloadImages(urls, completion)
    }
    
    ///  下载单张图片并保存到沙盒
    ///
    ///  :param: urlStr     图片的URL
    ///  :param: completion 回调
    func downloadImg(urlStr: String, _ completion: Completion) {
        net.downloadImage(urlStr, completion)
    }
    
    ///  完整的URL缓存路径
    func fullImgCachePath(urlStr: String) -> String {
        return net.fullImageCachePath(urlStr)
    }
}
