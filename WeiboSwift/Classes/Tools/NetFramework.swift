//
//  NetFramework.swift
//  WeiboSwift
//
//  Created by wangshiyu13 on 15/3/6.
//  Copyright (c) 2015年 wangshiyu13. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
}

public class NetFramework {
    /// 全局网络会话
    lazy var session: NSURLSession? = {
        return NSURLSession.sharedSession()
    }()
    
    // 定义闭包类型，类型别名->首字母一定要大写
    public typealias Completion = (result: AnyObject?, error: NSError?) ->()
    
    // 静态属性，在Swift中类属性可以返回值但是不能存储数值
    static let errorDomain = "com.wangshiyu13.error"
    
    // 静态属性，缓存路径
    private static var imageCachePath = "com.wangshiyu13.imageCache"
    
    /// 查询字符串的方法
    func queryString(params: [String: String]?) -> String? {
        if params == nil {
            return nil
        }
        var array = [String]()
        for (key, value) in params! {
            let str = key + "=" + value.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            array.append(str)
        }
        return join("&", array)
    }
    
    func request(method: HTTPMethod, _ urlStr: String, _ params: [String: String]?) -> NSURLRequest? {
        // 如果为空则直接返回
        if urlStr.isEmpty {
            println("网络请求不可用")
            return nil
        }
        
        var urlString = urlStr
        var rq: NSMutableURLRequest?
        
        if method == HTTPMethod.POST {
            // 1. 生成查询字符串
            if let query = queryString(params) {
                rq = NSMutableURLRequest(URL: NSURL(string: urlString)!)
                // 请求方法
                rq!.HTTPMethod = method.rawValue
                // 请求体
                rq!.HTTPBody = query.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
            }
        } else {
            let query = queryString(params)
            
            if query != nil {
                urlString += "?" + query!
            }
            
            rq = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        }
        return rq
    }
    
    public func requestJSON(method: HTTPMethod, _ urlStr: String, _ params: [String: String]?, _ completion: Completion) {
        // 实例化网络请求
        if let requestIns = request(method, urlStr, params) {
            session!.dataTaskWithRequest(requestIns, completionHandler: { (data, _, error) -> Void in
                if error != nil {
                    completion(result: nil, error: error)
                    return
                }
                
                // 反序列化
                let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: .allZeros, error: nil)
                
                if json == nil {
                    // 如果没有结果
                    let error = NSError(domain: NetFramework.errorDomain, code: -1, userInfo: ["error" : "无法反序列化"])
                } else {
                    // 如果有结果
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completion(result: json, error: nil)
                    })
                }
            }).resume()
            return
        }
        
        let error = NSError(domain: NetFramework.errorDomain, code: -1, userInfo: ["error": "无法建立请求"])
        completion(result: nil, error: error)
    }
    
    /// 图像缓存路径
    lazy var cachePath: String? = {
        // 缓存目录
        var path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, .UserDomainMask, true).last as! String
        path = path.stringByAppendingPathComponent(imageCachePath)
        
        // 检查目录是否存在
        var isDirectory: ObjCBool = true
        let exists = NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDirectory)
        // 如果有同名的文件需要全部删除
        // 一定要判断是否是文件，否则目录也会同样删除
        if exists && !isDirectory {
            var fileErr: NSError? = nil
            NSFileManager.defaultManager().removeItemAtPath(path, error: &fileErr)
            if fileErr != nil {
                println(fileErr)
            }
        }
        // 直接创建目录，如果目录已经存在，就什么都不做
        // withIntermediateDirectories 智能创建层级目录
        var pathErr: NSError? = nil
        NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil, error: &pathErr)
        if pathErr != nil {
            println(pathErr)
        }
        return path
    }()
    
    /// 完整的URL缓存路径
    func fullImageCachePath(urlStr: String) -> String {
        var path = urlStr.md5
        return cachePath!.stringByAppendingPathComponent(path)
    }
    
    func downloadImage(urlStr: String, _ completion: Completion) {
        // 目标路径
        let path = fullImageCachePath(urlStr)
        // 缓存检测，如果文件已下载则直接返回
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            completion(result: nil, error: nil)
            return
        }
        // 下载图像
        if let url = NSURL(string: urlStr) {
            self.session!.downloadTaskWithURL(url, completionHandler: { (location, _, error) -> Void in
                // 错误处理
                if error != nil {
                    completion(result: nil, error: error)
                    return
                }
                
                // 将文件复制到缓存路径
                NSFileManager.defaultManager().copyItemAtPath(location.path!, toPath: path, error: nil)
                // 直接回调， 不传递任何参数
                completion(result: nil, error: nil)
            }).resume()
        }
    }
        
    ///  下载多张图片
    ///
    ///  :param: urls       图片的url数组
    ///  :param: completion 所有图片下载完成后的回调
    func downloadImages(urls: [String], _ completion: Completion){
        // 利用调度组统一监听一组一步任务执行完毕
        let group = dispatch_group_create()
        
        // 遍历数组
        for url in urls {
            // 进入调度组
            dispatch_group_enter(group)
            downloadImage(url, { (result, error) -> () in
                // 一张图片下载完成，会自动保存在缓存目录
                // 下载多张图片的时候， 有时候有些有错误，有些没错误
                // 暂时不处理
                // 离开调度组
                dispatch_group_leave(group)
            })
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue()) { () -> Void in
            // 所有任务完成后的回调
            completion(result: nil, error: nil)
        }
    }
    
    ///  异步下载下载网络图像
    ///
    ///  :param: urlStr     urlString
    ///  :param: completion 回调
    func requestImage(urlStr: String, _ completion: Completion) {
        downloadImage(urlStr, { (result, error) -> () in
            if error != nil {
                completion(result: nil, error: error)
            } else {
                let path = self.fullImageCachePath(urlStr)
                var image = UIImage(contentsOfFile: path)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(result: image, error: nil)
                })
            }
        })
    }
}
